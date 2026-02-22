# md-fetch

Guardable alternative to built-in WebFetch tool. Fetches web pages and returns markdownified content. HTTPS-only with domain allowlisting.

## Usage

### As a library

```mlld
import { @mdFetch } from @mlld/md-fetch
let @page = @mdFetch("https://example.com")
show @page.content
```

### As an MCP tool

```bash
mlld mcp md-fetch --tools-collection @tools
```

Clients see one tool: `md_fetch(url)`.

**Claude Code `.mcp.json`:**

```json
{
  "mcpServers": {
    "md-fetch": {
      "command": "mlld",
      "args": ["mcp", "md-fetch", "--tools-collection", "@tools",
               "--env", "MLLD_ALLOWED_DOMAINS=*"]
    }
  }
}
```

## Configuration

`MLLD_ALLOWED_DOMAINS` — comma-separated allowlist of domains, or `*` for unrestricted.

```bash
mlld mcp md-fetch --tools-collection @tools --env MLLD_ALLOWED_DOMAINS=github.com,docs.python.org
```

## Exports

| Export | Type | Description |
|--------|------|-------------|
| `@mdFetch` | `exe net:r` | Fetch a URL and return `{ url, domain, content }` |
| `@tools` | `var tools` | Tool collection with `expose: ["url"]` for MCP serving |

## License

CC0 - Public Domain
