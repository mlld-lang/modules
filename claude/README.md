# @mlld/claude

Claude invocation primitives with tool bridging, streaming, and polling.

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

### `@claude(prompt, config)`

Core invocation. All other exes delegate to this.

- `config.model` — haiku, sonnet, opus (default: sonnet)
- `config.dir` — working directory
- `config.tools` — mixed array: strings for built-in tools, exe refs for mlld functions
- `config.stream` — boolean, enables streaming
- `config.system` — appended system prompt

```mlld
>> Simple call
var @answer = @claude("Explain TCP/IP", { model: "haiku" })

>> With tools (in VFS box, tools route through VFS bridge)
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
```

Tool handling uses `@toolbridge` internally:
- In a VFS box with string tools: routes through VFS bridge (`--tools "" --mcp-config`)
- With exe ref tools: creates per-call MCP server for mlld functions
- Outside a box with string tools only: passes `--allowedTools`

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
