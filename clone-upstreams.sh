#!/usr/bin/env bash
# clone-upstreams.sh: clone the upstream MCP server repos this catalog documents.
# They're gitignored here: each keeps its own history. Existing clones are left alone.
set -euo pipefail
cd "$(dirname "$0")"

clone() {   # clone <dir> <url>
    if [ -d "$1/.git" ]; then echo "exists  $1"; else git clone --depth 1 "$2" "$1"; fi
}

clone mcp-server-amazon  https://github.com/rigwild/mcp-server-amazon.git
clone monarch-mcp-server https://github.com/robcerda/monarch-mcp-server.git
clone one-search-mcp     https://github.com/yokingma/one-search-mcp.git
clone synology-mcp       https://github.com/atom2ueki/mcp-server-synology.git
