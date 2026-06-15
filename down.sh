#!/bin/bash

stop_stack() {
    local stack_path=$1
    shift
    local env_flags=()
    for env_file in "$@"; do
        if [ -f "$env_file" ]; then
            env_flags+=("--env-file" "$env_file")
        fi
    done
    if [ -f "$stack_path/docker-compose.yml" ]; then
        echo "Stopping stack: $stack_path..."
        docker compose -f "$stack_path/docker-compose.yml" "${env_flags[@]}" down
    fi
}

echo "=== Stopping Portal Layer ==="
stop_stack "homepage" "infra/core/.env"

echo "=== Stopping Infrastructure Layer ==="
stop_stack "infra/dozzle"
stop_stack "infra/diun"
stop_stack "infra/watchtower"
stop_stack "infra/portainer"
stop_stack "infra/authelia" "infra/core/.env" "infra/authelia/.env"
stop_stack "infra/core" "infra/core/.env"

echo "All services stopped."
