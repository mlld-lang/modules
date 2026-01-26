---
name: claude-poll
author: mlld
version: 1.0.0
about: Claude invocation with file-polling completion detection. Works around claude -p process hang by running in background and polling for a marker file.
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: [llm, ai, anthropic, claude, async, polling]
license: CC0
mlldVersion: ">=2.0.0-rc78"
---

/needs {
  sh
}

# @mlld/claude-poll

Claude invocation that detects completion by polling for an output file the agent writes, then kills the process. Works around a known issue where `claude -p` doesn't terminate after the agent session completes ([anthropics/claude-code#20084](https://github.com/anthropics/claude-code/issues/20084)).

## tldr

```mlld
/import { @claudePoll } from @mlld/claude-poll

>> Agent writes /tmp/result.json during its session
/var @output = @claudePoll(
  "Analyze data and write results to /tmp/result.json",
  "opus",
  @base,
  "Read,Write,Glob,Grep",
  "/tmp/result.json"
)
>> @output contains the contents of /tmp/result.json
```

## docs

### `@claudePoll(prompt, model, dir, tools, markerFile)`

Runs `claude -p` in the background and polls for `markerFile` to appear. Once detected, waits briefly for any final writes, kills the process, and returns the marker file contents.

- `prompt`: The prompt text (piped to claude stdin)
- `model`: Model name (haiku, sonnet, opus)
- `dir`: Working directory for the session
- `tools`: Comma-separated tool list (e.g., "Read,Write,Glob,Grep")
- `markerFile`: Absolute path to a file the agent will write as its final output

**Important**: Your prompt must instruct the agent to write the marker file. This function returns the contents of that file.

```mlld
/var @result = @claudePoll(
  "Research the topic and write findings to /tmp/findings.json",
  "sonnet",
  @base,
  "Read,Write,Glob,Grep",
  "/tmp/findings.json"
)
```

### `@claudePollTimeout(prompt, model, dir, tools, markerFile, timeout)`

Same as `@claudePoll` but with an explicit timeout in seconds. If the marker file doesn't appear within the timeout, the process is killed and an empty string is returned.

```mlld
>> Give up after 30 minutes
/var @result = @claudePollTimeout(
  "Analyze the codebase",
  "opus",
  @base,
  "Read,Write,Glob",
  "/tmp/analysis.json",
  1800
)
```

## module

```mlld-run
exe @claudePoll(prompt, model, dir, tools, markerFile) = sh {
  PROMPT_FILE=$(mktemp)
  printf '%s' "$prompt" > "$PROMPT_FILE"

  claude -p --model "$model" --allowedTools "$tools" < "$PROMPT_FILE" > /dev/null 2>&1 &
  CLAUDE_PID=$!

  while ! test -f "$markerFile"; do
    sleep 5
    if ! kill -0 $CLAUDE_PID 2>/dev/null; then
      break
    fi
  done

  sleep 15
  kill $CLAUDE_PID 2>/dev/null
  wait $CLAUDE_PID 2>/dev/null

  rm -f "$PROMPT_FILE"
  cat "$markerFile" 2>/dev/null
}

exe @claudePollTimeout(prompt, model, dir, tools, markerFile, timeout) = sh {
  PROMPT_FILE=$(mktemp)
  printf '%s' "$prompt" > "$PROMPT_FILE"

  claude -p --model "$model" --allowedTools "$tools" < "$PROMPT_FILE" > /dev/null 2>&1 &
  CLAUDE_PID=$!

  ELAPSED=0
  while ! test -f "$markerFile"; do
    sleep 5
    ELAPSED=$((ELAPSED + 5))
    if [ "$ELAPSED" -ge "$timeout" ]; then
      kill $CLAUDE_PID 2>/dev/null
      wait $CLAUDE_PID 2>/dev/null
      rm -f "$PROMPT_FILE"
      exit 0
    fi
    if ! kill -0 $CLAUDE_PID 2>/dev/null; then
      break
    fi
  done

  sleep 15
  kill $CLAUDE_PID 2>/dev/null
  wait $CLAUDE_PID 2>/dev/null

  rm -f "$PROMPT_FILE"
  cat "$markerFile" 2>/dev/null
}

export { @claudePoll, @claudePollTimeout }
```
