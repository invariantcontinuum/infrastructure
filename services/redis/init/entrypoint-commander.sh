#!/bin/sh
# Redis Commander initialization script
set -e

echo "Initializing Redis Commander..."

# Set Redis connection string
if [ -n "$REDIS_PASSWORD" ]; then
    export REDIS_HOSTS="local:redis:6379:0:${REDIS_PASSWORD}"
else
    export REDIS_HOSTS="local:redis:6379"
fi

echo "Redis Commander configured for Redis at: redis:6379"
echo "Redis Commander initialization complete!"
