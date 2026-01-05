---
name: stream-claude-agent-sdk
author: mlld
version: 1.0.1
about: Streaming format adapter for Claude Agent SDK NDJSON output
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
license: CC0
mlldVersion: ">=2.0.0-rc78"
---

/needs {}

# @mlld/streaming/claude-agent-sdk

## tldr

Parses Claude Agent SDK CLI streaming output (NDJSON) into structured events.

```mlld
/import { claudeAgentSdkAdapter } from @mlld/stream-claude-agent-sdk
```

## docs

Works with: `claude -p "..." --output-format stream-json --verbose --include-partial-messages`

Provides schema definitions for parsing various Claude CLI streaming event types:
- Content block deltas (text chunks)
- Metadata/token usage
- Thinking blocks
- Tool use and tool results
- Error events
- Direct Anthropic API format (fallback)

## module

```mlld-run
var @claudeAgentSdkAdapter = {
  name: "claude-agent-sdk",
  format: "ndjson",
  schemas: [
    {
      kind: "message",
      matchPath: "event.type",
      matchValue: "content_block_delta",
      extract: {
        chunk: ["event.delta.text", "event.delta.partial_json"]
      },
      templates: {
        text: '@evt.chunk',
        ansi: '@evt.chunk'
      },
      visibility: "always"
    },

    {
      kind: "metadata",
      matchPath: "event.type",
      matchValue: "message_delta",
      extract: {
        inputTokens: "event.usage.input_tokens",
        outputTokens: "event.usage.output_tokens"
      },
      templates: {
        text: 'Tokens: @evt.inputTokens in / @evt.outputTokens out',
        ansi: '%dim%Tokens: @evt.inputTokens in / @evt.outputTokens out%reset%'
      },
      visibility: "optional"
    },

    {
      kind: "thinking",
      matchPath: "type",
      matchValue: "thinking",
      extract: {
        text: ["thinking", "content", "message"]
      },
      templates: {
        text: '@evt.text',
        ansi: '%dim%@evt.text%reset%'
      },
      visibility: "optional"
    },

    {
      kind: "message",
      matchPath: "type",
      matchValue: "text",
      extract: {
        chunk: ["text", "content", "delta.text"]
      },
      templates: {
        text: '@evt.chunk',
        ansi: '@evt.chunk'
      },
      visibility: "always"
    },

    {
      kind: "tool-use",
      matchPath: "type",
      matchValue: "tool_use",
      extract: {
        name: ["name", "tool_name"],
        input: ["input", "parameters"],
        id: ["id", "tool_use_id"]
      },
      templates: {
        text: '[@evt.name] @evt.input',
        ansi: '%cyan%[@evt.name]%reset% @evt.input'
      },
      visibility: "optional"
    },

    {
      kind: "tool-result",
      matchPath: "type",
      matchValue: "tool_result",
      extract: {
        result: ["content", "result", "output"],
        toolUseId: ["tool_use_id", "id"],
        success: "success",
        isError: "is_error"
      },
      templates: {
        text: '[@evt.toolUseId] @evt.result',
        ansi: '%green%[@evt.toolUseId]%reset% @evt.result'
      },
      visibility: "optional"
    },

    {
      kind: "error",
      matchPath: "type",
      matchValue: "error",
      extract: {
        message: ["message", "error.message", "error"],
        code: ["code", "error.code"]
      },
      templates: {
        text: 'Error: @evt.message',
        ansi: '%red%Error:%reset% @evt.message'
      },
      visibility: "always"
    },

    {
      kind: "metadata",
      matchPath: "type",
      matchValue: "result",
      extract: {
        inputTokens: ["usage.input_tokens", "input_tokens"],
        outputTokens: ["usage.output_tokens", "output_tokens"],
        model: "model"
      },
      templates: {
        text: 'Tokens: @evt.inputTokens in / @evt.outputTokens out',
        ansi: '%dim%Tokens: @evt.inputTokens in / @evt.outputTokens out%reset%'
      },
      visibility: "optional"
    },

    {
      kind: "message",
      matchPath: "type",
      matchValue: "content_block_delta",
      extract: {
        chunk: ["delta.text", "delta.partial_json"]
      },
      templates: {
        text: '@evt.chunk',
        ansi: '@evt.chunk'
      },
      visibility: "always"
    },

    {
      kind: "metadata",
      matchPath: "type",
      matchValue: "message_delta",
      extract: {
        stopReason: "delta.stop_reason",
        inputTokens: "usage.input_tokens",
        outputTokens: "usage.output_tokens"
      },
      visibility: "optional"
    }
  ]
}

export { @claudeAgentSdkAdapter }
```
