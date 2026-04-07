#!/bin/sh
# Kibana initialization script
set -e

echo "Initializing Kibana..."

# Wait for Elasticsearch to be available
if [ -n "$ELASTICSEARCH_HOSTS" ]; then
    echo "Waiting for Elasticsearch at $ELASTICSEARCH_HOSTS..."
    until curl -s "$ELASTICSEARCH_HOSTS/_cluster/health" > /dev/null 2>&1; do
        sleep 2
    done
    echo "Elasticsearch is available!"
fi

# Import saved objects if specified
if [ -n "$KIBANA_IMPORT_OBJECTS" ] && [ -d "$KIBANA_IMPORT_OBJECTS" ]; then
    echo "Importing Kibana saved objects..."
    for file in "$KIBANA_IMPORT_OBJECTS"/*.ndjson; do
        if [ -f "$file" ]; then
            echo "Importing: $file"
            curl -X POST "localhost:5601/api/saved_objects/_import" \
                -H "kbn-xsrf: true" \
                --form file=@"$file" || true
        fi
    done
fi

echo "Kibana initialization complete!"
