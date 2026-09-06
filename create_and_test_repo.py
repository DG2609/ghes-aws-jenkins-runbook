import base64
import os
import sys
import time

import requests
from dotenv import load_dotenv

load_dotenv()

TOKEN = os.environ.get("GITHUB_TOKEN")
BASE_URL = os.environ.get("GITHUB_API_BASE", "https://api.github.com")

if not TOKEN:
    sys.exit("GITHUB_TOKEN chưa được set trong .env")

session = requests.Session()
session.headers.update(
    {
        "Authorization": f"Bearer {TOKEN}",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
)

# 1. Xac thuc
me = session.get(f"{BASE_URL}/user", timeout=10)
if me.status_code != 200:
    print("[1] Xac thuc THAT BAI:", me.status_code, me.json())
    sys.exit(1)
username = me.json()["login"]
print(f"[1] Xac thuc OK - user: {username}")

# 2. Tao repo moi (private)
repo_name = f"claude-access-key-test-{int(time.time())}"
create_resp = session.post(
    f"{BASE_URL}/user/repos",
    json={
        "name": repo_name,
        "description": "Test tao repo + push qua API voi personal access token",
        "private": True,
        "auto_init": True,
    },
    timeout=15,
)

if create_resp.status_code not in (200, 201):
    print("[2] Tao repo THAT BAI:", create_resp.status_code, create_resp.json())
    sys.exit(1)

repo_data = create_resp.json()
print(f"[2] Tao repo OK: {repo_data['full_name']} -> {repo_data['html_url']}")

time.sleep(3)  # doi GitHub init xong default branch

# 3. "Push" 1 file qua Contents API
file_path = "hello-from-claude.md"
content_str = (
    f"# Test tu Claude Code\n\n"
    f"File nay duoc tao qua GitHub REST API luc "
    f"{time.strftime('%Y-%m-%d %H:%M:%S')} de test personal access token.\n"
)
content_b64 = base64.b64encode(content_str.encode("utf-8")).decode("utf-8")

put_resp = session.put(
    f"{BASE_URL}/repos/{username}/{repo_name}/contents/{file_path}",
    json={
        "message": "Add test file via API (Claude Code test)",
        "content": content_b64,
    },
    timeout=15,
)

if put_resp.status_code not in (200, 201):
    print("[3] Push file THAT BAI:", put_resp.status_code, put_resp.json())
    sys.exit(1)

commit_sha = put_resp.json()["commit"]["sha"]
print(f"[3] Push file OK: {file_path} (commit {commit_sha[:7]})")

# 4. Xac nhan lai file ton tai tren repo
get_resp = session.get(
    f"{BASE_URL}/repos/{username}/{repo_name}/contents/{file_path}", timeout=10
)
if get_resp.status_code == 200:
    gd = get_resp.json()
    print(f"[4] Xac nhan file ton tai: sha={gd['sha'][:7]}, size={gd['size']} bytes")
else:
    print("[4] Khong doc lai duoc file:", get_resp.status_code, get_resp.json())

print("\nHOAN TAT.")
print("Repo:", repo_data["html_url"])
