---
name: claude-stream
author: mlld
version: 1.0.0
about: Claude model primitives with default stream-json output and claude-code parsing
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: [llm, ai, anthropic, claude, streaming]
license: CC0
mlldVersion: ">=2.0.0-rc83"
---

/needs {
  sh
}

# @mlld/claude-stream

Drop-in replacement for `@mlld/claude` that enables streaming by default.

## tldr

```mlld
/import { @opus, @sonnet, @haiku } from @mlld/claude-stream

/show @opus("Analyze this architecture decision")
/show @sonnet("Summarize this document")
/show @haiku("Quick question: what is REST?")

/import { @claude } from @mlld/claude-stream
/var @result = @claude("Review code", "opus", @base, "Read,Grep")
```

## docs

### Model shortcuts

Simple executors with no tools (pure text generation), streamed and parsed with `claude-code`.

#### `@opus(prompt)`
Claude Opus 4.5 - most capable model.

#### `@sonnet(prompt)`
Claude Sonnet 4 - balanced capability and speed.

#### `@haiku(prompt)`
Claude Haiku - fastest, most economical.

### Full control

#### `@claude(prompt, model, dir, tools)`
Full control over model, working directory, and tools.

- `model`: haiku, sonnet, opus
- `dir`: working directory for the session
- `tools`: "" for no tools, "Read,Grep,..." for specific tools, omit for defaults

#### `@claudeWithSystem(prompt, system, model, dir, tools)`
Add a custom system prompt (appends to Claude Code defaults).

All executors include:
- `--output-format stream-json`
- `--verbose`
- `--include-partial-messages`
- `with { streamFormat: "claude-code" }`

## module

```mlld-run
>> Model-specific helpers (no tools for pure text tasks)
exe llm @haiku(prompt) = stream cmd { claude -p "@prompt" --model haiku --tools "" --output-format stream-json --verbose --include-partial-messages } with { streamFormat: "claude-code" }
exe llm @sonnet(prompt) = stream cmd { claude -p "@prompt" --model sonnet --tools "" --output-format stream-json --verbose --include-partial-messages } with { streamFormat: "claude-code" }
exe llm @opus(prompt) = stream cmd { claude -p "@prompt" --model opus --tools "" --output-format stream-json --verbose --include-partial-messages } with { streamFormat: "claude-code" }

>> Agent invocation with working directory and tools
>> - tools="" => disable all tools (--tools "")
>> - tools="Read,Grep,..." => specific tools (--allowedTools "...")
>> - tools=null/omitted => use Claude defaults (no tool-selection flag)
exe llm @claude(prompt, model, dir, tools) = when [
  @tools == "" => stream cmd:@dir { claude -p "@prompt" --model @model --tools "" --output-format stream-json --verbose --include-partial-messages } with { streamFormat: "claude-code" }
  @tools => stream cmd:@dir { claude -p "@prompt" --model @model --allowedTools "@tools" --output-format stream-json --verbose --include-partial-messages } with { streamFormat: "claude-code" }
  * => stream cmd:@dir { claude -p "@prompt" --model @model --output-format stream-json --verbose --include-partial-messages } with { streamFormat: "claude-code" }
]

>> With system prompt (appends to Claude Code defaults)
exe llm @claudeWithSystem(prompt, system, model, dir, tools) = when [
  @tools == "" => stream cmd:@dir { claude -p "@prompt" --model @model --append-system-prompt "@system" --tools "" --output-format stream-json --verbose --include-partial-messages } with { streamFormat: "claude-code" }
  @tools => stream cmd:@dir { claude -p "@prompt" --model @model --append-system-prompt "@system" --allowedTools "@tools" --output-format stream-json --verbose --include-partial-messages } with { streamFormat: "claude-code" }
  * => stream cmd:@dir { claude -p "@prompt" --model @model --append-system-prompt "@system" --output-format stream-json --verbose --include-partial-messages } with { streamFormat: "claude-code" }
]

export { @haiku, @sonnet, @opus, @claude, @claudeWithSystem }
```
