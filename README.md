# Hardened Private Cloud Hub

This repository contains a modular, secure, and self-documenting homeserver architecture based on the **Hardened Hub** model.

## 🏗️ Architectural Overview

The system is split into two distinct layers to ensure stability and security:

### 1. Control Plane (`infra/`)
The "nervous system" of the server. These services handle security, routing, identity, and maintenance.

- **Core (`infra/core`):** 
    - **Traefik (v3.6):** The front door. Handles HTTPS (Let's Encrypt), routing, and load balancing.
    - **Socket-Proxy:** The security wall. Decouples containers from the host's `/var/run/docker.sock`.
- **Identity (`infra/authelia`):** Provides Single Sign-On (SSO) and 2FA protection for apps.
- **Management (`infra/portainer`):** Visual container and stack management.
- **Monitoring (`infra/dozzle`):** Real-time log streaming for all containers (SSO Protected).
- **Maintenance (`infra/watchtower`, `infra/diun`):** Automated image updates and notifications.

### 2. Data Plane (`apps/`)
The consumer-facing applications.

- **Homepage:** Central dashboard at `arch-services.mywire.org`.
- **Gitea:** Self-hosted Git service (SSO Protected).
- **Ollama:** Local LLM runner with 3 replicas.
- **Excalidraw & Mermaid:** Visual tools for whiteboarding and diagramming.

---

## 🚀 Getting Started

### 1. Secrets Management
Secrets are kept out of the configuration files and stored in `.env` files (git-ignored).

- **Core Infrastructure:** Create `infra/core/.env` based on `.env-example`:
    ```env
    DYNU_API_KEY=your_key
    ACME_EMAIL=your_email
    ```
- **Identity (Authelia):** Create `infra/authelia/.env` with the following:
    ```env
    AUTHELIA_SESSION_SECRET=long_random_string
    AUTHELIA_STORAGE_ENCRYPTION_KEY=long_random_string
    AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET=long_random_string
    ```

### 2. Deployment
Use the `up.sh` script to launch the stack. The script handles networks, permissions, and service sequencing.

```bash
# Start everything (Infrastructure + Apps)
./up.sh

# Start ONLY the Control Plane
./up.sh --infra-only
```

### 3. Verification
Once deployed, verify your services are reachable:
- **Homepage:** `https://arch-services.mywire.org`
- **Auth Portal:** `https://auth.arch-services.mywire.org`
- **Gitea:** `https://gitea.arch-services.mywire.org` (Redirects to Auth)
- **Logs:** `https://logs.arch-services.mywire.org` (Redirects to Auth)

---

## 📊 Observability & Monitoring

The system includes built-in tools for real-time monitoring and management:

- **Traefik Dashboard**: `https://traefik.arch-services.mywire.org` — View routing, entrypoints, and certificate status (SSO Protected).
- **Dozzle**: `https://logs.arch-services.mywire.org` — Real-time log streaming for all containers (SSO Protected).
- **Portainer**: `https://portainer.arch-services.mywire.org` — Advanced container, volume, and stack management (SSO Protected).
- **Homepage**: `https://arch-services.mywire.org` — The central "Single Pane of Glass" for all your services.

---

## 📜 Log Policy

To prevent the host system from running out of disk space, a **Log Rotation** policy is enforced:

- **Driver**: `json-file`
- **Max Size**: `10m` (10 Megabytes per file)
- **Max Files**: `3` (Keeps the last 3 files)

This policy is currently enabled on core infrastructure and is recommended for all high-traffic application containers.

---

## 🛡️ Security Features
- **Socket Isolation:** No application container has access to the Docker socket. All management tools use the `socket-proxy`.
- **SSO Integration:** Critical apps (Gitea, Dozzle, Portainer) are behind Authelia Forward Auth.
- **Automatic TLS:** Traefik manages Let's Encrypt certificates via DNS-01 challenges with Dynu.
- **Network Segmentation:** Services are isolated on `proxy-net` and `socket-net`.
