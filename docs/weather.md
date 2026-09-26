# Weather

- **Status:** planned for the `mcp` container.
- **Path and port:** `/weather`, 8487.
- **URL:** `https://mcp.<tailnet>.ts.net/weather/mcp`.
- **Source:** npm `@dangahagan/weather-mcp` (1.33.1 on 2026-09-26), installed in
  [../servers/](../servers/). stdio, Node.

Forecasts, current conditions, alerts, air quality, radar and history, from free
public sources (NOAA, Open-Meteo, MET Norway, USGS and others). **No API key needed.**
A few optional keys add extras; see the package README. It's the easiest first
plugin to add.

## Setup

**`iac/mcp/servers/weather/Dockerfile`:**

```dockerfile
FROM node:22-alpine
RUN npm install -g supergateway@4.0.0 @dangahagan/weather-mcp@1.33.1
USER node
ENTRYPOINT ["supergateway", "--outputTransport", "streamableHttp"]
```

**Service:**

```yaml
  weather:
    build: ./servers/weather
    image: mcp-weather:local
    container_name: mcp-weather
    restart: unless-stopped
    depends_on:
      - tailscale
    network_mode: service:tailscale
    command: ["--stdio", "weather-mcp", "--port", "8487"]
```

**Serve handler:** `"/weather": { "Proxy": "http://127.0.0.1:8487" }`.

Then deploy per [plugin-recipe.md](plugin-recipe.md#6-deploy-and-check).
