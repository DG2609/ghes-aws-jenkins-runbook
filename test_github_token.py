import os
import sys

from dotenv import load_dotenv
import requests

load_dotenv()

TOKEN = os.environ.get("GITHUB_TOKEN")
BASE_URL = os.environ.get("GITHUB_API_BASE", "https://api.github.com")

if not TOKEN:
    sys.exit("GITHUB_TOKEN chưa được set trong .env")

headers = {
    "Authorization": f"Bearer {TOKEN}",
    "Accept": "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
}

resp = requests.get(f"{BASE_URL}/user", headers=headers, timeout=10)
print("Status:", resp.status_code)

if resp.status_code == 200:
    data = resp.json()
    print("Đăng nhập thành công với user:", data.get("login"))
    print("Tên hiển thị:", data.get("name"))
    print("Tài khoản tạo lúc:", data.get("created_at"))
else:
    print("Lỗi:", resp.json())
