# Traefik Homelab

This repository contains the core Control Plane for a modular, secure, and self-documenting homeserver architecture based on the **Hardened Hub** model.

## 🏗️ Architectural Overview

The system is split into two distinct planes to ensure stability, security, and a clean separation of concerns:

### 1. Control Plane (`infra/` & `homepage/`)
The "nervous system" of the server. These services handle security, edge routing, identity, maintenance, and portal visualization.

- **Core (`infra/core`):** 
    - **Traefik (v3.6):** The entry gateway. Handles HTTPS (Let's Encrypt DNS-01 challenges), routing, and load balancing.
    - **Socket-Proxy:** The security boundary. Decouples core containers from the host's `/var/run/docker.sock`.
- **Identity (`infra/authelia`):** Provides Single Sign-On (SSO) and 2FA protection for administrative tools and exposed applications.
- **Management (`infra/portainer`):** Visual container and stack management.
- **Monitoring (`infra/dozzle`):** Real-time log streaming for core containers (SSO Protected).
- **Maintenance (`infra/watchtower`, `infra/diun`):** Automated image updates and registry monitoring.
- **Portal (`homepage/`):** Central landing dashboard at `arch-services.mywire.org` serving as the single entry point.

### 2. Data Plane (Decoupled User Applications)
User applications (such as Gitea, Jellyfin, or Kanban boards) are kept fully decoupled in separate directories outside this repository. They integrate with the Control Plane dynamically via the shared external Docker network (`proxy-net`) and Traefik routing labels.

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
Use the `up.sh` script to launch the core stack. The script handles network creation, Let's Encrypt certificate file initialization, and starts all infrastructure services plus the Homepage portal.

```bash
# Start the entire Core Infrastructure + Homepage
./up.sh
```

### 3. Verification
Once deployed, verify your services are reachable:
- **Homepage Dashboard:** `https://arch-services.mywire.org`
- **Auth Portal:** `https://auth.arch-services.mywire.org`
- **Traefik Dashboard:** `https://traefik.arch-services.mywire.org` (Redirects to Auth)
- **Logs:** `https://logs.arch-services.mywire.org` (Redirects to Auth)

---

## 📊 Observability & Monitoring

The system includes built-in tools for real-time monitoring and management:

- **Traefik Dashboard**: `https://traefik.arch-services.mywire.org` — View routing, entrypoints, and certificate status (SSO Protected).
- **Dozzle**: `https://logs.arch-services.mywire.org` — Real-time log streaming for all containers (SSO Protected).
- **Portainer**: `https://portainer.arch-services.mywire.org` — Advanced container, volume, and stack management (SSO Protected).
- **Homepage**: `https://arch-services.mywire.org` — The central portal displaying status indicators for all services.

### Maintenance Scripts
For rapid diagnostics and common fixes, use the included automation scripts:
- **`./scripts/check-ssl.sh`**: Instantly audits the SSL/TLS status across all configured public subdomains.
- **`./scripts/purge-dynu.sh`**: Clears stale ACME challenge records from Dynu to resolve "503 Quota" deadlocks.

---

## 📜 Log Policy

To prevent the host system from running out of disk space, a **Log Rotation** policy is enforced:

- **Driver**: `json-file`
- **Max Size**: `10m` (10 Megabytes per file)
- **Max Files**: `3` (Keeps the last 3 files)

This policy is currently enabled on core infrastructure and is recommended for all high-traffic application containers.

---

## 🛡️ Security Features
- **Socket Isolation:** No container has access to the host's raw Docker socket. All management tools communicate via the read/write-controlled `socket-proxy`.
- **SSO Integration:** Critical management tools (Portainer, Dozzle) and sensitive user applications are behind Authelia Forward Auth.
- **Automatic TLS:** Traefik automatically manages wildcard Let's Encrypt certificates via DNS-01 challenges with Dynu.
- **Network Segmentation:** System traffic is isolated on `proxy-net` and `socket-net` networks.
- **Decoupled Architecture:** Application stacks are isolated from the core repository config, preventing Git history contamination and permitting independent CI/CD pipelines.

---

## 📚 Detailed Documentation

For more in-depth information, please refer to the following guides:

- **[Server Architecture](https://kiskaadee.github.io/traefik-homelab/architecture.html)**: Deep dive into the layered model, networking, and security posture.
- **[Usability & Operations](https://kiskaadee.github.io/traefik-homelab/usability.html)**: How to use the hub, expose new decoupled apps, and manage updates.
- **[Troubleshooting](https://kiskaadee.github.io/traefik-homelab/troubleshooting.html)**: Solutions for common connectivity, SSL, and authentication issues.
- **[Project Roadmap](https://kiskaadee.github.io/traefik-homelab/roadmap.html)**: Current status and future planned features.
- **[Dynu IP Protocol](https://kiskaadee.github.io/traefik-homelab/dynu-ip-update-protocol.html)**: Technical details on the DDNS synchronization mechanism.
