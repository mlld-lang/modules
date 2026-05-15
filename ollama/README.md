# @mlld/ollama

Ollama chat completions with streaming support for local models.

## tldr

```mlld
import { @ollama, @llama3_2, @qwenCoder, @deepseekCoder } from @mlld/ollama

show @llama3_2("What is REST?")
show @qwenCoder("Write a Python function to sort a list")

var @result = @ollama("Review this code", {
  model: "qwen2.5-coder:32b",
  system: "You are a code reviewer",
  temperature: 0.3,
  stream: true
})
```

## docs

### `@ollama(prompt, config)`

Core invocation. All other exes delegate to this.

- `config.model` — model name (default: llama3.2)
- `config.system` — system prompt
- `config.messages` — prior conversation turns (array of `{role, content}`)
- `config.temperature` — sampling temperature (0.0 to 2.0)
- `config.numPredict` — max output tokens
- `config.topK` — top-k sampling
- `config.topP` — top-p (nucleus) sampling (0.0 to 1.0)
- `config.repeatPenalty` — repeat penalty (default: 1.1)
- `config.format` — set to `"json"` for structured JSON output
- `config.baseUrl` — API base URL (default: `http://localhost:11434`)
- `config.stream` — boolean, enables streaming

```mlld
>> Simple call
var @answer = @ollama("Explain TCP/IP", { model: "llama3.2" })

>> With system prompt and temperature
var @review = @ollama("Review the auth module", {
  model: "codellama",
  system: "Focus on security implications",
  temperature: 0.2
})

>> JSON mode
var @structured = @ollama("List 3 colors as JSON", {
  format: "json",
  system: "Respond with valid JSON"
})

>> Multi-turn conversation
var @followup = @ollama("What about error handling?", {
  messages: [
    { role: "user", content: "Review this auth code" },
    { role: "assistant", content: "The auth code looks solid..." }
  ]
})

>> Custom endpoint (remote Ollama server)
var @remote = @ollama("Hello", {
  model: "llama3.2",
  baseUrl: "http://192.168.1.100:11434"
})

>> Advanced sampling options
var @creative = @ollama("Write a creative story", {
  model: "mixtral",
  temperature: 1.2,
  topP: 0.9,
  topK: 40,
  repeatPenalty: 1.1,
  numPredict: 500
})
```

### General Purpose Models

### `@llama3_2(prompt)`

Llama 3.2 — latest model, good general capability.

### `@llama3_1(prompt)`

Llama 3.1 — previous generation, still capable.

### `@mixtral(prompt)`

Mixtral — Mixtral MoE model, good for reasoning.

### `@phi3(prompt)`

Phi-3 — Microsoft's small but capable model.

### `@mistral(prompt)`

Mistral — fast and efficient model.

### Code-Specialized Models

### `@codellama(prompt)`

CodeLlama — specialized for code generation and review.

### `@qwenCoder(prompt)`

Qwen2.5-Coder — Alibaba's latest coding model, excellent for code generation (default: 7B).

### `@qwenCoder32b(prompt)`

Qwen2.5-Coder 32B — larger variant, superior code understanding and generation.

### `@qwenCoder7b(prompt)`

Qwen2.5-Coder 7B — explicit 7B variant, fast and capable.

### `@deepseekCoder(prompt)`

DeepSeek-Coder — specialized for code completion and generation (default: 6.7B).

### `@deepseekCoder33b(prompt)`

DeepSeek-Coder 33B — larger variant, excellent for complex coding tasks.

### `@ollamaStreamFormat`

NDJSON adapter for Ollama streaming output. Use with `with { streamFormat: @ollamaStreamFormat }` in custom exe definitions.

## Setup

### Install Ollama

```bash
# macOS/Linux
curl -fsSL https://ollama.com/install.sh | sh

# Or download from https://ollama.com
```

### Pull Models

```bash
# General purpose models
ollama pull llama3.2
ollama pull mixtral
ollama pull phi3
ollama pull mistral

# Code-specialized models
ollama pull codellama
ollama pull qwen2.5-coder          # 7B default
ollama pull qwen2.5-coder:32b      # Larger variant
ollama pull deepseek-coder         # 6.7B default
ollama pull deepseek-coder:33b     # Larger variant
```

### Start Ollama

Ollama runs as a service by default on `http://localhost:11434`. To verify:

```bash
curl http://localhost:11434/api/tags
```

## Available Models

Popular models you can use with Ollama:

**General Purpose:**
- `llama3.2` — Latest Llama model (3B)
- `llama3.1` — Previous Llama generation (8B)
- `mixtral` — Mixtral 8x7B MoE
- `phi3` — Microsoft Phi-3 (3.8B)
- `mistral` — Mistral 7B
- `gemma2` — Google Gemma 2

**Code-Specialized:**
- `codellama` — Meta's CodeLlama (7B)
- `qwen2.5-coder` — Qwen 2.5 Coder (7B, 14B, 32B variants)
- `deepseek-coder` — DeepSeek Coder (1.3B, 6.7B, 33B variants)
- `codegemma` — Google's code-tuned Gemma

See full list at https://ollama.com/library

## Advantages

- **Local execution**: Run models on your own hardware
- **No API keys**: No authentication required
- **Privacy**: Data never leaves your machine
- **Cost**: Free to use, no token charges
- **Speed**: Low latency for local inference
- **Offline**: Works without internet connection

## License

CC0 - Public Domain
