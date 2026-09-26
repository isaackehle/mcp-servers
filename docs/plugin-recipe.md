# Adding an MCP server to the `mcp` container

Every server in the `mcp` stack (iac repo, `~/code/isaackehle/iac/mcp/`) follows
the same shape. Most MCP servers speak **stdio**, so each runs behind a small bridge
that serves it as streamable HTTP on its own port. Tailscale then routes a path to
that port.

```text
client ── https://mcp.<tailnet>.ts.net/<path>/mcp
  │  mcp-tailscale: TLS, then route by path, stripping /<path>
  ▼
127.0.0.1:<port>/mcp   bridge (supergateway or mcp-proxy) in its own container
  │  stdio
  ▼
the MCP server process
```

All the containers share the Tailscale container's network namespace, so each
needs its own port. The next free one is in the [catalog](../README.md#catalog).

## 1. Pick the bridge

| Server language | Bridge | Why |
| --- | --- | --- |
| Node (npm package) | [`supergateway`](https://www.npmjs.com/package/supergateway) 4.x | Node only, so the image is `node:22-alpine` and nothing else |
| Python | [`mcp-proxy`](https://github.com/sparfenyuk/mcp-proxy) with `mcp<1.20` | Python only, so the image is `python:3.12-alpine`. The pin is needed: newer `mcp` breaks `mcp-proxy`'s import (2026-09-26). |
| Already serves HTTP | none | Run it on its port directly (e.g. Synology) |

Both bridges serve streamable HTTP at `/mcp`.

## 2. Add a Dockerfile to the iac repo

Put it in `iac/mcp/servers/<name>/Dockerfile`. Portainer builds it from the repo.

**Node server:**

```dockerfile
FROM node:22-alpine
# Pin versions; bump deliberately.
RUN npm install -g supergateway@4.0.0 <package>@<version>
USER node
ENTRYPOINT ["supergateway", "--outputTransport", "streamableHttp"]
```

**Python server:**

```dockerfile
FROM python:3.12-alpine
RUN pip install --no-cache-dir "mcp-proxy" "mcp<1.20" "<package or git+https://github.com/owner/repo@<tag>>"
USER nobody
ENTRYPOINT ["mcp-proxy"]
```

The Python base lacks `git`. If you install from a git URL, add
`RUN apk add --no-cache git` before the `pip install`.

## 3. Add the service to `iac/mcp/docker-compose.yml`

```yaml
  <name>:
    build: ./servers/<name>
    image: mcp-<name>:local
    container_name: mcp-<name>
    restart: unless-stopped
    depends_on:
      - tailscale
    network_mode: service:tailscale   # share the mcp node's namespace
    # Node (supergateway):
    command: ["--stdio", "<server command>", "--port", "<port>"]
    # Python (mcp-proxy):
    # command: ["--host", "127.0.0.1", "--port", "<port>", "--", "<server command>"]
    environment:
      - SOME_KEY=${SOME_KEY}
```

Then add a row to the port table in the compose file's header.

## 4. Route a path to it

In `iac/mcp/serve.json.tmpl`, add a handler, and add the path to the `/` text:

```json
"/<path>": { "Proxy": "http://127.0.0.1:<port>" }
```

## 5. Secrets

Add each variable to `iac/mcp/.env.example` with a placeholder, and the real value
to `iac/iac-secrets.env` (a 1Password `op://` reference is fine).

## 6. Deploy and check

```shell
cd ~/code/isaackehle/iac
scripts/gen-env.sh mcp && git push
scripts/deploy.sh extras mcp nas         # the re-rendered serve.json
# Portainer: Stacks → mcp → Pull and redeploy (rebuilds changed images)
curl -s https://mcp.<tailnet>.ts.net/    # the server list
```

Then add it to your clients (see the [README](../README.md#using-a-server-from-a-client))
and to the catalog.

**Verify on first use:** that Portainer CE builds `build:` images in a repository
stack, and that Tailscale strips the path prefix before proxying. Both are expected
to work but haven't been exercised on this NAS yet. If building fails, build and
push the image from a Mac instead, and use `image:` without `build:`.

## Access control

The `mcp` node has no authentication. Tailscale ACLs can limit who reaches it.
Tag the node (e.g. `tag:mcp`, set with `TS_EXTRA_ARGS=--advertise-tags=tag:mcp`
and a tag-owning auth key), then allow only yourself:

```json
{ "action": "accept", "src": ["autogroup:member"], "dst": ["tag:mcp:443"] }
```

Anything that spends money or reads financial or password data stays local anyway;
see [local-only.md](local-only.md).
