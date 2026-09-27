# Web search (one-search)

- **Status:** planned for the `mcp` container.
- **Path and port:** `/search`, 8486.
- **URL:** `https://mcp.<tailnet>.ts.net/search/mcp`.
- **Source:** [yokingma/one-search-mcp](https://github.com/yokingma/one-search-mcp),
  cloned in [../one-search-mcp/](../one-search-mcp/). npm package `one-search-mcp`
  (1.2.4 on 2026-09-26). stdio, Node.

## What it needs

Web search, crawl and extract, across several backends, picked with
`SEARCH_PROVIDER`:

| Provider                          | Needs                                  | Notes                                                                                                             |
| --------------------------------- | -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `duckduckgo`                      | nothing                                | Simplest; fine to start with.                                                                                     |
| `searxng`                         | `SEARCH_API_URL` of a SearXNG instance | Best for privacy and volume. SearXNG could be its own iac stack.                                                  |
| `tavily`                          | `SEARCH_API_KEY`                       | Paid, good quality.                                                                                               |
| local browser search and scraping | a Chromium browser (`agent-browser`)   | **Won't work on Alpine as-is.** Use the upstream [Dockerfile](../one-search-mcp/Dockerfile), or skip those tools. |

Other settings: `LIMIT`, `LANGUAGE`, `SAFE_SEARCH`, `TIME_RANGE`, `TIMEOUT` (see its
README).

## Setup

**`iac/mcp/servers/search/Dockerfile`:**

```dockerfile
FROM node:22-alpine
RUN npm install -g supergateway@4.0.0 one-search-mcp@1.2.4
USER node
ENTRYPOINT ["supergateway", "--outputTransport", "streamableHttp"]
```

**Service in `iac/mcp/docker-compose.yml`:**

```yaml
  search:
    build: ./servers/search
    image: mcp-search:local
    container_name: mcp-search
    restart: unless-stopped
    depends_on:
      - tailscale
    network_mode: service:tailscale
    command: ["--stdio", "one-search-mcp", "--port", "8486"]
    environment:
      - SEARCH_PROVIDER=duckduckgo
```

**Serve handler:** `"/search": { "Proxy": "http://127.0.0.1:8486" }`.

Then deploy per [plugin-recipe.md](plugin-recipe.md#6-deploy-and-check).
