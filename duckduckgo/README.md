# duckduckgo

DuckDuckGo web search. No API key required.

Uses the `ddgs` Python package for search.

## Setup

```bash
pip3 install ddgs
```

## tldr

```mlld
import { @search } from @mlld/duckduckgo
var @results = @search("mlld scripting language", 5)
show @results
```

Returns an array of `{ title, href, body }` objects.

## Serve as MCP tool

```bash
mlld mcp modules/duckduckgo/index.mld --tools-collection @tools
```

## Dependencies

- Python 3 with `ddgs` package (`pip3 install ddgs`)

## License

CC0 - Public Domain
