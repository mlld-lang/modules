# mlld core modules

Core modules for the mlld prompt scripting language. Each module lives in its own folder and is imported as `@mlld/<name>`.

## Modules

- [@mlld/airlock](./airlock/README.md) — Dual-LLM security pattern: tainted input never shares context with the evaluation model.
- [@mlld/array](./array/README.md) — Array helpers that mlld's builtin methods don't cover.
- [@mlld/bravesearch](./bravesearch/README.md) — Brave Search API tool; reads its API key from the keychain first, then the environment.
- [@mlld/claude](./claude/README.md) — Claude invocation primitives with tool use and streaming.
- [@mlld/codex](./codex/README.md) — Codex CLI invocation with session resume, streaming, sandboxing, web search, and MCP tool bridging.
- [@mlld/decision-harness](./decision-harness/README.md) — Typed decisions (choice, score, yes/no, classify) from a model you pick in config.
- [@mlld/duckduckgo](./duckduckgo/README.md) — DuckDuckGo web search, no API key required.
- [@mlld/fix-relative-links](./fix-relative-links/README.md) — Adjusts relative paths in markdown links when content moves to a different folder.
- [@mlld/gh-issues](./gh-issues/README.md) — GitHub issues, pull requests, repos and workflows via the `gh` CLI.
- [@mlld/jev](./jev/README.md) — Typed, calibrated answers from TypeSafe's jev model.
- [@mlld/lms](./lms/README.md) — Call a local LM Studio model over its REST API, on-device with no API key.
- [@mlld/md-fetch](./md-fetch/README.md) — Fetches web pages as markdown, HTTPS-only with domain allowlisting.
- [@mlld/multi-harness](./multi-harness/README.md) — Run the same prompt on claude, codex, pi or opencode by changing one setting.
- [@mlld/openai](./openai/README.md) — OpenAI chat completions with auth sealing.
- [@mlld/opencode](./opencode/README.md) — Opencode CLI invocation with session resume, streaming, and MCP tool bridging.
- [@mlld/opencode-sse](./opencode-sse/README.md) — Drives opencode through `opencode serve` and Server-Sent Events, emitting `@mlld/claude`'s stream format.
- [@mlld/pg](./pg/README.md) — Postgres-backed artifact storage.
- [@mlld/pi](./pi/README.md) — Invoke the Pi coding agent with mlld tool integration.
- [@mlld/sqlite](./sqlite/README.md) — SQLite-backed artifact storage.
- [@mlld/string](./string/README.md) — String helpers that mlld's builtin methods don't cover.
- [@mlld/time](./time/README.md) — Date and time formatting, arithmetic, comparisons, business days, relative time and durations.

## Retired

These published modules are not carried into this major version. Old versions stay installable from the registry.

- `@mlld/ai-cli` — use [@mlld/multi-harness](./multi-harness/README.md), [@mlld/claude](./claude/README.md) or [@mlld/codex](./codex/README.md). Its gemini support has no replacement.
- `@mlld/claude-poll` — use [@mlld/multi-harness](./multi-harness/README.md). It worked around a `claude -p` hang that Claude Code has since fixed.
- `@mlld/env` — use `@input`, `using { env }` and `using creds:`.
- `@mlld/prose` — use [@mlld/claude](./claude/README.md).
- `@mlld/stream-claude-agent-sdk` — use the built-in `claude-agent-sdk` stream format.
- `@mlld/github` — use [@mlld/gh-issues](./gh-issues/README.md).
