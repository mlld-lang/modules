# @mlld/opencode

Opencode CLI invocation with session resume, streaming, and MCP tool bridging.

## tldr

```mlld
import { @opencode } from @mlld/opencode

show @opencode("What is REST?")

var @review = @opencode("Review code in src/", {
  model: "anthropic/claude-sonnet-4-5",
  dir: @base,
  stream: true,
  bypass: true
})
```

## docs

### `@opencode(prompt, config)`

Runs `opencode run --format json` and returns the final agent message. Session id, text chunks, and token usage are parsed from opencode's NDJSON events in a single call regardless of streaming mode.

| Field | Type | Default | Purpose |
|---|---|---|---|
| `model` | string | `"openrouter/z-ai/glm-5.1"` | `provider/model` string (see `opencode models`). |
| `dir` | string | `@root` | Working directory, passed via `--dir`. |
| `system` | string | — | Prepended to the prompt. Opencode has no per-call system flag — agents carry their own prompts — so this is the only per-invocation hook. |
| `agent` | string | — | Opencode agent name (`--agent`). |
| `variant` | string | — | Reasoning variant: `minimal` \| `high` \| `max`. Maps to `--variant`. |
| `bypass` | boolean | — | Adds `--dangerously-skip-permissions`. Required whenever `tools` is set, and generally needed for any tool call in non-interactive runs. |
| `stream` | boolean | — | Stream chunks through `@opencodeStreamFormat`. The adapter also emits session id + token usage + cost metadata. |
| `sessionId` | string | — | Explicit conversation tracking id (`ses_...`). Case-sensitive. |
| `resume` | string | — | Explicit resume session id. Equivalent to `opencode run -s <id>`. |
| `tools` | array | — | Standard mlld `exe llm` tools convention. The runtime builds an MCP bridge at `@mx.llm.config`; this module translates it into opencode's `{ mcp: { name: { type: "local", command, environment } } }` config and exposes it via a shadow `XDG_CONFIG_HOME`. Opencode has no per-tool gating, so `@mx.llm.native` is informational only. |
| `mcpTimeoutMs` | number | — | Optional per-request timeout (ms) opencode applies to MCP tool calls. Maps to opencode's `experimental.mcp_timeout`. When omitted, opencode's built-in default applies. Only takes effect when an inline MCP config is emitted (i.e. when `tools` is set or the runtime has bridged tools). Set this only when you have a specific reason to override opencode's default — for example, when long tool calls indicate planner failure rather than legitimate slow work, a short value lets the planner LLM see failures faster and exit cleanly via a terminal call instead of consuming wall budget. |

```mlld
>> Simple call
var @answer = @opencode("Explain TCP/IP")

>> Anthropic via opencode
var @review = @opencode("Code review this PR", {
  model: "anthropic/claude-sonnet-4-5",
  dir: @base
})

>> High-reasoning variant
var @deep = @opencode("Trace this race condition", {
  model: "anthropic/claude-opus-4-5",
  variant: "high"
})

>> System prompt (prepended)
var @r = @opencode("What's your codename?", {
  system: "Your codename is Zephyr. Answer in one word."
})

>> Explicit resume
var @followup = @opencode("Keep going", { resume: "ses_28591e74fffey5oyFDw6nSuzpk" })

>> mlld tool bridging — requires bypass so tool calls aren't blocked on permissions
exe @getOrders() = js { return JSON.stringify([{ id: 1 }]); }

var @summary = @opencode("Call getOrders and summarise the results.", {
  tools: [@getOrders],
  bypass: true
})
```

### Session tracking and resume

`@opencode` returns a hidden `_mlld` envelope (`{ sessionId, provider: "opencode" }`) that the interpreter harvests. Two things fall out:

1. **Public API.** Pass `config.sessionId` to seed a known id, or `config.resume` to resume explicitly. Opencode session ids are case-sensitive (`ses_<base36>`) and preserved verbatim.
2. **Guard-driven resume.** When a guard retries, the runtime injects `config._mlld.resume = { sessionId, provider, continue }`. The module only honours it when `provider === "opencode"`, so a claude or codex session never leaks across providers.

### MCP bridge via shadow XDG_CONFIG_HOME

Opencode has no `--mcp-config` flag and no `-c key=val` config overrides on `run`, so per-invocation MCP injection uses the same shadow-dir trick as the codex module:

1. Translate mlld's generated `{ mcpServers: {...} }` JSON into opencode's `{ mcp: { name: { type: "local", command: [...], environment: {...} } } }` shape.
2. Create a temp dir and symlink every entry from `$XDG_CONFIG_HOME/opencode/` into `tmpdir/opencode/` **except** the config files (`config.json`, `opencode.json`, `opencode.jsonc`).
3. Merge the user's existing config + the generated `mcp` block into a single `tmpdir/opencode/opencode.json`.
4. The sh wrapper exports `XDG_CONFIG_HOME=<tmpdir>` for that invocation.

Opencode's data dir (`$XDG_DATA_HOME/opencode` — auth tokens, sessions, snapshots) is not rerouted, so auth and session history remain intact.

### `@opencodeStreamFormat`

NDJSON adapter for `opencode run --format json`. Use with `with { streamFormat: @opencodeStreamFormat }` in custom exe definitions.

Event types handled:
- `text` → `message` chunks (`part.text`)
- `step_start` → `metadata.sessionId`
- `step_finish` → `metadata.{inputTokens, outputTokens, totalTokens, cost}`

### `@conversation`: reading opencode sessions

Reads a stored opencode session and turns it into IFT events, the event format of mlld's run tape. It is an object of two functions, with the same signatures as `@conversation` in `@mlld/claude`, `@mlld/codex` and `@mlld/pi`:

```mlld
import { @conversation } from @mlld/opencode

var @path = @conversation.locate("ses_f32dadd9cffeySLGHspzO7cmgF", @base)
var @log = <@path>
var @tape = @conversation.ingest(@log.mx.text)
show @tape.events.length
```

The session id is the one `@opencode` returns (`ses_…`).

**`@conversation.locate(sessionId, cwd, root?, bin?)`** returns the absolute path of a JSON file holding the session, or `null`.

- opencode keeps sessions in a database, not in files. So `locate` runs `opencode export <sessionId>`, opencode's public way to get a session out, and writes what it prints to a new temp directory (`$TMPDIR/mlld-opencode-…/<sessionId>.json`). That file is a snapshot taken when `locate` ran. Outside mlld's fence it stays until something deletes it. Under the fence the temp directory is inside the run's own temp area, which mlld removes when the run ends, so ingest the file in the same run or copy it somewhere kept.
- `root` is the data directory the session ran under: pass the same value you gave `@opencode` as `config.dataHome`. It is set as `XDG_DATA_HOME` for the export only. Without it, opencode's default store is read.
- `cwd` is ignored. It is there so every harness's `locate` takes the same arguments. `bin` replaces the `opencode` binary; the tests use it.
- The id must match `ses_` followed by letters and digits, and it is case-sensitive. It returns `null`, never an error, for any other id, and when the export fails, times out (30 seconds), or prints something that is not this session.
- **mlld 2.2.0 fences the processes it starts**: they may write only inside the project and the temp directory. `opencode export` writes to opencode's database, so under the default fence `locate` works only for sessions whose data directory is inside the project or the temp directory: run `@opencode` with `config.dataHome` there and pass the same value as `root`. Sessions in opencode's default store return `null` unless the fence is off (`"fence": { "generic": "off" }` in `mlld-config.json`). opencode keeps its provider login (`auth.json`) in the data directory, so a fresh one has none, and `@opencode` runs there need a provider API key in the environment.

**`@conversation.ingest(text)`** returns `{ header, events }`.

- `text` is the JSON an `opencode export` printed, such as the contents of the file `locate` wrote. It reads no files. A file loaded with `<path>` must be passed as `.mx.text`, because mlld parses `.json` and `.jsonl` files when it loads them.
- `header` is `{ type: "session", session_id, harness: { name: "opencode", version }, cwd, started_at }`.
- `events` is the conversation as the model last saw it. After a compaction, the events start with the compaction summary and leave out everything before it. Each event has `id`, `parent_id` (absent on the first), `seq`, `ts`, `type`, `payload` and sometimes `usage`. Types are `session_start`, `message`, `assistant_turn`, `thinking`, `tool_call`, `tool_result` and `context_injection`.
- Messages opencode adds on its own (such as the "continue" message after a compaction) are `context_injection` events of kind `synthetic`.
- A failed tool shows: its `tool_result` has `is_error: true` and the error text as content. A provider error does not: opencode's export keeps only an empty assistant message, which produces no event. Only the `--format json` stream that `@opencode` reads carries the error.
- In `usage`, `output` includes reasoning tokens and `thinking` says how many of them were reasoning. opencode counts reasoning separately, so its `output` is lower than this one.
- opencode has no ingester in fray, so the mapping is this module's own; the tests' expected outputs are written by hand from it (`tests/fixtures/conversation/README.md`).
- It throws only when `text` is not a string or is not JSON. A part type it does not know prints one warning line to stderr and is skipped. A session with a pending revert prints a warning and is ingested in full.

**Treat an ingested conversation as untrusted input.** The export is a plain file, and nothing in it proves opencode produced it.

## Known limitations

- **No per-tool native gating.** Opencode exposes its built-in tools as-is. When `config.tools` is set, mlld bridges are added alongside them.
- **Shadow config dir leaks.** Each call with tools creates a temp `XDG_CONFIG_HOME/opencode/` symlink tree in `$TMPDIR`. They're tiny and `$TMPDIR` is periodically cleaned on macOS, but there's no explicit cleanup today.
- **Box VFS isolation is partial.** The runtime passes the mlld VFS bridge through, but opencode's native shell/edit tools still hit the real filesystem. Use claude if you need strict box isolation.

## License

CC0 - Public Domain
