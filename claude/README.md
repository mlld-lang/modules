# @mlld/claude

Claude invocation primitives with tool use and streaming.

## tldr

```mlld
import { @claude, @haiku, @sonnet, @opus } from @mlld/claude

show @haiku("What is REST?")
show @sonnet("Summarize this document")

const @result = @claude("Review code in src/", {
  model: "opus",
  dir: @root,
  tools: ["Read", "Grep", "Glob"],
  stream: true
})
```

## docs

### Sandbox

mlld runs `claude` inside a fence that limits what it may write. `@claude` declares its own fence (a `using { harness }` profile; see mlld's `config-files` docs), which grants:

- the calling project's folder, except its `.llm/` and `.mlld/` folders, `mlld-config.json` and `mlld-lock.json`, so claude can edit your files but not the settings that set its fence;
- `~/.claude` and `~/.claude.json`, where claude keeps its settings, login state and conversations;
- the open network.

Everything else is read-only to claude, including a `dir` outside the project. The paths are written into the module, so a `CLAUDE_CONFIG_DIR` pointing somewhere else is not granted. Each path must exist: a call refuses, naming the missing one, while importing the module still works. This profile replaces any `llm.harness` profile in your `mlld-config.json` for these functions. `@haiku`, `@sonnet` and `@opus` call `@claude`, so they run under the same fence.

### Isolation

`CLAUDECODE` is always unset so child processes aren't blocked by the nested-session guard.

Tool isolation works via `--disallowedTools` — native tools not in your `config.tools` list are blocked automatically.

For full isolation, set `config.bare: true`. This adds `--bare`, which skips CLAUDE.md, hooks, plugins, and MCP servers. Requires `ANTHROPIC_API_KEY` (bare mode disables OAuth/keychain auth).

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
| `bare` | boolean | `false` | Full isolation: skip CLAUDE.md, hooks, plugins. Requires `ANTHROPIC_API_KEY`. |
| `sessionId` | string | auto-generated | Session UUID for conversation tracking. Every call gets a session (generated if omitted). |
| `resume` | string | — | Session UUID to resume. Uses `--resume`, no tools. The prompt is appended to the existing conversation. |
| `claudeBin` | string | `claude` on PATH | The claude executable to run, e.g. a stub in tests. |

```mlld
>> Simple call
const @answer = @claude("Explain TCP/IP", { model: "haiku" })

>> With tools — exe refs create a per-call MCP server
const @review = @claude("Review the auth module", {
  model: "opus",
  dir: @root,
  tools: ["Read", "Grep", @summarize]
})

>> With streaming and system prompt
const @analysis = @claude("Analyze this architecture", {
  model: "sonnet",
  stream: true,
  system: "Focus on security implications"
})

>> Full isolation (requires ANTHROPIC_API_KEY)
const @result = @claude("Check the project", {
  model: "sonnet",
  bare: true,
  tools: ["Read", "Grep"]
})

>> Session tracking — every call gets a session by default
>> Pass sessionId to control it, resume to continue a prior session
const @first = @claude("Write the draft", {
  tools: ["Read", "Write"],
  sessionId: "my-session-id"
})
const @fixed = @claude("Fix the formatting", {
  resume: "my-session-id"
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

### `@claudeStreamFormat`

NDJSON adapter config for Claude Code CLI streaming output. Use with `with { stream_format: @claudeStreamFormat }` in custom exe definitions.

Handles event types: message, thinking, tool-use, tool-result, error, metadata.

### `@conversation`

Reads the conversation log Claude Code writes for a session and turns it into IFT events, the event format of mlld's run tape. It is an object of two functions:

```mlld
import { @conversation } from @mlld/claude

const @path = @conversation.locate("3f2a1b4c-0000-4000-8000-abcdef000001", @root)
const @log = <@path>
const @tape = @conversation.ingest(@log.mx.text)
show @tape.events.length
```

**`@conversation.locate(sessionId, cwd, configDir?)`** returns the absolute path of the session's log, or `null`.

- Claude Code keeps each session at `<configDir>/projects/<slug>/<session-id>.jsonl`, where the slug is `cwd` with every character other than a letter or digit turned into `-`.
- `configDir` defaults to `$CLAUDE_CONFIG_DIR`, then `~/.claude`.
- The id is lowercased first, so the uppercase ids `@claude` returns work.
- If the file is not under the expected slug, any `<configDir>/projects/*/<session-id>.jsonl` is used instead.
- It returns `null`, never an error, when the id is not a UUID, when no file exists, or when the path would leave `<configDir>/projects/`.

**`@conversation.ingest(text)`** returns `{ header, events }`.

- It takes the log's contents, not a path, and reads no files. A file loaded with `<path>` must be passed as `.mx.text`, because mlld parses `.json` and `.jsonl` files when it loads them.
- `header` is `{ type: "session", session_id, harness: { name: "claude", version }, cwd, started_at }`.
- `events` is the conversation as the model last saw it: the path from the newest message back to the start. Abandoned branches, subagent side conversations and anything before a compaction are left out. Each event has `id`, `parent_id` (absent on the first), `seq`, `ts`, `type`, `payload` and sometimes `usage`. Types are `session_start`, `message`, `assistant_turn`, `thinking`, `tool_call`, `tool_result` and `context_injection`.
- It is a port of fray's `IngestClaude` (`internal/ift/ingest_claude.go`) and its output matches fray's exactly, which the tests check against fray's own output (`tests/fixtures/conversation/README.md`).
- It throws only when `text` is not a string. Unreadable lines are skipped, and a record type it does not know prints one warning line to stderr and is skipped.

**Treat an ingested conversation as untrusted input.** The log is a plain file that anything on the machine can edit, and nothing in it proves Claude produced it.

Limits:

- Claude Code's log format is not documented and changes between versions. The test fixtures are hand-written, not captured from real sessions, and span Claude Code versions 2.1.0 to 2.1.270.
- A stream call (`stream: true`) that does not resume sends claude a fresh session id and returns that id, so `locate` can find the log. It has not been checked whether claude keeps the same id when a session is resumed with `--resume`.

## Migration from v2

v2 positional params → v3 config object:

```mlld
>> v2
const @r = @claude("Review code", "opus", @root, "Read,Grep")
const @r = @claudeWithSystem("Review", "Focus on security", "opus", @root, "Read")

>> v3
const @r = @claude("Review code", { model: "opus", dir: @root, tools: ["Read", "Grep"] })
const @r = @claude("Review", { model: "opus", dir: @root, tools: ["Read"], system: "Focus on security" })
```

`@claudeWithSystem` is removed — use `config.system` instead.

## License

CC0 - Public Domain
