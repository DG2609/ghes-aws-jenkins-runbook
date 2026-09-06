#!/bin/bash
set -a
source /mnt/d/down/.env
set +a
AUTH="${JENKINS_ADMIN_USER}:${JENKINS_ADMIN_PASSWORD}"

echo "=== Build #6 info + cause ==="
curl -sg -u "$AUTH" \
  "http://localhost:8080/job/ghes-access-key-test/6/api/json?tree=number,result,building,actions[causes[shortDescription]]"
echo
echo "=== Console tail ==="
curl -sg -u "$AUTH" "http://localhost:8080/job/ghes-access-key-test/6/consoleText" | tail -15
