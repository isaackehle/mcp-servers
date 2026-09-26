# MCP Servers

## Installed MCP Servers

| Name            | Purpose                                                                                 |
| --------------- | --------------------------------------------------------------------------------------- |
| time            | Time and timezone queries                                                               |
| tailscale-admin | Tailscale infrastructure management                                                     |
| 1password       | 1Password vault access, password organization, secret retrieval, secure note management |

## Installation Notes

### 1Password MCP

- Package: `mcp-1password@beta` (npm)
- Auth mode: desktop (uses 1Password desktop app + `op` CLI)
- Account: my.1password.com (use your account UUID)
- Transport: stdio
- Config: `~/.hermes/config.yaml` under `mcp_servers.1password`
- Security: secrets are redacted by default; explicit opt-in required for plaintext reveal
- Audit log: `~/.onepassword-mcp/audit.jsonl`

### Tailscale MCP

- Image: `isaackehle/tailscale-mcp:latest`
- Requires `TAILSCALE_API_KEY` env var

@hexsleeves/tailscale-mcp-server
