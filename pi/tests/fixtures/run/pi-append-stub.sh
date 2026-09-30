#!/bin/sh
# Stands in for pi in run.test.mld's @pi test: appends a line to the file after
# --session, as pi does when it saves, and prints that file's path.
prev=""
for a in "$@"; do
  if [ "$prev" = "--session" ]; then
    printf '{"type":"message"}\n' >> "$a"
    printf 'appended=%s\n' "$a"
  fi
  prev="$a"
done
