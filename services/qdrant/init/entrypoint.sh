#!/bin/sh
# Qdrant initialization script
set -e

echo "Initializing Qdrant..."

# Create configuration if API key is set
if [ -n "$QDRANT_API_KEY" ]; then
    mkdir -p /qdrant/config
    cat > /qdrant/config/config.yaml <<EOF
service:
  api_key: "$QDRANT_API_KEY"
  enable_cors: true

storage:
  storage_path: /qdrant/storage
  snapshots_path: /qdrant/snapshots
  on_disk_payload: true

performance:
  max_search_limit: 10000
  max_collection_vector_size_bytes: 0
  max_request_cancel_time_sec: 5

telemetry_disabled: true
EOF
    echo "Qdrant configuration with API key created"
fi

echo "Qdrant initialization complete!"
