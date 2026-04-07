#!/bin/bash
# Setup proxy hosts for Nginx Proxy Manager

NPM_URL="http://localhost:81"
EMAIL="admin@example.com"
PASSWORD="changeme"

# Login and get token
echo "Logging in to NPM..."
TOKEN=$(curl -s -X POST "${NPM_URL}/api/tokens" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"${EMAIL}\",\"secret\":\"${PASSWORD}\"}" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "Failed to get token. Trying to parse differently..."
  TOKEN=$(curl -s -X POST "${NPM_URL}/api/tokens" \
    -H "Content-Type: application/json" \
    -d '{"identity":"admin@example.com","secret":"changeme"}' | sed 's/.*"token":"\([^"]*\)".*/\1/')
fi

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "Failed to get token. Raw response:"
  curl -s -X POST "${NPM_URL}/api/tokens" \
    -H "Content-Type: application/json" \
    -d '{"identity":"admin@example.com","secret":"changeme"}'
  exit 1
fi

echo "Got token: ${TOKEN:0:10}..."
echo "Creating proxy hosts..."

# Create proxy host function
create_proxy_host() {
  local domain=$1
  local forward_host=$2
  local forward_port=$3
  
  curl -s -X POST "${NPM_URL}/api/nginx/proxy-hosts" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" \
    -d "{
      \"domain_names\":[\"${domain}\"],
      \"forward_hostname\":\"${forward_host}\",
      \"forward_port\":${forward_port},
      \"access_list_id\":0,
      \"certificate_id\":0,
      \"ssl_forced\":false,
      \"caching_enabled\":false,
      \"block_exploits\":true,
      \"advanced_config\":\"\",
      \"meta\":{}
    }"
  echo " - Created: ${domain} -> ${forward_host}:${forward_port}"
}

# Create all proxy hosts
create_proxy_host "pgadmin.invariantcontinuum.io" "pgadmin" 5050
create_proxy_host "redis.invariantcontinuum.io" "redis-commander" 8081
create_proxy_host "elasticsearch.invariantcontinuum.io" "elasticsearch" 9200
create_proxy_host "kibana.invariantcontinuum.io" "kibana" 5601
create_proxy_host "keycloak.invariantcontinuum.io" "keycloak" 8080
create_proxy_host "nats.invariantcontinuum.io" "nats" 8222
create_proxy_host "neo4j.invariantcontinuum.io" "neo4j" 7474
create_proxy_host "qdrant.invariantcontinuum.io" "qdrant" 6333

echo ""
echo "All proxy hosts configured!"
