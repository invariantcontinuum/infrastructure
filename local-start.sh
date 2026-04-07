#!/bin/bash
# =============================================================================
# LOCAL START SCRIPT - INFRASTRUCTURE
# =============================================================================
# Starts infrastructure services in the correct order with proper health checks
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
PROFILE="${1:-foundation}"

# =============================================================================
# FUNCTIONS
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env exists
check_env() {
    if [[ ! -f "$ENV_FILE" ]]; then
        log_warn ".env file not found. Creating from .env.example..."
        if [[ -f "${SCRIPT_DIR}/.env.example" ]]; then
            cp "${SCRIPT_DIR}/.env.example" "$ENV_FILE"
            log_warn "Please edit .env file with your configuration before running again."
            exit 1
        else
            log_error ".env.example not found!"
            exit 1
        fi
    fi
}

# Load environment
load_env() {
    set -a
    source "$ENV_FILE"
    set +a
}

# Check if Docker is running
check_docker() {
    if ! docker info &>/dev/null; then
        log_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    log_success "Docker is running"
}

# Check Docker Compose version
check_compose() {
    if docker compose version &>/dev/null; then
        COMPOSE_CMD="docker compose"
    elif docker-compose version &>/dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        log_error "Docker Compose not found. Please install Docker Compose."
        exit 1
    fi
    log_success "Using: $COMPOSE_CMD"
}

# Create required networks (optional - docker compose will create them)
create_networks() {
    log_info "Checking networks..."
    # Networks will be created by docker compose
    # Only create traefik-public if it doesn't exist (external dependency)
    if ! docker network inspect "${TRAEFIK_NETWORK:-traefik-public}" &>/dev/null; then
        docker network create "${TRAEFIK_NETWORK:-traefik-public}" 2>/dev/null || true
        log_success "Created external network: ${TRAEFIK_NETWORK:-traefik-public}"
    fi
    log_info "Networks ready"
}

# Create volume directories
create_volumes() {
    log_info "Creating volume directories..."
    
    local dirs=(
        "services/postgres/volumes/data"
        "services/postgres/volumes/pgadmin"
        "services/redis/volumes/data"
        "services/elasticsearch/volumes/data"
        "services/elasticsearch/volumes/kibana"
        "services/neo4j/volumes/data"
        "services/neo4j/volumes/logs"
        "services/neo4j/volumes/plugins"
        "services/nats/volumes/data"
        "services/qdrant/volumes/data"
        "services/nginx-proxy-manager/data"
        "services/nginx-proxy-manager/letsencrypt"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "${SCRIPT_DIR}/${dir}"
    done
    
    log_success "Volume directories created"
}

# Wait for service to be healthy
wait_for_health() {
    local service=$1
    local max_attempts=${2:-30}
    local attempt=0
    
    log_info "Waiting for $service to be healthy..."
    
    while [[ $attempt -lt $max_attempts ]]; do
        local status
        status=$(docker inspect --format='{{.State.Health.Status}}' "$service" 2>/dev/null || echo "unknown")
        
        if [[ "$status" == "healthy" ]]; then
            log_success "$service is healthy"
            return 0
        elif [[ "$status" == "unhealthy" ]]; then
            log_error "$service is unhealthy"
            return 1
        fi
        
        attempt=$((attempt + 1))
        sleep 2
    done
    
    log_warn "$service health check timed out, but continuing..."
    return 0
}

# Start services by profile
start_services() {
    local profile=$1
    
    log_info "Starting services with profile: $profile"
    
    cd "$SCRIPT_DIR"
    
    case "$profile" in
        foundation)
            log_info "Starting foundation services (postgres, redis)..."
            $COMPOSE_CMD --profile foundation up -d
            wait_for_health "postgres"
            ;;
        database)
            log_info "Starting database services..."
            $COMPOSE_CMD --profile database up -d
            wait_for_health "postgres"
            wait_for_health "neo4j"
            wait_for_health "elasticsearch"
            wait_for_health "qdrant"
            ;;
        cache)
            log_info "Starting cache services..."
            $COMPOSE_CMD --profile cache up -d
            wait_for_health "redis"
            ;;
        search)
            log_info "Starting search services..."
            $COMPOSE_CMD --profile search up -d
            wait_for_health "elasticsearch"
            ;;
        auth)
            log_info "Starting auth services (requires postgres)..."
            $COMPOSE_CMD --profile foundation up -d
            wait_for_health "postgres"
            sleep 5
            $COMPOSE_CMD --profile auth up -d
            wait_for_health "keycloak"
            ;;
        messaging)
            log_info "Starting messaging services..."
            $COMPOSE_CMD --profile messaging up -d
            ;;
        proxy)
            log_info "Starting proxy services..."
            $COMPOSE_CMD --profile proxy up -d
            ;;
        all)
            log_info "Starting all services..."
            # Start foundation first
            $COMPOSE_CMD --profile foundation up -d
            wait_for_health "postgres"
            wait_for_health "redis"
            sleep 5
            # Start remaining services
            $COMPOSE_CMD --profile all up -d
            ;;
        *)
            log_error "Unknown profile: $profile"
            log_info "Valid profiles: foundation, database, cache, search, auth, messaging, proxy, all"
            exit 1
            ;;
    esac
    
    log_success "Services started successfully"
}

# Show status
show_status() {
    echo ""
    log_info "Container Status:"
    echo "--------------------------------------------"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(NAMES|postgres|redis|elasticsearch|kibana|keycloak|nats|neo4j|qdrant|nginx)" || true
    echo ""
    log_info "Health Status:"
    echo "--------------------------------------------"
    local services=("postgres" "redis" "elasticsearch" "kibana" "keycloak" "nats" "neo4j" "qdrant" "nginx-proxy-manager")
    for service in "${services[@]}"; do
        local container_name=$service
        local id
        id=$(docker ps -qf "name=$service" 2>/dev/null || true)
        if [[ -n "$id" ]]; then
            local health
            health=$(docker inspect --format='{{.State.Health.Status}}' "$id" 2>/dev/null || echo "N/A")
            printf "  %-25s %s\n" "$service" "$health"
        fi
    done
}

# Main function
main() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}          INFRASTRUCTURE LOCAL START SCRIPT${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    log_info "Profile: $PROFILE"
    
    check_env
    load_env
    check_docker
    check_compose
    create_networks
    create_volumes
    start_services "$PROFILE"
    show_status
    
    echo ""
    log_success "Infrastructure is ready!"
    echo ""
    log_info "Useful commands:"
    echo "  View logs:     docker compose logs -f"
    echo "  Stop services: docker compose --profile $PROFILE down"
    echo "  Full status:   docker compose ps"
}

# Show help
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [PROFILE]"
    echo ""
    echo "Profiles:"
    echo "  foundation    - PostgreSQL + Redis (core infrastructure)"
    echo "  database      - All databases (postgres, neo4j, elasticsearch, qdrant)"
    echo "  cache         - Redis cache"
    echo "  search        - Elasticsearch + Kibana"
    echo "  auth          - Keycloak (includes postgres)"
    echo "  messaging     - NATS"
    echo "  proxy         - Nginx Proxy Manager"
    echo "  all           - Everything (default)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Start foundation services"
    echo "  $0 foundation         # Start postgres + redis"
    echo "  $0 all                # Start all services"
    exit 0
fi

main "$@"
