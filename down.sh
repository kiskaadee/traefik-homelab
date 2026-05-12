#!/bin/bash

stop_stack() {
    local stack_path=$1
    if [ -f "$stack_path/docker-compose.yml" ]; then
        echo "Stopping stack: $stack_path..."
        docker compose -f "$stack_path/docker-compose.yml" down
    fi
}

echo "=== Stopping Application Layer ==="
for app_dir in apps/*/; do
    stop_stack "${app_dir%/}"
done

echo "=== Stopping Infrastructure Layer ==="
stop_stack "infra/dozzle"
stop_stack "infra/diun"
stop_stack "infra/watchtower"
stop_stack "infra/portainer"
stop_stack "infra/authelia"
stop_stack "infra/core"

echo "All services stopped."
