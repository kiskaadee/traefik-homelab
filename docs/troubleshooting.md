# 🩺 Troubleshooting Guide

Common issues and their resolutions for the Hardened Hub.

## 🌐 Connectivity Issues
### 1. Site is unreachable (General)
- **Check External IP**: Verify if your public IP matches the DNS record at Dynu.
  - Run `scripts/dynu/run-once.sh` to force an update.
- **Check Traefik Status**:
  - `docker compose -f infra/core/docker-compose.yml ps`
  - Ensure Traefik is running and port 80/443 are mapped.

### 2. "Bad Gateway" (502) or "Service Unavailable" (503)
- This usually means the application container is down or not connected to the `proxy-net`.
- **Action**: Verify the app container is running:
  ```bash
  docker ps | grep <app_name>
  ```
- **Action**: Check container logs via Dozzle or `docker logs`.

## 🔒 SSL & Certificate Issues
### 1. "Your connection is not private"
- Traefik might be struggling with the Let's Encrypt challenge.
- **Action**: Check Traefik logs for "ACME" or "LE" errors:
  ```bash
  docker compose -f infra/core/docker-compose.yml logs -f traefik
  ```
- **Common Cause**: Dynu API key is incorrect or API rate limits were hit.

### 2. Certificate is not valid for the subdomain
- Ensure the Traefik `Host` rule in your `docker-compose.yml` labels is correct.

## 🔐 Authentication (Authelia) Issues
### 1. Stuck in a Login Loop
- This often happens if the browser clock or server clock is out of sync.
- **Action**: Sync the server time (`sudo ntpdate pool.ntp.org`).
- **Action**: Clear browser cookies for your domain.

### 2. Forbidden (403) after login
- Your user may not have the required permissions in `infra/authelia/config/configuration.yml`.
- **Action**: Check the `access_control` section in the Authelia config.

## 🐳 Docker & Performance
### 1. Disk is full
- **Cause**: Usually excessive logs or orphaned volumes.
- **Action**: Run the cleanup command:
  ```bash
  docker system prune -a --volumes
  ```
- **Action**: Check `apps/homepage/config/logs/` and other app-specific log paths.

### 2. High CPU/RAM Usage
- Check the Homepage dashboard or run `docker stats` to identify the culprit.
- **Common Culprit**: Ollama during model inference or Gitea indexing large repos.
