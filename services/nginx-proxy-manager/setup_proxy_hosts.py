#!/usr/bin/env python3
"""Setup proxy hosts in Nginx Proxy Manager database"""
import sqlite3
import json
import sys

DB_PATH = "/data/database.sqlite"

# Service definitions: (id, domain, forward_host, forward_port)
SERVICES = [
    (1, "pgadmin.invariantcontinuum.io", "pgadmin", 5050),
    (2, "redis.invariantcontinuum.io", "redis-commander", 8081),
    (3, "elasticsearch.invariantcontinuum.io", "elasticsearch", 9200),
    (4, "kibana.invariantcontinuum.io", "kibana", 5601),
    (5, "keycloak.invariantcontinuum.io", "keycloak", 8080),
    (6, "nats.invariantcontinuum.io", "nats", 8222),
    (7, "neo4j.invariantcontinuum.io", "neo4j", 7474),
    (8, "qdrant.invariantcontinuum.io", "qdrant", 6333),
]

def setup_database():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    for service_id, domain, forward_host, forward_port in SERVICES:
        try:
            domain_json = json.dumps([domain])
            cursor.execute("""
                INSERT INTO proxy_host 
                (id, created_on, modified_on, owner_user_id, domain_names, forward_host, forward_port, 
                 access_list_id, certificate_id, ssl_forced, caching_enabled, block_exploits, 
                 advanced_config, meta, allow_websocket_upgrade, http2_support, forward_scheme, enabled)
                VALUES (?, datetime('now'), datetime('now'), 1, ?, ?, ?, 0, 0, 0, 0, 1, '', '{}', 0, 0, 'http', 1)
                ON CONFLICT(id) DO UPDATE SET
                    domain_names=excluded.domain_names,
                    forward_host=excluded.forward_host,
                    forward_port=excluded.forward_port,
                    modified_on=datetime('now')
            """, (service_id, domain_json, forward_host, forward_port))
            print(f"✓ Configured: {domain} -> {forward_host}:{forward_port}")
        except Exception as e:
            print(f"✗ Error configuring {domain}: {e}")
            return False
    
    conn.commit()
    conn.close()
    return True

def generate_nginx_configs():
    """Generate nginx config files for each proxy host"""
    import os
    
    proxy_host_dir = "/data/nginx/proxy_host"
    os.makedirs(proxy_host_dir, exist_ok=True)
    
    for service_id, domain, forward_host, forward_port in SERVICES:
        config = f"""server {{
  set $forward_scheme http;
  set $server "{forward_host}";
  set $port {forward_port};

  listen 80;
  listen [::]:80;

  server_name {domain};

  location / {{
    include /etc/nginx/conf.d/include/proxy.conf;
  }}
}}
"""
        config_path = f"{proxy_host_dir}/{service_id}.conf"
        with open(config_path, 'w') as f:
            f.write(config)
        print(f"✓ Generated nginx config: {config_path}")
    
    return True

if __name__ == "__main__":
    print("Setting up Nginx Proxy Manager proxy hosts...")
    print("")
    
    if setup_database():
        print("")
        if generate_nginx_configs():
            print("")
            print("✓ Setup complete! Reload nginx to apply changes:")
            print("  docker exec nginx-proxy-manager nginx -s reload")
            sys.exit(0)
    
    sys.exit(1)
