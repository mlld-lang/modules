---
name: ai-cli
author: mlld
version: 2.0.0
about: CLI wrappers for Claude Code, Codex, and Gemini with unified, ergonomic API
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: [llm, ai, openai, anthropic, google, claude, codex, gemini, cli]
license: CC0
mlldVersion: ">=2.0.0-rc78"
---

/needs {
  sh
}

# @mlld/ai-cli

Unified wrappers for AI CLI tools. Simple functions for common cases, all using stdin piping for reliability.

## tldr

```mlld
/import { @claude, @claudeJson, @codex, @gemini } from @mlld/ai-cli

/show @claude("What is 2+2?")
/show @codex("Write a Python fibonacci function")
/show @gemini("Explain quantum computing")

/var @result = @claudeJson("Analyze this code")
/show `Cost: $@result.total_cost_usd, Tokens: @result.usage.output_tokens`
```

## docs

### Claude Code

Requires: `npm install -g @anthropic-ai/claude-code`

All Claude functions use stdin piping for safety and reliability.

#### `claude(prompt)`
Basic query, returns plain text.

```mlld
/show @claude("Explain CORS in one sentence")
/var @answer = @claude("What is the capital of Spain?")
```

#### `claudeJson(prompt)`
Returns structured JSON with metadata (cost, tokens, duration, session_id).

```mlld
/var @result = @claudeJson("What is machine learning?")
/show `Answer: @result.result`
/show `Cost: $@result.total_cost_usd`
/show `Input tokens: @result.usage.input_tokens`
/show `Output tokens: @result.usage.output_tokens`
/show `Duration: @result.duration_ms ms`
```

#### `claudeModel(prompt, model)`
Use a specific Claude model.

```mlld
/show @claudeModel("Complex reasoning task", "claude-opus-4")
/show @claudeModel("Quick question", "claude-sonnet-4-5")
```

#### `claudeTools(prompt, tools)`
Restrict Claude to specific tools (comma-separated: Bash, Read, Write, Edit, Glob, Grep, etc).

```mlld
/show @claudeTools("List files in current directory", "Bash")
/show @claudeTools("Read the package.json file", "Read")
/show @claudeTools("Search for TODO comments", "Grep")
/show @claudeTools("Find and read config files", "Glob,Read")
```

### Codex

Requires: `npm install -g @openai/codex`

All Codex functions use stdin piping and automatically skip git repo checks.

#### `codex(prompt)`
Basic code generation and explanation.

```mlld
/show @codex("Write a Python function to calculate fibonacci numbers")
/var @code = @codex("Explain async/await in JavaScript")
```

#### `codexModel(prompt, model)`
Use a specific model (gpt-4, gpt-5-codex, etc).

```mlld
/show @codexModel("Refactor this code for clarity", "gpt-4")
```

#### `codexDir(prompt, dir)`
Run codex in a specific working directory.

```mlld
/show @codexDir("What files are in this project?", "/path/to/project")
/show @codexDir("Run the test suite", "./my-app")
```

### Gemini

Requires: `npm install -g @google/gemini-cli`

All Gemini functions use headless mode with stdin piping.

#### `gemini(prompt)`
Basic query via Gemini CLI.

```mlld
/show @gemini("Explain quantum computing in simple terms")
/var @answer = @gemini("What are the benefits of TypeScript?")
```

#### `geminiJson(prompt)`
Returns structured JSON output with metadata.

```mlld
/var @result = @geminiJson("Analyze this algorithm")
/show `Response: @result`
```

#### `geminiModel(prompt, model)`
Use a specific Gemini model (gemini-2.0-flash, etc).

```mlld
/show @geminiModel("Complex analysis task", "gemini-2.0-flash")
```

## examples

### Cost tracking across multiple queries

```mlld
/import { @claudeJson } from @mlld/ai-cli

/var @queries = [
  "What is REST?",
  "What is GraphQL?",
  "What is gRPC?"
]

/var @results = foreach @claudeJson(@queries)
/var @totalCost = js {
  return @results.reduce((sum, r) => sum + r.total_cost_usd, 0)
}

/show `Total cost: $@totalCost`
```

### Multi-tool code generation workflow

```mlld
/import { @claude, @codex } from @mlld/ai-cli

>> Get requirements from Claude
/var @spec = @claude("Describe the requirements for a URL shortener API")

>> Generate code with Codex
/var @code = @codex(`Write a Node.js URL shortener based on: @spec`)

>> Review with Claude (restricted to just reading)
/var @review = @claudeTools(`Review this code: @code`, "Read")

/show `Specification:`
/show @spec
/show `Generated code:`
/show @code
/show `Review:`
/show @review
```

## module

```mlld-run
>> Claude Code - stdin-based for reliability
/exe @claude(prompt) = run @prompt | { claude --print }

/exe @claudeJson(prompt) = run @prompt | { claude --print --output-format json } | @json

/exe @claudeModel(prompt, model) = run @prompt | { claude --print --model @model }

/exe @claudeTools(prompt, tools) = run @prompt | { claude --print --allowedTools @tools }

>> Codex - stdin-based, skip git checks for flexibility
/exe @codex(prompt) = run @prompt | { codex exec --skip-git-repo-check }

/exe @codexModel(prompt, model) = run @prompt | { codex exec --skip-git-repo-check --model @model }

/exe @codexDir(prompt, dir) = run @prompt | { codex exec --skip-git-repo-check --cd @dir }

>> Gemini - headless mode with stdin
/exe @gemini(prompt) = run @prompt | { gemini --prompt - }

/exe @geminiJson(prompt) = run @prompt | { gemini --prompt - --output-format json } | @json

/exe @geminiModel(prompt, model) = run @prompt | { gemini --prompt - --model @model }

/export {
  @claude, @claudeJson, @claudeModel, @claudeTools,
  @codex, @codexModel, @codexDir,
  @gemini, @geminiJson, @geminiModel
}
```
