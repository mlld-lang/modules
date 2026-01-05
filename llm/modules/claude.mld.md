---
name: claude
author: mlld
version: 2.0.0
about: Claude model primitives for prose execution and direct LLM invocation
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: [llm, ai, anthropic, claude, prose]
license: CC0
mlldVersion: ">=2.0.0-rc78"
---

/needs {
  sh
}

# @mlld/claude

Pure Claude invocation primitives. Simple executors for prose execution and direct LLM tasks.

## tldr

```mlld
/import { @opus, @sonnet, @haiku } from @mlld/claude

>> Simple prompts (no tools, pure text)
/show @opus("Analyze this architecture decision")
/show @sonnet("Summarize this document")
/show @haiku("Quick question: what is REST?")

>> Full control with @claude
/import { @claude } from @mlld/claude
/var @result = @claude("Review code", "opus", @base, "Read,Grep")
```

## docs

### Model shortcuts

Simple executors with no tools (pure text generation).

#### `@opus(prompt)`
Claude Opus 4.5 - most capable model.

```mlld
/show @opus("Complex reasoning task requiring sophistication")
```

#### `@sonnet(prompt)`
Claude Sonnet 4 - balanced capability and speed.

```mlld
/show @sonnet("Summarize this technical document")
```

#### `@haiku(prompt)`
Claude Haiku - fastest, most economical.

```mlld
/show @haiku("Quick factual question")
```

### Full control

#### `@claude(prompt, model, dir, tools)`
Full control over model, working directory, and tools.

- `model`: haiku, sonnet, opus
- `dir`: working directory for the session
- `tools`: "" for no tools, "Read,Grep,..." for specific tools, omit for defaults

```mlld
>> No tools (pure text)
/var @analysis = @claude("Analyze this", "opus", @base, "")

>> Specific tools
/var @review = @claude("Review code in src/", "sonnet", @base, "Read,Grep,Glob")

>> Default tools
/var @task = @claude("Help me refactor", "opus", @base)
```

#### `@claudeWithSystem(prompt, system, model, dir, tools)`
Add a custom system prompt (appends to Claude Code defaults).

```mlld
/var @result = @claudeWithSystem(
  "Review this PR",
  "Focus on security implications",
  "opus",
  @base,
  "Read,Grep"
)
```

## module

```mlld-run
>> Model-specific helpers (no tools for pure text tasks)
exe @haiku(prompt) = @prompt | cmd { claude -p --model haiku --tools "" }
exe @sonnet(prompt) = @prompt | cmd { claude -p --model sonnet --tools "" }
exe @opus(prompt) = @prompt | cmd { claude -p --model opus --tools "" }

>> Agent invocation with working directory and tools
>> - tools="" => disable all tools (--tools "")
>> - tools="Read,Grep,..." => specific tools (--allowedTools "...")
>> - tools=null/omitted => use Claude defaults (no flag)
exe @claude(prompt, model, dir, tools) = when first [
  @tools == "" => @prompt | cmd:@dir { claude -p --model @model --tools "" }
  @tools => @prompt | cmd:@dir { claude -p --model @model --allowedTools "@tools" }
  * => @prompt | cmd:@dir { claude -p --model @model }
]

>> With system prompt (appends to Claude Code defaults)
exe @claudeWithSystem(prompt, system, model, dir, tools) = when first [
  @tools == "" => @prompt | cmd:@dir { claude -p --model @model --append-system-prompt "@system" --tools "" }
  @tools => @prompt | cmd:@dir { claude -p --model @model --append-system-prompt "@system" --allowedTools "@tools" }
  * => @prompt | cmd:@dir { claude -p --model @model --append-system-prompt "@system" }
]

export { @haiku, @sonnet, @opus, @claude, @claudeWithSystem }
```
