# Conversation fixtures

Test data for `@conversation.ingest` and `@conversation.locate` (`../../conversation.test.mld`).

## Native rollouts and goldens

- `codex-<name>.jsonl` are codex rollout logs, copied from fray (`github.com/adamavenir/fray`) at commit `9139f657e556bf3af800415672087eff3ec609da`, `internal/ift/testdata/`. They are hand-written, not captured from real sessions. `codex-basic` and `codex-compacted` carry codex `cli_version` 0.139.0, and `codex-custom-tools` carries 0.153.4.
- `codex-<name>.fray.jsonl` are the expected outputs: what fray's `IngestCodex` writes for the matching rollout. They are copied from the mlld repo, `tests/fixtures/agent-sessions/`, at commit `9acbb81a60e553e503a6a7d104d76e577a008ee9` (branch `pod/2-2-0.checkpoint-resume.tape`). That directory's README says how they are regenerated.
- `codex-basic-truncated.jsonl` is `codex-basic.jsonl` with its last line (the final `function_call_output`) cut in half. Its expected output is the `codex-basic` golden's header and first 6 events.

Line 1 of a golden is the tape header, and each later line is one event.

## These are fray-shaped, not opgate-shaped

The goldens are fray's output unchanged. They differ from opgate's IFT format in four ways:

1. `session_id` appears only on the header line, not on each event.
2. The root event (`session_start`) has no `parent_id`, rather than a null one.
3. There is no `producer` field.
4. A failed tool call would be `is_error: true` on the `tool_result` payload, not a separate `tool_failed` marker.

Two codex quirks are frozen into them as well:

- **Zero timestamps.** fray appends `session_start`, the `base_instructions` injection and the `compaction` injection without a time, so they carry Go's zero time `0001-01-01T00:00:00Z` even when the source record has one. There are two per file.
- **No failure marking.** fray's codex ingester never sets `is_error`, so a failed codex tool call looks the same as a successful one.

## Fake sessions directory

`home/sessions/` stands in for `~/.codex/sessions` in the `locate` tests. It holds one dated rollout (`2026/09/13/rollout-2026-09-13T19-14-00-<id>.jsonl`) and one legacy file named `<id>.jsonl`. Their contents are the first line of `codex-basic.jsonl` and are never ingested.

## Environment note

The goldens' headers carry cwds under `/tmp/`. `ingest` resolves symlinks in the cwd, as fray does, so if one of those directories exists on the test machine, macOS reports it as `/private/tmp/...` and the header check fails. Remove the directory; the port is not at fault.
