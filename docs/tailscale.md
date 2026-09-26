# Tailscale admin

- **Status:** planned for the `mcp` container, after an ACL on the node.
- **Path and port:** `/tailscale`, 8488.
- **URL:** `https://mcp.<tailnet>.ts.net/tailscale/mcp`.
- **Source:** your own code, in [../tailscale/](../tailscale/). stdio, Python
  (`server.py`, using the `mcp` SDK and `aiohttp`). It talks to the Tailscale Admin
  API.

## Two copies: pick one first

The code exists twice and has diverged:

- here, in [../tailscale/server.py](../tailscale/server.py);
- in iac, `~/code/isaackehle/iac/tailscale-mcp/server.py`, which is newer (it uses
  `mcp.types.Tool`).

The container is built from the iac repo, so the iac copy should become the one
source: move it to `iac/mcp/servers/tailscale/`, and delete or archive the other.

The iac copy's own compose file publishes port 8000 and health-checks it, but the
server only speaks stdio. That compose file goes away once it runs as a plugin.

## Credentials

- **Tools:** it can list, get, reboot and delete devices and manage keys. So its
  credential matters.
- **Scope it down:** prefer a Tailscale **OAuth client** limited to the scopes you
  want (e.g. `devices:core:read`) over a full `tskey-api-...` key.
- **Settings:** `TAILSCALE_API_KEY` and `TAILSCALE_TAILNET` (e.g. `-`, or your
  tailnet name).
- **Add an ACL on the `mcp` node before deploying**
  ([plugin-recipe.md](plugin-recipe.md#access-control)). Otherwise anyone on the
  tailnet can manage the tailnet.

## Setup

**`iac/mcp/servers/tailscale/Dockerfile`** (next to `server.py` and `requirements.txt`):

```dockerfile
FROM python:3.12-alpine
WORKDIR /app
COPY requirements.txt server.py ./
RUN pip install --no-cache-dir -r requirements.txt "mcp-proxy" "mcp<1.20"
USER nobody
ENTRYPOINT ["mcp-proxy"]
```

Check that `requirements.txt` doesn't pull an `mcp` version that conflicts with the pin.

**Service:**

```yaml
  tailscale-admin:
    build: ./servers/tailscale
    image: mcp-tailscale-admin:local
    container_name: mcp-tailscale-admin
    restart: unless-stopped
    depends_on:
      - tailscale
    network_mode: service:tailscale
    command: ["--host", "127.0.0.1", "--port", "8488", "--", "python", "/app/server.py"]
    environment:
      - TAILSCALE_API_KEY=${TAILSCALE_API_KEY}
      - TAILSCALE_TAILNET=${TAILSCALE_TAILNET}
```

The service is named `tailscale-admin` because `tailscale` is already the sidecar.

**Serve handler:** `"/tailscale": { "Proxy": "http://127.0.0.1:8488" }`.
