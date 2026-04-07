#!/usr/bin/env python3
import http.client
import json

# Create first user
conn = http.client.HTTPConnection("localhost", 81)
payload = json.dumps({
    "name": "Admin",
    "email": "admin@example.com",
    "password": "changeme",
    "password_confirm": "changeme"
})
headers = {"Content-Type": "application/json"}
conn.request("POST", "/api/users/first", payload, headers)
res = conn.getresponse()
data = res.read().decode()
conn.close()
print(f"First user creation: {data}")
