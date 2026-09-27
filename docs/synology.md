# Synology DSM

- **Status:** deployed in the `mcp` container, service `synology`.
- **URL:** `https://mcp.<tailnet>.ts.net/synology/mcp` (legacy:
  `http://nas.<tailnet>.ts.net:8485/mcp`).
- **Port:** 8485.

## Which Synology server

Two different projects, not forks of each other:

|                   | [`lefty3382/synology-mcp`](https://github.com/lefty3382/synology-mcp)                | [`atom2ueki/mcp-server-synology`](https://github.com/atom2ueki/mcp-server-synology), the clone in [../synology-mcp/](../synology-mcp/) |
| ----------------- | ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| Does              | NAS health, storage and system monitoring                                            | File management, downloads, system operations                                                                                          |
| Writes to the NAS | Only above the `health` tier                                                         | Yes, by design                                                                                                                         |
| Transport         | HTTP on `MCP_PORT`: no bridge needed                                                 | stdio (its `docker-compose.http.yml` adds `mcp-proxy`)                                                                                 |
| In the container  | **Yes**: image `ghcr.io/lefty3382/synology-mcp:latest`, `MCP_PERMISSION_TIER=health` | Not yet                                                                                                                                |

The deployed one is `lefty3382` at the `health` tier: read-mostly, so it's safe on an
unauthenticated node.

## Setup (already in `iac/mcp/docker-compose.yml`)

```yaml
  synology:
    image: ghcr.io/lefty3382/synology-mcp:latest
    container_name: mcp-synology
    network_mode: service:tailscale
    environment:
      - SYNOLOGY_TANK_HOST=${SYNOLOGY_HOST}          # NAS LAN IP, not nas.<tailnet> (see below)
      - SYNOLOGY_TANK_PORT=${SYNOLOGY_PORT}          # DSM HTTPS port: 5001 unless you moved it
      - SYNOLOGY_TANK_USERNAME=${SYNOLOGY_USERNAME}
      - SYNOLOGY_TANK_PASSWORD=${SYNOLOGY_PASSWORD}
      - MCP_PORT=8485
      - MCP_PERMISSION_TIER=health
```

Serve handler: `"/synology": { "Proxy": "http://127.0.0.1:8485" }`.

**Use the NAS's LAN IP for `SYNOLOGY_HOST`, not its tailnet name.** The `mcp` sidecar runs
Tailscale in userspace mode, so containers sharing its namespace get no MagicDNS and no
tailnet routes: `nas.<tailnet>` never resolves, `list_nas` shows `connected: false`, and every
tool returns `{}`. The server skips TLS verification, so DSM's certificate not matching the IP
is fine.

**Port:** DSM's defaults are 5000 (HTTP) and 5001 (HTTPS). DSM's Security Advisor
recommends moving them (Control Panel → Login Portal → DSM tab). If you have, keep the
real numbers out of any repo: set `DSM_HTTPS_PORT` in `~/.env`; the iac repo's
`mcp/.env.example` reads it as `SYNOLOGY_PORT=${DSM_HTTPS_PORT:-5001}`.

**DSM account:** use a dedicated DSM user with only the permissions the tier needs,
not an admin.

## Adding atom2ueki's file tools too

1. **Pick a path and port:** e.g. `/synology-files`, the next free port.
2. **Install:** a Python plugin per [plugin-recipe.md](plugin-recipe.md), installing
   `git+https://github.com/atom2ueki/mcp-server-synology` and running `python main.py`
   under `mcp-proxy`.
3. **Settings:** `SYNOLOGY_URL`, `SYNOLOGY_USERNAME`, `SYNOLOGY_PASSWORD`,
   `VERIFY_SSL` (see [../synology-mcp/env.example](../synology-mcp/env.example)).

It can write and delete files. Put an ACL on the `mcp` node first
([plugin-recipe.md](plugin-recipe.md#access-control)).
