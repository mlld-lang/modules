# Pi Module

Invoke [Pi](https://github.com/badlogic/pi-mono/) coding agent with mlld tool integration.

## Setup

Install the MCP adapter (one-time setup):

```bash
pi install npm:pi-mcp-adapter
```

This enables Pi to load MCP servers from config files.

## Usage

```mlld
use { pi }

>> Basic invocation
@pi("Analyze the code in src/")

>> With custom model
@pi("Review code" with { model: "claude-sonnet" })

>> With mlld tools
exe @myCustomExe(input) = js {
  return `Processed: ${input}`;
}

@pi("Process data" with {
  tools: { 
    myTool: { 
      mlld: 'myCustomExe',
      description: "Process input data"
    }
  }
})

>> With pi built-in tools + mlld tools
@pi("Read and process" with {
  tools: { process: { mlld: 'processor' } },
  provider: "anthropic"
})

>> Model shortcuts
@haiku("Quick task")
@sonnet("Standard task")
@opus("Complex task")
```

## How Tools Work

When `config.tools` is provided, mlld creates an MCP bridge:

1. **mlld runtime** creates a socket server that implements the MCP protocol
2. **`@mx.llm.config`** points to a config file with the MCP server connection
3. **pi-mcp-adapter** loads the MCP servers from the config
4. **Tools are callable** via the MCP bridge

This is the same pattern as the Claude and Opencode modules.

## Tool Flags

| Config | Built-in Tools | MCP Tools |
|--------|----------------|-----------|
| `noTools: true` | None | None |
| `tools: {...}` | None | From config |
| `tools: {...}` + `native: "read,bash"` | read, bash | From config |
| No tools arg | All built-ins | None |

## Parameters

| Parameter | Description |
|-----------|-------------|
| `model` | Model pattern or provider/id (default: provider default) |
| `provider` | Provider name: google, anthropic, openai, etc. (default: google) |
| `dir` | Working directory (default: @root) |
| `system` | System prompt appended to default |
| `tools` | Tool collection or array of tool references |
| `noTools` | Boolean, disable all tools |
| `thinking` | Thinking level: off, minimal, low, medium, high, xhigh |
| `stream` | Boolean, enable streaming output |

## Available Built-in Tools

Pi's built-in tools: `read`, `bash`, `edit`, `write`, `grep`, `find`, `ls`

These can be selectively enabled via the native tools list.

## Exports

```mlld
@pi(prompt, config)       >> Main invocation
@haiku(prompt, config)    >> Claude Haiku
@sonnet(prompt, config)   >> Claude Sonnet  
@opus(prompt, config)     >> Claude Opus
@piStreamFormat           >> Stream format adapter
@isPiBuiltin(name)        >> Check if tool is built-in
@piToolAndMcpFlags(llm)  >> Build tool flags from @mx.llm
```

## Requirements

- Pi CLI installed: `npm install -g @mariozechner/pi`
- pi-mcp-adapter: `pi install npm:pi-mcp-adapter`
