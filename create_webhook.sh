#!/bin/bash
set -a
source /mnt/d/down/.env
set +a

SMEE_URL="https://smee.io/O7DgWMwKET6BUEiq"
REPO="DG2609/claude-access-key-test-1788715753"

curl -sg -X POST \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${REPO}/hooks" \
  -d "{\"name\":\"web\",\"active\":true,\"events\":[\"push\",\"create\"],\"config\":{\"url\":\"${SMEE_URL}\",\"content_type\":\"json\"}}"
