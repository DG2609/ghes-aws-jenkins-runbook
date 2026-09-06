#!/bin/bash
set -a
source /mnt/d/down/.env
set +a

REPO="DG2609/claude-access-key-test-1788715753"
AUTH_HDR="Authorization: Bearer ${GITHUB_TOKEN}"

# Lay sha cua main hien tai de branch/tag tro toi
MAIN_SHA=$(curl -sg -H "$AUTH_HDR" "https://api.github.com/repos/${REPO}/git/refs/heads/main" \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['object']['sha'])")
echo "main sha: $MAIN_SHA"

echo "=== Tao branch moi: feature/webhook-test ==="
curl -sg -X POST -H "$AUTH_HDR" -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${REPO}/git/refs" \
  -d "{\"ref\":\"refs/heads/feature/webhook-test\",\"sha\":\"${MAIN_SHA}\"}" \
  | python3 -c "import sys,json;d=json.load(sys.stdin);print('created:', d.get('ref', d))"

sleep 6

echo "=== Tao tag moi: v0.0.1-test ==="
curl -sg -X POST -H "$AUTH_HDR" -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${REPO}/git/refs" \
  -d "{\"ref\":\"refs/tags/v0.0.1-test\",\"sha\":\"${MAIN_SHA}\"}" \
  | python3 -c "import sys,json;d=json.load(sys.stdin);print('created:', d.get('ref', d))"

sleep 6
