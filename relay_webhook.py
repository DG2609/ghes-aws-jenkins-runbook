import json
import time

import requests

SMEE_URL = "https://smee.io/O7DgWMwKET6BUEiq"
TARGET = "http://localhost:8080/github-webhook/"


def run():
    resp = requests.get(SMEE_URL, stream=True, headers={"Accept": "text/event-stream"}, timeout=(10, None))
    for raw_line in resp.iter_lines(decode_unicode=True):
        if not raw_line or not raw_line.startswith("data:"):
            continue
        data_str = raw_line[len("data:"):].strip()
        try:
            data = json.loads(data_str)
        except json.JSONDecodeError:
            continue
        if "body" not in data:
            continue

        body = data["body"]
        headers = {"Content-Type": "application/json"}
        for h in ("x-github-event", "x-github-delivery", "x-hub-signature", "x-hub-signature-256"):
            if h in data:
                headers[h] = data[h]

        event_name = headers.get("x-github-event", "?")
        print(f"[relay] event={event_name} delivery={headers.get('x-github-delivery')}", flush=True)
        try:
            r = requests.post(TARGET, json=body, headers=headers, timeout=10)
            print(f"[relay] -> Jenkins responded {r.status_code}", flush=True)
        except Exception as e:
            print(f"[relay] -> ERROR posting to Jenkins: {e}", flush=True)


if __name__ == "__main__":
    while True:
        try:
            run()
        except Exception as e:
            print(f"[relay] stream error, retry in 3s: {e}", flush=True)
            time.sleep(3)
