# @mlld/multi-harness

Run the same prompt on any coding-agent command-line tool — claude, codex, pi or opencode — by changing one setting. `@agent` passes the call to [@mlld/claude](../claude/README.md), [@mlld/codex](../codex/README.md), [@mlld/pi](../pi/README.md) or [@mlld/opencode](../opencode/README.md), so each works exactly as it does on its own.

## tldr

```mlld
import { @agent } from @mlld/multi-harness

const @harness = "codex"
show @agent("Summarize the open issues in this repo", { harness: @harness, dir: "." })
```

## setup

Install the tool you pick and sign in to it, as that tool's own module README describes. Nothing else is needed here.

## docs

### `@agent(prompt, config)`

Runs `prompt` on `config.harness`, which is one of `"claude"`, `"codex"`, `"pi"` or `"opencode"`. Anything else fails with `multi-harness: unknown harness '<name>' (supported: claude, codex, pi, opencode)`.

The whole `config` goes to that tool's module unchanged. These keys mean the same thing on all four:

| key | meaning |
|---|---|
| `dir` | the folder the tool works in |
| `model` | the model name, in that tool's own naming |
| `system` | extra instructions added to the tool's own |
| `sessionId` | continue or name a conversation |
| `stream` | stream output as it arrives |
| `tools` | the tools the tool may use |

When `model` is left out, each tool uses its own default:

| harness | default model |
|---|---|
| claude | `sonnet` |
| codex | `gpt-5.4` |
| opencode | `openrouter/z-ai/glm-5.1` |
| pi | none: pi's own configured default |

Keys only one tool understands pass through and are ignored by the others:

| harness | its own keys |
|---|---|
| claude | `bare`, `resume`, `claudeBin` |
| codex | `sandbox`, `bypass`, `search`, `resume`, `codexBin` |
| pi | `provider`, `thinking`, `flags`, `noTools`, `session`, `piBin` |
| opencode | `agent`, `variant`, `bypass`, `pure`, `dataHome`, `stateHome`, `resume`, `opencodeBin` |

The `…Bin` keys name the program to run instead of the one on your `PATH`; the tests use them to run stand-in programs.

### `@conversation(harness)`

That tool's own `{ locate, ingest }`, which find and read the log a run left behind. Their arguments differ by tool (opencode's `locate` also takes the opencode program), so see the tool's own README.

```mlld
import { @conversation } from @mlld/multi-harness

const @codexLogs = @conversation("codex")
const @log = <./session.jsonl>
const @events = @codexLogs.ingest(@log.mx.text)
```

## license

CC0 - Public Domain
