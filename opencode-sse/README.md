# @mlld/opencode-sse

Drive [opencode](https://opencode.ai) through `opencode serve` + Server-Sent Events instead of `opencode run`. Emits claude-shaped NDJSON so any code built against `@mlld/claude`'s stream format works unchanged.

## Why

The CLI path (`opencode run --format json`, used by `@mlld/opencode`) only emits tool events after the tool has already run — `status: "completed"` only, `tool_use` and `tool_result` fused into one event. `opencode serve` publishes the full bus over SSE including `status: "pending"` → `running` → `completed` transitions, so you see a real time gap between a tool call and its result (30ms on a trivial echo in local testing; proportionally more for real work).

The module is also smaller in intent: one `node {}` block drives the whole turn, replacing the 14-variant `when` block of shell templates in `@mlld/opencode`.

## Usage

```mlld
import { @opencode } from @mlld/opencode-sse

const @reply = @opencode("Summarize this doc", {
  model: "openrouter/z-ai/glm-5.1",
  system: "You are concise."
})

show @reply
```

Interface is the same as `@mlld/claude` and `@mlld/opencode`:

```mlld
>> model: provider/model; dir: working directory hint; system: prepended to the prompt
>> stream: live streaming; sessionId: track or resume a session; resume: resume another session
>> port: opencode serve port
const @result = @opencode(@prompt, {
  model: "anthropic/claude-sonnet-4-5",
  dir: @root,
  system: "...",
  stream: true,
  sessionId: "ses_abc...",
  resume: "ses_abc...",
  port: 4096
})
```

## Streaming

Pass `stream: true` and mlld's stream adapter consumes claude-shaped events:

```mlld
import { @opencode, @opencodeSseStreamFormat } from @mlld/opencode-sse

const @out = @opencode("Run ls then summarize", {
  model: "anthropic/claude-sonnet-4-5",
  stream: true
})
```

Event kinds emitted: `message`, `thinking`, `tool-use`, `tool-result`, `error`, `metadata`. Same surface as `@claudeStreamFormat` — any stream sink / adapter / logger wired against Claude works here.

**Timing note.** This module collects SSE frames internally and returns the accumulated NDJSON at turn end. Stream adapter events are emitted when the adapter parses that return value, which in the default `node {}` path happens after the turn completes rather than line-by-line during execution. The event *kinds* and *payloads* match Claude's live stream; the delivery is batched. For most pipelines (logging, state writes, post-hoc analysis) this is indistinguishable; for UIs that want per-token updates, a future version can move to the streaming subprocess path.

## Server lifecycle

On first use, the module tries `GET /session` on the configured port. If that fails, it spawns `opencode serve --port <port>` detached and waits for it to respond. The server persists across mlld invocations (it's detached); kill it manually when you're done:

```sh
pkill -f "opencode serve --port 4096"
```

Override the port via `config.port`, or export `OPENCODE_SSE_PORT`. Turn-level timeout via `OPENCODE_SSE_TIMEOUT_MS` (default 10 minutes).

## Session semantics

- `config.sessionId` — checks if the session exists on the server; reuses it if so, otherwise creates a new one.
- `config.resume` — same as `sessionId` for opencode. Present for interface parity with `@mlld/claude`.
- Returned value carries a hidden `_mlld` envelope with the live session id so guards and resume flows see it.

Opencode sessions persist on the server between turns; just reuse the same `sessionId` to continue a conversation.

## Tools (MCP bridge)

mlld-defined exes passed via `config.tools` are translated into opencode's `mcp` config and loaded into the server:

```mlld
exe @addNumbers(a, b) = js { return { sum: Number(a) + Number(b) }; }

const @reply = @opencode("Use addNumbers to compute 17 + 25.", {
  model: "openrouter/z-ai/glm-5.1",
  tools: [@addNumbers]
})
```

Under the hood: the claude-format `@mx.llm.config` is translated into opencode's top-level `mcp` block, written to a shadow `XDG_CONFIG_HOME/opencode/opencode.json`, and `opencode serve` is spawned with that env pointing at the shadow dir. Sibling files (auth, plugins) symlink through; only the config file is rewritten.

**Server-per-call with tools.** mlld's MCP tool bridge is call-scoped — each `llm` invocation generates a fresh socket and proxy. Because `opencode serve` reads its MCP config at startup, this module spawns a dedicated server per tool-using call. Side effects:

- Session continuity *does* work across tool-using calls (opencode's session DB lives outside `XDG_CONFIG_HOME`) if you thread `config.sessionId` explicitly.
- Orphaned `opencode serve` processes accumulate across runs. Clean up with `pkill -f "opencode serve --port"`.
- Non-tool calls (no `tools:` in config) share a single server on port 4096 and reuse it across runs.

A future mlld change making the tool bridge run-scoped would let multiple tool-using calls in one run share a server.

## Not supported in v1

- **Agent / variant / bypass flags.** These are CLI-level in opencode; not exposed through `/message`. Can be added if the server's API grows to accept them per-request.

## How it works

1. Ensure `opencode serve` is reachable on the configured port (ping `GET /session`; spawn detached if not).
2. Resolve the session: verify `config.sessionId` exists on the server, otherwise `POST /session` to create one.
3. Open `GET /event` SSE, filter frames by our `sessionID`.
4. `POST /session/<id>/message` with the prompt.
5. Translate incoming `message.part.updated` frames into claude-shaped NDJSON:
   - `part.type=text` (time.end present) → `{ type: "text", content }`
   - `part.type=reasoning` (time.end present) → `{ type: "thinking", text }`
   - `part.type=tool` with `state.status=pending` → `{ type: "tool_use", name, id, input }`
   - `part.type=tool` with `state.status=completed` → `{ type: "tool_result", tool_use_id, result }`
   - `part.type=tool` with `state.status=error` → `{ type: "tool_result", ..., is_error: true }`
6. Close SSE and return when `session.idle` arrives for our session.
7. Emit a final `{ type: "result", text, session_id, input_tokens, output_tokens, cost }` so non-stream callers can recover the aggregate.

The node block writes each translated event to its stdout as it arrives. mlld's stream adapter (`stream_format: @opencodeSseStreamFormat`) consumes the same stream live when `stream: true`.

## Requirements

- `opencode` CLI on `$PATH` (v1.4+).
- Node.js available to mlld's `node {}` runtime (built-in modules only; no npm deps).
- A network-free loopback connection to 127.0.0.1:<port>.

## Exports

- `@opencode(prompt, config)` — main exe.
- `@opencodeSseStreamFormat` — claude-shaped stream format for `with { stream_format: ... }`.
- `@opencodeSseSplitModel`, `@normalizeOpencodeSseSessionId`, `@opencodeSseResume`, `@opencodeSseResult`, `@parseOpencodeSseResult` — the helpers `@opencode` is built from, exported so they can be tested without a server.
