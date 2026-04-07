-- Setup proxy hosts for infrastructure services
INSERT INTO proxy_host (id, created_on, modified_on, domain_names, forward_hostname, forward_port, access_list_id, certificate_id, ssl_forced, caching_enabled, block_exploits, advanced_config, meta, allow_websocket_upgrade, http2_support, forward_scheme, enabled) 
VALUES 
(1, datetime('now'), datetime('now'), '["pgadmin.invariantcontinuum.io"]', 'pgadmin', 5050, 0, 0, 0, 0, 1, '', '{}', 0, 0, 'http', 1),
(2, datetime('now'), datetime('now'), '["redis.invariantcontinuum.io"]', 'redis-commander', 8081, 0, 0, 0, 0, 1, '', '{}', 0, 0, 'http', 1),
(3, datetime('now'), datetime('now'), '["elasticsearch.invariantcontinuum.io"]', 'elasticsearch', 9200, 0, 0, 0, 0, 1, '', '{}', 0, 0, 'http', 1),
(4, datetime('now'), datetime('now'), '["kibana.invariantcontinuum.io"]', 'kibana', 5601, 0, 0, 0, 0, 1, '', '{}', 0, 0, 'http', 1),
(5, datetime('now'), datetime('now'), '["keycloak.invariantcontinuum.io"]', 'keycloak', 8080, 0, 0, 0, 0, 1, '', '{}', 0, 0, 'http', 1),
(6, datetime('now'), datetime('now'), '["nats.invariantcontinuum.io"]', 'nats', 8222, 0, 0, 0, 0, 1, '', '{}', 0, 0, 'http', 1),
(7, datetime('now'), datetime('now'), '["neo4j.invariantcontinuum.io"]', 'neo4j', 7474, 0, 0, 0, 0, 1, '', '{}', 0, 0, 'http', 1),
(8, datetime('now'), datetime('now'), '["qdrant.invariantcontinuum.io"]', 'qdrant', 6333, 0, 0, 0, 0, 1, '', '{}', 0, 0, 'http', 1)
ON CONFLICT(id) DO UPDATE SET 
  domain_names=excluded.domain_names,
  forward_hostname=excluded.forward_hostname,
  forward_port=excluded.forward_port,
  modified_on=datetime('now');
