#!/bin/sh
# Stands in for claude in run.test.mld: prints the directory it ran in, each
# argument on its own line, then stdin, so the test can see what @claude passed.
# Asked for --output-format json, it wraps that text as claude's JSON result.
dump=$(printf 'pwd=%s\n' "$PWD"; for a in "$@"; do printf 'arg=%s\n' "$a"; done; printf 'stdin='; cat)
json=""
for a in "$@"; do [ "$prev" = "--output-format" ] && [ "$a" = "json" ] && json=1; prev="$a"; done
if [ -n "$json" ]; then
  printf '%s' "$dump" | python3 -c 'import json,sys; print(json.dumps({"type": "result", "result": sys.stdin.read(), "session_id": "5a0c3e1d-0000-4000-8000-00000000cafe"}))'
else
  printf '%s\n' "$dump"
fi
