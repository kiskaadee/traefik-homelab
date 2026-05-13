# 🖱️ Usability & Operational Notes

This guide explains how to interact with the Hardened Hub once it is deployed.

## 🔑 Authentication (SSO)
Most services are protected by **Authelia**.
1. When you access a protected service (e.g., `gitea.*`), you will be redirected to the Auth Portal (`auth.*`).
2. Log in with your credentials.
3. Once authenticated, you will have access to all SSO-enabled services for the duration of your session.

## 🧭 Navigating the Hub
The **Homepage** dashboard is your central entry point:
- **URL**: `https://arch-services.mywire.org`
- **Widgets**: View the health of Docker containers, system resources, and quick links to all deployed applications.

## 🛠️ Service Management
### Deployment Commands
Use the provided scripts for lifecycle management:
- `./up.sh`: Starts everything.
- `./up.sh --infra-only`: Starts only the control plane (routing, auth, monitoring).
- `./down.sh`: Stops and removes all containers gracefully.

### Managing a Specific Service
To restart or view logs for a single service (e.g., Gitea):
```bash
cd apps/gitea
docker compose restart
docker compose logs -f
```

## ➕ Adding a New Application
To add a new service to the Hub:
1. Create a directory in `apps/your-app`.
2. Add a `docker-compose.yml`.
3. Ensure it connects to the `proxy-net` network:
   ```yaml
   networks:
     proxy-net:
       external: true
   ```
4. Add Traefik labels for routing and (optional) Authelia labels for SSO.
5. Add the service to `apps/homepage/config/services.yaml` to see it on the dashboard.

## 📦 Container Updates
- **Automated**: Watchtower checks for updates every few hours.
- **Manual**: Use Portainer (`portainer.*`) to manually pull new images and recreate containers with a single click.

## 📝 Logging
Real-time logs can be viewed via **Dozzle** at `https://logs.arch-services.mywire.org`. This is preferred over `docker logs` for quick debugging across multiple containers.

## 🤖 Ollama API & Automation (Trusted Payload)
Ollama uses a hybrid security model to allow both browser use and automated tools:

### Browser Use
Accessing `https://ollama.arch-services.mywire.org` directly will prompt for **Authelia SSO** login.

### API & CLI Bypass
For scripts, cron jobs, or terminal use, you can bypass SSO by including the `X-Ollama-Key` header.
- **Header**: `X-Ollama-Key: sk-ollama-hardened-hub-2026`

**Example (curl):**
```bash
curl https://ollama.arch-services.mywire.org/api/generate \
  -H "X-Ollama-Key: sk-ollama-hardened-hub-2026" \
  -d '{"model": "llama3", "prompt": "hi"}'
```

