# opencode-sse — Known gaps

Triaged by impact. Items in each section are rough-ordered by how much they'd hurt if left.

## Correctness blockers for production use

### 1. Orphaned `opencode serve` processes

Each mlld run that uses tools spawns a server and never cleans it up. Over time these accumulate.

**Fix.** Register a cleanup handler on the mlld process. The node `{}` block executes in mlld's VM, so `process.on('exit', ...)` fires when mlld exits. Track the pid we spawned and `process.kill(pid, 'SIGTERM')` on exit. Guard against registering the handler twice across multiple `@opencode` calls in one run.

Effort: ~15 lines in `index.mld`. Should land before this is used at any scale.

### 2. Concurrent `@opencode` calls race on spawn

If mlld runs two `@opencode(...)` calls in parallel (e.g. `foreach` or a fan-out pipeline), both may try to spawn on the same port. The second gets `EADDRINUSE` and dies.

**Fix.** Per-process lock around spawn. File lock at `/tmp/mlld-opencode-sse-<hash>.lock`, acquire before spawn, release after `waitForReady` returns. Concurrent callers on the second path either wait for the lock and then ping-and-reuse, or fail fast.

Effort: ~30 lines. Also worth wrapping `ensureServer` with a run-scoped memo so repeated calls in the same run don't re-check.

### 3. Server-unresponsive recovery

First call spawns and writes to the hash-derived port. Subsequent calls ping `/session` to reuse. If the server crashed without releasing the port (or is mid-restart), ping fails, we try to spawn on the same port, `EADDRINUSE`, we die.

**Fix.** On failed ping, check whether we own the port (pid from our lockfile, `kill -0` check). If ours and dead, remove lockfile and respawn. If not ours, fall back to a different port (increment hash-derived port until a free one is found, ping + respawn there).

Effort: ~20 lines. Requires (1) to also be in place so we actually have pids to check.

## Significant for the persistent planner use case

### 4. Tool bridge is call-scoped → multi-tool-call runs spawn multiple servers

The big one. Within one mlld run, two `@opencode(prompt, {tools: [...]})` calls land on different ports today, because the socket path in `@mx.llm.config` changes per call (`pid-nonce`). Correctness is fine (each call's server has the matching bridge live); efficiency isn't (spawn overhead per call); session continuity fragments into whatever the opencode DB can bridge.

**Fix.** Runtime change in mlld's `interpreter/env/executors/function-mcp-bridge.ts` to make socket paths run-scoped — key on `process.pid` alone (or a per-run UUID) rather than `pid-nonce`. Then the same shadow config hashes to the same port across every `exe llm` call in a run, and one server handles all turns.

This is a mlld runtime change, not a module change. Out of scope for this module but blocking for persistent-planner-with-tools.

### 5. Real-time streaming not wired

Current implementation accumulates all SSE frames in the node block and returns the NDJSON at turn end. The stream adapter parses that return value and emits events *after* the turn completes. For UIs that want per-token updates (live tool-use indicator, streaming text), this is too coarse.

**Fix options, in order of invasiveness.**

- **Option A.** Also write each event to `process.stdout` inside the node block. Works cleanly on the subprocess streaming path (`NodeExecutor.executeNodeSubprocessStreaming`), where stdout chunks emit `CHUNK` bus events in real time. Hostile on the in-process VM path, where stdout writes go straight to the user's terminal. Need to verify whether `with { stream: true, streamFormat: ... }` reliably forces the subprocess path; if yes, do this.
- **Option B.** Rewrite the core loop as a `sh {}` block that spawns `node -e '<...>'`. Subprocess by definition, streaming works. Downside: escaping hell for a 400-line script.
- **Option C.** Ship `opencode-client.mjs` as a bundled module file (see `spec-event-loop-modules.md`) and use `sh { node <bundled-path> }`. Clean code, real streaming, no escaping. Blocked on the bundled-assets spec landing.

Option A is the pragmatic near-term path if the subprocess detection works. Option C is the correct long-term answer.

### 6. `agent` / `variant` / `bypass` flags not plumbed

CLI-level today; `POST /session/{id}/message` may or may not accept them as body fields. `agent` likely matters for planner use (different agent personas per turn). `variant` matters for reasoning-effort control. `bypass` (`--dangerously-skip-permissions`) won't map directly — permissions in serve are session-scoped.

**Fix.** Probe opencode's `/message` request schema (source or OpenAPI once it's complete). Add passthrough fields where the API accepts them. For `bypass`, document the session-permission alternative instead.

Effort: depends on what the API accepts; probably under an hour once we know.

## Edge cases I didn't test

### 7. `session.error` handling

The event type exists in opencode's bus but I never triggered one during development. Provider failures, rate limits, context-length-exceeded, stream truncation mid-tool — none are tested. My current code likely hangs on the 10-min turn timeout rather than erroring cleanly.

**Fix.** Add a `session.error` case in `onEvent` that resolves the SSE subscription with an error marker. Translate into a claude-shape `{type: "error", message: ...}` event so downstream sees it.

### 8. Structured tool results

Translation assumes `state.output` is a string. Claude's `tool_result.result` accepts strings or structured content; opencode may serialize non-string outputs through `state.output` (stringified) or a different field.

**Fix.** Probe with a tool that returns an object. If `state.output` is already stringified, no change. If opencode uses a separate field for structured results, extract both.

### 9. Long turns near the 10-minute default timeout

`TURN_TIMEOUT_MS` defaults to 600000. For genuinely long turns (large refactors, deep reasoning), timeout fires, SSE is destroyed, POST is still pending — leaves a half-completed turn. Should either make the timeout configurable per call (`config.timeout`) or detect activity on SSE and reset the timeout on each frame (heartbeat-driven timeout rather than absolute).

### 10. Resume across separate mlld runs

Tested within one run; cross-run resume via opencode's shared DB is untested. Likely works for plain chat (session DB persists), but tool-bridged resume may fail — the original server is gone, the new server has a fresh MCP config with different socket paths, the session's recorded tool state may be dangling.

**Fix.** Explicit test case: run A captures a sessionId, run B with the same tools and that sessionId, verify it continues. If tool continuity breaks, document the limit.

## Nice-to-haves

### 11. Remote MCP servers (`spec.url`)

Translation handles the `url` case but it's untested end-to-end. Easy fix: test with any remote MCP server.

### 12. Attachments / file inputs to `POST /message`

The `parts` array in the message body likely supports file parts (analogous to `--file` on the CLI). Today we only send text parts.

### 13. `opencode` version pinning / check

Tested against 1.4.8. Future versions may change HTTP routes or SSE event shapes. A one-time version probe on first spawn and a warning on mismatch would catch API drift early.

### 14. Tests

No `.test.mld` cases, no fixtures, no CI verification. For a published `@mlld/opencode-sse` in the registry, this is expected. Minimal suite: plain turn, tool turn, session continuity, error path.

### 15. Server debug mode

`--log-level DEBUG --print-logs` isn't plumbed. When something breaks, no easy way to see what opencode saw. Add a `config.debug` flag that passes through.

## Priority summary

- **Half-day of work to make this production-usable:** 1, 2, 3.
- **Blocks persistent planner with tools:** 4 (mlld runtime change, bigger lift). 5 if you need live UI.
- **Ship when evidence demands:** 6–15.
