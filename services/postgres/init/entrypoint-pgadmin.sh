#!/bin/sh
# =============================================================================
# PGADMIN INITIALIZATION
# =============================================================================
# Auto-configures a server entry and pgpass on first start.
# This file is mounted as a Docker entrypoint init script.
# =============================================================================
set -e

SERVERS_FILE="/pgadmin4/servers.json"
PGPASS_FILE="/pgadmin4/.pgpass"

# Write servers.json so pgAdmin auto-registers the postgres server
if [ ! -f "$SERVERS_FILE" ]; then
  mkdir -p /pgadmin4
  cat > "$SERVERS_FILE" <<JSON
{
  "Servers": {
    "1": {
      "Name": "PostgreSQL (Main)",
      "Group": "Infrastructure",
      "Host": "postgres",
      "Port": 5432,
      "MaintenanceDB": "postgres",
      "Username": "${POSTGRES_USER:-postgres}",
      "SSLMode": "prefer",
      "PassFile": "/pgadmin4/.pgpass"
    }${NPM_DB_NAME:+,}
    ${NPM_DB_NAME:+"2": {
      "Name": "Nginx Proxy Manager DB",
      "Group": "Infrastructure",
      "Host": "postgres",
      "Port": 5432,
      "MaintenanceDB": "${NPM_DB_NAME}",
      "Username": "${NPM_DB_USER}",
      "SSLMode": "prefer",
      "PassFile": "/pgadmin4/.pgpass"
    }}${N8N_DB_NAME:+,}
    ${N8N_DB_NAME:+"3": {
      "Name": "n8n DB",
      "Group": "Infrastructure",
      "Host": "postgres",
      "Port": 5432,
      "MaintenanceDB": "${N8N_DB_NAME}",
      "Username": "${N8N_DB_USER}",
      "SSLMode": "prefer",
      "PassFile": "/pgadmin4/.pgpass"
    }}
  }
}
JSON
  echo "✓ pgAdmin servers.json created"
fi

# Write passwordless auth file
if [ ! -f "$PGPASS_FILE" ]; then
  : > "$PGPASS_FILE"
  # Main postgres user
  if [ -n "$POSTGRES_PASSWORD" ]; then
    echo "postgres:5432:*:${POSTGRES_USER:-postgres}:${POSTGRES_PASSWORD}" >> "$PGPASS_FILE"
  fi
  # Nginx Proxy Manager
  if [ -n "$NPM_DB_PASSWORD" ]; then
    echo "postgres:5432:${NPM_DB_NAME}:${NPM_DB_USER}:${NPM_DB_PASSWORD}" >> "$PGPASS_FILE"
  fi
  # n8n
  if [ -n "$N8N_DB_PASSWORD" ]; then
    echo "postgres:5432:${N8N_DB_NAME}:${N8N_DB_USER}:${N8N_DB_PASSWORD}" >> "$PGPASS_FILE"
  fi
  chmod 600 "$PGPASS_FILE"
  echo "✓ pgAdmin .pgpass created"
fi

echo "pgAdmin initialisation complete"
