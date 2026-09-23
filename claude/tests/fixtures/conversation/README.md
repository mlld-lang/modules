# Conversation fixtures

Test data for `@conversation.ingest` and `@conversation.locate` (`../../conversation.test.mld`).

## Native logs and goldens

- `claude-<name>.jsonl` are Claude Code session logs, copied from fray (`github.com/adamavenir/fray`) at commit `9139f657e556bf3af800415672087eff3ec609da`, `internal/ift/testdata/`. They are hand-written, not captured from real sessions (their uuids are values like `u1` and `aaaa0001`), and their `version` fields span Claude Code 2.1.0 to 2.1.270. Most records carry 2.1.241.
- `claude-<name>.fray.jsonl` are the expected outputs: what fray's `IngestClaude` writes for the matching log. They are copied from the mlld repo, `tests/fixtures/agent-sessions/`, at commit `9acbb81a60e553e503a6a7d104d76e577a008ee9` (branch `pod/2-2-0.checkpoint-resume.tape`). That directory's README says how they are regenerated.

Line 1 of a golden is the tape header, and each later line is one event.

## These are fray-shaped, not opgate-shaped

The goldens are fray's output unchanged. They differ from opgate's IFT format in four ways:

1. `session_id` appears only on the header line, not on each event.
2. The root event (`session_start`) has no `parent_id`, rather than a null one.
3. There is no `producer` field.
4. A failed tool call is `is_error: true` on the `tool_result` payload, not a separate `tool_failed` marker.

No golden contains a failed tool call, so `is_error` is untested here.

## Fake Claude home

`home/` stands in for `~/.claude` in the `locate` tests: `home/projects/-work-fixture-proj/3f2a1b4c-0000-4000-8000-abcdef000001.jsonl` is the session for cwd `/work/fixture-proj`. Its contents are the first lines of `claude-basic.jsonl` and are never ingested.

## Environment note

The goldens' headers carry cwds `/tmp/fixture-proj` and `/tmp/proj`. `ingest` resolves symlinks in the cwd, as fray does, so if either directory exists on the test machine, macOS reports it as `/private/tmp/...` and the header check fails. Remove the directory; the port is not at fault.
