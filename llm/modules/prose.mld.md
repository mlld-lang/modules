---
name: prose
author: mlld
version: 2.1.0
about: Pre-configured prose execution configs for OpenProse
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: [llm, ai, prose, openprose, orchestration]
license: CC0
mlldVersion: ">=2.0.0-rc78"
---

# @mlld/prose

Pre-configured execution configs for OpenProse. Use these with `prose:@config` syntax.

## tldr

```mlld
/import { @opus } from @mlld/prose

/exe @workflow(ctx) = prose:@opus {
  session "Analyze the requirements"
    input @ctx.docs

  session "Generate implementation plan"
    context: analysis
}

/run @workflow({ docs: <requirements.md> })
```

## docs

### Config shortcuts

Ready-to-use configs for prose execution. All use OpenProse (`skillName: "prose"`).

#### `@opus`
Claude Opus 4.5 config - required for OpenProse execution due to its complexity.

```mlld
/import { @opus } from @mlld/prose

/exe @analyze(data) = prose:@opus {
  session "Deep analysis of @data"
}
```

#### `@sonnet`
Claude Sonnet 4 config - may work for simpler prose programs.

```mlld
/import { @sonnet } from @mlld/prose

/exe @summarize(text) = prose:@sonnet {
  session "Summarize: @text"
}
```

#### `@haiku`
Claude Haiku config - for very simple prose programs only.

```mlld
/import { @haiku } from @mlld/prose

/exe @quick(prompt) = prose:@haiku {
  session "@prompt"
}
```

### Config structure

Configs are objects with these fields:

| Field | Type | Description |
|-------|------|-------------|
| `model` | executable | Model executor (e.g., `@opus` from `@mlld/claude`) |
| `skillName` | string | Interpreter skill (default: "prose" for OpenProse) |

### Creating custom configs

```mlld
/import { @opus } from @mlld/claude

/var @myConfig = {
  model: @opus,
  skillName: "prose"
}

/exe @workflow(ctx) = prose:@myConfig { session "Process @ctx" }
```

## examples

### Multi-session workflow

```mlld
/import { @opus } from @mlld/prose

/var @docs = <specs/*.md>
/var @code = <src/**/*.ts>

/exe @review(context) = prose:@opus {
  parallel:
    specs = session "Analyze specifications"
      input @context.docs
    impl = session "Review implementation"
      input @context.code

  session "Generate review report"
    context: { specs, impl }
}

/run @review({ docs: @docs, code: @code })
```

### Custom interpreter

```mlld
/import { @proseConfig } from @mlld/prose

>> Use a custom skill instead of OpenProse
/var @myDsl = {
  model: "claude-opus-4.5",
  skillName: "myDSL"
}

/exe @process(data) = prose:@myDsl {
  analyze @data
  transform result
}
```

## module

```mlld-run
>> Import @claude for configurable tool access
import { @claude } from @mlld/claude

>> Prose-specific executors (uses project/system Claude config for permissions)
exe @opusExe(prompt) = @claude(@prompt, "opus", @base)
exe @sonnetExe(prompt) = @claude(@prompt, "sonnet", @base)
exe @haikuExe(prompt) = @claude(@prompt, "haiku", @base)

>> Pre-configured prose execution configs
var @opus = {
  model: @opusExe,
  skillName: "prose"
}

var @sonnet = {
  model: @sonnetExe,
  skillName: "prose"
}

var @haiku = {
  model: @haikuExe,
  skillName: "prose"
}

export { @opus, @sonnet, @haiku }
```
