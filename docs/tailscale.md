# Tailscale admin

- **Status:** in the `mcp` container as service `tailscale-admin`
  ([isaackehle/iac#6](https://github.com/isaackehle/iac/pull/6)).
- **Path and port:** `/tailscale`, 8488.
- **URL:** `https://mcp.<tailnet>.ts.net/tailscale/mcp`.
- **Source:** the iac repo, `mcp/servers/tailscale/` (the only copy; this repo's old
  `tailscale/` folder was removed). Python stdio server behind `mcp-proxy`.

## What it does

Read-only access to the Tailscale Admin API: `list_devices`, `get_device`, `list_users`,
`get_acl` (the policy file) and `get_network_settings`. The earlier `reboot_device` was
removed: the endpoint it called isn't part of the Tailscale API.

## Credentials

- **Preferred:** an OAuth client limited to read scopes (`devices:core:read`,
  `users:read`, `policy_file:read`, plus `feature_settings:read` for settings), as
  `TAILSCALE_OAUTH_CLIENT_ID` and `TAILSCALE_OAUTH_CLIENT_SECRET`. The server fetches and
  refreshes access tokens itself.
- **Fallback:** `TAILSCALE_API_KEY` (a `tskey-api-...` key; full access).
- `TAILSCALE_TAILNET` defaults to `-`, the credential's own tailnet.
- With no credentials the server starts anyway and every tool answers "not configured".

Even read-only, it shows your whole tailnet. Restrict who can reach the `mcp` node first
([plugin-recipe.md](plugin-recipe.md#access-control)).

## Running it locally instead

```shell
cd ~/code/isaackehle/iac/mcp/servers/tailscale
uvx --from mcp-proxy --with-requirements requirements.txt \
  mcp-proxy --pass-environment --port 8488 -- python server.py
```

`--pass-environment` matters: without it `mcp-proxy` starts the server with no env vars.
