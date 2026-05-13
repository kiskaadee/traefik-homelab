# 🗺️ Project Roadmap: Hardened Private Cloud Hub

This roadmap reflects the current system maturity and future priorities.

---

## ✅ Phase 1: Core Gateway & Infrastructure (Complete)
*Objective: Stable external access, identity management, and core security.*

- [x] **Dynamic DNS:** Reliable IP synchronization via systemd-based Dynu updater.
- [x] **Edge Routing:** Traefik v3 with Let's Encrypt (DNS-01) automation.
- [x] **Layered Architecture:** Clear separation between `infra/` (control plane) and `apps/` (data plane).
- [x] **Identity & SSO:** Authelia integration with 2FA/OIDC support.
- [x] **Security Hardening:** Docker socket proxy, internal network segmentation, and non-root users where possible.
- [x] **Centralized Logging:** Real-time log streaming via Dozzle.

---

## 🏗️ Phase 2: Application Ecosystem & Observability (In Progress)
*Objective: Expand utility and improve "Single Pane of Glass" monitoring.*

- [x] **Service Discovery:** 'Homepage' dashboard integration.
- [x] **Visual Tools:** Excalidraw and Mermaid deployment.
- [x] **Development:** Self-hosted Gitea with SSO.
- [x] **AI/ML:** Scalable Ollama cluster with model management.
- [ ] **Unified Health:** Integrate Traefik/Docker health checks into the Homepage dashboard.
- [ ] **Resource Monitoring:** Add lightweight metrics (e.g., Glances or Netdata) with dashboard widgets.

---

## 🚀 Phase 3: Automation & Resilience
*Objective: Move from "manual maintenance" to "autonomous operations".*

- [x] **Automated Updates:** Watchtower and Diun for image lifecycle management.
- [ ] **Backup Strategy:** Automated, encrypted off-site backups for persistent volumes (Gitea, DBs).
- [ ] **Infrastructure as Code:** Further modularization of the `up.sh` script into a more robust CLI or Ansible-based setup.
- [ ] **Alerting:** Push notifications (via Gotify/Ntfy) for system failures, auth breaches, or IP update issues.

---

## 🌐 Phase 4: Network Optimization
*Objective: Reduce latency and external dependencies.*

- [ ] **Local DNS:** Ad-blocking DNS (Pi-hole/AdGuard Home) for LAN clients.
- [ ] **Hairpin NAT:** Validation and optimization for internal traffic routing.
- [ ] **VPN Integration:** WireGuard-based remote access for private management without public exposure.

---

## 📜 Engineering Principles

1. **Idempotency:** All deployment scripts (`up.sh`, `down.sh`) must be safe to run repeatedly.
2. **Layered Security:** No single point of failure. If the gateway is breached, apps are still behind SSO.
3. **Auditability:** Every change is reflected in documentation and Git history.
4. **Resilience:** Infrastructure must survive reboots and network outages automatically.
