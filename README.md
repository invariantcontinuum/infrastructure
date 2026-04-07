# Infrastructure

Consolidated infrastructure services for the invariantcontinuum organization. This repository contains Docker Compose configurations for all backend services including databases, caches, search engines, and proxy servers.

## Services

| Service | Description | Profile | Ports |
|---------|-------------|---------|-------|
| **PostgreSQL** | Relational database | `postgres`, `database`, `foundation` | 5432 |
| **PgAdmin** | PostgreSQL administration UI | `postgres`, `database`, `foundation` | 5050 |
| **Redis** | In-memory data store | `redis`, `cache`, `foundation` | 6379 |
| **Redis Commander** | Redis web UI | `redis`, `cache` | 8081 |
| **Elasticsearch** | Search & analytics engine | `elasticsearch`, `search` | 9200 |
| **Kibana** | Data visualization | `elasticsearch`, `search` | 5601 |
| **Keycloak** | Identity & access management | `keycloak`, `auth` | 8080 |
| **NATS** | Message queue & streaming | `nats`, `messaging` | 4222, 8222, 6222 |
| **Neo4j** | Graph database | `neo4j`, `graph` | 7474, 7687 |
| **Qdrant** | Vector database | `qdrant`, `vector`, `ai` | 6333, 6334 |
| **Nginx Proxy Manager** | Reverse proxy & SSL | `nginx-proxy-manager`, `proxy`, `edge` | 80, 81, 443 |

## Quick Start

1. **Copy environment file:**
   ```bash
   cp .env.example .env
   # Edit .env with your secrets
   ```

2. **Initialize infrastructure:**
   ```bash
   make init
   ```

3. **Start services:**
   ```bash
   # Start all services
   make up PROFILE=all

   # Or start specific profiles
   make up PROFILE=foundation  # postgres + redis
   make up PROFILE=database    # all databases
   make up PROFILE=cache       # redis only
   ```

## Usage

### Profiles

Profiles allow you to start groups of related services:

- `foundation` - Core infrastructure (PostgreSQL + Redis)
- `database` - All databases (PostgreSQL, Neo4j, Elasticsearch, Qdrant)
- `cache` - Caching services (Redis)
- `search` - Search stack (Elasticsearch + Kibana)
- `auth` - Authentication (Keycloak)
- `messaging` - Message queue (NATS)
- `graph` - Graph database (Neo4j)
- `vector` / `ai` - Vector database (Qdrant)
- `proxy` / `edge` - Reverse proxy (Nginx Proxy Manager)
- `all` - Everything

### Individual Services

Start individual services directly:

```bash
make postgres          # PostgreSQL + PgAdmin
make redis             # Redis + Redis Commander
make elasticsearch     # Elasticsearch + Kibana
make keycloak          # Keycloak (starts PostgreSQL first)
make nats              # NATS
make neo4j             # Neo4j
make qdrant            # Qdrant
make nginx-proxy-manager  # Nginx Proxy Manager
```

### Management Commands

```bash
make logs              # View logs
make status            # Show running containers
make health            # Show health status
make restart           # Restart services
make down              # Stop all services
make clean             # Remove stopped containers
make prune             # DANGER: Remove all data including volumes
```

## Directory Structure

```
.
├── docker-compose.yml      # Main compose file with all services
├── .env.example            # Environment template
├── Makefile                # Management commands
├── README.md               # This file
├── services/               # Service-specific files
│   ├── postgres/           # PostgreSQL init scripts and volumes
│   ├── redis/              # Redis configuration and volumes
│   ├── elasticsearch/      # Elasticsearch and Kibana volumes
│   ├── keycloak/           # Keycloak themes and volumes
│   ├── nats/               # NATS volumes
│   ├── neo4j/              # Neo4j volumes and plugins
│   ├── qdrant/             # Qdrant volumes
│   └── nginx-proxy-manager/# NPM data and letsencrypt
└── .github/
    ├── workflows/          # GitHub Actions
    └── scripts/            # Deployment scripts
```

## Environment Variables

See `.env.example` for all available configuration options. Key variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `DOMAIN` | Base domain for services | `localhost` |
| `TRAEFIK_NETWORK` | External Traefik network name | `traefik-public` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `CHANGE_ME_POSTGRES` |
| `REDIS_PASSWORD` | Redis password | `CHANGE_ME_REDIS` |
| `ELASTICSEARCH_PASSWORD` | Elasticsearch password | `CHANGE_ME_ELASTIC` |
| `KEYCLOAK_ADMIN_PASSWORD` | Keycloak admin password | `CHANGE_ME_KEYCLOAK` |
| `NEO4J_AUTH` | Neo4j credentials | `neo4j/CHANGE_ME_NEO4J` |

## Networks

- `traefik-public` - External network for Traefik reverse proxy
- `postgres-internal` - PostgreSQL and related services
- `redis-internal` - Redis and Redis Commander
- `elasticsearch-internal` - Elasticsearch and Kibana
- `keycloak-internal` - Keycloak services
- `nats-internal` - NATS messaging
- `neo4j-internal` - Neo4j graph database
- `qdrant-internal` - Qdrant vector database
- `nginx-proxy-manager-network` - Nginx Proxy Manager

## CI/CD

GitHub Actions workflows:

- **Validate** - Linting and security scanning on PR/push
- **Deploy** - Manual deployment to server with profile selection

## License

Private - invariantcontinuum organization
