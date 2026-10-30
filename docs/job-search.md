# Job Search

Several MCP servers for career and job search. Some are hosted (zero setup),
others run locally (free, more control).

## Hosted (plug-and-play)

### Startup Jobs

- **Endpoint:** `https://api.startup.jobs/mcp`
- **Source:** [startup.jobs](https://startup.jobs) (killbridge/startupjobs-mcp on Glama)
- **Cost:** Free tier (20 req/min, last 14 days). Full archive via API key.
- **Auth:** None for free tier; `Authorization: Bearer sj_KEY` for full access.
- **Tools (8, read-only):** `search_jobs`, `get_job`, `get_company`, `get_company_jobs`, `list_roles`, `list_countries`,
  `job_trends`, `salary_benchmarks`.
- **Config (any Streamable HTTP client):**

```json
{
  "mcpServers": {
    "startup-jobs": { "httpUrl": "https://api.startup.jobs/mcp" }
  }
}
```

274,000+ live startup jobs across 71,800 startups. No account required for the
free tier.

### Himalayas (Remote Jobs)

- **Endpoint:** `https://mcp.himalayas.app/mcp`
- **Source:** [Himalayas-App/himalayas-mcp](https://github.com/Himalayas-App/himalayas-mcp)
- **Cost:** Free (partial); free account for full.
- **Auth:** 13 public tools need no account; 46 job-seeker + 20 employer tools
  need a free Himalayas account (OAuth).
- **Tools:** 79 total — search, salary, company, talent search, application
  tracker, job posting.
- **Config (Cursor):**

```json
{
  "mcpServers": {
    "himalayas": { "url": "https://mcp.himalayas.app/mcp" }
  }
}
```

100,000+ remote jobs, salary benchmarks, application tracking, and employer
tools (posting jobs, finding candidates).

### Apify Jobright Scraper

- **Endpoint:** `https://mcp.apify.com/?tools=fetch-actor-details,scrapeai/jobright-scraper`
- **Source:** Apify Actor `scrapeai/jobright-scraper` (hosted via
  [apify/mcp-server](https://github.com/apify/apify-mcp-server))
- **Cost:** ~$2.49/1,000 results (proxy costs extra).
- **Auth:** OAuth (browser sign-in) or `Authorization: Bearer <APIFY_TOKEN>`.
- **Features:** AI skill matching, Glassdoor ratings, H1B/visa status, salary
  extraction, proxy rotation.
- **Config:**

```json
{
  "mcpServers": {
    "apify": {
      "type": "http",
      "url": "https://mcp.apify.com/?tools=fetch-actor-details,scrapeai/jobright-scraper"
    }
  }
}
```

## Local (open source, free)

### JobSpy

- **Source:** [borgius/jobspy-mcp-server](https://github.com/borgius/jobspy-mcp-server)
- **Stars:** 123 | **Forks:** 45
- **Setup:** Node.js 16+ + Python 3.6+ (runs locally via stdio or SSE).
- **Tools:** `search_jobs` — filters by site, search term, location, hours-old,
  format (JSON/CSV).
- **Coverage:** Indeed, LinkedIn, Glassdoor, ZipRecruiter, Google Jobs, Bayt,
  Naukri, BDJobs.
- **Config (Claude Desktop):**

```json
{
  "mcpServers": {
    "jobspy": {
      "command": "node",
      "args": ["/path/to/jobspy-mcp-server/src/index.js"],
      "env": { "ENABLE_SSE": "0" }
    }
  }
}
```

### Openings

- **Source:** [amikai/openings-mcp](https://github.com/amikai/openings-mcp)
- **Stars:** 105 | **Forks:** 11
- **Language:** Go (single binary, fast).
- **Install:** `brew install --cask amikai/tap/openings-mcp` or
  `go install github.com/amikai/openings-mcp/cmd/openings-mcp@latest` or Docker.
- **Setup:** Run `openings-mcp --http=127.0.0.1:8080`, then connect any MCP
  client.
- **Coverage:** 41,000+ company career sites (Workday, Greenhouse, Lever, Ashby,
  etc.) + major job boards (LinkedIn, Indeed, 104, Cake, Jobindex).
- **Claude Code:**

```text
claude mcp add --transport http --scope user openings-mcp http://127.0.0.1:8080
```

## Quick comparison

| Server         | Type   | Cost              | Coverage                          | Auth          |
| -------------- | ------ | ----------------- | --------------------------------- | ------------- |
| Startup Jobs   | Hosted | Free (limited)    | 274K startup jobs                 | None          |
| Himalayas      | Hosted | Free (partial)    | 100K+ remote jobs                 | None (public) |
| Apify Jobright | Hosted | ~$2.49/1k results | Jobright.ai only                  | OAuth/token   |
| JobSpy         | Local  | Free              | Indeed, LinkedIn, Glassdoor, etc. | None          |
| Openings       | Local  | Free              | 41K+ ATS + major boards           | None          |
