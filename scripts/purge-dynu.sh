#!/bin/bash

# Path to your configuration
# Changed to project relative path
ENV_FILE="infra/core/.env"

# 1. Load Environment Variables
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo "Error: .env file not found at $ENV_FILE"
    exit 1
fi

# 2. Fetch Domain ID dynamically using the DOMAIN variable
echo "Fetching Domain ID for $DOMAIN..."
DOMAIN_ID=$(curl -s -X GET "https://api.dynu.com/v2/dns" \
    -H "API-Key: $DYNU_API_KEY" | \
    jq -r --arg DOMAIN "$DOMAIN" '.domains[] | select(.name==$DOMAIN) | .id')

if [ -z "$DOMAIN_ID" ] || [ "$DOMAIN_ID" == "null" ]; then
    echo "Error: Could not find Domain ID for $DOMAIN. Check your API key and domain name."
    exit 1
fi

echo "Targeting Domain ID: $DOMAIN_ID"

# 3. Identify and Delete all TXT records
echo "Searching for stale TXT records..."
TXT_RECORD_IDS=$(curl -s -X GET "https://api.dynu.com/v2/dns/$DOMAIN_ID/record" \
    -H "API-Key: $DYNU_API_KEY" | \
    jq -r '.dnsRecords[] | select(.recordType=="TXT") | .id')

if [ -z "$TXT_RECORD_IDS" ] || [ "$TXT_RECORD_IDS" == "null" ]; then
    echo "No TXT records found. Quota should be clear."
else
    for ID in $TXT_RECORD_IDS; do
        echo "Deleting TXT Record ID: $ID"
        curl -s -X DELETE "https://api.dynu.com/v2/dns/$DOMAIN_ID/record/$ID" \
            -H "API-Key: $DYNU_API_KEY" > /dev/null
    done
    echo "Purge complete."
fi

# 4. Restart Traefik to trigger new challenge
echo "Restarting Traefik..."
cd infra/core/ && docker compose restart traefik

echo "Process complete. Monitor logs with: docker logs traefik 2>&1 | grep -iE 'acme|dynu'"
