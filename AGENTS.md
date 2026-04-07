# Agent Context - Infrastructure

## Repository Purpose

This is the consolidated infrastructure repository for the invariantcontinuum GitHub organization. It contains Docker Compose configurations for all backend infrastructure services.

## Services Overview

| Service | Type | Internal Network | Dependencies |
|---------|------|------------------|--------------|
| PostgreSQL | Database | postgres-internal | None (foundation) |
| Redis | Cache | redis-internal | None (foundation) |
| Elasticsearch | Search | elasticsearch-internal | None |
| Kibana | Visualization | elasticsearch-internal | Elasticsearch |
| Keycloak | Auth | keycloak-internal, postgres-internal | PostgreSQL |
| NATS | Messaging | nats-internal | None |
| Neo4j | Graph DB | neo4j-internal | None |
| Qdrant | Vector DB | qdrant-internal | None |
| Nginx Proxy Manager | Proxy | nginx-proxy-manager-network, traefik-public | None |

## Development Workflow

1. All services use Docker Compose profiles for selective startup
2. Use `make up PROFILE=<profile>` to start service groups
3. Foundation services (PostgreSQL, Redis) should be started first
4. Keycloak requires PostgreSQL to be running

## Environment Management

- `.env.example` - Template with all variables and defaults
- `.env` - Local secrets (never commit)
- All services have default values in docker-compose.yml using `${VAR:-default}` syntax

## GitHub Actions

- **validate.yml** - Runs on PR/push: linting, security scan, env sync check
- **deploy.yml** - Manual trigger: deploys selected profile to server

## Important Notes

- Data volumes are in `services/<name>/volumes/` and are gitignored
- Networks are created automatically by `make init`
- Traefik network is external and must exist before starting services
