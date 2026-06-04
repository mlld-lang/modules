# Quick Start Guide

## Installation

1. Install Ollama:
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

2. Pull your desired models:
```bash
ollama pull llama3.2
ollama pull qwen3-coder        # Latest Qwen 3 - Best for coding
ollama pull qwen2.5-coder      # Qwen 2.5 - Still excellent
ollama pull deepseek-coder     # Alternative coding model
```

3. Verify Ollama is running:
```bash
curl http://localhost:11434/api/tags
```

## Basic Usage

```mlld
import { @llama3_2, @qwen3Coder, @qwenCoder, @deepseekCoder } from @mlld/ollama

>> Simple query
var @answer = @llama3_2("Explain Docker in one sentence")
show @answer

>> Code generation with Qwen 3 (latest)
var @code = @qwen3Coder("Write a binary search function in Python")
show @code

>> Code generation with Qwen 2.5 (also excellent)
var @code2 = @qwenCoder("Write a quicksort in JavaScript")
show @code2

>> Code review with DeepSeek
var @review = @deepseekCoder("Review this: const x = 5;")
show @review
```

## Advanced Usage

### Custom Configuration

```mlld
import { @ollama } from @mlld/ollama

var @response = @ollama("Write a poem", {
  model: "mixtral",
  temperature: 1.2,
  topP: 0.9,
  numPredict: 200,
  system: "You are a creative poet"
})
```

### Streaming

```mlld
var @story = @ollama("Tell me a story", {
  model: "llama3.2",
  stream: true
})
```

### JSON Output

```mlld
var @data = @ollama("List 3 programming languages", {
  format: "json",
  system: "Return as JSON array"
})
```

## Troubleshooting

### Connection Refused
- Make sure Ollama is running: `ollama serve`
- Check the service: `curl http://localhost:11434/api/tags`

### Model Not Found
- Pull the model first: `ollama pull <model-name>`
- List available models: `ollama list`

### Slow Performance
- Use smaller models (phi3, mistral)
- Reduce `numPredict` to limit output length
- Check system resources (RAM, GPU)

## Model Recommendations

- **General queries**: llama3.2
- **Code generation** (best): qwen3-coder, qwen3-coder:32b
- **Code generation** (fast): qwen2.5-coder, deepseek-coder
- **Code review**: qwen3-coder:32b, qwen2.5-coder:32b
- **Code completion**: deepseek-coder (fastest)
- **Creative writing**: mixtral
- **Fast/efficient**: phi3, mistral
- **Reasoning**: mixtral, llama3.1
