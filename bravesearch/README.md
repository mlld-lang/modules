# bravesearch

Brave Search API tool. Uses standalone `auth` with keychain-first, env fallback.

## Setup

Store your Brave Search API key in keychain (recommended):

```bash
mlld keychain add BRAVE_API_KEY
```

Or provide it via environment (CI/Docker):

```bash
export BRAVE_API_KEY=...
```

## tldr

```mlld
import { @search } from @mlld/bravesearch
var @results = @search("mlld scripting language", 5)
show @results
```

## Serve as MCP tool

```bash
mlld mcp modules/bravesearch/index.mld --tools-collection @tools
```

## License

CC0 - Public Domain
