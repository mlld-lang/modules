# @mlld/lms

Call a local LM Studio model from mlld over its REST API. Runs on-device, no API key. Supports temperature, token limits, JSON-schema structured output, conversation history, and token usage.

## tldr

```mlld
import { @lms } from @mlld/lms

show @lms("What is REST?")

>> Guaranteed structured output via JSON Schema
const @result = @lms("Classify: patient SSN 123-45-6789", {
  model: "google/gemma-4-26b-a4b",
  temperature: 0,
  schema: {
    type: "object",
    properties: { labels: { type: "array", items: { type: "string" } } },
    required: ["labels"]
  }
}) | @json
show @result.labels
```

Requires LM Studio's local server running (`lms server start`, default `http://localhost:1234`). The endpoint returns the model's final answer with reasoning split out, so there is no `<think>` block to strip.

## docs

### `@lms(prompt, config)`

Calls the OpenAI-compatible `/v1/chat/completions` endpoint and returns the assistant's message content. Pipe through `@json` when using `schema` / `responseFormat`.

| Field | Type | Default | Purpose |
|---|---|---|---|
| `model` | string | loaded model | Model id (`lms ls` to list) |
| `system` | string | — | System prompt |
| `messages` | array | — | Prior turns (`{role, content}`), inserted before the prompt |
| `temperature` | number | — | Sampling temperature (`0` for deterministic classification) |
| `maxTokens` | number | — | Max output tokens |
| `schema` | object | — | JSON Schema → guaranteed structured output |
| `schemaName` | string | `"response"` | Name for the schema |
| `responseFormat` | object | — | Raw `response_format` passthrough (overrides `schema`) |
| `ttl` | number | — | Seconds to keep the model loaded after the call |
| `baseUrl` | string | `http://localhost:1234/v1` | API base URL |
| `apiKey` | string | — | Bearer token, if the server requires auth |
| `full` | boolean | `false` | Return JSON `{ content, model, usage, finishReason }` instead of just content |

```mlld
>> Deterministic one-word classification
show @lms("Classify this doc's sensitivity", {
  model: "google/gemma-4-26b-a4b",
  temperature: 0,
  system: "Reply with one word: public, internal, or sensitive."
})

>> Inspect token usage and finish reason
const @meta = @lms("Summarize the changelog.", { full: true }) | @json
show `tokens: ${@meta.usage.total_tokens}, finish: ${@meta.finishReason}`

>> Multi-turn conversation
show @lms("And in one sentence?", {
  messages: [
    { role: "user", content: "Explain Rayleigh scattering." },
    { role: "assistant", content: "Shorter wavelengths scatter more in the atmosphere." }
  ]
})
```

Note: JSON-schema structured output is enforced by the server, but output quality still depends on the model — small quantized models can degenerate under a strict schema. Pin a capable model and `temperature: 0` for reliable classification.

For a no-server CLI alternative (`lms chat`), see the git history of `@mlld/lms-cli`.
