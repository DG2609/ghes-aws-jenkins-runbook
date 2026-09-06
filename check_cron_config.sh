#!/bin/bash
set -a
source /mnt/d/down/.env
set +a
AUTH="${JENKINS_ADMIN_USER}:${JENKINS_ADMIN_PASSWORD}"

echo "=== config.xml (grep trigger) ==="
curl -sg -u "$AUTH" "http://localhost:8080/job/ghes-access-key-test/config.xml" | grep -A3 -i "trigger\|cron"

echo "=== current server time ==="
date -u

echo "=== build history ==="
curl -sg -u "$AUTH" "http://localhost:8080/job/ghes-access-key-test/api/json?tree=builds[number,timestamp]"
