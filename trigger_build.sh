#!/bin/bash
set -a
source /mnt/d/down/.env
set +a

AUTH="${JENKINS_ADMIN_USER}:${JENKINS_ADMIN_PASSWORD}"
COOKIES=/tmp/jenkins-cookies.txt

# Lấy crumb + cookie session cùng lúc, dùng chung cho request POST sau
CRUMB_JSON=$(curl -sg -c "$COOKIES" -u "$AUTH" "http://localhost:8080/crumbIssuer/api/json")
CRUMB_FIELD=$(echo "$CRUMB_JSON" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['crumbRequestField'])")
CRUMB_VALUE=$(echo "$CRUMB_JSON" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['crumb'])")
echo "Crumb: $CRUMB_FIELD=$CRUMB_VALUE"

echo "=== Trigger build with crumb + cookie session ==="
curl -sg -b "$COOKIES" -u "$AUTH" -H "${CRUMB_FIELD}: ${CRUMB_VALUE}" -X POST \
  -w '\nHTTP_CODE:%{http_code}\n' \
  "http://localhost:8080/job/ghes-access-key-test/build"

sleep 12

echo "=== Last build status ==="
curl -sg -u "$AUTH" \
  "http://localhost:8080/job/ghes-access-key-test/lastBuild/api/json?tree=number,result,building"
echo

echo "=== Console output ==="
curl -sg -u "$AUTH" \
  "http://localhost:8080/job/ghes-access-key-test/lastBuild/consoleText"
