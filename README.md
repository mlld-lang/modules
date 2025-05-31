# mlld official modules

Official modules for the mlld prompt scripting language.

## Available Modules

### [@mlld/ai](./ai/) 
Simple wrappers for AI CLI tools (llm, claude, codex).

```mlld
@import { ai } from @mlld/ai
@run response = @ai.claude.ask("What's the weather like?")
```

### [@mlld/http](./http/)
Simple HTTP client wrappers for REST APIs and web requests.

```mlld
@import { http } from @mlld/http  
@run data = @http.get("https://api.example.com/data")
```
## Contributing

For community modules, see the [main registry](https://github.com/mlld-lang/registry).

To suggest improvements to these modules:
1. Open an issue in this repository
2. Submit a pull request with proposed changes

## Module Standards

Official modules follow these guidelines:
- Clean, consistent API design
- Comprehensive documentation with examples
- Minimal external dependencies

## License

MIT License - see [LICENSE](./LICENSE) file for details.
