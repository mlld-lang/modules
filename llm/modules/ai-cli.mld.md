---
name: ai-cli
author: mlld
version: 1.0.0
about: LLM cli wrappers
needs: ["sh"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["llm", "ai", "openai", "anthropic", "google", "claude", "codex", "gemini", "cli"]
license: CC0
mlldVersion: "*"
---

# @mlld/ai-cli

Simple wrappers for AI CLI tools (llm, claude, codex, gemini) to integrate language models into mlld workflows.

## tldr

Easy AI integration for your mlld scripts:

```mlld
/import { claude, llm, codex, gemini } from @mlld/ai-cli

/var @response = @claude.ask("What's the capital of France?")
/show `Claude says: @response`

/var @answer = @llm.ask("You are a helpful assistant", "Explain quantum computing in one sentence")
/show `LLM says: @answer`
```

## docs

### Claude Integration

#### `claude.ask(prompt)`

Direct interface to Claude via the claude CLI tool.

```mlld
/var @analysis = @claude.ask("Analyze this code for potential issues: function add(a,b) { return a + b }")
/show `Code review: @analysis`
```

### LLM CLI Integration

#### `llm.ask(system, prompt)`

Basic LLM interaction with system prompt.

```mlld
/var @haiku = @llm.ask("You are a poet", "Write a haiku about programming")
/show @haiku
```

#### `llm.media(system, prompt, media_path)`

Include images or files in your prompts.

```mlld
/var @description = @llm.media("You are an image analyst", "Describe this diagram", "architecture.png")
/show `Analysis: @description`
```

#### `llm.tools(system, prompt, tools)`

Use LLM with tool capabilities.

```mlld
/var @weather = @llm.tools("You can check weather", "What's the weather in NYC?", "weather")
/show @weather
```

#### `llm.all(system, prompt, parameters)`

Full control over LLM parameters.

```mlld
/var @creative = @llm.all("You are creative", "Write a story opening", "--temperature 0.9 --max-tokens 200")
/show @creative
```

### Codex Integration

#### `codex.ask(prompt)`

Generate code with OpenAI Codex or similar.

```mlld
/var @code = @codex.ask("Write a Python function to calculate fibonacci numbers")
/show `Generated code:`
/show @code
```

#### `codex.media(prompt, media_path)`

Convert diagrams or images to code.

```mlld
/var @implementation = @codex.media("Convert this flowchart to Python code", "algorithm.png")
/show @implementation
```

### Gemini Integration

#### `gemini.ask(prompt)`

Direct interface to Google's Gemini via the gemini CLI tool.

```mlld
/var @analysis = @gemini.ask("Explain quantum computing in simple terms")
/show `Explanation: @analysis`
```

#### `gemini.media(prompt, media_path)`

Multimodal prompts with Gemini.

```mlld
/var @description = @gemini.media("What's happening in this image?", "photo.jpg")
/show @description
```

## module

Wrappers for popular AI CLI tools:

```mlld-run
/exe @claude_ask(@prompt) = sh {
  # Requires claude CLI tool installed
  if ! command -v claude >/dev/null 2>&1; then
    echo "Error: claude CLI not found. Install with: npm install -g @anthropic-ai/claude-code"
    exit 1
  fi
  
  result=$(claude -p "$prompt" 2>&1)
  exit_code=$?
  
  if [ $exit_code -eq 0 ]; then
    echo "$result"
  elif echo "$result" | grep -q "Invalid API key"; then
    echo "Error: Invalid Claude API key. Set ANTHROPIC_API_KEY environment variable."
  else
    echo "Error: $result"
  fi
}

/exe @llm_ask(@system, @prompt) = sh {
  # Requires llm CLI tool installed
  if ! command -v llm >/dev/null 2>&1; then
    echo "Error: llm CLI not found. Install with: pip install llm"
    exit 1
  fi
  
  result=$(llm "$system - $prompt" 2>&1)
  exit_code=$?
  
  if [ $exit_code -eq 0 ]; then
    echo "$result"
  elif echo "$result" | grep -q "No API key"; then
    echo "Error: No LLM API key found. Configure with: llm keys set openai"
  else
    echo "Error: $result"
  fi
}

/exe @llm_media(@system, @prompt, @media) = sh {
  # LLM with media attachment
  if [ -f "$media" ]; then
    llm -a "$media" "$system - $prompt" 2>/dev/null || echo "Error: llm CLI not found or media file missing"
  else
    echo "Error: Media file not found: $media"
  fi
}

/exe @llm_tools(@system, @prompt, @tools) = sh {
  # LLM with tools enabled
  llm --tools "$tools" "$system - $prompt" 2>/dev/null || echo "Error: llm CLI not found or tools not available"
}

/exe @llm_all(@system, @prompt, @parameters) = sh {
  # LLM with custom parameters
  llm $parameters "$system - $prompt" 2>/dev/null || echo "Error: llm CLI not found"
}

/exe @codex_ask(@prompt) = sh {
  # Requires codex or compatible CLI
  # Codex tries to do interactive auth, so we need to handle it carefully
  if command -v codex >/dev/null 2>&1; then
    # Check if API key is set to avoid interactive prompt
    if [ -n "$OPENAI_API_KEY" ]; then
      codex "$prompt" 2>/dev/null || echo "Error: Codex failed. Check your OPENAI_API_KEY."
    else
      echo "Error: OPENAI_API_KEY not set. Export OPENAI_API_KEY environment variable."
    fi
  elif command -v llm >/dev/null 2>&1; then
    llm -m gpt-4 "$prompt" 2>/dev/null || echo "Error: LLM fallback failed"
  else
    echo "Error: codex CLI not found. Install with: npm install -g @openai/codex"
  fi
}

/exe @codex_media(@prompt, @media) = sh {
  # Codex with media input
  if [ -f "$media" ]; then
    codex -a "$media" "$prompt" 2>/dev/null || llm -m gpt-4-vision -a "$media" "$prompt" 2>/dev/null || echo "Error: codex CLI not found or media file missing"
  else
    echo "Error: Media file not found: $media"
  fi
}

/exe @gemini_ask(@prompt) = sh {
  # Requires gemini CLI tool installed
  if ! command -v gemini >/dev/null 2>&1; then
    echo "Error: gemini CLI not found. Install with: npm install -g @google/gemini-cli"
    exit 1
  fi
  
  result=$(gemini -p "$prompt" 2>&1)
  exit_code=$?
  
  if [ $exit_code -eq 0 ]; then
    echo "$result"
  elif echo "$result" | grep -q "API key"; then
    echo "Error: Invalid Gemini API key. Set GOOGLE_API_KEY environment variable."
  else
    echo "Error: $result"
  fi
}

/exe @gemini_media(@prompt, @media) = sh {
  # Gemini with media input
  if [ -f "$media" ]; then
    gemini -a "$media" -p "$prompt" 2>/dev/null || echo "Error: gemini CLI not found or media file missing. Install with: npm install -g @google/gemini-cli"
  else
    echo "Error: Media file not found: $media"
  fi
}

/var @claude = {
  ask: @claude_ask
}

/var @llm = {
  ask: @llm_ask,
  media: @llm_media,
  tools: @llm_tools,
  all: @llm_all
}

/var @codex = {
  ask: @codex_ask,
  media: @codex_media
}

/var @gemini = {
  ask: @gemini_ask,
  media: @gemini_media
}
```
