#!/usr/bin/env bash
set -euo pipefail

environment="${INPUT_ENVIRONMENT:-production}"
domain="${INPUT_DOMAIN:-localhost}"
profile="${INPUT_PROFILE:-foundation}"
target="${INPUT_TARGET:-vm}"
actor="${GITHUB_ACTOR:-unknown}"
repo="${GITHUB_REPOSITORY:-unknown}"
run_id="${GITHUB_RUN_ID:-0}"
date=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

entry="## [${date}] - Deploy to ${environment}

- **Target**: ${target}
- **Profile**: ${profile}
- **Domain**: ${domain}
- **Deployed by**: @${actor}
- **Workflow**: https://github.com/${repo}/actions/runs/${run_id}

"

echo "entry<<EOF" >> "$GITHUB_OUTPUT"
echo "$entry" >> "$GITHUB_OUTPUT"
echo "EOF" >> "$GITHUB_OUTPUT"
