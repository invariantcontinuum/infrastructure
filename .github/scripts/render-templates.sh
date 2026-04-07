#!/usr/bin/env bash
set -euo pipefail
echo "==> Rendering templates..."
# Find and render any .template files
find . -name "*.template" -type f | while read -r template; do
  output="${template%.template}"
  echo "  Rendering: $template -> $output"
  envsubst < "$template" > "$output"
done
echo "  ✓ Templates rendered"
