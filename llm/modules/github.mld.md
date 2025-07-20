---
name: github
author: mlld
version: 1.0.0
about: GitHub API client for PR, issue, and repository operations
needs: ["js"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["github", "api", "pr", "pull-request", "issue", "repository", "fetch", "rest"]
license: CC0
mlldVersion: "*"
---

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
export GITHUB_TOKEN="ghp_your_token_here"
# or
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

GitHub operations via the GitHub REST API:

```mlld-run
>> GitHub API helper functions
/exe @github_request(@method, @endpoint, @body) = js {
  const token = process.env.GITHUB_TOKEN || process.env.MLLD_GITHUB_TOKEN;
  if (!token) {
    return { error: "GitHub token not found in GITHUB_TOKEN or MLLD_GITHUB_TOKEN environment variables" };
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
}

>> Now functions can access github_request from the shadow environment
>> Pull Request operations
/exe @pr_view(@number, @repo, @fields) = js {
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
}

/exe @pr_diff(@number, @repo, @paths) = js {
  const headers = {
    'Accept': 'application/vnd.github.v3.diff'
  };
  
  const token = process.env.GITHUB_TOKEN || process.env.MLLD_GITHUB_TOKEN;
  if (!token) {
    return { error: "GitHub token not found in environment variables" };
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
}

/exe @pr_list(@repo, @options) = js {
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
}

/exe @pr_comment(@number, @repo, @body) = js {
  return await github_request('POST', `repos/${repo}/issues/${number}/comments`, {
    body: body
  });
}

/exe @pr_review(@number, @repo, @event, @body) = js {
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
}

/exe @pr_edit(@number, @repo, @options) = js {
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
}

>> Issue operations
/exe @issue_create(@repo, @title, @body) = js {
  return await github_request('POST', `repos/${repo}/issues`, {
    title: title,
    body: body
  });
}

/exe @issue_list(@repo, @options) = js {
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
}

/exe @issue_comment(@number, @repo, @body) = js {
  return await github_request('POST', `repos/${repo}/issues/${number}/comments`, {
    body: body
  });
}

>> Repository operations
/exe @repo_view(@repo, @fields) = js {
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
}

/exe @repo_clone(@repo, @dir) = js {
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
}

>> Collaborator checks
/exe @collab_check(@user, @repo) = js {
  const result = await github_request('GET', `repos/${repo}/collaborators/${user}`);
  
  // Return boolean string for compatibility
  if (result.error) {
    return ""; // Not a collaborator or error
  }
  
  return "true"; // Is a collaborator
}

>> Workflow operations
/exe @workflow_run(@repo, @workflow, @options) = js {
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
}

/exe @workflow_list(@repo) = js {
  return await github_request('GET', `repos/${repo}/actions/runs`);
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

>> Set up JavaScript shadow environment with all functions
/exe @js = { 
  github_request,
  pr_view, pr_diff, pr_list, pr_comment, pr_review, pr_edit,
  issue_create, issue_list, issue_comment,
  repo_view, repo_clone,
  collab_check,
  workflow_run, workflow_list
}
```