#!/usr/bin/env bash
set -euo pipefail
environment="${INPUT_ENVIRONMENT:-production}"
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add CHANGELOG.md
git diff --cached --quiet || git commit -m "docs: update changelog for ${environment} deploy"
git push
