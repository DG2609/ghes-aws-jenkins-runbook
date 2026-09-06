#!/bin/bash
set -euo pipefail
set -a
source /mnt/d/down/.env
set +a

docker rm -f ghes-jenkins >/dev/null 2>&1 || true

docker run -d --name ghes-jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -e GITHUB_TOKEN \
  -e GITHUB_USERNAME \
  -e TEST_REPO_URL \
  -e JENKINS_ADMIN_USER \
  -e JENKINS_ADMIN_PASSWORD \
  ghes-jenkins-test

echo "=== container started, waiting for Jenkins ==="
for i in $(seq 1 50); do
  code=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/login || echo "000")
  if [ "$code" = "200" ] || [ "$code" = "403" ]; then
    echo "Jenkins responding with HTTP $code after $((i*3))s"
    break
  fi
  sleep 3
done

echo "=== final check ==="
curl -s -o /dev/null -w 'HTTP_CODE:%{http_code}\n' http://localhost:8080/login
echo "=== last 40 log lines ==="
docker logs ghes-jenkins --tail 40
