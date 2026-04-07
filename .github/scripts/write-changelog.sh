#!/usr/bin/env bash
set -euo pipefail
entry="${ENTRY:-}"
if [ -z "$entry" ]; then
  echo "No entry provided"
  exit 0
fi
if [ ! -f CHANGELOG.md ]; then
  echo "# Changelog" > CHANGELOG.md
  echo "" >> CHANGELOG.md
fi
# Prepend entry after the header
tmp=$(mktemp)
echo "# Changelog" > "$tmp"
echo "" >> "$tmp"
echo "$entry" >> "$tmp"
tail -n +3 CHANGELOG.md >> "$tmp"
mv "$tmp" CHANGELOG.md
