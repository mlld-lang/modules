#!/bin/sh
# Stands in for pi in run.test.mld: prints the directory it ran in, then each
# argument on its own line, so the test can see what @runPiSh passed.
printf 'pwd=%s\n' "$PWD"
for a in "$@"; do printf 'arg=%s\n' "$a"; done
