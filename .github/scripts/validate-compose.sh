#!/usr/bin/env bash
set -euo pipefail

echo "==> Validating Docker Compose configuration..."

# Check if .env.example exists
if [[ ! -f ".env.example" ]]; then
    echo "ERROR: .env.example not found"
    exit 1
fi

# Copy .env for validation
cp .env.example .env

# Validate compose files
for file in docker-compose.yml docker-compose*.yml; do
    if [[ -f "$file" ]]; then
        echo "  Validating: $file"
        if ! docker compose -f "$file" config > /dev/null 2>&1; then
            echo "    ERROR: Invalid compose file: $file"
            exit 1
        fi
        echo "    ✓ Valid"
    fi
done

# Check for required files
echo ""
echo "==> Checking required files..."

required_files=(
    "docker-compose.yml"
    ".env.example"
    "local-start.sh"
    "README.md"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  ✓ $file exists"
    else
        echo "  ✗ $file MISSING"
        exit 1
    fi
done

# Check if local-start.sh is executable
if [[ -x "local-start.sh" ]]; then
    echo "  ✓ local-start.sh is executable"
else
    echo "  ✗ local-start.sh is NOT executable"
    exit 1
fi

echo ""
echo "==> All validations passed!"
