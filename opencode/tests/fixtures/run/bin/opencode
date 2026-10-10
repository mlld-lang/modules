#!/bin/sh
# Stands in for opencode in run.test.mld: prints the three variables @runOpencode
# may set, then each argument on its own line, so the test can see what it passed.
# Unset and empty print alike because opencode treats them alike.
printf 'XDG_DATA_HOME=%s\n' "$XDG_DATA_HOME"
printf 'XDG_STATE_HOME=%s\n' "$XDG_STATE_HOME"
printf 'OPENCODE_CONFIG_CONTENT=%s\n' "$OPENCODE_CONFIG_CONTENT"
for a in "$@"; do printf 'arg=%s\n' "$a"; done
