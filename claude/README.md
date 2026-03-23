# @mlld/claude

Claude invocation primitives with tool use, streaming, and polling.

## tldr

```mlld
import { @claude, @haiku, @sonnet, @opus } from @mlld/claude

show @haiku("What is REST?")
show @sonnet("Summarize this document")

var @result = @claude("Review code in src/", {
  model: "opus",
  dir: @base,
  tools: ["Read", "Grep", "Glob"],
  stream: true
})
```

## docs

### Isolation

All invocations run with `--bare` and `CLAUDECODE` unset by default. This means child `claude` processes start clean — no CLAUDE.md, no hooks, no plugins, no MCP servers from the parent environment. Only tools you explicitly pass via `config.tools` are available.

This ensures consistent behavior whether your script runs inside Claude Code, from the CLI, or via the SDK. Without `--bare`, child processes would inherit the parent's project context (CLAUDE.md instructions, installed plugins, configured MCP servers), making behavior dependent on where the script is invoked from.

To allow the child process to inherit project context, set `config.inherit: true`. This removes `--bare` so the child loads CLAUDE.md, hooks, and plugins normally. `CLAUDECODE` is always unset regardless of `inherit`.

### `@claude(prompt, config)`

Core invocation. All other exes delegate to this.

**Config object:**

| Field | Type | Default | Description |
|---|---|---|---|
| `model` | string | `"sonnet"` | Model name: haiku, sonnet, opus, or a full model ID |
| `dir` | string | `@root` | Working directory for tool operations |
| `tools` | array | — | Tool access: strings for built-in tools, exe refs for mlld functions |
| `stream` | boolean | — | Enable token streaming |
| `system` | string | — | Appended system prompt |
| `inherit` | boolean | `false` | Inherit project context (CLAUDE.md, hooks, plugins). Removes `--bare`. |

```mlld
>> Simple call
var @answer = @claude("Explain TCP/IP", { model: "haiku" })

>> With tools — exe refs create a per-call MCP server
var @review = @claude("Review the auth module", {
  model: "opus",
  dir: @base,
  tools: ["Read", "Grep", @summarize]
})

>> With streaming and system prompt
var @analysis = @claude("Analyze this architecture", {
  model: "sonnet",
  stream: true,
  system: "Focus on security implications"
})

>> Inherit project context (loads CLAUDE.md, hooks, plugins)
var @result = @claude("Check the project", {
  model: "sonnet",
  inherit: true,
  tools: ["Read", "Grep"]
})
```

**Tool handling:**

| Entry type | Behavior |
|---|---|
| String (`"Read"`) | Passed as `--allowedTools`. Native Claude Code tools not in the list are disallowed. |
| Exe ref (`@summarize`) | Wrapped as an MCP tool via a function bridge. Schema generated from the function signature. |
| Mixed | Both types can be combined in one array. |
| Omitted | No `--allowedTools` constraint. With `--bare`, only base tools are available. |

When exe ref tools are provided, all native tools not explicitly listed as strings are disallowed via `--disallowedTools`.

### `@haiku(prompt)`

Claude Haiku — fastest, most economical.

### `@sonnet(prompt)`

Claude Sonnet — balanced capability and speed.

### `@opus(prompt)`

Claude Opus — most capable model.

### `@claudePoll(prompt, config)`

Runs claude in the background and polls for a marker file. Works around `claude -p` process hang ([#20084](https://github.com/anthropics/claude-code/issues/20084)).

Extends `@claude` config with:
- `config.poll` — marker file path (required). Your prompt must instruct the agent to write this file.
- `config.timeout` — seconds before giving up (default: 3600)

Returns the marker file contents.

```mlld
var @result = @claudePoll("Analyze data and write results to /tmp/out.json", {
  model: "opus",
  dir: @base,
  tools: ["Read", "Write", "Glob"],
  poll: "/tmp/out.json"
})
```

### `@claudePollJsonl(prompt, config)`

Polls for a grep pattern in a JSONL file.

Extends `@claude` config with:
- `config.poll` — JSONL file path (required)
- `config.pattern` — grep pattern to match (required)
- `config.timeout` — seconds (default: 3600)

Returns the matching JSONL line.

```mlld
var @result = @claudePollJsonl("Process item and log to events.jsonl", {
  model: "opus",
  dir: @base,
  tools: ["Read", "Write"],
  poll: "/path/to/events.jsonl",
  pattern: "\"id\":\"m-24a0\".*\"status\":\"done\""
})
```

### `@claudePollEvent(prompt, config)`

Polls for a specific event type and item ID in a JSONL file.

Extends `@claude` config with:
- `config.poll` — JSONL file path (required)
- `config.event` — event type to match (required)
- `config.itemId` — item ID to match (required)
- `config.timeout` — seconds (default: 3600)

Returns the matching JSONL line.

```mlld
var @result = @claudePollEvent("Process ticket m-24a0", {
  model: "opus",
  dir: @base,
  tools: ["Read", "Write"],
  poll: "/path/to/events.jsonl",
  event: "item_done",
  itemId: "m-24a0"
})
```

### `@claudeStreamFormat`

NDJSON adapter config for Claude Code CLI streaming output. Use with `with { streamFormat: @claudeStreamFormat }` in custom exe definitions.

Handles event types: message, thinking, tool-use, tool-result, error, metadata.

## Migration from v2

v2 positional params → v3 config object:

```mlld
>> v2
var @r = @claude("Review code", "opus", @base, "Read,Grep")
var @r = @claudeWithSystem("Review", "Focus on security", "opus", @base, "Read")

>> v3
var @r = @claude("Review code", { model: "opus", dir: @base, tools: ["Read", "Grep"] })
var @r = @claude("Review", { model: "opus", dir: @base, tools: ["Read"], system: "Focus on security" })
```

`@claudeWithSystem` is removed — use `config.system` instead.

## License

CC0 - Public Domain
