# Conversation fixtures

Test data for `@conversation.ingest` and `@conversation.locate` (`../../conversation.test.mld`).

The `*.export.json` files and the capture notes below are copied from the mlld repo, `tests/fixtures/agent-sessions/opencode/`, at commit `4b8e8b3083` (branch `pod/2-2-0.checkpoint-resume.tape`), where they were captured under #m-f548. The `*.run.ndjson` stream captures are not copied: `ingest` reads only the export.

## Expected outputs

`<name>.opencode.jsonl` is what `ingest` must return for `<name>.export.json`. Line 1 is the header and each later line is one event, in the same shape as the fray goldens the other adapters test against. fray has no opencode ingester, so these were written by hand from the mapping in ticket #m-bdd3, before `ingest` was, and not produced by any tool. Only the hash ids and time strings were computed; strings such as tool output are copied from the export.

## Stub opencode

`opencode-stub.sh` stands in for `opencode export` in the `locate` tests. It writes a marker file `ran` into `$XDG_DATA_HOME` every time it runs, then prints `failed-tool.export.json` if asked for that session and exits 1 for any other.

## Capture

- opencode `0.0.0-dev-202605160127` (the `opencode` CLI on the capture machine, `~/.bun/bin/opencode`).
- Date: 2026-09-23.
- Every run: `opencode run --pure --format json -m <model> --title <title> "<prompt>"`, started in a scratch directory holding one file, `notes.txt`, with the two lines `alpha line` and `beta line`. Tools ran under opencode's default permissions (no `--dangerously-skip-permissions`).
- The scratch directory sat inside a git checkout of the mlld repo, and opencode took that checkout as its project root. So each message's `path.root` is the checkout and `path.cwd` is the scratch directory below it. The checkout's `AGENTS.md` and `CLAUDE.md` may have been loaded into the prompt (the first request was about 19k input tokens); the stored files do not show the system prompt, so this is unconfirmed.
- Account: the capture machine's existing opencode login, using its stored API-key credentials for the provider named per file (`opencode providers list` shows them as "Fireworks AI — api" and "Groq — api"). The login has no account name or label beyond that. No credentials appear in any file.
- opencode stores sessions in its sqlite database, so each session comes in two forms:
  - `*.run.ndjson` — the `--format json` event stream the run printed on stdout. This is what the mlld opencode module parses.
  - `*.export.json` — `opencode export <session id>` after the run: `{ info, messages: [{ info, parts }] }`, the stored session.

## Files

| file | model | command | covers |
|---|---|---|---|
| `basic-resumed.export.json` | `fireworks-ai/accounts/fireworks/models/gpt-oss-120b` | `opencode export ses_f32dadd9cffeySLGHspzO7cmgF` after two runs: `--title f548-basic "Use the read tool to read notes.txt in the current directory, then reply with its first line only."`, then `--thinking -s ses_f32dadd9cffeySLGHspzO7cmgF "Now read notes.txt again and reply with its second line only."` | the whole two-turn session; `reasoning` parts appear on both turns in the stored form |
| `failed-tool.export.json` | same | `--title f548-failed-tool "Use the read tool to read missing.txt in the current directory. If the read fails, reply with the single word FAILED and do not try anything else."` | a `read` tool call with `"status":"error"` (`File not found`), then a text reply |
| `compacted-overflow.export.json` | `groq/openai/gpt-oss-20b` | `--title f548-basic` and the basic prompt | an automatic compaction: the provider refused the request as too large (`ContextOverflowError`), opencode compacted (`compaction` part with `auto: true, overflow: true`), wrote a summary turn, and added a synthetic continue message |

## Edits made after capture

- Absolute paths: the checkout (opencode's project root) is replaced by `/workspace` and the scratch directory by `/workspace/scratch` (the session `path`, relative to the root, by `scratch`), so root and cwd keep their real relationship. A shortened checkout path the model wrote in one reasoning part (`failed-tool.export.json`) is replaced the same way.
- In the provider error, which only the `.run.ndjson` capture holds: the account's organisation id is `org_REDACTED` and the `cf-ray` header is `REDACTED`.
- `compacted-overflow.*` (both forms) is truncated. The provider's rate limit was below opencode's prompt size, so the run repeated the overflow-compact-retry cycle until it was stopped by hand (27 compactions). The run file keeps its first 6 events (the first error, the compaction summary step, the synthetic continue text, and the next error); the export keeps its first 6 messages (the same cycle). Nothing inside a kept event or message was changed apart from the scrubbing above.

## Not captured

A compaction triggered by a long conversation rather than by a provider refusal. It would take a session long enough to fill the model's context, which was not attempted within the 10-run cap.
