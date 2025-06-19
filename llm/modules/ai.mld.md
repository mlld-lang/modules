---
name: ai
author: mlld-dev
version: 1.0.0
about: LLM cli wrappers
needs: ["sh"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["llm", "ai", "openai", "anthropic", "claude", "codex"]
license: CC0
mlldVersion: "*"
---

# @mlld/ai

Simple wrappers for AI CLI tools (llm, claude, codex) to integrate language models into mlld workflows.

## tldr

Easy AI integration for your mlld scripts:

```mlld
@import { claude, llm, codex } from @mlld/ai

@text response = @claude.ask("What's the capital of France?")
@add [[Claude says: {{response}}]]

@text answer = @llm.ask("You are a helpful assistant", "Explain quantum computing in one sentence")
@add [[LLM says: {{answer}}]]
```

## docs

### Claude Integration

#### `claude.ask(prompt)`

Direct interface to Claude via the claude CLI tool.

```mlld
@text analysis = @claude.ask("Analyze this code for potential issues: function add(a,b) { return a + b }")
@add [[Code review: {{analysis}}]]
```

### LLM CLI Integration

#### `llm.ask(system, prompt)`

Basic LLM interaction with system prompt.

```mlld
@text haiku = @llm.ask("You are a poet", "Write a haiku about programming")
@add [[{{haiku}}]]
```

#### `llm.media(system, prompt, media_path)`

Include images or files in your prompts.

```mlld
@text description = @llm.media("You are an image analyst", "Describe this diagram", "architecture.png")
@add [[Analysis: {{description}}]]
```

#### `llm.tools(system, prompt, tools)`

Use LLM with tool capabilities.

```mlld
@text weather = @llm.tools("You can check weather", "What's the weather in NYC?", "weather")
@add [[{{weather}}]]
```

#### `llm.all(system, prompt, parameters)`

Full control over LLM parameters.

```mlld
@text creative = @llm.all("You are creative", "Write a story opening", "--temperature 0.9 --max-tokens 200")
@add [[{{creative}}]]
```

### Codex Integration

#### `codex.ask(prompt)`

Generate code with OpenAI Codex or similar.

```mlld
@text code = @codex.ask("Write a Python function to calculate fibonacci numbers")
@add [[Generated code:]]
@add [[{{code}}]]
```

#### `codex.media(prompt, media_path)`

Convert diagrams or images to code.

```mlld
@text implementation = @codex.media("Convert this flowchart to Python code", "algorithm.png")
@add [[{{implementation}}]]
```

## module

Wrappers for popular AI CLI tools:

```mlld-run
@exec claude_ask(prompt) = @run sh [(
  # Requires claude CLI tool installed
  claude-code "$prompt" 2>/dev/null || echo "Error: claude CLI not found. Install from https://github.com/anthropics/claude-code"
)]

@exec llm_ask(system, prompt) = @run sh [(
  # Requires llm CLI tool installed
  llm -s "$system" "$prompt" 2>/dev/null || echo "Error: llm CLI not found. Install with: pip install llm"
)]

@exec llm_media(system, prompt, media) = @run sh [(
  # LLM with media attachment
  if [ -f "$media" ]; then
    llm -s "$system" -a "$media" "$prompt" 2>/dev/null || echo "Error: llm CLI not found or media file missing"
  else
    echo "Error: Media file not found: $media"
  fi
)]

@exec llm_tools(system, prompt, tools) = @run sh [(
  # LLM with tools enabled
  llm -s "$system" --tools "$tools" "$prompt" 2>/dev/null || echo "Error: llm CLI not found or tools not available"
)]

@exec llm_all(system, prompt, parameters) = @run sh [(
  # LLM with custom parameters
  llm -s "$system" $parameters "$prompt" 2>/dev/null || echo "Error: llm CLI not found"
)]

@exec codex_ask(prompt) = @run sh [(
  # Requires codex or compatible CLI
  codex "$prompt" 2>/dev/null || llm -m gpt-4 "$prompt" 2>/dev/null || echo "Error: codex CLI not found. Using llm as fallback."
)]

@exec codex_media(prompt, media) = @run sh [(
  # Codex with media input
  if [ -f "$media" ]; then
    codex -a "$media" "$prompt" 2>/dev/null || llm -m gpt-4-vision -a "$media" "$prompt" 2>/dev/null || echo "Error: codex CLI not found or media file missing"
  else
    echo "Error: Media file not found: $media"
  fi
)]

@data claude = {
  ask: @claude_ask
}

@data llm = {
  ask: @llm_ask,
  media: @llm_media,
  tools: @llm_tools,
  all: @llm_all
}

@data codex = {
  ask: @codex_ask,
  media: @codex_media
}

@data module = {
  claude: @claude,
  llm: @llm,
  codex: @codex
}
```