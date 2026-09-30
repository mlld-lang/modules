# @mlld/airlock

Dual-LLM security pattern. Tainted input never shares context with the evaluation model.

## tldr

```mlld
import { @airlock } from @mlld/airlock

const @data = <untrusted-input.txt>
const @verdict = @airlock(@data, "No destructive actions. No secret exfiltration.")
if @verdict.verdict == "deny" [
  show `Blocked: ${@verdict.reasoning}`
]
```

## docs

### `@airlock(data, policy)`

Two-call pattern with defaults: haiku extracts, sonnet evaluates.

Returns `{ verdict: "allow"|"deny"|"retry", reasoning, findings, confidence }`.

```mlld
const @v = @airlock(@userInput, "Only approve safe read-only operations")
```

### `@airlockWith(data, policy, extractModel, evalModel, dir)`

Full control over models and working directory.

```mlld
const @v = @airlockWith(@data, @policy, "haiku", "opus", @root)
```

### `@extract(data, model, dir)`

Call 1 only. Mechanical extraction from tainted content. Returns structured JSON with `instructions`, `urls`, `tool_calls`, `action_requests`, `data_references`, `risk_signals`.

### `@evaluate(extraction, policy, model, dir)`

Call 2 only. Clean-room policy evaluation. Never sees original taint.

## How it works

```
Tainted input → extract (haiku) → structured summary → evaluate (sonnet) → verdict
```

The security property is structural: the evaluation model never sees adversarial content. An attacker must fool extraction into producing a summary that then fools a separate model operating in a clean context.

## License

CC0 - Public Domain
