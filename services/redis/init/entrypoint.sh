#!/bin/sh
# Redis initialization script
set -e

echo "Initializing Redis..."

# Set Redis configuration based on environment
if [ -n "$REDIS_MAX_MEMORY" ]; then
    echo "maxmemory $REDIS_MAX_MEMORY" >> /usr/local/etc/redis/redis.conf
    echo "maxmemory-policy allkeys-lru" >> /usr/local/etc/redis/redis.conf
fi

# Enable AOF persistence if specified
if [ "$REDIS_ENABLE_AOF" = "true" ]; then
    echo "appendonly yes" >> /usr/local/etc/redis/redis.conf
    echo "appendfsync everysec" >> /usr/local/etc/redis/redis.conf
fi

echo "Redis initialization complete!"
