#!/bin/bash
set -a
source /mnt/d/down/.env
set +a
AUTH="${JENKINS_ADMIN_USER}:${JENKINS_ADMIN_PASSWORD}"

curl -sg -u "$AUTH" \
  "http://localhost:8080/job/ghes-access-key-test/api/json?tree=builds[number,result,building,timestamp]"
