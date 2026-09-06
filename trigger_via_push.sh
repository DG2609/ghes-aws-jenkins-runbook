#!/bin/bash
set -a
source /mnt/d/down/.env
set +a

REPO="DG2609/claude-access-key-test-1788715753"
FILE_PATH="hello-from-claude.md"

# Lay sha hien tai cua file de update (Contents API can sha khi update)
CURRENT=$(curl -sg -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "https://api.github.com/repos/${REPO}/contents/${FILE_PATH}")
SHA=$(echo "$CURRENT" | python3 -c "import sys,json;print(json.load(sys.stdin)['sha'])")

NEW_CONTENT=$(printf '# Test tu Claude Code\n\nCommit trigger qua webhook luc %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" | base64 -w0)

echo "=== Push commit moi (trigger push event) ==="
curl -sg -X PUT \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${REPO}/contents/${FILE_PATH}" \
  -d "{\"message\":\"Webhook trigger test commit\",\"content\":\"${NEW_CONTENT}\",\"sha\":\"${SHA}\"}" \
  | python3 -c "import sys,json;d=json.load(sys.stdin);print('commit:', d['commit']['sha'][:7])"

echo "Waiting 8s for webhook relay..."
sleep 8
