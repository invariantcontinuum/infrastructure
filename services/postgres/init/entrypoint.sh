#!/bin/sh
# =============================================================================
# POSTGRESQL INITIALIZATION
# =============================================================================
# Runs inside the postgres container via docker-entrypoint-initdb.d on first start.
# Creates extra databases and the Keycloak user/database.
# =============================================================================
set -e

echo "PostgreSQL: running custom initialization..."

# ── Extra databases ──────────────────────────────────────────────────────────
if [ -n "$EXTRA_DATABASES" ]; then
  for db in $(echo "$EXTRA_DATABASES" | tr ',' ' '); do
    echo "  Creating database: $db"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
      SELECT 'CREATE DATABASE "$db"'
      WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$db')\gexec
EOSQL
  done
fi

# ── Keycloak database & user ─────────────────────────────────────────────────
if [ -n "$KEYCLOAK_DB_NAME" ] && [ -n "$KEYCLOAK_DB_USER" ] && [ -n "$KEYCLOAK_DB_PASSWORD" ]; then
  echo "  Setting up Keycloak database: $KEYCLOAK_DB_NAME"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT 'CREATE DATABASE "$KEYCLOAK_DB_NAME"'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$KEYCLOAK_DB_NAME')\gexec

    DO \$\$
    BEGIN
      IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$KEYCLOAK_DB_USER') THEN
        CREATE USER "$KEYCLOAK_DB_USER" WITH PASSWORD '$KEYCLOAK_DB_PASSWORD';
      ELSE
        ALTER USER "$KEYCLOAK_DB_USER" WITH PASSWORD '$KEYCLOAK_DB_PASSWORD';
      END IF;
    END
    \$\$;

    GRANT ALL PRIVILEGES ON DATABASE "$KEYCLOAK_DB_NAME" TO "$KEYCLOAK_DB_USER";
    ALTER DATABASE "$KEYCLOAK_DB_NAME" OWNER TO "$KEYCLOAK_DB_USER";
EOSQL
fi

# ── Nginx Proxy Manager database & user ─────────────────────────────────────
if [ -n "$NPM_DB_NAME" ] && [ -n "$NPM_DB_USER" ] && [ -n "$NPM_DB_PASSWORD" ]; then
  echo "  Setting up Nginx Proxy Manager database: $NPM_DB_NAME"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT 'CREATE DATABASE "$NPM_DB_NAME"'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$NPM_DB_NAME')\gexec

    DO \$\$
    BEGIN
      IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$NPM_DB_USER') THEN
        CREATE USER "$NPM_DB_USER" WITH PASSWORD '$NPM_DB_PASSWORD';
      ELSE
        ALTER USER "$NPM_DB_USER" WITH PASSWORD '$NPM_DB_PASSWORD';
      END IF;
    END
    \$\$;

    GRANT ALL PRIVILEGES ON DATABASE "$NPM_DB_NAME" TO "$NPM_DB_USER";
    ALTER DATABASE "$NPM_DB_NAME" OWNER TO "$NPM_DB_USER";
EOSQL
fi

# ── n8n database & user ─────────────────────────────────────────────────────
if [ -n "$N8N_DB_NAME" ] && [ -n "$N8N_DB_USER" ] && [ -n "$N8N_DB_PASSWORD" ]; then
  echo "  Setting up n8n database: $N8N_DB_NAME"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT 'CREATE DATABASE "$N8N_DB_NAME"'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$N8N_DB_NAME')\gexec

    DO \$\$
    BEGIN
      IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$N8N_DB_USER') THEN
        CREATE USER "$N8N_DB_USER" WITH PASSWORD '$N8N_DB_PASSWORD';
      ELSE
        ALTER USER "$N8N_DB_USER" WITH PASSWORD '$N8N_DB_PASSWORD';
      END IF;
    END
    \$\$;

    GRANT ALL PRIVILEGES ON DATABASE "$N8N_DB_NAME" TO "$N8N_DB_USER";
    ALTER DATABASE "$N8N_DB_NAME" OWNER TO "$N8N_DB_USER";
EOSQL
fi

echo "PostgreSQL: custom initialization complete"
