#!/bin/bash
set -a
source /mnt/d/down/.env
set +a

echo "=== Job list ==="
curl -sg -u "${JENKINS_ADMIN_USER}:${JENKINS_ADMIN_PASSWORD}" \
  "http://localhost:8080/api/json?tree=jobs[name,url]"
echo

echo "=== Credentials list ==="
curl -sg -u "${JENKINS_ADMIN_USER}:${JENKINS_ADMIN_PASSWORD}" \
  "http://localhost:8080/credentials/store/system/domain/_/api/json?tree=credentials[id,description]"
echo

echo "=== Trigger build ==="
curl -sg -u "${JENKINS_ADMIN_USER}:${JENKINS_ADMIN_PASSWORD}" -X POST \
  "http://localhost:8080/job/ghes-access-key-test/build"
sleep 10

echo "=== Last build status ==="
curl -sg -u "${JENKINS_ADMIN_USER}:${JENKINS_ADMIN_PASSWORD}" \
  "http://localhost:8080/job/ghes-access-key-test/lastBuild/api/json?tree=number,result,building"
echo

echo "=== Console output ==="
curl -sg -u "${JENKINS_ADMIN_USER}:${JENKINS_ADMIN_PASSWORD}" \
  "http://localhost:8080/job/ghes-access-key-test/lastBuild/consoleText"
