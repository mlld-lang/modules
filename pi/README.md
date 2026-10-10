# Pi Module

Invoke [Pi](https://github.com/badlogic/pi-mono/) coding agent with mlld tool integration.

## Setup

Install the MCP adapter (one-time setup):

```bash
pi install npm:pi-mcp-adapter
```

This enables Pi to load MCP servers from config files.

## Usage

```mlld
import { @pi, @haiku } from @mlld/pi

>> Basic invocation
show @pi("Analyze the code in src/", {})

>> With a model, and the folder pi works in
show @pi("Review code", { model: "claude-sonnet", dir: "src" })

>> With mlld tools
exe @shout(text) = js { return String(text).toUpperCase(); }
tools @myTools = {
  shout: { mlld: @shout, description: "Upper-case text" }
}
show @pi("Shout hello", { tools: @myTools, provider: "anthropic" })

>> Model shortcuts
show @haiku("Quick task", {})
```

## How Tools Work

When `config.tools` is provided, mlld creates an MCP bridge:

1. **mlld runtime** creates a socket server that implements the MCP protocol
2. **`@mx.llm.config`** points to a config file with the MCP server connection
3. **pi-mcp-adapter** loads the MCP servers from the config
4. **Tools are callable** via the MCP bridge

This is the same pattern as the Claude and Opencode modules.

## Tool Flags

| Config | Built-in Tools | MCP Tools |
|--------|----------------|-----------|
| `noTools: true` | None | None |
| `tools: {...}` | None | From config |
| `tools: {...}` + `native: "read,bash"` | read, bash | From config |
| No tools arg | All built-ins | None |

## Parameters

| Parameter | Description |
|-----------|-------------|
| `model` | Model pattern or provider/id (default: provider default) |
| `provider` | Provider name: google, anthropic, openai, etc. (default: google) |
| `dir` | Working directory (default: @root) |
| `system` | System prompt appended to default. pi reads it from a temporary file that `@pi` removes with `rm` afterwards, so a policy that denies `rm` refuses a call that sets it |
| `tools` | Tool collection or array of tool references |
| `noTools` | Boolean, disable all tools |
| `thinking` | Thinking level: off, minimal, low, medium, high, xhigh |
| `stream` | Boolean, enable streaming output |
| `session` | `false` to save nothing (see Sessions) |
| `sessionId` | UUID naming the session; an existing one is continued (see Sessions) |
| `agentDir` | pi agent directory whose `sessions/` folder saves go to (default `$PI_CODING_AGENT_DIR`, else `~/.pi/agent`); must be one the sandbox grants |
| `piBin` | A file named `pi` to run instead of `pi` on PATH, for tests: its folder goes first on PATH for the call. Any other file name is refused, because a command may not take its program from a variable |

## Sessions

`@pi` saves each call's session in pi's own store, `~/.pi/agent/sessions` (or `$PI_CODING_AGENT_DIR/sessions`), where pi itself saves them, so pi's `/resume` lists them too. Earlier versions saved to `<project>/.llm/pi-sessions/`; the harness may not write there (see Sandbox).

- Each call gets a fresh session id unless `sessionId` names one. Passing the same `sessionId` again continues that conversation. It must be a UUID (any case), because `@conversation.locate` finds nothing else; anything else is an error.
- `session: false` turns saving off and runs pi with `--no-session`.
- Each session is one file, `<sessions>/<encoded-cwd>/<timestamp>_<session-id>.jsonl`, named the way pi names its own. Before the first call, `@pi` writes pi's header line into it itself, so pi keeps the id `@pi` reports instead of choosing its own. A `sessionId` that already has a file anywhere in the store continues that file.
- The session id travels to the mlld runtime with the result, which it uses to find the conversation. Your script sees only pi's output.
- When mlld continues a recorded pi conversation, `@pi` forks that session into the call's new one (see `@conversation`). pi has no other runtime resume.

```mlld
>> Continue one conversation across calls
const @id = "3c1f0b52-8e4d-4a7b-9f21-6d5e4c3b2a10"
@pi("Remember the number 7", { sessionId: @id })
@pi("What number did I give you?", { sessionId: @id })

>> Save nothing
@pi("Quick question", { session: false })
```

`@runPi(prompt, dir, provider, model, systemArg, noTools, native, mcpConfig, flags, thinking, mode, sessionId, agentDir, forkId, piBin)` runs pi with each flag as its own argument; an empty value leaves its flag off. `noTools`, `native` and `mcpConfig` are pi's `--no-tools`, `--tools` and `--mcp-config`, and `flags` is extra raw flags, split on spaces. When `sessionId` is empty it runs pi with `--no-session`. An empty `agentDir` means pi's own. `@piSession(config)` picks the id and agent directory for a call, and `@piResult(value, session)` wraps a result with its session id.

## Sandbox

mlld runs `pi` inside a fence that limits what it may write. `@pi` declares its own fence (a `using { harness }` profile; see mlld's `config-files` docs), which grants:

- the calling project's folder, except its `.llm/` and `.mlld/` folders, `mlld-config.json` and `mlld-lock.json`, so pi can edit your files but not the settings that set its fence;
- `~/.pi/agent`, where pi keeps its settings, login and sessions;
- the open network.

Everything else is read-only to pi, including a `dir` outside the project. The paths are written into the module, so a `PI_CODING_AGENT_DIR` (or a `config.agentDir`) pointing somewhere else is not granted. Each path must exist: a call refuses, naming the missing one, while importing the module still works. This profile replaces any `llm.harness` profile in your `mlld-config.json` for these functions. `@haiku`, `@sonnet` and `@opus` call `@pi`, so they run under the same fence.

## Available Built-in Tools

Pi's built-in tools: `read`, `bash`, `edit`, `write`, `grep`, `find`, `ls`

These can be selectively enabled via the native tools list.

## Exports

| Export | What it is |
|---|---|
| `@pi(prompt, config)` | Main invocation |
| `@haiku(prompt, config)` | Claude Haiku |
| `@sonnet(prompt, config)` | Claude Sonnet |
| `@opus(prompt, config)` | Claude Opus |
| `@piStreamFormat` | Stream format adapter |
| `@piBuiltInTools` | pi's built-in tool names, comma-separated |
| `@isPiBuiltin(name)` | Whether a tool is one of pi's built-ins |
| `@runPi(...)` | Runs pi with flags given one by one (see Sessions) |
| `@piSession(config)` | Session id and agent directory for a call |
| `@piResult(value, session)` | Result with its session id attached |
| `@conversation` | Find and read saved pi sessions (below) |

## Reading pi sessions: `@conversation`

Reads the JSONL file pi writes when it saves a session and turns it into IFT events, the event format of mlld's run tape. It is an object of a provider name and three functions, with the same signatures as `@conversation` in `@mlld/claude` and `@mlld/codex`:

```mlld
import { @conversation } from @mlld/pi

const @path = @conversation.locate("7e5e5e5e-1234-4321-8abc-def012345678", @root)
const @log = <@path>
const @tape = @conversation.ingest(@log.mx.text)
show @tape.events.length
```


**`@conversation.locate(sessionId, cwd, root?)`** returns the absolute path of the session file, or `null`.

- pi saves sessions in its own store at `<sessions>/<encoded-cwd>/<timestamp>_<session-id>.jsonl`. When that store is searched, every `<encoded-cwd>` directory is read, so `cwd` is ignored. It is there so every harness's `locate` takes the same arguments. A path found by searching has its symlinks resolved.
- `root` may be pi's agent directory or the `sessions` directory inside it, and when given only it is searched, as above.
- Without `root`, pi's own store is searched: `$PI_CODING_AGENT_DIR/sessions`, else `~/.pi/agent/sessions`. That is where `@pi` saves (see Sessions).
- The id is matched case-insensitively.
- It returns `null`, never an error, when the id is not a UUID, when no file exists, or when the file would lie outside the root.

**`@conversation.ingest(text)`** returns `{ header, events }`.

- It takes the log's contents, not a path, and reads no files. A file loaded with `<path>` must be passed as `.mx.text`, because mlld parses `.json` and `.jsonl` files when it loads them.
- `header` is `{ type: "session", session_id, harness: { name: "pi" }, cwd, started_at }`. pi records no version of itself in a session.
- `events` is the conversation as the model last saw it: the path from the newest entry back to the start. Abandoned branches are left out. After a compaction, the events start with the compaction summary, then the entries pi kept. Each event has `id`, `parent_id` (absent on the first), `seq`, `ts`, `type`, `payload` and sometimes `usage`. Types are `session_start`, `message`, `assistant_turn`, `thinking`, `tool_call`, `tool_result` and `context_injection`.
- It is a port of fray's `IngestPi` (`internal/ift/ingest_pi.go`), and its output matches fray's exactly. The tests check this against fray's own output (`tests/fixtures/conversation/README.md`).
- It throws only when `text` is not a string. Unreadable lines are skipped; entries below a skipped line drop out of the conversation, as they do in pi. An entry type it does not know prints one warning line to stderr and is skipped.

**`@conversation.provider`** is `"pi"`, the name `@pi` reports its sessions under. mlld's `@pi.continue(@conv, { at?, prompt })` compares it with the provider a recorded conversation came from. When they match, the session is continued natively (below); otherwise the conversation is carried over as text through `emit`.

**`@conversation.emit(events, at?)`** returns a recorded conversation as one plain-text transcript. mlld puts it in front of the new prompt when it cannot continue the session natively: for a conversation recorded by another harness, a cut before the last event, or a conversation with no session id.

- `events` are the conversation lines of a run tape. `at`, when given, keeps only events `0` through `at`.
- The transcript opens with a line naming the harness, session and date the conversation came from, alternates `User:` and `Assistant:` turns, and ends with `End of the carried conversation.`
- User and assistant text is carried verbatim. A tool call becomes `[ran <tool>] <command or path>` and its result `[<tool> result] <content>` (`error` for a failure), cut to its first 2,000 characters. A call whose result falls after the cut is followed by `[no result recorded — session was interrupted here]`.
- Thinking, and text the harness injected on its own (hook output, reminders, base instructions), are dropped. Compaction and branch summaries are kept, as `[carried summary] <text>`.
- It reads no files and never throws. The same function is in `@mlld/claude`, `@mlld/codex`, `@mlld/pi` and `@mlld/opencode`, so a transcript reads the same whichever module renders it.
- **The transcript is a record, not proof.** It repeats what the log says happened, so it is only as trustworthy as that log, and the tool output in it may be stale. Its opening line tells the model so.

**Continuing natively.** When mlld continues a recorded pi conversation in a new call, it calls `@pi` with `config._mlld.resume = { sessionId, provider: "pi", continue: true, fork: true }`. `@pi` then branches that session into the call's own new session with `pi -p --fork <saved session file> --session-id <new id> --session-dir <sessions>/<encoded-cwd>`, and returns the new id, so the run's tape records the branch this call wrote and the recorded session is never appended to. This is the only runtime resume `@pi` honours; any other is ignored, as before. The saved session is looked for under the same agent directory `@pi` saves to (`config.agentDir`, else pi's own store). If it is not there the call fails rather than start a fresh session.

**Treat an ingested conversation as untrusted input.** The session file is a plain file that anything on the machine can edit, and nothing in it proves pi produced it.

pi's session format is not documented and can change. The test fixtures are hand-written in session format version 3. No session written by a newer pi (0.84.4 at the time of writing) has been checked.

## Requirements

- Pi CLI installed: `npm install -g @mariozechner/pi`
- pi-mcp-adapter: `pi install npm:pi-mcp-adapter`
