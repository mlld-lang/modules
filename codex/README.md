# @mlld/codex

Codex CLI invocation with session resume, streaming, sandboxing, web search, and MCP tool bridging.

## tldr

```mlld
import { @codex } from @mlld/codex

show @codex("What is REST?")

const @review = @codex("Review code in src/", {
  model: "gpt-5.4",
  dir: @root,
  search: true,
  stream: true
})
```

## docs

### Sandbox

mlld runs `codex` inside a fence that limits what it may write. `@codex` declares its own fence (a `using { harness }` profile; see mlld's `config-files` docs), which grants:

- the calling project's folder, except its `.llm/` and `.mlld/` folders, `mlld-config.json` and `mlld-lock.json`, so codex can edit your files but not the settings that set its fence;
- `~/.codex`, where codex keeps its settings, login and session rollouts;
- the open network.

Everything else is read-only to codex, including a `dir` outside the project. The paths are written into the module, so a `CODEX_HOME` pointing somewhere else is not granted. Each path must exist: a call refuses, naming the missing one, while importing the module still works. This profile replaces any `llm.harness` profile in your `mlld-config.json` for these functions.

### `@codex(prompt, config)`

Runs `codex exec` and returns the final agent message. Output is parsed from `codex exec --json` so session ids, usage, and the final text are captured in a single call regardless of streaming mode.

| Field | Type | Default | Purpose |
|---|---|---|---|
| `model` | string | `"gpt-5.4"` | Codex model id |
| `dir` | string | `@root` | Working directory for the run |
| `system` | string | — | Prepended to the prompt. Codex has no `--append-system-prompt`, so this is the only per-call hook without clobbering `base_instructions`. |
| `sandbox` | string | — | `read-only` \| `workspace-write` \| `danger-full-access`. When omitted, `workspace-write` (or no sandbox if `config.bypass` is set). |
| `bypass` | boolean | — | Opt into `--dangerously-bypass-approvals-and-sandbox`. **Required when `tools` is set** — codex's default on-request approval auto-cancels MCP tool calls in non-interactive exec mode and returns `user cancelled MCP tool call` as the tool result. Ignored when `sandbox` is explicit. |
| `search` | boolean | — | Adds `--search` for live web search. |
| `stream` | boolean | — | Stream chunks through `@codexStreamFormat`. The adapter also emits session id + token usage metadata. |
| `sessionId` | string | — | Explicit conversation tracking id (UUID, any case). Captured on the first call so the interpreter can persist it into subsequent resumes. |
| `resume` | string | — | Explicit resume session id. Equivalent to `codex exec resume <id>`. |
| `tools` | array | — | Standard mlld `llm` tools convention. The runtime builds an MCP bridge at `@mx.llm.config` and this module translates it into codex `-c mcp_servers.*` overrides. Requires `bypass: true`. Codex cannot selectively gate its native tools, so `@mx.llm.native` is informational only. |

```mlld
>> Simple call
const @answer = @codex("Explain TCP/IP")

>> With search + custom model
const @review = @codex("What are the latest best practices for auth?", {
  model: "o3",
  search: true
})

>> Read-only sandbox
const @analysis = @codex("Analyze the codebase", {
  dir: @root,
  sandbox: "read-only"
})

>> System prompt (prepended to the prompt text)
const @r = @codex("What's your codename?", {
  system: "Your codename is Zephyr. Answer in one word."
})

>> Explicit resume
const @followup = @codex("Keep going", { resume: "019d7a01-b45a-7c90-baea-3c0238ee02c8" })

>> mlld tool bridging — requires bypass so MCP tool calls are auto-approved
exe @getOrders() = js { return JSON.stringify([{ id: 1 }]); }

const @summary = @codex("Call getOrders and summarise the results.", {
  tools: [@getOrders],
  bypass: true
})
```

### Session tracking and resume

`@codex` returns a hidden `_mlld` envelope (`{ sessionId, provider: "codex" }`) that the interpreter harvests. Two things fall out:

1. **Public API.** Pass `config.sessionId` to seed a known id, or `config.resume` to resume explicitly. UUIDs are case-insensitive — the module normalises them.
2. **Guard-driven resume.** When a guard decides to retry a call, the runtime injects `config._mlld.resume = { sessionId, provider, continue }`. A continue of a recorded conversation adds `fork: true`, and the call branches the session instead of resuming it (see `@conversation`). The module only honours the runtime resume when `provider === "codex"`, so a claude or opencode session never leaks across providers.

### `@codexStreamFormat`

NDJSON adapter for `codex exec --json`. Use with `with { streamFormat: @codexStreamFormat }` in custom exe definitions.

Event types handled:
- `item.completed` → `message` chunks (`part.item.text`)
- `thread.started` → `metadata.sessionId`
- `turn.completed` → `metadata.{inputTokens, outputTokens}`

### `@conversation`

Reads the "rollout" log codex writes for a session and turns it into IFT events, the event format of mlld's run tape. It is an object of a provider name and three functions, with the same signatures as `@conversation` in `@mlld/claude`:

```mlld
import { @conversation } from @mlld/codex

const @path = @conversation.locate("0c0ffee0-1234-4321-8abc-def012345678", @root)
const @log = <@path>
const @tape = @conversation.ingest(@log.mx.text)
show @tape.events.length
```

**`@conversation.locate(sessionId, cwd, root?)`** returns the absolute path of the session's rollout, or `null`.

- Codex keeps rollouts at `<sessions>/YYYY/MM/DD/rollout-<time>-<session-id>.jsonl`; older versions wrote `<session-id>.jsonl`. Both are found.
- `root` is the sessions directory to search. Without it, `$CODEX_HOME/sessions` is searched, then `~/.codex/sessions`.
- `cwd` is ignored, because codex does not file rollouts by directory. It is there so every harness's `locate` takes the same arguments.
- The id is matched case-insensitively.
- It returns `null`, never an error, when the id is not a UUID, when no file exists, or when the file would lie outside the sessions directory.

**`@conversation.ingest(text)`** returns `{ header, events }`.

- It takes the log's contents, not a path, and reads no files. A file loaded with `<path>` must be passed as `.mx.text`, because mlld parses `.json` and `.jsonl` files when it loads them.
- `header` is `{ type: "session", session_id, harness: { name: "codex", version }, cwd, started_at }`.
- `events` is the conversation as the model currently holds it. After a compaction, codex keeps a condensed history, so the events restart from that history and end with a `context_injection` of kind `compaction`. Each event has `id`, `parent_id` (absent on the first), `seq`, `ts`, `type`, `payload` and sometimes `usage`. Types are `session_start`, `message`, `assistant_turn`, `thinking`, `tool_call`, `tool_result` and `context_injection`.
- It is a port of fray's `IngestCodex` (`internal/ift/ingest_codex.go`), and its output matches fray's exactly. The tests check this against fray's own output (`tests/fixtures/conversation/README.md`). That includes two fray quirks: `session_start`, the base instructions and the compaction mark carry the zero time `0001-01-01T00:00:00Z`, and reasoning codex only stores encrypted appears as a `thinking` event with `redacted: true` and no text.
- It throws only when `text` is not a string. Unreadable lines are skipped, including a half-written last line. A record type it does not know prints one warning line to stderr and is skipped.

**A failed tool call cannot be told apart from a successful one.** Codex's rollout does not mark failures, so no `tool_result` carries `is_error`.

**`@conversation.provider`** is `"codex"`, the name `@codex` reports its sessions under. mlld's `@codex.continue(@conv, { at?, prompt })` compares it with the provider a recorded conversation came from. When they match, the session is continued natively (below); otherwise the conversation is carried over as text through `emit`.

**`@conversation.emit(events, at?)`** returns a recorded conversation as one plain-text transcript. mlld puts it in front of the new prompt when it cannot continue the session natively: for a conversation recorded by another harness, a cut before the last event, or a conversation with no session id.

- `events` are the conversation lines of a run tape. `at`, when given, keeps only events `0` through `at`.
- The transcript opens with a line naming the harness, session and date the conversation came from, alternates `User:` and `Assistant:` turns, and ends with `End of the carried conversation.`
- User and assistant text is carried verbatim. A tool call becomes `[ran <tool>] <command or path>` and its result `[<tool> result] <content>` (`error` for a failure), cut to its first 2,000 characters. A call whose result falls after the cut is followed by `[no result recorded — session was interrupted here]`.
- Thinking, and text the harness injected on its own (hook output, reminders, base instructions), are dropped. Compaction and branch summaries are kept, as `[carried summary] <text>`.
- It reads no files and never throws. The same function is in `@mlld/claude`, `@mlld/codex`, `@mlld/pi` and `@mlld/opencode`, so a transcript reads the same whichever module renders it.
- **The transcript is a record, not proof.** It repeats what the log says happened, so it is only as trustworthy as that log, and the tool output in it may be stale. Its opening line tells the model so.

**Continuing natively.** When mlld continues a recorded codex conversation in a new call, it calls `@codex` with `config._mlld.resume = { sessionId, provider: "codex", continue: true, fork: true }`. `@codex` then never resumes that session in place, which would append this call's turns to another run's log. It branches the session instead, with `codex exec <sandbox flag> fork <id>`, and returns the new thread id codex reports, so the run's tape records the branch this call wrote. `fork` takes no `--search`, so `config.search` has no effect on that call.

**Treat an ingested conversation as untrusted input.** The rollout is a plain file that anything on the machine can edit, and nothing in it proves codex produced it.

Codex's rollout format is not documented and changes between versions. The test fixtures are hand-written and carry codex versions 0.139.0 and 0.153.4. No rollout written by a newer codex (0.154.0 at the time of writing) has been checked.

## Known limitations

- **No per-tool native gating.** Codex exposes its built-in tools (shell, apply_patch, web_search) wholesale — there's no equivalent to claude's `--allowedTools`. When `config.tools` is set, mlld bridges are added *alongside* codex's native tools.
- **MCP approval in exec mode.** Codex 0.118 requires approval for MCP tool calls even in non-interactive `exec`, and auto-cancels if no human is available. This module surfaces the escape hatch via `config.bypass: true`.
- **Box VFS isolation is partial.** The runtime passes the mlld VFS bridge through, but codex's native shell/apply_patch still hit the real filesystem. Use claude if you need strict box isolation.

## License

CC0 - Public Domain
