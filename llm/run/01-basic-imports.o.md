# Basic Module Import Test

Testing that each core module can be imported successfully.

## Debug Info

## /Users/adam/dev/mlld/modules/llm/run/01-basic-imports.mld debug:

### Environment variables:

CLAUDECODE, CLAUDE*CODE_ENTRYPOINT, COLORTERM, COMMAND_MODE, COREPACK_ENABLE_AUTO_PIN, GHOSTTY_BIN_DIR, GHOSTTY_RESOURCES_DIR, GIT_EDITOR, HOME, LANG, LOGNAME, NVM_DIR, OLDPWD, OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE, PWD, SHELL, SHLVL, SSH_AUTH_SOCK, STARSHIP_SESSION_KEY, STARSHIP_SHELL, TERM, TERMINFO, TERM_PROGRAM, TERM_PROGRAM_VERSION, TMPDIR, USER, XDG_DATA_DIRS, XPC_FLAGS, XPC_SERVICE_NAME, **CFBundleIdentifier, **CF_USER_TEXT_ENCODING
*(not available unless passed via @INPUT)\_

### Global variables:

**@TIME**

- type: simple-text
- value: "2025-06-27T01:35:03.478Z"

**@PROJECTPATH**

- type: path
- value: /Users/adam/dev/mlld/modules

### User variables:

**@XML**

- type: executable
- value: [object Object]

**@xml**

- type: executable
- value: [object Object]

**@JSON**

- type: executable
- value: [object Object]

**@json**

- type: executable
- value: [object Object]

**@CSV**

- type: executable
- value: [object Object]

**@csv**

- type: executable
- value: [object Object]

**@MD**

- type: executable
- value: [object Object]

**@md**

- type: executable
- value: [object Object]

**@fm**

- type: object
- value: [object Object]
- defined at: <frontmatter>:0

**@frontmatter**

- type: object
- value: [object Object]
- defined at: <frontmatter>:0

### Statistics:

- Total variables: 13
- Output nodes: 1
- Errors collected: 0
- Current file: /Users/adam/dev/mlld/modules/llm/run/01-basic-imports.mld
- Base path: /Users/adam/dev/mlld/modules

## String Module

Original: ' Hello World '
Upper: HELLO WORLD
Lower: hello world
Trimmed: 'Hello World'
Capitalized: hello world

## Array Module

Array: [10,20,30,40,50]
First:
Last:
Sum: 0
Average: 0

## Test Module

✓ eq(5, 5) works

## FS Module

✓ This file exists

✓ modules directory exists

\n✅ Basic import test complete!
