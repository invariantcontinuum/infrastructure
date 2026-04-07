#!/usr/bin/env bash
set -euo pipefail

echo "==> Checking .env.example sync..."

# Extract keys from .env.example
mapfile -t example_keys < <(grep -E '^[A-Z_]+=' .env.example | cut -d'=' -f1 | sort)

# Check that all keys have defaults in docker-compose.yml
missing=0
missing_in_compose=()
missing_defaults=()

for key in "${example_keys[@]}"; do
    if ! grep -q "\\${$key:-" docker-compose.yml 2>/dev/null; then
        if ! grep -q "\\${$key}" docker-compose.yml 2>/dev/null; then
            missing_in_compose+=("$key")
            missing=1
        else
            missing_defaults+=("$key")
            missing=1
        fi
    fi
done

if [[ ${#missing_in_compose[@]} -gt 0 ]]; then
    echo "  WARNING: Variables not found in docker-compose.yml:"
    for key in "${missing_in_compose[@]}"; do
        echo "    - $key"
    done
fi

if [[ ${#missing_defaults[@]} -gt 0 ]]; then
    echo "  WARNING: Variables without defaults in docker-compose.yml:"
    for key in "${missing_defaults[@]}"; do
        echo "    - $key (use \${$key:-default})"
    done
fi

if [[ $missing -eq 0 ]]; then
    echo "  ✓ All environment variables are properly configured"
    exit 0
else
    echo "  ✗ Some variables need attention"
    exit 0  # Don't fail the build, just warn
fi
