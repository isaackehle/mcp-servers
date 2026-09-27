# Local-only servers

These act on your personal accounts. They stay as stdio servers on the machine that
uses them, not in the `mcp` container, because that node has no authentication and
anyone on the tailnet could call them.

| Server                                                                                                                                          | Why it stays local                                                                                                                                                   | Where it's configured                                                            |
| ----------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| Amazon account ([../mcp-server-amazon/](../mcp-server-amazon/), [rigwild/mcp-server-amazon](https://github.com/rigwild/mcp-server-amazon))      | Uses your Amazon session cookies (`amazonCookies.json`) to manage the cart and read orders. Its "place order" tool is documented as a demo, but the session is real. | Per client, stdio                                                                |
| Monarch Money ([../monarch-mcp-server/](../monarch-mcp-server/), [robcerda/monarch-mcp-server](https://github.com/robcerda/monarch-mcp-server)) | Full read access to your finances. Login needs MFA, done once with `login_setup.py`, and the session is stored locally.                                              | Per client, stdio                                                                |
| 1Password (npm `mcp-1password`)                                                                                                                 | Vault access through the desktop app.                                                                                                                                | `~/.hermes/config.yaml` `mcp_servers.1password` (see [../index.md](../index.md)) |

## Running them

**Amazon account.** Its npm package (0.0.1) has no runnable command, so run the clone:

```shell
cd mcp-server-amazon && pnpm install && pnpm build
# client entry: command "node", args ["<repo>/mcp-server-amazon/build/index.js"]
```

`amazonCookies.json` holds a live Amazon session. Don't commit it, and don't copy it
to shared machines.

**Monarch.** It isn't on PyPI, so run the clone:

```shell
cd monarch-mcp-server
uv run python login_setup.py      # once, with your MFA code
# client entry: command "uv", args ["--directory", "<repo>/monarch-mcp-server", "run", "monarch-mcp-server"]
```

`monarch-mcp-server` is the command its `pyproject.toml` defines.

## If one ever needs to be remote

Put it in a **separate** stack with its own Tailscale node, an ACL that allows only
you, and ideally a proxy that checks Tailscale's identity headers
(`Tailscale-User-Login`) that `tailscale serve` adds. Don't add it to the shared `mcp`
node.
