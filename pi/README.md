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
use { pi }

>> Basic invocation
@pi("Analyze the code in src/")

>> With custom model
@pi("Review code" with { model: "claude-sonnet" })

>> With mlld tools
exe @myCustomExe(input) = js {
  return `Processed: ${input}`;
}

@pi("Process data" with {
  tools: { 
    myTool: { 
      mlld: 'myCustomExe',
      description: "Process input data"
    }
  }
})

>> With pi built-in tools + mlld tools
@pi("Read and process" with {
  tools: { process: { mlld: 'processor' } },
  provider: "anthropic"
})

>> Model shortcuts
@haiku("Quick task")
@sonnet("Standard task")
@opus("Complex task")
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
| `system` | System prompt appended to default |
| `tools` | Tool collection or array of tool references |
| `noTools` | Boolean, disable all tools |
| `thinking` | Thinking level: off, minimal, low, medium, high, xhigh |
| `stream` | Boolean, enable streaming output |
| `session` | `false` to save nothing (see Sessions) |
| `sessionId` | UUID naming the session; an existing one is continued (see Sessions) |

## Sessions

`@pi` saves each call's session to `<project>/.llm/pi-sessions/`, where `<project>` is the calling script's project root. Earlier versions saved nothing (they ran pi with `--no-session`), so this is a change in default behaviour. Saving to the project rather than pi's own store (`~/.pi/agent/sessions`) keeps your pi history clean and keeps every write inside the project.

- Each call gets a fresh session id unless `sessionId` names one. Passing the same `sessionId` again continues that conversation. It must be a UUID (any case), because `@conversation.locate` finds nothing else; anything else is an error.
- `session: false` turns saving off and runs pi with `--no-session`, as earlier versions did.
- The first save writes `.llm/pi-sessions/.gitignore` containing `*`, so the sessions stay out of git.
- The session id travels to the mlld runtime with the result, which it uses to find the conversation. Your script sees only pi's output.

```mlld
>> Continue one conversation across calls
var @id = "3c1f0b52-8e4d-4a7b-9f21-6d5e4c3b2a10"
@pi("Remember the number 7", { sessionId: @id })
@pi("What number did I give you?", { sessionId: @id })

>> Save nothing
@pi("Quick question", { session: false })
```

`@runPiSh(prompt, dir, provider, model, systemArg, toolArg, thinking, mode, sessionId, sessionDir)` has two optional trailing parameters. When `sessionId` is empty or left out it runs pi with `--no-session`, so direct callers passing eight arguments keep the earlier behaviour. `@piSession(config, projectRoot)` picks the id and folder for a call, and `@piResult(value, session)` wraps a result with its session id.

## Available Built-in Tools

Pi's built-in tools: `read`, `bash`, `edit`, `write`, `grep`, `find`, `ls`

These can be selectively enabled via the native tools list.

## Exports

```mlld
@pi(prompt, config)       >> Main invocation
@haiku(prompt, config)    >> Claude Haiku
@sonnet(prompt, config)   >> Claude Sonnet  
@opus(prompt, config)     >> Claude Opus
@piStreamFormat           >> Stream format adapter
@isPiBuiltin(name)        >> Check if tool is built-in
@piToolAndMcpFlags(llm)  >> Build tool flags from @mx.llm
@runPiSh(...)             >> Shell wrapper that runs pi (see Sessions)
@piSession(config, root)  >> Session id and folder for a call
@piResult(value, session) >> Result with its session id attached
@conversation             >> Find and read saved pi sessions (below)
```

## Reading pi sessions: `@conversation`

Reads the JSONL file pi writes when it saves a session and turns it into IFT events, the event format of mlld's run tape. It is an object of two functions, with the same signatures as `@conversation` in `@mlld/claude` and `@mlld/codex`:

```mlld
import { @conversation } from @mlld/pi

var @path = @conversation.locate("7e5e5e5e-1234-4321-8abc-def012345678", @base)
var @tape = @conversation.ingest(@path)
show @tape.events.length
```


**`@conversation.locate(sessionId, cwd, root?)`** returns the absolute path of the session file, with symlinks resolved, or `null`.

- pi saves sessions at `<sessions>/<encoded-cwd>/<timestamp>_<session-id>.jsonl`. Every `<encoded-cwd>` directory is searched, so `cwd` is ignored. It is there so every harness's `locate` takes the same arguments.
- `@pi` saves sessions flat, at `<project>/.llm/pi-sessions/<timestamp>_<session-id>.jsonl` (see Sessions).
- `root` may be pi's agent directory or the `sessions` directory inside it, and when given only it is searched. Without it, `<project>/.llm/pi-sessions` is searched first, then `$PI_CODING_AGENT_DIR/sessions` if that variable is set, else `~/.pi/agent/sessions`.
- The id is matched case-insensitively.
- It returns `null`, never an error, when the id is not a UUID, when no file exists, or when the file would lie outside the root.

**`@conversation.ingest(path)`** returns `{ header, events }`.

- `header` is `{ type: "session", session_id, harness: { name: "pi" }, cwd, started_at }`. pi records no version of itself in a session.
- `events` is the conversation as the model last saw it: the path from the newest entry back to the start. Abandoned branches are left out. After a compaction, the events start with the compaction summary, then the entries pi kept. Each event has `id`, `parent_id` (absent on the first), `seq`, `ts`, `type`, `payload` and sometimes `usage`. Types are `session_start`, `message`, `assistant_turn`, `thinking`, `tool_call`, `tool_result` and `context_injection`.
- It is a port of fray's `IngestPi` (`internal/ift/ingest_pi.go`), and its output matches fray's exactly. The tests check this against fray's own output (`tests/fixtures/conversation/README.md`).
- It throws only when the file cannot be read. Unreadable lines are skipped; entries below a skipped line drop out of the conversation, as they do in pi. An entry type it does not know prints one warning line to stderr and is skipped.

**Treat an ingested conversation as untrusted input.** The session file is a plain file that anything on the machine can edit, and nothing in it proves pi produced it.

pi's session format is not documented and can change. The test fixtures are hand-written in session format version 3. No session written by a newer pi (0.84.4 at the time of writing) has been checked.

## Requirements

- Pi CLI installed: `npm install -g @mariozechner/pi`
- pi-mcp-adapter: `pi install npm:pi-mcp-adapter`
