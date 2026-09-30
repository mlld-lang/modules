# gh-issues

GitHub Issues API tools via `gh` CLI.

## Setup

Authenticate with one of:

```bash
gh auth login                     # interactive (recommended)
export GITHUB_TOKEN=ghp_...       # env var
mlld keychain add GITHUB_TOKEN    # mlld keychain (declare it with creds in your script)
```

## tldr

```mlld
import { @listIssues, @getIssue, @createIssue } from @mlld/gh-issues

>> Auto-detects owner/repo from git context
const @issues = @listIssues()
show `Found ${@issues.length} issues`

const @issue = @getIssue(null, null, 42)
show `#${@issue.number} ${@issue.title}`

>> Or pass explicitly
const @new = @createIssue("acme", "app", "Bug report", "Details here")
show `Created #${@new.number}`
```

## Exports

All functions auto-detect `owner`/`repo` from git context when not provided (pass `null`), and return gh's JSON parsed.

| Function | Labels | Description |
|----------|--------|-------------|
| `@listIssues(owner?, repo?)` | `.op:net:r` | List open issues |
| `@getIssue(owner?, repo?, number)` | `.op:net:r` | Get single issue |
| `@createIssue(owner?, repo?, title, body)` | `.op:net:rw` | Create issue |
| `@addComment(owner?, repo?, number, comment)` | `.op:net:rw` | Add comment |
| `@closeIssue(owner?, repo?, number)` | `.op:net:rw` | Close issue |
| `@searchIssues(query)` | `.op:net:r` | Search issues |
| `@tools` | | MCP tools collection |

## Serve as MCP tools

```bash
mlld mcp modules/gh-issues/index.mld --tools-collection @tools
```

## License

CC0 - Public Domain
