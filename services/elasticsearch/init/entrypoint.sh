#!/bin/sh
# Elasticsearch initialization script
set -e

echo "Initializing Elasticsearch..."

# Set heap size
if [ -n "$ELASTICSEARCH_HEAP_SIZE" ]; then
    export ES_JAVA_OPTS="-Xms$ELASTICSEARCH_HEAP_SIZE -Xmx$ELASTICSEARCH_HEAP_SIZE"
fi

# Wait for Elasticsearch to be ready
wait_for_es() {
    echo "Waiting for Elasticsearch to be ready..."
    until curl -s "http://localhost:9200/_cluster/health" | grep -q '"status":"\(green\|yellow\)"'; do
        sleep 2
    done
    echo "Elasticsearch is ready!"
}

# Create initial indices if specified
if [ -n "$ES_CREATE_INDICES" ]; then
    wait_for_es
    for index in $(echo "$ES_CREATE_INDICES" | tr ',' '\n'); do
        echo "Creating index: $index"
        curl -X PUT "localhost:9200/$index" -H 'Content-Type: application/json' -d'{
            "settings": {
                "number_of_shards": 1,
                "number_of_replicas": 0
            }
        }' || true
    done
fi

echo "Elasticsearch initialization complete!"
