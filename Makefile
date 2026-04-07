# =============================================================================
# INFRASTRUCTURE - CONSOLIDATED MAKEFILE
# =============================================================================
# Manage all infrastructure services with Docker Compose profiles
# =============================================================================

# Load environment variables
ifneq ($(wildcard .env),)
  include .env
  export
else
  $(warning .env not found — run: cp .env.example .env)
endif

COMPOSE_FLAGS := -f docker-compose.yml
BLUE  := \033[34m
GREEN := \033[32m
YELLOW:= \033[33m
RED   := \033[31m
NC    := \033[0m

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "$(BLUE)Infrastructure - Consolidated Services$(NC)"
	@echo ""
	@echo "Usage: make <target> [PROFILE=<profile>]"
	@echo ""
	@echo "$(GREEN)Profiles:$(NC)"
	@echo "  foundation    - Core infrastructure (postgres, redis)"
	@echo "  database      - All databases (postgres, neo4j, elasticsearch, qdrant)"
	@echo "  cache         - Caching services (redis)"
	@echo "  search        - Search services (elasticsearch, kibana)"
	@echo "  auth          - Authentication (keycloak)"
	@echo "  messaging     - Message queue (nats)"
	@echo "  graph         - Graph database (neo4j)"
	@echo "  vector        - Vector database (qdrant)"
	@echo "  ai            - AI/ML services (qdrant)"
	@echo "  proxy         - Reverse proxy (nginx-proxy-manager)"
	@echo "  edge          - Edge services (nginx-proxy-manager)"
	@echo "  all           - All services"
	@echo ""
	@echo "$(GREEN)Setup:$(NC)"
	@echo "  make init              Create networks and volume directories"
	@echo "  make up PROFILE=all    Start all services"
	@echo "  make up PROFILE=database  Start database services only"
	@echo ""
	@echo "$(GREEN)Management:$(NC)"
	@echo "  make down              Stop services"
	@echo "  make restart           Restart services"
	@echo "  make logs              Tail logs"
	@echo "  make pull              Pull latest images"
	@echo "  make ps                Show service status"
	@echo "  make status            Show running containers"
	@echo "  make health            Show health status"
	@echo ""
	@echo "$(GREEN)Individual Services:$(NC)"
	@echo "  make postgres          Start postgres + pgadmin"
	@echo "  make redis             Start redis + redis-commander"
	@echo "  make elasticsearch     Start elasticsearch + kibana"
	@echo "  make keycloak          Start keycloak (requires postgres)"
	@echo "  make nats              Start nats"
	@echo "  make neo4j             Start neo4j"
	@echo "  make qdrant            Start qdrant"
	@echo "  make nginx-proxy-manager  Start nginx-proxy-manager"
	@echo ""
	@echo "$(GREEN)Utilities:$(NC)"
	@echo "  make clean             Remove stopped containers"
	@echo "  make prune             DANGER: remove all data"
	@echo "  make validate          Validate docker-compose.yml"

# =============================================================================
# SETUP
# =============================================================================

.PHONY: init
init: _check-env _create-networks _create-volumes
	@echo "$(GREEN)✓ Infrastructure ready$(NC)"

.PHONY: _check-env
_check-env:
	@test -f .env || (echo "$(RED)ERROR: cp .env.example .env$(NC)" && exit 1)

.PHONY: _create-networks
_create-networks:
	@echo "$(BLUE)Creating networks...$(NC)"
	@docker network inspect $(TRAEFIK_NETWORK) >/dev/null 2>&1 \
		|| docker network create $(TRAEFIK_NETWORK)
	@echo "  ✓ $(TRAEFIK_NETWORK)"
	@docker network inspect postgres-internal >/dev/null 2>&1 \
		|| docker network create postgres-internal
	@echo "  ✓ postgres-internal"
	@docker network inspect redis-internal >/dev/null 2>&1 \
		|| docker network create redis-internal
	@echo "  ✓ redis-internal"
	@docker network inspect elasticsearch-internal >/dev/null 2>&1 \
		|| docker network create elasticsearch-internal
	@echo "  ✓ elasticsearch-internal"
	@docker network inspect keycloak-internal >/dev/null 2>&1 \
		|| docker network create keycloak-internal
	@echo "  ✓ keycloak-internal"
	@docker network inspect nats-internal >/dev/null 2>&1 \
		|| docker network create nats-internal
	@echo "  ✓ nats-internal"
	@docker network inspect neo4j-internal >/dev/null 2>&1 \
		|| docker network create neo4j-internal
	@echo "  ✓ neo4j-internal"
	@docker network inspect qdrant-internal >/dev/null 2>&1 \
		|| docker network create qdrant-internal
	@echo "  ✓ qdrant-internal"
	@docker network inspect nginx-proxy-manager-network >/dev/null 2>&1 \
		|| docker network create nginx-proxy-manager-network
	@echo "  ✓ nginx-proxy-manager-network"

.PHONY: _create-volumes
_create-volumes:
	@echo "$(BLUE)Creating volume directories...$(NC)"
	@mkdir -p services/postgres/volumes/data services/postgres/volumes/pgadmin
	@mkdir -p services/redis/volumes/data
	@mkdir -p services/elasticsearch/volumes/data services/elasticsearch/volumes/kibana
	@mkdir -p services/neo4j/volumes/data services/neo4j/volumes/logs services/neo4j/volumes/plugins
	@mkdir -p services/nats/volumes/data
	@mkdir -p services/qdrant/volumes/data
	@mkdir -p services/nginx-proxy-manager/data services/nginx-proxy-manager/letsencrypt
	@echo "  ✓ Volume directories ready"

# =============================================================================
# MAIN COMMANDS
# =============================================================================

PROFILE ?= all

.PHONY: up
up: init
	@echo "$(BLUE)Starting services (profile: $(PROFILE))...$(NC)"
	@docker compose $(COMPOSE_FLAGS) --profile $(PROFILE) up -d
	@echo "$(GREEN)✓ Services started$(NC)"

.PHONY: down
down:
	@echo "$(YELLOW)Stopping services...$(NC)"
	@docker compose $(COMPOSE_FLAGS) --profile all down

.PHONY: restart
restart: down up

.PHONY: logs
logs:
	@docker compose $(COMPOSE_FLAGS) --profile $(PROFILE) logs -f --tail=100

.PHONY: pull
pull:
	@docker compose $(COMPOSE_FLAGS) --profile $(PROFILE) pull

.PHONY: ps
ps:
	@docker compose $(COMPOSE_FLAGS) --profile $(PROFILE) ps

.PHONY: status
status:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" \
		| grep -E "(NAMES|postgres|redis|elasticsearch|kibana|keycloak|nats|neo4j|qdrant|nginx)" || echo "No containers running"

.PHONY: health
health:
	@echo "$(BLUE)Health Status:$(NC)"
	@for name in postgres pgadmin redis redis-commander elasticsearch kibana keycloak nats neo4j qdrant nginx-proxy-manager; do \
		id=$$(docker ps -qf "name=$${name}" 2>/dev/null); \
		if [ -n "$$id" ]; then \
			status=$$(docker inspect --format '{{.State.Status}}' "$$id" 2>/dev/null); \
			health=$$(docker inspect --format '{{.State.Health.Status}}' "$$id" 2>/dev/null || echo "no healthcheck"); \
			printf "  %-25s %-12s %s\n" "$$name" "$$status" "$$health"; \
		fi; \
	done

# =============================================================================
# INDIVIDUAL SERVICES
# =============================================================================

.PHONY: postgres
postgres:
	@echo "$(BLUE)Starting PostgreSQL...$(NC)"
	@docker compose $(COMPOSE_FLAGS) --profile postgres up -d

.PHONY: redis
redis:
	@echo "$(BLUE)Starting Redis...$(NC)"
	@docker compose $(COMPOSE_FLAGS) --profile redis up -d

.PHONY: elasticsearch
elasticsearch:
	@echo "$(BLUE)Starting Elasticsearch...$(NC)"
	@docker compose $(COMPOSE_FLAGS) --profile elasticsearch up -d

.PHONY: keycloak
keycloak: postgres
	@echo "$(BLUE)Starting Keycloak (requires PostgreSQL)...$(NC)"
	@sleep 5  # Give postgres time to be ready
	@docker compose $(COMPOSE_FLAGS) --profile keycloak up -d

.PHONY: nats
nats:
	@echo "$(BLUE)Starting NATS...$(NC)"
	@docker compose $(COMPOSE_FLAGS) --profile nats up -d

.PHONY: neo4j
neo4j:
	@echo "$(BLUE)Starting Neo4j...$(NC)"
	@docker compose $(COMPOSE_FLAGS) --profile neo4j up -d

.PHONY: qdrant
qdrant:
	@echo "$(BLUE)Starting Qdrant...$(NC)"
	@docker compose $(COMPOSE_FLAGS) --profile qdrant up -d

.PHONY: nginx-proxy-manager
nginx-proxy-manager:
	@echo "$(BLUE)Starting Nginx Proxy Manager...$(NC)"
	@docker compose $(COMPOSE_FLAGS) --profile nginx-proxy-manager up -d

# =============================================================================
# UTILITIES
# =============================================================================

.PHONY: clean
clean:
	@echo "$(YELLOW)Cleaning up...$(NC)"
	@docker system prune -f
	@echo "$(GREEN)✓ Done$(NC)"

.PHONY: prune
prune:
	@echo "$(RED)WARNING: This will delete ALL data including volumes!$(NC)"
	@read -rp "Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ] || exit 1
	@docker compose $(COMPOSE_FLAGS) --profile all down -v --remove-orphans
	@docker system prune -af --volumes
	@echo "$(GREEN)✓ Everything removed$(NC)"

.PHONY: validate
validate:
	@echo "$(BLUE)Validating docker-compose.yml...$(NC)"
	@docker compose $(COMPOSE_FLAGS) config > /dev/null && echo "$(GREEN)✓ Valid$(NC)" || echo "$(RED)✗ Invalid$(NC)"
