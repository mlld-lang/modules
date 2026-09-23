# Conversation fixtures

Test data for `@conversation.ingest` and `@conversation.locate` (`../../conversation.test.mld` and `../../session.test.mld`).

## Native sessions and goldens

- `pi-<name>.jsonl` are pi session files, copied from fray (`github.com/adamavenir/fray`) at commit `9139f657e556bf3af800415672087eff3ec609da`, `internal/ift/testdata/`. They are hand-written in pi session format version 3, not captured from real sessions. `pi-openrouter`'s session id is `"fixture"`, not a UUID. `pi-basic` holds an entry of an unknown type (`something_new`), so its test prints one warning line to stderr.
- `pi-<name>.fray.jsonl` are the expected outputs: what fray's `IngestPi` writes for the matching session. They are copied from the mlld repo, `tests/fixtures/agent-sessions/`, at commit `9acbb81a60e553e503a6a7d104d76e577a008ee9` (branch `pod/2-2-0.checkpoint-resume.tape`). That directory's README says how they are regenerated.

Line 1 of a golden is the tape header, and each later line is one event.

## These are fray-shaped, not opgate-shaped

The goldens are fray's output unchanged. They differ from opgate's IFT format in four ways:

1. `session_id` appears only on the header line, not on each event.
2. The root event (`session_start`) has no `parent_id`, rather than a null one.
3. There is no `producer` field.
4. A failed tool call is `is_error: true` on the `tool_result` payload, not a separate `tool_failed` marker.

## Fake agent directory

`home/` stands in for `~/.pi/agent` in the `locate` tests: `home/sessions/--tmp-proj--/2026-09-10T00-22-39-649Z_<id>.jsonl` is one saved session. The tests pass both `home` and `home/sessions` as the root. The file holds the first line of `pi-basic.jsonl` and is never ingested.

## Fake project

`project/` stands in for a user's project in `../../session.test.mld`: `project/.llm/pi-sessions/2026-09-23T10-00-00-000Z_<id>.jsonl` is one session saved where `@pi` saves them. It holds only a header line and is never ingested.

## Environment note

The goldens' headers carry cwds under `/tmp/` and `/scrubbed`. `ingest` resolves symlinks in the cwd, as fray does, so if one of those directories exists on the test machine, macOS reports it as `/private/tmp/...` and the header check fails. Remove the directory; the port is not at fault.
