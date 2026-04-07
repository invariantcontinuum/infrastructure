#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up .env..."

# Copy example file
cp .env.example .env

# Update domain settings
if [[ -n "${INPUT_DOMAIN:-}" ]]; then
    sed -i "s/^DOMAIN=.*/DOMAIN=${INPUT_DOMAIN}/" .env
    echo "    Set DOMAIN=${INPUT_DOMAIN}"
fi

if [[ -n "${INPUT_ACME_EMAIL:-}" ]]; then
    sed -i "s/^TRAEFIK_ACME_EMAIL=.*/TRAEFIK_ACME_EMAIL=${INPUT_ACME_EMAIL}/" .env
    echo "    Set TRAEFIK_ACME_EMAIL=${INPUT_ACME_EMAIL}"
fi

# Function to append secrets
append_secret() {
    local key="$1"
    local value="$2"
    
    if [[ -n "${value}" ]]; then
        # Remove existing line if present
        sed -i "/^${key}=/d" .env 2>/dev/null || true
        # Append new value
        echo "${key}=${value}" >> .env
        echo "    Set ${key}"
    fi
}

# Append all secrets
append_secret POSTGRES_PASSWORD       "${SECRET_POSTGRES_PASSWORD:-}"
append_secret REDIS_PASSWORD          "${SECRET_REDIS_PASSWORD:-}"
append_secret NEO4J_AUTH              "${SECRET_NEO4J_AUTH:-}"
append_secret KEYCLOAK_ADMIN_PASSWORD "${SECRET_KEYCLOAK_ADMIN_PASSWORD:-}"
append_secret KEYCLOAK_DB_PASSWORD    "${SECRET_KEYCLOAK_DB_PASSWORD:-}"
append_secret ELASTICSEARCH_PASSWORD  "${SECRET_ELASTICSEARCH_PASSWORD:-}"
append_secret QDRANT_API_KEY          "${SECRET_QDRANT_API_KEY:-}"
append_secret NPM_ADMIN_PASSWORD      "${SECRET_NPM_ADMIN_PASSWORD:-}"

echo "==> .env ready"
