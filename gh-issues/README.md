# gh-issues

GitHub issues, pull requests, repos and workflows via the `gh` CLI. This module replaces `@mlld/github`; see [Moving from @mlld/github](#moving-from-mlldgithub).

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

>> Pull requests take the repo as "owner/name"
const @pr = @viewPr(123, "acme/app", "number,title,state")
const @diff = @prDiff(123, "acme/app", "src/")
@reviewPr(123, "acme/app", "approve", "LGTM")
```

## Exports

Every function uses the repo from git context when none is given (pass `null`), and returns gh's JSON parsed unless noted. A failed request (not found, no permission) is an error; wrap the call in `try` to handle it.

### Issues

Issue functions take the repo as separate `owner` and `repo` arguments.

| Function | Labels | Description |
|----------|--------|-------------|
| `@listIssues(owner?, repo?)` | `.op:net:r` | List open issues |
| `@getIssue(owner?, repo?, number)` | `.op:net:r` | Get single issue |
| `@createIssue(owner?, repo?, title, body)` | `.op:net:rw` | Create issue |
| `@addComment(owner?, repo?, number, comment)` | `.op:net:rw` | Add comment |
| `@closeIssue(owner?, repo?, number)` | `.op:net:rw` | Close issue |
| `@searchIssues(query)` | `.op:net:r` | Search issues |

### Pull requests, repos and workflows

These take the repo as one `"owner/name"` string.

| Function | Labels | Description |
|----------|--------|-------------|
| `@viewPr(number, repo?, fields?)` | `.op:net:r` | Get a PR. `fields` is a comma list of keys to keep. `files` is always present, as an array |
| `@listPrFiles(number, repo?)` | `.op:net:r` | Files the PR changes, each with `filename`, `status`, `additions`, `deletions`, `patch` |
| `@prDiff(number, repo?, paths?)` | `.op:net:r` | The PR's unified diff as text. `paths` (comma list) keeps only files whose diff header mentions one |
| `@listPrs(repo?, options?)` | `.op:net:r` | List PRs. `options` is `{ state, author, label }` |
| `@commentPr(number, repo, body)` | `.op:net:rw` | Comment on a PR |
| `@reviewPr(number, repo, event, body)` | `.op:net:rw` | Review a PR. `event` is `approve`, `request-changes` or `comment` |
| `@editPr(number, repo, options)` | `.op:net:rw` | Edit a PR. `options` is `{ title, body, labels }`; labels are added to the existing ones |
| `@viewRepo(repo?, fields?)` | `.op:net:r` | Get a repo. `fields` works as in `@viewPr` |
| `@cloneRepo(repo, dir?)` | `.op:net:r`, `.op:fs:w` | Clone the repo to `dir` (default: the repo name). Returns `{ repo, directory }` |
| `@isCollaborator(user, repo?)` | `.op:net:r` | `true` if the user is a collaborator, else `false` |
| `@runWorkflow(repo, workflow, options?)` | `.op:net:rw` | Start a GitHub Actions workflow, named by display name, file name or id. `options` is `{ ref }`, default `"main"`. Returns `{ success, workflow, ref }` |
| `@listWorkflowRuns(repo?)` | `.op:net:r` | Recent Actions runs, as `{ total_count, workflow_runs }` |
| `@tools` | | MCP tools collection |

## Moving from @mlld/github

`@mlld/github` called the GitHub API with `MLLD_GITHUB_TOKEN`. These functions use `gh` and its login instead, and return the same GitHub API shapes. What else changed:

| @mlld/github | @mlld/gh-issues |
|--------------|-----------------|
| `@github.pr.view`, `.files`, `.diff`, `.list`, `.comment`, `.review`, `.edit` | `@viewPr`, `@listPrFiles`, `@prDiff`, `@listPrs`, `@commentPr`, `@reviewPr`, `@editPr` |
| `@github.repo.view`, `.clone` | `@viewRepo`, `@cloneRepo` |
| `@github.collab.check` | `@isCollaborator` |
| `@github.workflow.run`, `.list` | `@runWorkflow`, `@listWorkflowRuns` |
| `@github.issue.create`, `.list`, `.comment` | `@createIssue`, `@listIssues`, `@addComment` |
| options as CLI text, e.g. `"--state open"`, `"--ref main"` | options as objects, e.g. `{ state: "open" }`, `{ ref: "main" }` |
| failures returned `{ error }` | failures are errors; use `try` |
| `collab.check` returned `"true"` or `""` | `@isCollaborator` returns `true` or `false` |
| `repo.clone` only returned clone URLs | `@cloneRepo` really clones |
| `pr.diff` paths kept every file's `diff --git` line | `@prDiff` keeps only the matching files |

## Serve as MCP tools

```bash
mlld mcp modules/gh-issues/index.mld --tools-collection @tools
```

## License

CC0 - Public Domain
