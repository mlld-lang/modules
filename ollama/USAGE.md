# Quick Start Guide

## Installation

1. Install Ollama:
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

2. Pull your desired models:
```bash
ollama pull llama3.2
ollama pull codellama
ollama pull mixtral
```

3. Verify Ollama is running:
```bash
curl http://localhost:11434/api/tags
```

## Basic Usage

```mlld
import { @llama3_2, @codellama } from @mlld/ollama

>> Simple query
var @answer = @llama3_2("Explain Docker in one sentence")
show @answer

>> Code-specific queries
var @review = @codellama("Review this: const x = 5;")
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
- **Code tasks**: codellama, deepseek-coder
- **Creative writing**: mixtral
- **Fast/efficient**: phi3, mistral
- **Reasoning**: mixtral, llama3.1
