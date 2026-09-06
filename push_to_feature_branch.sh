#!/bin/bash
set -a
source /mnt/d/down/.env
set +a

REPO="DG2609/claude-access-key-test-1788715753"
AUTH_HDR="Authorization: Bearer ${GITHUB_TOKEN}"

FILE_PATH="hello-from-claude.md"
FEATURE_SHA=$(curl -sg -H "$AUTH_HDR" \
  "https://api.github.com/repos/${REPO}/contents/${FILE_PATH}?ref=feature/webhook-test" \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['sha'])")

NEW_CONTENT=$(printf '# Test tu Claude Code\n\nCommit nay push vao branch feature/webhook-test luc %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" | base64 -w0)

echo "=== Push commit vao branch feature/webhook-test ==="
curl -sg -X PUT \
  -H "$AUTH_HDR" -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${REPO}/contents/${FILE_PATH}" \
  -d "{\"message\":\"Commit tren branch phu\",\"content\":\"${NEW_CONTENT}\",\"sha\":\"${FEATURE_SHA}\",\"branch\":\"feature/webhook-test\"}" \
  | python3 -c "import sys,json;d=json.load(sys.stdin);print('commit:', d['commit']['sha'][:7])"

sleep 6
