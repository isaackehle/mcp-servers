# Amazon product data (PullAPI)

- **Status:** planned for the `mcp` container.
- **Path and port:** `/amazon-products`, 8489.
- **URL:** `https://mcp.<tailnet>.ts.net/amazon-products/mcp`.
- **Source:** npm `@pullapi/amazon-scraper-mcp` (1.0.0 on 2026-09-26), installed in
  [../amazon-scraper/](../amazon-scraper/). stdio, Node.

Looks up Amazon product details: price, rating, features, images. It uses PullAPI
through **RapidAPI**, a paid key, and **doesn't touch your Amazon account**. That's
why it can be in the container, unlike the account server in
[local-only.md](local-only.md).

## Setup

**`iac/mcp/servers/amazon-products/Dockerfile`:**

```dockerfile
FROM node:22-alpine
RUN npm install -g supergateway@4.0.0 @pullapi/amazon-scraper-mcp@1.0.0
USER node
ENTRYPOINT ["supergateway", "--outputTransport", "streamableHttp"]
```

**Service:**

```yaml
  amazon-products:
    build: ./servers/amazon-products
    image: mcp-amazon-products:local
    container_name: mcp-amazon-products
    restart: unless-stopped
    depends_on:
      - tailscale
    network_mode: service:tailscale
    command: ["--stdio", "pullapi-amazon-scraper-mcp", "--port", "8489"]
    environment:
      - RAPIDAPI_KEY=${RAPIDAPI_KEY}
```

**Serve handler:** `"/amazon-products": { "Proxy": "http://127.0.0.1:8489" }`.

The key costs money per call, and anyone on the tailnet could use it. Put an ACL on
the node, or set a spending cap in RapidAPI.
