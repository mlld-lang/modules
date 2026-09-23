#!/bin/sh
# Stands in for `opencode export <id>` in the locate tests. The marker shows the
# test that it ran; only failed-tool's session is known.
: > "$XDG_DATA_HOME/ran"
if [ "$2" = "ses_f32dab56cffemtZGIZ407tXu7U" ]; then
  cat "$(dirname "$0")/failed-tool.export.json"
  exit 0
fi
exit 1
