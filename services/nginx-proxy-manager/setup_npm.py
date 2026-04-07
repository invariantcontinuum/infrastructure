#!/usr/bin/env python3
import http.client
import json
import time

def get_token():
    conn = http.client.HTTPConnection("localhost", 81)
    payload = json.dumps({"identity": "admin@example.com", "secret": "changeme"})
    headers = {"Content-Type": "application/json"}
    conn.request("POST", "/api/tokens", payload, headers)
    res = conn.getresponse()
    data = json.loads(res.read().decode())
    conn.close()
    if "token" in data:
        return data["token"]
    print(f"Login response: {data}")
    return None

def create_proxy_host(token, domain, forward_host, forward_port):
    conn = http.client.HTTPConnection("localhost", 81)
    payload = json.dumps({
        "domain_names": [domain],
        "forward_hostname": forward_host,
        "forward_port": forward_port,
        "access_list_id": 0,
        "certificate_id": 0,
        "ssl_forced": False,
        "caching_enabled": False,
        "block_exploits": True,
        "advanced_config": "",
        "meta": {},
        "allow_websocket_upgrade": False,
        "http2_support": False,
        "forward_scheme": "http",
        "enabled": True
    })
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {token}"
    }
    conn.request("POST", "/api/nginx/proxy-hosts", payload, headers)
    res = conn.getresponse()
    data = res.read().decode()
    conn.close()
    return data

# Wait for NPM to be ready
time.sleep(2)

# Get token
token = get_token()
if not token:
    print("Failed to get token")
    exit(1)

print(f"Got token: {token[:20]}...")

# Create proxy hosts
hosts = [
    ("pgadmin.invariantcontinuum.io", "pgadmin", 5050),
    ("redis.invariantcontinuum.io", "redis-commander", 8081),
    ("elasticsearch.invariantcontinuum.io", "elasticsearch", 9200),
    ("kibana.invariantcontinuum.io", "kibana", 5601),
    ("keycloak.invariantcontinuum.io", "keycloak", 8080),
    ("nats.invariantcontinuum.io", "nats", 8222),
    ("neo4j.invariantcontinuum.io", "neo4j", 7474),
    ("qdrant.invariantcontinuum.io", "qdrant", 6333),
]

for domain, host, port in hosts:
    result = create_proxy_host(token, domain, host, port)
    print(f"Created {domain}: {result}")

print("\nDone! Restarting NPM to apply changes...")
