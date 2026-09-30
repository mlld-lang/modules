#!/bin/sh
# Stands in for pi in run.test.mld: prints the directory it ran in, then each
# argument on its own line, so the test can see what @runPiSh passed. The file
# after --append-system-prompt is printed as system=<its text>.
printf 'pwd=%s\n' "$PWD"
prev=""
for a in "$@"; do
  printf 'arg=%s\n' "$a"
  if [ "$prev" = "--append-system-prompt" ]; then printf 'system=%s\n' "$(cat "$a")"; fi
  prev="$a"
done
