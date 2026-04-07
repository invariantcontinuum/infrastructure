#!/bin/sh
# Keycloak initialization script
set -e

echo "Initializing Keycloak..."

# Wait for database to be ready
if [ -n "$KC_DB_URL_HOST" ]; then
    echo "Waiting for database at $KC_DB_URL_HOST:$KC_DB_URL_PORT..."
    while ! nc -z "$KC_DB_URL_HOST" "$KC_DB_URL_PORT"; do
        sleep 1
    done
    echo "Database is ready!"
fi

# Import realms if specified
if [ -n "$KEYCLOAK_IMPORT_REALM" ] && [ -f "$KEYCLOAK_IMPORT_REALM" ]; then
    echo "Importing realm from $KEYCLOAK_IMPORT_REALM..."
    /opt/keycloak/bin/kc.sh import --file "$KEYCLOAK_IMPORT_REALM" --override true || true
fi

# Set theme if specified
if [ -n "$KEYCLOAK_DEFAULT_THEME" ]; then
    echo "Setting default theme to: $KEYCLOAK_DEFAULT_THEME"
fi

echo "Keycloak initialization complete!"
