# @mlld/codex

Codex CLI invocation with session resume, streaming, sandboxing, web search, and MCP tool bridging.

## tldr

```mlld
import { @codex } from @mlld/codex

show @codex("What is REST?")

var @review = @codex("Review code in src/", {
  model: "gpt-5.4",
  dir: @base,
  search: true,
  stream: true
})
```

## docs

### `@codex(prompt, config)`

Runs `codex exec` and returns the final agent message. Output is parsed from `codex exec --json` so session ids, usage, and the final text are captured in a single call regardless of streaming mode.

| Field | Type | Default | Purpose |
|---|---|---|---|
| `model` | string | `"gpt-5.4"` | Codex model id |
| `dir` | string | `@root` | Working directory for the run |
| `system` | string | — | Prepended to the prompt. Codex has no `--append-system-prompt`, so this is the only per-call hook without clobbering `base_instructions`. |
| `sandbox` | string | — | `read-only` \| `workspace-write` \| `danger-full-access`. When omitted defaults to `--full-auto` (or bypass if `config.bypass` is set). |
| `bypass` | boolean | — | Opt into `--dangerously-bypass-approvals-and-sandbox`. **Required when `tools` is set** — codex's default on-request approval auto-cancels MCP tool calls in non-interactive exec mode and returns `user cancelled MCP tool call` as the tool result. Ignored when `sandbox` is explicit. |
| `search` | boolean | — | Adds `--search` for live web search. |
| `stream` | boolean | — | Stream chunks through `@codexStreamFormat`. The adapter also emits session id + token usage metadata. |
| `sessionId` | string | — | Explicit conversation tracking id (UUID, any case). Captured on the first call so the interpreter can persist it into subsequent resumes. |
| `resume` | string | — | Explicit resume session id. Equivalent to `codex exec resume <id>`. |
| `tools` | array | — | Standard mlld `exe llm` tools convention. The runtime builds an MCP bridge at `@mx.llm.config` and this module translates it into codex `-c mcp_servers.*` overrides. Requires `bypass: true`. Codex cannot selectively gate its native tools, so `@mx.llm.native` is informational only. |

```mlld
>> Simple call
var @answer = @codex("Explain TCP/IP")

>> With search + custom model
var @review = @codex("What are the latest best practices for auth?", {
  model: "o3",
  search: true
})

>> Read-only sandbox
var @analysis = @codex("Analyze the codebase", {
  dir: @base,
  sandbox: "read-only"
})

>> System prompt (prepended to the prompt text)
var @r = @codex("What's your codename?", {
  system: "Your codename is Zephyr. Answer in one word."
})

>> Explicit resume
var @followup = @codex("Keep going", { resume: "019d7a01-b45a-7c90-baea-3c0238ee02c8" })

>> mlld tool bridging — requires bypass so MCP tool calls are auto-approved
exe @getOrders() = js { return JSON.stringify([{ id: 1 }]); }

var @summary = @codex("Call getOrders and summarise the results.", {
  tools: [@getOrders],
  bypass: true
})
```

### Session tracking and resume

`@codex` returns a hidden `_mlld` envelope (`{ sessionId, provider: "codex" }`) that the interpreter harvests. Two things fall out:

1. **Public API.** Pass `config.sessionId` to seed a known id, or `config.resume` to resume explicitly. UUIDs are case-insensitive — the module normalises them.
2. **Guard-driven resume.** When a guard decides to retry a call, the runtime injects `config._mlld.resume = { sessionId, provider, continue }`. The module only honours the runtime resume when `provider === "codex"`, so a claude or opencode session never leaks across providers.

### `@codexStreamFormat`

NDJSON adapter for `codex exec --json`. Use with `with { streamFormat: @codexStreamFormat }` in custom exe definitions.

Event types handled:
- `item.completed` → `message` chunks (`part.item.text`)
- `thread.started` → `metadata.sessionId`
- `turn.completed` → `metadata.{inputTokens, outputTokens}`

## Known limitations

- **No per-tool native gating.** Codex exposes its built-in tools (shell, apply_patch, web_search) wholesale — there's no equivalent to claude's `--allowedTools`. When `config.tools` is set, mlld bridges are added *alongside* codex's native tools.
- **MCP approval in exec mode.** Codex 0.118 requires approval for MCP tool calls even in non-interactive `exec`, and auto-cancels if no human is available. This module surfaces the escape hatch via `config.bypass: true`.
- **Box VFS isolation is partial.** The runtime passes the mlld VFS bridge through, but codex's native shell/apply_patch still hit the real filesystem. Use claude if you need strict box isolation.

## License

CC0 - Public Domain
