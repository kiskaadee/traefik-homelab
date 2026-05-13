# 🏗️ Server Architecture: Hardened Hub Model

The homeserver follows a **Layered Architecture** designed for security, observability, and modularity. It is split into two logical tiers: the **Control Plane** (Infrastructure) and the **Data Plane** (Applications).

## 1. Physical & Host Layer
- **OS**: Linux (Generic).
- **IP Sync**: A host-level systemd service (`scripts/dynu/`) monitors the public IP and updates Dynu DDNS records. This ensures that the external domain always points to the correct gateway.
- **Docker Engine**: Orchestrates all containerized services.

## 2. Infrastructure Layer (`infra/`)
The "Control Plane" manages the lifecycle and security of the entire stack.

### 🌐 Edge Gateway (`infra/core`)
- **Traefik v3**: Acts as the Reverse Proxy and SSL terminator.
  - Handles **DNS-01 Challenges** via Dynu for wildcard SSL certificates.
  - Routes traffic based on subdomains (e.g., `gitea.*`).
- **Socket-Proxy**: A secure bridge that protects the Docker socket. Services needing Docker access (Portainer, Watchtower) talk to this proxy instead of the raw socket, preventing container-escape vulnerabilities.

### 🔐 Identity & Access (`infra/authelia`)
- **Authelia**: Provides Single Sign-On (SSO) and Two-Factor Authentication (2FA).
- **Forward Auth**: Traefik delegates authentication to Authelia before allowing traffic to sensitive applications.

### 🛠️ Management & Maintenance
- **Portainer**: Graphical UI for managing Docker stacks and containers.
- **Watchtower**: Automatically pulls new images and restarts containers when updates are available.
- **Diun**: Notifies the administrator of new image tags.

## 3. Application Layer (`apps/`)
The "Data Plane" contains the services used by end-users. These are isolated on the `proxy-net` network and have no direct access to host resources unless explicitly defined.

- **Service Discovery**: 'Homepage' (the dashboard) provides a unified portal.
- **SSO Integration**: Apps like Gitea and Dozzle are integrated with Authelia for secure, authenticated access.

## 4. Networking Model
- **`proxy-net`**: Shared internal network for Traefik and all exposed applications.
- **`socket-net`**: Isolated network for communication between the Socket-Proxy and management tools.
- **External Exposure**: Only ports 80 and 443 are exposed to the internet. All other management (SSH, API) is restricted or handled via the reverse proxy.

---

## 🛡️ Security Posture
1. **No Root Docker**: Most containers are encouraged to run with specific PUID/PGID.
2. **Wildcard Certificates**: Wildcard SSL prevents domain enumeration by malicious scanners.
3. **Internal-Only Services**: Some tools (like Portainer) are reachable only via the local network or authenticated proxy.
4. **Log Rotation**: Global policy ensures container logs don't consume all disk space.
