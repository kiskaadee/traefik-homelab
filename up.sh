#!/bin/bash

# --- 1. NETWORK & PERMISSIONS ---
docker network inspect proxy-net >/dev/null 2>&1 || docker network create proxy-net
docker network inspect socket-net >/dev/null 2>&1 || docker network create socket-net

# SSL Permissions (Moved to infra/core)
if [ ! -f infra/core/letsencrypt/acme.json ]; then
    echo "Initializing letsencrypt/acme.json..."
    sudo mkdir -p infra/core/letsencrypt
    sudo touch infra/core/letsencrypt/acme.json
    sudo chmod 600 infra/core/letsencrypt/acme.json
    sudo chown root:root infra/core/letsencrypt/acme.json
fi

# --- 2. HELPER FUNCTIONS ---
start_stack() {
    local stack_path=$1
    shift
    local env_flags=()
    for env_file in "$@"; do
        if [ -f "$env_file" ]; then
            env_flags+=("--env-file" "$env_file")
        fi
    done
    if [ -f "$stack_path/docker-compose.yml" ]; then
        echo "Starting stack: $stack_path..."
        docker compose -f "$stack_path/docker-compose.yml" "${env_flags[@]}" up -d
    else
        echo "Warning: No docker-compose.yml found in $stack_path"
    fi
}

# --- 3. DEPLOY CONTROL PLANE & PORTAL ---
echo "=== Deploying Control Plane ==="
start_stack "infra/core" "infra/core/.env"
start_stack "infra/authelia" "infra/core/.env" "infra/authelia/.env"
start_stack "infra/portainer"
start_stack "infra/watchtower"
start_stack "infra/diun"
start_stack "infra/dozzle"

echo "=== Deploying Homepage Portal ==="
start_stack "homepage" "infra/core/.env"

echo ""
echo "Hardened Private Cloud Deployment Complete."
