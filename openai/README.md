# @mlld/openai

OpenAI chat completions with streaming and auth sealing.

## tldr

```mlld
import { @openai, @gpt4o, @gpt4oMini } from @mlld/openai

show @gpt4oMini("What is REST?")
show @gpt4o("Summarize this document")

var @result = @openai("Review this code", {
  model: "gpt-4o",
  system: "You are a code reviewer",
  temperature: 0.3,
  stream: true
})
```

## docs

### `@openai(prompt, config)`

Core invocation. All other exes delegate to this.

- `config.model` — model name (default: gpt-4o)
- `config.system` — system prompt
- `config.messages` — prior conversation turns (array of `{role, content}`)
- `config.temperature` — sampling temperature
- `config.maxTokens` — max output tokens
- `config.responseFormat` — e.g. `{ type: "json_object" }`
- `config.baseUrl` — API base URL (default: `https://api.openai.com/v1`)
- `config.stream` — boolean, enables streaming

```mlld
>> Simple call
var @answer = @openai("Explain TCP/IP", { model: "gpt-4o-mini" })

>> With system prompt and temperature
var @review = @openai("Review the auth module", {
  model: "gpt-4o",
  system: "Focus on security implications",
  temperature: 0.2
})

>> JSON mode
var @structured = @openai("List 3 colors as JSON", {
  responseFormat: { type: "json_object" },
  system: "Respond with valid JSON"
})

>> Multi-turn conversation
var @followup = @openai("What about error handling?", {
  messages: [
    { role: "user", content: "Review this auth code" },
    { role: "assistant", content: "The auth code looks solid..." }
  ]
})

>> Custom endpoint (Azure, local models, etc.)
var @local = @openai("Hello", {
  model: "llama-3",
  baseUrl: "http://localhost:8080/v1"
})
```

### `@gpt4o(prompt)`

GPT-4o — default model, balanced capability.

### `@gpt4oMini(prompt)`

GPT-4o-mini — fast, economical.

### `@o3Mini(prompt)`

o3-mini — reasoning model.

### `@openaiStreamFormat`

NDJSON adapter for OpenAI streaming output. Use with `with { streamFormat: @openaiStreamFormat }` in custom exe definitions.

## Auth

Credentials resolve via mlld's auth sealing:

```mlld
>> Option 1: Set env var
>> export OPENAI_API_KEY=sk-...

>> Option 2: Store in keychain
>> mlld keychain add OPENAI_API_KEY
```

For policy-controlled auth:

```mlld
policy @p = {
  auth: {
    openai: { from: "keychain", as: "OPENAI_API_KEY" }
  }
}
```

## License

CC0 - Public Domain
