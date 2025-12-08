---
name: github
author: mlld
version: 1.0.0
about: GitHub API client for PR, issue, and repository operations
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["github", "api", "pr", "pull-request", "issue", "repository", "fetch", "rest"]
license: CC0
mlldVersion: "*"
---

/needs {
  js: []
}

# @mlld/github

GitHub operations via the GitHub REST API. Simplifies working with pull requests, issues, repositories, and more in mlld workflows using direct API calls.

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

Requires a GitHub Personal Access Token with appropriate permissions:

```bash
# Set your GitHub token as an environment variable
export MLLD_GITHUB_TOKEN="ghp_your_token_here"
```

**Required token permissions:**
- `repo` - For private repository access
- `public_repo` - For public repository access  
- `pull_requests` - For PR operations
- `issues` - For issue operations

### Pull Request Operations

#### `pr.view(number, repo, fields?)`

Get PR data as JSON. Default fields include number, title, author, state, body, files.

**Returns:** PR object with GitHub API fields
- `number`: PR number
- `title`: PR title string
- `state`: "open" | "closed" | "merged"
- `author`: { login, id, avatar_url, ... }
- `body`: PR description text
- `created_at`, `updated_at`, `closed_at`: ISO date strings
- `head`, `base`: branch information objects
- `error`: Error message if request fails

```mlld
/var @pr = @github.pr.view(123, "mlld-lang/mlld")
/show `PR #@pr.number: @pr.title by @pr.author.login`

>> Custom fields
/var @prDetails = @github.pr.view(123, "owner/repo", "number,title,labels,milestone")
```

#### `pr.files(number, repo)`

Get the list of files changed in a PR with metadata.

**Returns:** Array of file objects, each containing:
- `filename`: Path to the file (NOT `path` - this is important!)
- `status`: "added" | "removed" | "modified" | "renamed"
- `additions`: Number of lines added
- `deletions`: Number of lines removed
- `changes`: Total lines changed
- `blob_url`: Link to file in GitHub web UI
- `raw_url`: Direct link to raw file content
- `contents_url`: API URL for file contents
- `patch`: The diff patch for this file
- `sha`: File SHA hash

```mlld
/var @files = @github.pr.files(123, "owner/repo")
/for @file in @files => /show `@file.filename: +@file.additions -@file.deletions`

>> Example file object:
>> {
>>   "filename": "src/utils.js",
>>   "status": "modified",
>>   "additions": 25,
>>   "deletions": 10,
>>   "changes": 35,
>>   "blob_url": "https://github.com/owner/repo/blob/abc123/src/utils.js",
>>   "raw_url": "https://github.com/owner/repo/raw/abc123/src/utils.js",
>>   "patch": "@@ -10,7 +10,12 @@\n-old code\n+new code"
>> }
```

#### `pr.diff(number, repo, paths?)`

Get the diff for a PR, optionally filtered by paths.

**Returns:** String containing unified diff format
- Full git diff output as a single string
- Includes file headers, hunks, and line changes
- Empty string if no changes or error

```mlld
>> Get full diff
/var @diff = @github.pr.diff(123, "owner/repo")

>> Get diff for specific paths
/var @srcDiff = @github.pr.diff(123, "owner/repo", "src/**/*.js")

>> Example output:
>> "diff --git a/file.js b/file.js
>> index abc123..def456 100644
>> --- a/file.js
>> +++ b/file.js
>> @@ -1,3 +1,4 @@
>> +// New comment
>>  function example() {
>>    return true;
>>  }"
```

#### `pr.list(repo, options?)`

List PRs with various filters.

**Returns:** Array of PR objects, each containing:
- Same fields as `pr.view()` but in summary form
- Common fields: number, title, state, author, created_at, updated_at
- Array is empty if no PRs match filters

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

**Returns:** Comment object with:
- `id`: Comment ID
- `body`: Comment text
- `user`: Author object { login, id, ... }
- `created_at`: ISO date string
- `html_url`: Web URL for the comment

```mlld
/run @github.pr.comment(456, "owner/repo", "Thanks for the contribution!")
```

#### `pr.review(number, repo, event, body)`

Create a PR review with approve/request-changes/comment.

**Returns:** Review object with:
- `id`: Review ID
- `state`: "APPROVED" | "CHANGES_REQUESTED" | "COMMENTED"
- `body`: Review comment text
- `user`: Reviewer object
- `submitted_at`: ISO date string

```mlld
/run @github.pr.review(789, "owner/repo", "approve", "LGTM!")
/run @github.pr.review(789, "owner/repo", "request-changes", "Please update the tests")
/run @github.pr.review(789, "owner/repo", "comment", "Looking good so far")
```

#### `pr.edit(number, repo, options)`

Edit PR properties like title, labels, or assignees.

**Returns:** Updated PR object with all fields (same as pr.view())

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

**Returns:** Issue object with:
- `number`: Issue number
- `title`: Issue title
- `state`: "open"
- `body`: Issue description
- `user`: Creator object
- `created_at`: ISO date string
- `html_url`: Web URL for the issue

```mlld
/var @issue = @github.issue.create("owner/repo", "Bug: App crashes on startup", "Details: ...")
/show `Created issue #@issue.number`
```

#### `issue.list(repo, options?)`

List issues with filters.

**Returns:** Array of issue objects, each containing:
- `number`: Issue number
- `title`: Issue title
- `state`: "open" | "closed"
- `labels`: Array of label objects
- `assignees`: Array of user objects
- `created_at`, `updated_at`: ISO date strings

```mlld
>> List open issues
/var @issues = @github.issue.list("owner/repo")

>> List bugs assigned to me
/var @myBugs = @github.issue.list("owner/repo", "--assignee @me --label bug")
```

#### `issue.comment(number, repo, body)`

Add a comment to an issue.

**Returns:** Comment object (same structure as pr.comment())

```mlld
/run @github.issue.comment(456, "owner/repo", "I can reproduce this issue")
```

### Repository Operations

#### `repo.view(repo, fields?)`

Get repository information.

**Returns:** Repository object with:
- `name`: Repository name
- `full_name`: "owner/repo" format
- `description`: Repository description
- `owner`: Owner object { login, id, type, ... }
- `private`: Boolean
- `stargazerCount`: Number of stars
- `forkCount`: Number of forks
- `language`: Primary language
- `created_at`, `updated_at`: ISO date strings
- `default_branch`: Usually "main" or "master"

```mlld
/var @repo = @github.repo.view("mlld-lang/mlld")
/show `Stars: @repo.stargazerCount, Forks: @repo.forkCount`
```

#### `repo.clone(repo, dir?)`

Clone a repository.

**Returns:** String with clone confirmation message or error

```mlld
/run @github.repo.clone("owner/repo", "./local-copy")
```

### Collaborator & Permission Checks

#### `collab.check(user, repo)`

Check if a user is a collaborator (has write access).

**Returns:** Boolean
- `true` if user has write access
- `false` if user does not have write access or on error

```mlld
/var @hasAccess = @github.collab.check("alice", "owner/repo")
/when @hasAccess => /run @github.pr.review(123, "owner/repo", "approve", "Auto-approved for collaborator")
```

### Workflow Operations

#### `workflow.run(repo, workflow, options?)`

Trigger a GitHub Actions workflow.

**Returns:** Workflow run object with:
- `id`: Run ID
- `name`: Workflow name
- `head_branch`: Branch that triggered the run
- `status`: "queued" | "in_progress" | "completed"
- `conclusion`: "success" | "failure" | "cancelled" | null
- `created_at`: ISO date string

```mlld
/run @github.workflow.run("owner/repo", "deploy.yml", "--ref main")
```

#### `workflow.list(repo)`

List workflow runs.

**Returns:** Array of workflow run objects (same structure as workflow.run())

```mlld
/var @runs = @github.workflow.list("owner/repo")
/show `Latest run: @runs.0.name - @runs.0.conclusion`
```

### Error Handling

All methods return an object with an `error` property when requests fail:

```mlld
/var @result = @github.repo.view("nonexistent/repo")
/when @result.error => /show `Error: @result.error`

>> Common error responses:
>> - 404: Repository, PR, or issue not found
>> - 401: Invalid or missing authentication token
>> - 403: Insufficient permissions
>> - 422: Invalid parameters
>> - 429: Rate limit exceeded
```

## module

GitHub operations via the GitHub REST API:

```mlld-run
>> STEP 1: Define the helper function (must be async)
/exe @github_request(@method, @endpoint, @body) = js {
  return (async () => {
    const token = process.env.MLLD_GITHUB_TOKEN;
    if (!token) {
      return { error: "GitHub token not found in MLLD_GITHUB_TOKEN environment variable" };
    }

    const url = endpoint.startsWith('https://') ? endpoint : `https://api.github.com/${endpoint}`;
    
    const options = {
      method: method || 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'mlld-github-module',
        'X-GitHub-Api-Version': '2022-11-28'
      }
    };

    if (body && (method === 'POST' || method === 'PATCH' || method === 'PUT')) {
      options.headers['Content-Type'] = 'application/json';
      options.body = typeof body === 'string' ? body : JSON.stringify(body);
    }

    try {
      const response = await fetch(url, options);
      
      if (!response.ok) {
        const errorText = await response.text();
        let errorMessage;
        try {
          const errorJson = JSON.parse(errorText);
          errorMessage = errorJson.message || errorText;
        } catch {
          errorMessage = errorText || `HTTP ${response.status} ${response.statusText}`;
        }
        
        return { 
          error: `GitHub API error: ${errorMessage}`,
          status: response.status,
          statusText: response.statusText
        };
      }

      // Handle empty responses (204 No Content)
      if (response.status === 204) {
        return { success: true };
      }

      const data = await response.json();
      return data;
    } catch (error) {
      return { error: `Request failed: ${error.message}` };
    }
  })();
}

>> STEP 2: Set up the shadow environment with github_request IMMEDIATELY
>> This must happen BEFORE defining any functions that use github_request
/exe js = { github_request }

>> STEP 3: Now define all functions that use github_request
>> Pull Request operations
/exe @pr_view(@number, @repo, @fields) = js {
  return (async () => {
    const result = await github_request('GET', `repos/${repo}/pulls/${number}`);
    
    if (result.error) {
      return result;
    }

    // Always ensure files is an array to prevent undefined errors
    if (!result.files) {
      result.files = [];
    }

    // If specific fields requested, filter the response
    if (fields) {
      const fieldArray = fields.split(',').map(f => f.trim());
      const filtered = {};
      fieldArray.forEach(field => {
        if (result[field] !== undefined) {
          filtered[field] = result[field];
        }
      });
      return filtered;
    }

    return result;
  })();
}

/exe @pr_files(@number, @repo) = js {
  return (async () => {
    const result = await github_request('GET', `repos/${repo}/pulls/${number}/files`);
    
    if (result.error) {
      return result;
    }
    
    // GitHub returns an array of file objects
    return result;
  })();
}

/exe @pr_diff(@number, @repo, @paths) = js {
  return (async () => {
    const headers = {
      'Accept': 'application/vnd.github.v3.diff'
    };
    
    const token = process.env.MLLD_GITHUB_TOKEN;
    if (!token) {
      return { error: "GitHub token not found in MLLD_GITHUB_TOKEN environment variable" };
    }

    try {
      const response = await fetch(`https://api.github.com/repos/${repo}/pulls/${number}`, {
        headers: {
          ...headers,
          'Authorization': `Bearer ${token}`,
          'User-Agent': 'mlld-github-module'
        }
      });

      if (!response.ok) {
        return { error: `Failed to fetch diff: ${response.status} ${response.statusText}` };
      }

      const diff = await response.text();
      
      // If paths specified, filter the diff (basic implementation)
      if (paths) {
        const lines = diff.split('\n');
        const filteredLines = [];
        let inRelevantFile = false;
        
        for (const line of lines) {
          if (line.startsWith('diff --git')) {
            inRelevantFile = paths.split(',').some(path => line.includes(path.trim()));
          }
          if (inRelevantFile || line.startsWith('diff --git')) {
            filteredLines.push(line);
          }
        }
        return filteredLines.join('\n');
      }

      return diff;
    } catch (error) {
      return { error: `Request failed: ${error.message}` };
    }
  })();
}

/exe @pr_list(@repo, @options) = js {
  return (async () => {
    let endpoint = `repos/${repo}/pulls`;
    const params = new URLSearchParams();
    
    // Parse common options
    if (options) {
      if (options.includes('--state open')) params.set('state', 'open');
      if (options.includes('--state closed')) params.set('state', 'closed');
      if (options.includes('--state all')) params.set('state', 'all');
      
      // Parse author
      const authorMatch = options.match(/--author\s+(\S+)/);
      if (authorMatch) {
        params.set('head', `${authorMatch[1]}:`);
      }
      
      // Parse label
      const labelMatch = options.match(/--label\s+(\S+)/);
      if (labelMatch) {
        params.set('labels', labelMatch[1]);
      }
    }
    
    if (params.toString()) {
      endpoint += `?${params.toString()}`;
    }

    return await github_request('GET', endpoint);
  })();
}

/exe @pr_comment(@number, @repo, @body) = js {
  return (async () => {
    return await github_request('POST', `repos/${repo}/issues/${number}/comments`, {
      body: body
    });
  })();
}

/exe @pr_review(@number, @repo, @event, @body) = js {
  return (async () => {
    const eventMap = {
      'approve': 'APPROVE',
      'request-changes': 'REQUEST_CHANGES', 
      'comment': 'COMMENT'
    };
    
    const reviewEvent = eventMap[event] || event.toUpperCase();
    
    return await github_request('POST', `repos/${repo}/pulls/${number}/reviews`, {
      event: reviewEvent,
      body: body
    });
  })();
}

/exe @pr_edit(@number, @repo, @options) = js {
  return (async () => {
    const updateData = {};
    
    // Parse common edit options
    if (options) {
      const titleMatch = options.match(/--title\s+['"]([^'"]+)['"]/);
      if (titleMatch) updateData.title = titleMatch[1];
      
      const bodyMatch = options.match(/--body\s+['"]([^'"]+)['"]/);
      if (bodyMatch) updateData.body = bodyMatch[1];
      
      const labelMatch = options.match(/--add-label\s+([^\s]+)/);
      if (labelMatch) updateData.labels = labelMatch[1].split(',');
    }
    
    return await github_request('PATCH', `repos/${repo}/pulls/${number}`, updateData);
  })();
}

>> Issue operations
/exe @issue_create(@repo, @title, @body) = js {
  return (async () => {
    return await github_request('POST', `repos/${repo}/issues`, {
      title: title,
      body: body
    });
  })();
}

/exe @issue_list(@repo, @options) = js {
  return (async () => {
    let endpoint = `repos/${repo}/issues`;
    const params = new URLSearchParams();
    
    // Parse options
    if (options) {
      if (options.includes('--state open')) params.set('state', 'open');
      if (options.includes('--state closed')) params.set('state', 'closed');
      if (options.includes('--state all')) params.set('state', 'all');
      
      const assigneeMatch = options.match(/--assignee\s+(\S+)/);
      if (assigneeMatch) {
        params.set('assignee', assigneeMatch[1] === '@me' ? '' : assigneeMatch[1]);
      }
      
      const labelMatch = options.match(/--label\s+(\S+)/);
      if (labelMatch) {
        params.set('labels', labelMatch[1]);
      }
    }
    
    if (params.toString()) {
      endpoint += `?${params.toString()}`;
    }

    return await github_request('GET', endpoint);
  })();
}

/exe @issue_comment(@number, @repo, @body) = js {
  return (async () => {
    return await github_request('POST', `repos/${repo}/issues/${number}/comments`, {
      body: body
    });
  })();
}

>> Repository operations
/exe @repo_view(@repo, @fields) = js {
  return (async () => {
    const result = await github_request('GET', `repos/${repo}`);
    
    if (result.error) {
      return result;
    }

    // If specific fields requested, filter the response
    if (fields) {
      const fieldArray = fields.split(',').map(f => f.trim());
      const filtered = {};
      fieldArray.forEach(field => {
        if (result[field] !== undefined) {
          filtered[field] = result[field];
        }
      });
      return filtered;
    }

    return result;
  })();
}

/exe @repo_clone(@repo, @dir) = js {
  return (async () => {
    // Note: This returns clone information, not actual cloning
    // For actual git operations, use shell commands or git APIs
    const result = await github_request('GET', `repos/${repo}`);
    
    if (result.error) {
      return result;
    }

    return {
      clone_url: result.clone_url,
      ssh_url: result.ssh_url,
      git_url: result.git_url,
      directory: dir || result.name,
      instructions: `git clone ${result.clone_url} ${dir || result.name}`
    };
  })();
}

>> Collaborator checks
/exe @collab_check(@user, @repo) = js {
  return (async () => {
    const result = await github_request('GET', `repos/${repo}/collaborators/${user}`);
    
    // Return boolean string for compatibility
    if (result.error) {
      return ""; // Not a collaborator or error
    }
    
    return "true"; // Is a collaborator
  })();
}

>> Workflow operations
/exe @workflow_run(@repo, @workflow, @options) = js {
  return (async () => {
    // First, get the workflow ID if a name was provided
    let workflowId = workflow;
    
    if (isNaN(workflow)) {
      // It's a workflow name, need to find the ID
      const workflows = await github_request('GET', `repos/${repo}/actions/workflows`);
      if (workflows.error) return workflows;
      
      const found = workflows.workflows.find(w => w.name === workflow || w.path.includes(workflow));
      if (!found) {
        return { error: `Workflow '${workflow}' not found` };
      }
      workflowId = found.id;
    }
    
    const dispatchData = { ref: 'main' };
    
    // Parse options for ref and inputs
    if (options) {
      const refMatch = options.match(/--ref\s+(\S+)/);
      if (refMatch) dispatchData.ref = refMatch[1];
    }
    
    return await github_request('POST', `repos/${repo}/actions/workflows/${workflowId}/dispatches`, dispatchData);
  })();
}

/exe @workflow_list(@repo) = js {
  return (async () => {
    return await github_request('GET', `repos/${repo}/actions/runs`);
  })();
}

>> STEP 4: Update shadow environment to include ALL functions
>> This ensures all functions are available to each other
/exe @js = { 
  github_request,
  pr_view, pr_files, pr_diff, pr_list, pr_comment, pr_review, pr_edit,
  issue_create, issue_list, issue_comment,
  repo_view, repo_clone,
  collab_check,
  workflow_run, workflow_list
}

>> STEP 5: Export module structure
/var @pr = {
  view: @pr_view,
  files: @pr_files,
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

/export { @github, @pr, @issue, @repo, @collab, @workflow }
```
