# @mlld/decision-harness

Typed decisions from a model you pick in config. Ask a choice, score or yes/no question about some text and get a value your code can branch on, or sort text into one of your own keys with `@classify`. It has the same calls as [@mlld/jev](../jev/README.md), plus a `model` setting. jev is the only model supported so far.

## tldr

```mlld
import { @classify } from @mlld/decision-harness

const @team = @classify(@ticket, ["billing", "technical"], "Which team should handle this")

const @queue = match choice @team [
  "billing" => "billing"
  "technical" => "engineering"
  * => "human-review"
]
```

`@classify` returns one of your keys, or null when the model's answer is not one of them. Null lands in the `*` arm.

## setup

jev needs a TypeSafe API key, declared as a policy credential named `typesafe`. See [jev's setup section](../jev/README.md#setup); nothing else is needed here.

## choosing the model

Every call takes an optional `config` as its last argument. `config.model` picks the model:

| `config.model` | What is called |
|---|---|
| absent, or `"jev"` | jev, model `jev-latest` |
| any name starting `"jev"`, e.g. `"jev-preview"`, `"jev-1.13.0"` | jev, with that exact model name |
| anything else | nothing: the call fails with `decision-harness: unknown model '<name>' (supported: jev)` |

The rest of `config` goes to the model unchanged.

## docs

These work as they do in jev (see [jev's docs](../jev/README.md#docs)), with the model picked from `config.model`:

- `@ask(state, questions, config?)` and `@askFull(state, questions, config?)`
- `@askChoice`, `@askScore`, `@askNoul(state, instructions, criteria, config?)`
- `@flags(state, statements, config?)`
- `@models(config?)`: the model names the configured provider accepts
- `@choice`, `@score`, `@noul`: the question builders, re-exported from jev

### `@classify(text, keys, question, config?)`

Asks which of `keys` the `text` is. `keys` is an array of key names, or an object mapping each key to a description of what it covers:

```mlld
const @kind = @classify(@email, {
  refund: "Asks for money back",
  bug: "Reports something broken",
  other: "Anything else"
}, "What is this email about", { minConfidence: 0.7 })
```

- The answer is one of the keys, or null.
- An answer that is not one of the keys is asked once more; if it still is not, the result is null.
- With `config.minConfidence` set, an answer less confident than that is null.

## security

`@classify` is for routing, not for permission. Its result is the model's own answer, so it keeps the labels of the text it read (an `.untrusted` email gives an `.untrusted` key). Routed through `match choice`, the result is one of your own literals and also carries `.chosen`, as described in [jev's security section](../jev/README.md#security). Confidence only ever sends a call to the fallback; it never makes an answer more trusted.

Use the policy `@noVibeAuthority` where a model may pick a route but must never approve a destructive or data-sending operation: it refuses `.chosen` values there.

The text you pass is sent to the model's provider (TypeSafe, for jev). The same limits on sending secrets apply as for jev.

## license

CC0 - Public Domain
