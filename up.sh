#!/bin/bash

# --- 1. NETWORK & PERMISSIONS ---
docker network inspect proxy-net >/dev/null 2>&1 || docker network create proxy-net
docker network inspect socket-net >/dev/null 2>&1 || docker network create socket-net

# SSL Permissions (Moved to infra/core)
sudo mkdir -p infra/core/letsencrypt
sudo touch infra/core/letsencrypt/acme.json
sudo chmod 600 infra/core/letsencrypt/acme.json
sudo chown root:root infra/core/letsencrypt/acme.json

# --- 2. HELPER FUNCTIONS ---
start_stack() {
    local stack_path=$1
    if [ -f "$stack_path/docker-compose.yml" ]; then
        echo "Starting stack: $stack_path..."
        docker compose -f "$stack_path/docker-compose.yml" up -d
    else
        echo "Warning: No docker-compose.yml found in $stack_path"
    fi
}

# --- 3. INFRASTRUCTURE LAYER (Control Plane) ---
echo "=== Deploying Infrastructure Layer ==="
start_stack "infra/core"
start_stack "infra/authelia"
start_stack "infra/portainer"
start_stack "infra/watchtower"
start_stack "infra/diun"
start_stack "infra/dozzle"
echo "Infrastructure is ready."
echo ""

# --- 4. APPLICATION LAYER (Data Plane) ---
if [[ "$1" == "--infra-only" ]]; then
    echo "Skipping Application Layer as requested."
else
    echo "=== Deploying Application Layer ==="
    # Dynamically start all apps in the apps/ directory
    for app_dir in apps/*/; do
        start_stack "${app_dir%/}"
    done
    echo "Applications are ready."
fi

echo ""
echo "Hardened Private Cloud Deployment Complete."
echo "Usage: ./up.sh [--infra-only]"
