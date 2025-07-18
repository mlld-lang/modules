---
name: github
author: mlld
version: 1.0.0
about: GitHub CLI wrapper for PR, issue, and repository operations
needs: ["sh"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["github", "gh", "pr", "pull-request", "issue", "repository", "api", "cli"]
license: CC0
mlldVersion: "*"
---

# @mlld/github

GitHub operations via the `gh` CLI tool. Simplifies working with pull requests, issues, repositories, and more in mlld workflows.

## tldr

Common GitHub operations made easy:

```mlld
/import { github } from @mlld/github

>> Get PR information
/var @prData = @github.pr.view(123, "owner/repo")
/show `PR Title: @prData.title`

>> Post a comment
/run @github.pr.comment(123, "owner/repo", "LGTM! 🚀")

>> Check if user is a collaborator
/var @isCollab = @github.collab.check("octocat", "owner/repo")
/when @isCollab => /show "User has write access"
```

## docs

### Prerequisites

Requires the GitHub CLI (`gh`) to be installed and authenticated:

```bash
# Install
brew install gh  # macOS
# or see: https://cli.github.com/

# Authenticate
gh auth login
```

### Pull Request Operations

#### `pr.view(number, repo, fields?)`

Get PR data as JSON. Default fields include number, title, author, state, body, files.

```mlld
/var @pr = @github.pr.view(123, "mlld-lang/mlld")
/show `PR #@pr.number: @pr.title by @pr.author.login`

>> Custom fields
/var @prDetails = @github.pr.view(123, "owner/repo", "number,title,labels,milestone")
```

#### `pr.diff(number, repo, paths?)`

Get the diff for a PR, optionally filtered by paths.

```mlld
>> Get full diff
/var @diff = @github.pr.diff(123, "owner/repo")

>> Get diff for specific paths
/var @srcDiff = @github.pr.diff(123, "owner/repo", "src/**/*.js")
```

#### `pr.list(repo, options?)`

List PRs with various filters.

```mlld
>> List open PRs
/var @openPRs = @github.pr.list("owner/repo")

>> List PRs by author
/var @myPRs = @github.pr.list("owner/repo", "--author @me")

>> List PRs with specific labels
/var @bugPRs = @github.pr.list("owner/repo", "--label bug")
```

#### `pr.comment(number, repo, body)`

Add a comment to a PR.

```mlld
/run @github.pr.comment(456, "owner/repo", "Thanks for the contribution!")
```

#### `pr.review(number, repo, event, body)`

Create a PR review with approve/request-changes/comment.

```mlld
/run @github.pr.review(789, "owner/repo", "approve", "LGTM!")
/run @github.pr.review(789, "owner/repo", "request-changes", "Please update the tests")
/run @github.pr.review(789, "owner/repo", "comment", "Looking good so far")
```

#### `pr.edit(number, repo, options)`

Edit PR properties like title, labels, or assignees.

```mlld
>> Add labels
/run @github.pr.edit(123, "owner/repo", "--add-label bug,priority-high")

>> Change title
/run @github.pr.edit(123, "owner/repo", "--title 'fix: resolve memory leak'")

>> Assign reviewers
/run @github.pr.edit(123, "owner/repo", "--add-reviewer alice,bob")
```

### Issue Operations

#### `issue.create(repo, title, body)`

Create a new issue.

```mlld
/var @issue = @github.issue.create("owner/repo", "Bug: App crashes on startup", "Details: ...")
/show `Created issue #@issue.number`
```

#### `issue.list(repo, options?)`

List issues with filters.

```mlld
>> List open issues
/var @issues = @github.issue.list("owner/repo")

>> List bugs assigned to me
/var @myBugs = @github.issue.list("owner/repo", "--assignee @me --label bug")
```

#### `issue.comment(number, repo, body)`

Add a comment to an issue.

```mlld
/run @github.issue.comment(456, "owner/repo", "I can reproduce this issue")
```

### Repository Operations

#### `repo.view(repo, fields?)`

Get repository information.

```mlld
/var @repo = @github.repo.view("mlld-lang/mlld")
/show `Stars: @repo.stargazerCount, Forks: @repo.forkCount`
```

#### `repo.clone(repo, dir?)`

Clone a repository.

```mlld
/run @github.repo.clone("owner/repo", "./local-copy")
```

### Collaborator & Permission Checks

#### `collab.check(user, repo)`

Check if a user is a collaborator (has write access).

```mlld
/var @hasAccess = @github.collab.check("alice", "owner/repo")
/when @hasAccess => /run @github.pr.review(123, "owner/repo", "approve", "Auto-approved for collaborator")
```

### Workflow Operations

#### `workflow.run(repo, workflow, options?)`

Trigger a GitHub Actions workflow.

```mlld
/run @github.workflow.run("owner/repo", "deploy.yml", "--ref main")
```

#### `workflow.list(repo)`

List workflow runs.

```mlld
/var @runs = @github.workflow.list("owner/repo")
```

## module

GitHub operations via the gh CLI:

```mlld-run
>> Pull Request operations
/exe @pr_view(@number, @repo, @fields) = run {
  if [ -z "$fields" ]; then
    gh pr view @number --repo @repo --json number,title,author,files,state,body,labels,createdAt
  else
    gh pr view @number --repo @repo --json @fields
  fi
}

/exe @pr_diff(@number, @repo, @paths) = run {
  if [ -z "$paths" ]; then
    gh pr diff @number --repo @repo
  else
    gh pr diff @number --repo @repo -- @paths
  fi
}

/exe @pr_list(@repo, @options) = run {
  if [ -z "$options" ]; then
    gh pr list --repo @repo --json number,title,author,state,labels
  else
    gh pr list --repo @repo @options --json number,title,author,state,labels
  fi
}

/exe @pr_comment(@number, @repo, @body) = run {
  gh pr comment @number --repo @repo --body "@body"
}

/exe @pr_review(@number, @repo, @event, @body) = run {
  gh pr review @number --repo @repo --@event --body "@body"
}

/exe @pr_edit(@number, @repo, @options) = run {
  gh pr edit @number --repo @repo @options
}

>> Issue operations
/exe @issue_create(@repo, @title, @body) = run {
  gh issue create --repo @repo --title "@title" --body "@body" --json number,url
}

/exe @issue_list(@repo, @options) = run {
  if [ -z "$options" ]; then
    gh issue list --repo @repo --json number,title,author,state,labels
  else
    gh issue list --repo @repo @options --json number,title,author,state,labels
  fi
}

/exe @issue_comment(@number, @repo, @body) = run {
  gh issue comment @number --repo @repo --body "@body"
}

>> Repository operations
/exe @repo_view(@repo, @fields) = run {
  if [ -z "$fields" ]; then
    gh repo view @repo --json name,owner,description,stargazerCount,forkCount,url
  else
    gh repo view @repo --json @fields
  fi
}

/exe @repo_clone(@repo, @dir) = run {
  if [ -z "$dir" ]; then
    gh repo clone @repo
  else
    gh repo clone @repo @dir
  fi
}

>> Collaborator checks
/exe @collab_check(@user, @repo) = sh {
  # Check if user is a collaborator
  # Returns "true" if they are, empty string if not
  if gh api "repos/$repo/collaborators/$user" --silent 2>/dev/null; then
    echo "true"
  else
    echo ""
  fi
}

>> Workflow operations
/exe @workflow_run(@repo, @workflow, @options) = run {
  if [ -z "$options" ]; then
    gh workflow run @workflow --repo @repo
  else
    gh workflow run @workflow --repo @repo @options
  fi
}

/exe @workflow_list(@repo) = run {
  gh run list --repo @repo --json databaseId,name,status,conclusion,headBranch
}

>> Export module structure
/var @pr = {
  view: @pr_view,
  diff: @pr_diff,
  list: @pr_list,
  comment: @pr_comment,
  review: @pr_review,
  edit: @pr_edit
}

/var @issue = {
  create: @issue_create,
  list: @issue_list,
  comment: @issue_comment
}

/var @repo = {
  view: @repo_view,
  clone: @repo_clone
}

/var @collab = {
  check: @collab_check
}

/var @workflow = {
  run: @workflow_run,
  list: @workflow_list
}

/var @github = {
  pr: @pr,
  issue: @issue,
  repo: @repo,
  collab: @collab,
  workflow: @workflow
}
```