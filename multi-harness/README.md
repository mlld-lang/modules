# @mlld/multi-harness

Run the same prompt on any coding-agent command-line tool — claude, codex, pi or opencode — by changing one setting, or let it use whichever one you have. `@agent` passes the call to [@mlld/claude](../claude/README.md), [@mlld/codex](../codex/README.md), [@mlld/pi](../pi/README.md) or [@mlld/opencode](../opencode/README.md), so each works exactly as it does on its own.

## tldr

```mlld
import { @agent } from @mlld/multi-harness

const @harness = "codex"
show @agent("Summarize the open issues in this repo", { harness: @harness, dir: "." })
```

Leave `harness` out and it runs on the first tool that is installed and signed in:

```mlld
import { @agent } from @mlld/multi-harness

show @agent("Summarize the open issues in this repo", { dir: "." })
```

## setup

Install at least one of the tools and sign in to it, as that tool's own module README describes. Nothing else is needed here.

## docs

### `@agent(prompt, config)`

Runs `prompt` on `config.harness`, which is one of `"auto"`, `"claude"`, `"codex"`, `"pi"` or `"opencode"`. Anything else fails with `multi-harness: unknown harness '<name>' (supported: auto, claude, codex, pi, opencode)`.

`"auto"`, or no `harness` at all, uses the first tool in the order claude, codex, pi, opencode that is ready, and prints which one to stderr, e.g. `multi-harness: auto picked codex (claude: not installed)`. Ready means the program is found and signed in; checking costs no model call:

| harness | signed in when |
|---|---|
| claude | `claude auth status --json` reports `"loggedIn": true` |
| codex | `codex login status` succeeds |
| pi | `pi auth check` reports `ready` for `config.provider`, or else for the `defaultProvider` in pi's `settings.json` |
| opencode | opencode's `auth.json` (under `config.dataHome`, else `$XDG_DATA_HOME` or `~/.local/share`) has a key for the provider in `config.model`, or `<PROVIDER>_API_KEY` is set |

When none is ready it fails with each reason, e.g. `multi-harness: no harness available (claude: not installed; codex: not signed in; pi: not signed in; opencode: not installed)`. Leave `model` out with auto, since model names differ per tool.

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
| opencode | `agent`, `variant`, `bypass`, `pure`, `dataHome`, `stateHome`, `mcpTimeoutMs`, `resume`, `opencodeBin` |

The `…Bin` keys name the program to run instead of the one on your `PATH`; the tests use them to run stand-in programs. Auto checks the same programs.

### `@pickHarness(config)`

The harness `@agent` would run for this `config`, without running it: `config.harness` as given, or the auto pick. Fails the same way `@agent` does when nothing is ready.

```mlld
import { @pickHarness } from @mlld/multi-harness

show @pickHarness({})   >> "codex", when claude is not installed and codex is signed in
```

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
