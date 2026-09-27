# MCP servers

A catalog of the MCP servers I use or plan to, and how each one runs: either as a
**plugin** of the NAS's `mcp` container (one Tailscale node, one URL per server,
`https://mcp.<tailnet>.ts.net/<path>/mcp`), or locally on the machine that uses it.

- **The container:** the iac repo's `mcp` stack,
  `~/code/isaackehle/iac/mcp/` ([INSTALLATION.md](https://github.com/isaackehle/iac/blob/main/mcp/INSTALLATION.md),
  [docker-compose.yml](https://github.com/isaackehle/iac/blob/main/mcp/docker-compose.yml)).
- **Adding any server as a plugin:** [docs/plugin-recipe.md](docs/plugin-recipe.md).
- **What's configured in clients today:** [index.md](index.md). LM Studio's client
  config: [mcp.jsonc](mcp.jsonc).
- **Upstream code:** servers written by others are cloned locally for reading and
  development, not committed here. `./clone-upstreams.sh` fetches them. The
  container installs each server from its published package or git URL, not from
  these clones.

## Catalog

### In the `mcp` container

| Server                      | Source                                                                                                                   | Path, port               | Needs                                                                  | Doc                                                |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ------------------------ | ---------------------------------------------------------------------- | -------------------------------------------------- |
| Synology DSM (**deployed**) | [lefty3382/synology-mcp](https://github.com/lefty3382/synology-mcp)                                                      | `/synology`, 8485        | DSM user and password                                                  | [docs/synology.md](docs/synology.md)               |
| Web search (one-search)     | npm `one-search-mcp` ([yokingma/one-search-mcp](https://github.com/yokingma/one-search-mcp))                             | `/search`, 8486          | Nothing for DuckDuckGo; a SearXNG URL or Tavily key for better results | [docs/one-search.md](docs/one-search.md)           |
| Weather                     | npm `@dangahagan/weather-mcp` ([servers/](servers/))                                                                     | `/weather`, 8487         | Nothing                                                                | [docs/weather.md](docs/weather.md)                 |
| Tailscale admin             | [tailscale/](tailscale/) (my own)                                                                                        | `/tailscale`, 8488       | Tailscale API key, read-only if possible                               | [docs/tailscale.md](docs/tailscale.md)             |
| Amazon product data         | npm `@pullapi/amazon-scraper-mcp` ([amazon-scraper/](amazon-scraper/))                                                   | `/amazon-products`, 8489 | RapidAPI key (paid)                                                    | [docs/amazon-scraper.md](docs/amazon-scraper.md)   |
| Time and time zones         | PyPI `mcp-server-time` ([modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers))                 | `/time`, 8490            | Nothing                                                                | [plugin-recipe.md](docs/plugin-recipe.md) (Python) |
| Brave Search                | npm `@brave/brave-search-mcp-server` ([brave/brave-search-mcp-server](https://github.com/brave/brave-search-mcp-server)) | `/brave`, 8491           | `BRAVE_API_KEY` (free tier)                                            | [plugin-recipe.md](docs/plugin-recipe.md) (Node)   |

- **Next free port:** 8492.
- **The paths and ports are the plan.** The compose file's header table lists what's
  actually deployed; add a server there when you deploy it.
- **Alternatives:** npm `@hexsleeves/tailscale-mcp-server` is a published Node
  alternative to my Tailscale server. Brave Search overlaps with one-search; pick
  one.

### Local only

These act on personal accounts or local files, so they run as stdio servers on the
machine that uses them. See [docs/local-only.md](docs/local-only.md).

| Server                        | Source                                                                                                                              | Why it stays local                                                                                                                                              |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Amazon account (cart, orders) | [rigwild/mcp-server-amazon](https://github.com/rigwild/mcp-server-amazon) ([amazon/](amazon/))                                      | Uses your Amazon session cookies                                                                                                                                |
| Monarch Money                 | [robcerda/monarch-mcp-server](https://github.com/robcerda/monarch-mcp-server)                                                       | Full access to your finances; MFA login                                                                                                                         |
| 1Password                     | npm `mcp-1password`                                                                                                                 | Vault access through the desktop app ([index.md](index.md) has its setup)                                                                                       |
| Filesystem                    | npm `@modelcontextprotocol/server-filesystem`                                                                                       | Reads and writes a local folder (LM Studio uses it: [mcp.jsonc](mcp.jsonc))                                                                                     |
| LiteLLM admin (LiteAdmin)     | [BerriAI/litellm-admin-mcp](https://github.com/BerriAI/litellm-admin-mcp), [docs](https://docs.litellm.ai/docs/proxy/liteadmin_mcp) | Needs a proxy-admin key. Use it for keys, teams, budgets and spend; add models through your own config, not through it. New (v0.1.0, 2026-09): pin the version. |

### Hosted by the provider

Nothing to run: point a client at the provider's own endpoint. They use your
personal login, so configure them per client, not in the shared `mcp` container.

| Server               | Endpoint                                                                                    | Notes                                                           |
| -------------------- | ------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| Fastmail             | `https://api.fastmail.com/mcp`                                                              | Your mail                                                       |
| Monarch Money (beta) | Enabled in [Monarch's integrations settings](https://app.monarch.com/settings/integrations) | Monarch's own server; an alternative to the community one above |

## Container or local: the rule

The `mcp` node has **no authentication of its own**. Anyone who can reach it on the
tailnet can call every tool on every server. So:

- **In the container:** servers that read public data, or read your
  infrastructure with a scoped credential (Synology at the `health` tier, a
  read-only Tailscale key).
- **Local only:** anything that spends money, places orders, or reads financial,
  password, mail or local-file data.
- **Adding authentication:** LiteLLM's [MCP gateway](https://docs.litellm.ai/docs/mcp)
  can front these servers (stdio, SSE or HTTP) at `http://<host>:4000/<server>/mcp`
  and limit each one to specific LiteLLM keys or teams. With the `mcp` node reachable
  only from LiteLLM (a Tailscale ACL), every client goes through a key.
- **Narrowing access:** a Tailscale ACL can limit who reaches the `mcp` node
  (e.g. only your user, port 443). Do it before adding the Tailscale admin server or
  anything with a paid key. See [docs/plugin-recipe.md](docs/plugin-recipe.md#access-control).

## Using a server from a client

Every container server has the same URL shape: `https://mcp.<tailnet>.ts.net/<path>/mcp`.

| Client      | Where                                                                                     | Entry                                                                                               |
| ----------- | ----------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| opencode    | `~/.config/opencode/opencode.jsonc` (fleet template: homelab `fleet/templates/opencode/`) | `"<name>": { "type": "remote", "url": "https://mcp.<tailnet>.ts.net/<path>/mcp", "enabled": true }` |
| Hermes      | `~/.hermes/config.yaml`, `mcp_servers:`                                                   | `<name>: { url: https://mcp.<tailnet>.ts.net/<path>/mcp, enabled: true }`                           |
| LM Studio   | `~/.lmstudio/mcp.json` ([mcp.jsonc](mcp.jsonc) here)                                      | `"<name>": { "url": "https://mcp.<tailnet>.ts.net/<path>/mcp" }`                                    |
| Claude Code | `claude mcp add --transport http <name> https://mcp.<tailnet>.ts.net/<path>/mcp`          |                                                                                                     |

LM Studio **plugins** (e.g. `Beledarians_LM_Studio_Toolbox`) aren't MCP servers.
They install into LM Studio itself and don't belong here.

## Candidates

Servers worth adding, found in September 2026. None are set up here yet.

### Built into apps that may already be running

- **Home Assistant:** the official
  [Model Context Protocol Server integration](https://www.home-assistant.io/integrations/mcp_server/)
  exposes Home Assistant to agents directly, with no add-on.
- **LiteLLM:** the [MCP gateway](https://docs.litellm.ai/docs/mcp) (see the rule above)
  and [LiteAdmin](https://docs.litellm.ai/docs/proxy/liteadmin_mcp) (local-only table).
- **n8n:** the
  [MCP Server Trigger node](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-langchain.mcptrigger/)
  turns workflows into MCP tools.
- **Langfuse:** a
  [built-in MCP server](https://langfuse.com/docs/api-and-data-platform/features/mcp-server)
  for prompt management.

### First-party servers

- **[Context7](https://github.com/upstash/context7)** (Upstash): current library and
  tool docs for coding agents, so they stop guessing flags and APIs.
- **[Portainer MCP](https://github.com/portainer/portainer-mcp)** (official): manage
  Docker stacks through Portainer.
- **[GitHub MCP](https://github.com/github/github-mcp-server)** (official): also
  available hosted.
- **[Todoist](https://github.com/Doist/todoist-ai)** (official): also hosted, as
  `net.todoist/mcp` in the registry.
- **[Playwright](https://github.com/microsoft/playwright-mcp)** (Microsoft): browser
  automation. Run it locally rather than in the container.

### Community servers

Review these before trusting them: they'd hold credentials to your infrastructure.

- **Pi-hole:** several, e.g. `hexamatic/pihole-mcp`, which ships a container image.
- **Frigate:** `mrfentmen/frigate-mcp`.
- **zigbee2mqtt:** `alexpfau/zigbee2mqtt-mcp`.
- **Tailscale:** `YawLabs/tailscale-mcp`, an alternative to [tailscale/](tailscale/).

Nothing credible found for Syncthing, Plex, LM Studio or NotePlan.

## Finding more servers

- **[Official MCP Registry](https://registry.modelcontextprotocol.io):** the canonical
  index. It has an API, so agents and scripts can search it:

  ```shell
  curl -s 'https://registry.modelcontextprotocol.io/v0/servers?search=pihole&limit=10'
  ```

- **[GitHub MCP directory](https://github.com/mcp):** curated, mostly first-party.
- **[Docker MCP Catalog](https://hub.docker.com/mcp):** prebuilt container images; the
  most natural source for the `mcp` container.
- **[modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers):**
  reference servers, plus a community list.
- **[awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers):** a large
  list sorted by category.
- **[Smithery](https://smithery.ai) and [Glama](https://glama.ai/mcp/servers):**
  directories, some with hosted versions. mcp.so and PulseMCP are similar; they block
  scripted requests but load in a browser.
- **[Hugging Face Spaces with MCP](https://huggingface.co/spaces?filter=mcp-server):**
  also searchable through the Hugging Face MCP server.

## Reading list

- **1Password:**
  - [Securing MCP servers with 1Password](https://1password.com/blog/securing-mcp-servers-with-1password-stop-credential-exposure-in-your-agent):
    keeping credentials out of agent configs.
  - [1Password MCP server](https://www.1password.dev/environments/mcp-server)
  - [Local `.env` files from 1Password Environments](https://www.1password.dev/environments/local-env-file)
  - [Testing CLI shell plugins](https://www.1password.dev/cli/shell-plugins/test)
- **Roundups:**
  [10 best free MCP servers for developers in 2026](https://medium.com/syntest/10-best-free-mcp-servers-for-developers-in-2026-20bd96314f4b)

## License

[MIT](LICENSE), for the files in this repo (docs, recipes, wrappers and scripts). The upstream
MCP servers are not included: `clone-upstreams.sh` fetches them, and each keeps its own license.
