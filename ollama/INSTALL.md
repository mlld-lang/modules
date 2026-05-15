# Installation Guide

## Prerequisites

### 1. Install Ollama

#### macOS
```bash
# Using the install script
curl -fsSL https://ollama.com/install.sh | sh

# Or download from https://ollama.com/download
```

#### Linux
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

#### Windows
Download the installer from https://ollama.com/download

### 2. Verify Ollama Installation

```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# Or check version
ollama --version
```

## Installing the Module

### Option 1: Direct Import (if published to registry)

```mlld
import { @ollama, @llama3_2 } from @mlld/ollama

# Module will be automatically downloaded
```

### Option 2: Local Development

If working from the repository:

```mlld
# Import from local modules directory
import { @ollama } from @mlld/ollama

# Use as normal
show @ollama("Hello!")
```

## Setting Up Models

### Pull Recommended Models

```bash
# Essential models
ollama pull llama3.2          # Latest Llama (4GB)
ollama pull codellama         # Code-specialized (3.8GB)

# Optional models
ollama pull mixtral           # Reasoning (26GB)
ollama pull phi3              # Small but capable (2.3GB)
ollama pull mistral           # Fast (4.1GB)
ollama pull llama3.1          # Previous gen (4.7GB)
```

### List Installed Models

```bash
ollama list
```

### Remove Models

```bash
ollama rm <model-name>
```

## Quick Test

### 1. Create a test script

```bash
cat > test-ollama.mld << 'EOF'
import { @llama3_2 } from @mlld/ollama

show "Testing Ollama module..."
var @result = @llama3_2("Say 'Hello from Ollama!' in exactly 5 words")
show @result
EOF
```

### 2. Run the test

```bash
mlld test-ollama.mld
```

Expected output:
```
Testing Ollama module...
Hello from Ollama today!
```

## Configuration

### Custom Ollama Endpoint

If running Ollama on a different host/port:

```mlld
import { @ollama } from @mlld/ollama

var @result = @ollama("Hello", {
  baseUrl: "http://192.168.1.100:11434"
})
```

### Environment Variables

None required! Unlike OpenAI/Claude, Ollama needs no API keys.

## Troubleshooting

### Issue: "Connection refused"

**Solution**: Start Ollama service
```bash
ollama serve
```

### Issue: "Model not found"

**Solution**: Pull the model first
```bash
ollama pull llama3.2
```

### Issue: "Out of memory"

**Solution**: Use smaller models
```bash
ollama pull phi3          # 2.3GB
ollama pull mistral       # 4.1GB
```

### Issue: Slow performance

**Solutions**:
- Use smaller models (phi3, mistral)
- Reduce output length with `numPredict`
- Check GPU availability: `ollama list`
- Close other resource-heavy applications

### Issue: Module not found

**Solution**: Check module path
```mlld
# Verify import path
import { @ollama } from @mlld/ollama

# Check mlld config
show @mx.config
```

## System Requirements

### Minimum
- **RAM**: 8GB
- **Storage**: 5GB per model
- **CPU**: Any modern CPU

### Recommended
- **RAM**: 16GB+
- **Storage**: 50GB for multiple models
- **GPU**: NVIDIA/AMD GPU (for faster inference)
- **CPU**: Multi-core processor

### Model Size Reference

| Model | Size | RAM Required |
|-------|------|--------------|
| phi3 | 2.3GB | 4GB |
| mistral | 4.1GB | 8GB |
| llama3.2 | 4GB | 8GB |
| codellama | 3.8GB | 8GB |
| llama3.1 | 4.7GB | 8GB |
| mixtral | 26GB | 32GB |

## GPU Support

Ollama automatically uses GPU if available:

### Check GPU Usage
```bash
# NVIDIA
nvidia-smi

# AMD
rocm-smi
```

### Force CPU
```bash
OLLAMA_COMPUTE=cpu ollama serve
```

## Next Steps

1. ✅ Install complete? Run the test script above
2. 📖 Read the [README.md](README.md) for full API docs
3. 🚀 Check [USAGE.md](USAGE.md) for common patterns
4. 🔍 See [COMPARISON.md](COMPARISON.md) for use cases

## Getting Help

- **Ollama docs**: https://ollama.com/docs
- **Module issues**: https://github.com/mlld-lang/modules/issues
- **mlld docs**: Check main mlld documentation

## Uninstallation

### Remove the module
```bash
# If installed via registry
mlld uninstall @mlld/ollama

# If using locally
rm -rf modules/ollama
```

### Remove Ollama
```bash
# Stop service
ollama stop

# Remove binary (macOS/Linux)
sudo rm /usr/local/bin/ollama

# Remove models
rm -rf ~/.ollama
```
