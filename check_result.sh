#!/bin/bash
set -a
source /mnt/d/down/.env
set +a
AUTH="${JENKINS_ADMIN_USER}:${JENKINS_ADMIN_PASSWORD}"

echo "=== Build result ==="
curl -sg -u "$AUTH" "http://localhost:8080/job/ghes-access-key-test/lastBuild/api/json?tree=number,result,building,duration"
echo
echo "=== Console tail ==="
curl -sg -u "$AUTH" "http://localhost:8080/job/ghes-access-key-test/lastBuild/consoleText" | tail -25
