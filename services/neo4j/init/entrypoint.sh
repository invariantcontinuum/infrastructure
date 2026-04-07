#!/bin/sh
# Neo4j initialization script
set -e

echo "Initializing Neo4j..."

# Wait for Neo4j to be ready
wait_for_neo4j() {
    echo "Waiting for Neo4j to be ready..."
    until curl -s -u "${NEO4J_AUTH%%/*}:${NEO4J_AUTH#*/}" \
        "http://localhost:7474/dbms/health" | grep -q '"status":"UP"'; do
        sleep 2
    done
    echo "Neo4j is ready!"
}

# Execute Cypher scripts if provided
if [ -n "$NEO4J_INIT_SCRIPTS" ] && [ -d "$NEO4J_INIT_SCRIPTS" ]; then
    wait_for_neo4j
    for script in "$NEO4J_INIT_SCRIPTS"/*.cypher; do
        if [ -f "$script" ]; then
            echo "Executing: $script"
            cypher-shell -u "${NEO4J_AUTH%%/*}" -p "${NEO4J_AUTH#*/}" -f "$script" || true
        fi
    done
fi

# Create constraints if specified
if [ -n "$NEO4J_CONSTRAINTS" ]; then
    wait_for_neo4j
    for constraint in $(echo "$NEO4J_CONSTRAINTS" | tr ',' '\n'); do
        echo "Creating constraint: $constraint"
        cypher-shell -u "${NEO4J_AUTH%%/*}" -p "${NEO4J_AUTH#*/}" \
            "CREATE CONSTRAINT $constraint IF NOT EXISTS" || true
    done
fi

echo "Neo4j initialization complete!"
