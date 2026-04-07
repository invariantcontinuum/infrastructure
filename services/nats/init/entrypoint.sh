#!/bin/sh
# NATS initialization script
set -e

echo "Initializing NATS..."

# Generate NATS configuration
if [ -n "$NATS_CONFIG_FILE" ]; then
    echo "Using NATS configuration from: $NATS_CONFIG_FILE"
else
    # Create default configuration
    cat > /etc/nats/nats-server.conf <<EOF
port: ${NATS_CLIENT_PORT:-4222}
http_port: ${NATS_HTTP_PORT:-8222}

# JetStream configuration
jetstream {
    store_dir: "/data/jetstream"
    max_memory_store: ${NATS_JS_MAX_MEMORY:-1GB}
    max_file_store: ${NATS_JS_MAX_FILE:-10GB}
}

# Logging
logfile: "/var/log/nats/nats.log"
log_size_limit: 100MB
log_max_num: 10
log_max_age: 30

# Monitoring
monitoring {
    port: ${NATS_HTTP_PORT:-8222}
}
EOF
    echo "Default NATS configuration created"
fi

echo "NATS initialization complete!"
