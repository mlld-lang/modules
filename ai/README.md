# @mlld/ai

Simple wrappers for AI CLI tools (llm, claude, codex).

## Installation

```mlld
@import { ai } from @mlld/ai
```

## Usage

### Claude Code CLI

```mlld
@run response = @ai.claude.ask("What's the capital of France?")
@add [[Claude says: {{response}}]]
```

### LLM CLI (simonw/llm)

```mlld
>> Basic prompt
@run answer = @ai.llm.ask("You are a helpful assistant", "Explain quantum computing")

>> With media attachments
@run analysis = @ai.llm.media("You are an image analyst", "Describe this image", "screenshot.png")

>> With tools
@run result = @ai.llm.tools("You can use tools", "What's the weather in NYC?", "weather")

>> Full control over parameters
@run custom = @ai.llm.all("You are creative", "Write a haiku", "--temperature 0.9 --max-tokens 100")
```

### Codex (OpenAI)

```mlld
>> Text generation
@run code = @ai.codex.ask("Write a Python function to reverse a string")

>> With media
@run diagram_code = @ai.codex.media("Convert this diagram to code", "flowchart.png")
```

## Requirements

- [llm](https://github.com/simonw/llm) CLI tool
- [claude](https://github.com/anthropics/claude-code) CLI tool  
- [codex](https://github.com/openai/codex) CLI tool (or equivalent)

## API Reference

- `ai.llm.ask(system, prompt)` - Basic LLM call with system prompt
- `ai.llm.media(system, prompt, media)` - LLM with image/file attachments
- `ai.llm.tools(system, prompt, tools)` - LLM with tool usage
- `ai.llm.all(system, prompt, parameters)` - LLM with custom parameters
- `ai.claude.ask(prompt)` - Claude Code CLI call
- `ai.codex.ask(prompt)` - Codex text generation
- `ai.codex.media(prompt, media)` - Codex with media input