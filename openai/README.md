# @mlld/openai

OpenAI chat completions with auth sealing.

## tldr

```mlld
import { @openai, @gpt4o, @gpt4oMini } from @mlld/openai

show @gpt4oMini("What is REST?")
show @gpt4o("Summarize this document")

const @result = @openai("Review this code", {
  model: "gpt-4o",
  system: "You are a code reviewer",
  temperature: 0.3
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
- `config.fnTools` — tool definitions for native function calling
- `config.fnToolChoice` — `"auto"`, `"required"`, `"none"`, or `{ type: "function", function: { name } }`
- `config.baseUrl` — API base URL (default: `https://api.openai.com/v1`)

Returns the reply text. When the model calls functions instead, it returns `{ type: "tool_calls", tool_calls: [{ function, args }] }` with `args` already parsed. A non-2xx status raises an error, which `try` catches.

Replies arrive whole: the request goes through mlld's `@http`, which reads a response only once it is complete, so there is no streaming. A `baseUrl` on your own machine or network (`localhost`, `192.168.…`) is refused unless `MLLD_URL_ALLOW_PRIVATE_HOSTS=1` is set in the environment; that setting applies to every request in the run.

```mlld
>> Simple call
const @answer = @openai("Explain TCP/IP", { model: "gpt-4o-mini" })

>> With system prompt and temperature
const @review = @openai("Review the auth module", {
  model: "gpt-4o",
  system: "Focus on security implications",
  temperature: 0.2
})

>> JSON mode
const @structured = @openai("List 3 colors as JSON", {
  responseFormat: { type: "json_object" },
  system: "Respond with valid JSON"
})

>> Multi-turn conversation
const @followup = @openai("What about error handling?", {
  messages: [
    { role: "user", content: "Review this auth code" },
    { role: "assistant", content: "The auth code looks solid..." }
  ]
})

>> Custom endpoint (Azure, local models, etc.)
const @selfHosted = @openai("Hello", {
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

## Auth

The key reaches the request through `using creds:openai` as an `Authorization: Bearer` header, never through the script text:

```mlld
>> Option 1: Set env var
>> export OPENAI_API_KEY=sk-...

>> Option 2: Store in keychain
>> mlld keychain add OPENAI_API_KEY
```

For policy-controlled auth:

```mlld
policy @keys = {
  * {
    credentials: {
      openai: { from: "keychain", as: "OPENAI_API_KEY" }
    }
  }
}
```

## License

CC0 - Public Domain
