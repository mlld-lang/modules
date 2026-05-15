# Changelog

All notable changes to the @mlld/ollama module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-15

### Added
- Initial release of @mlld/ollama module
- Core `@ollama` function with full configuration support
- Streaming support with NDJSON format adapter
- Model shortcuts: `@llama3_2`, `@llama3_1`, `@mixtral`, `@codellama`, `@phi3`, `@mistral`
- Support for custom Ollama endpoints via `baseUrl`
- JSON output mode via `format: "json"`
- Multi-turn conversation support via `messages` array
- System prompt support
- Temperature and sampling controls (topK, topP, repeatPenalty)
- Token usage tracking (prompt_eval_count, eval_count)
- Comprehensive documentation (README, USAGE, COMPARISON)
- Working test examples

### Features
- No API key required (local execution)
- Privacy-first design (data never leaves local machine)
- Compatible with all Ollama models
- Consistent API with @mlld/openai and @mlld/claude modules
- Full streaming support
- Error handling

### Documentation
- Complete API reference in README.md
- Quick start guide in USAGE.md
- Provider comparison in COMPARISON.md
- Working examples in test-example.mld

### Technical
- mlld version requirement: >=2.1.0
- Ollama API version: v1
- License: CC0 (Public Domain)
- Module type: library
- Capabilities: network

## Future Enhancements

Potential features for future versions:
- Tool calling support (when Ollama adds native support)
- Vision model support (multimodal inputs)
- Embeddings generation
- Model management helpers (pull, list, delete)
- Performance monitoring and metrics
- Batch processing utilities
- Response caching
- Context window optimization
- Custom model loading from local files
