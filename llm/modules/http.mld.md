---
name: http
author: mlld
version: 1.0.0
about: HTTP methods using fetch with native return values
needs: ["js"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["http", "api", "get", "put", "post", "delete", "rest"]
license: CC0
mlldVersion: ">=1.4.1"
---

# @mlld/http

HTTP methods using the fetch API for making REST calls. All methods now return native JavaScript values (objects, arrays, strings) for easy processing. Version 2.0 requires mlld 1.4.1+ for return value support.

## tldr

Quick HTTP requests with automatic JSON handling:

```mlld
/import { http } from @mlld/http

/run @http.get("https://api.github.com/users/octocat")
/run @http.post("https://httpbin.org/post", {"message": "hello"})
/run @http.auth.get("https://api.github.com/user", @token)

/var @userData = @http.fetch.get("https://api.github.com/users/octocat")
/show `User: @userData.name`
```

## docs

### Basic HTTP Methods

#### `get(url)`, `post(url, data)`, `put(url, data)`, `patch(url, data)`, `delete(url)`

Standard HTTP methods that print formatted responses to console.

```mlld
/run @http.get("https://api.github.com/users/octocat")
/run @http.post("https://httpbin.org/post", {"key": "value"})
/run @http.delete("https://httpbin.org/delete")
```

### Authenticated Requests

#### `auth.get(url, token)`, `auth.post(url, token, data)`

HTTP methods with Bearer token authentication.

```mlld
/run @http.auth.get("https://api.github.com/user", @githubToken)
/run @http.auth.post("https://api.github.com/user/repos", @token, {"name": "new-repo"})
```

### Advanced Requests

#### `request(url, options)`

Full control over fetch options.

```mlld
/var @customOptions = {
  "method": "POST",
  "headers": {"Custom-Header": "value"},
  "body": "raw data"
}
/run @request("https://httpbin.org/post", @customOptions)
```

### Fetch Methods (Data-Returning)

#### `fetch.get(url)`, `fetch.post(url, data)`, `fetch.put(url, data)`, `fetch.patch(url, data)`, `fetch.delete(url)`

Return response data as native JavaScript objects for easy processing.

```mlld
/var @userData = @fetch.get("https://api.github.com/users/octocat")
/var @response = @fetch.post("https://httpbin.org/post", {"test": true})

/show `User: @userData.name has @userData.public_repos repos`
/show `Posted data echo: @response.json.test`
```

### Display Methods

#### `display.get(url)`, `display.post(url, data)`

Format and display HTTP responses with pretty printing.

```mlld
/run @display.get("https://api.github.com/users/octocat")
/run @display.post("https://httpbin.org/post", {"message": "hello"})
```

## module

All HTTP methods use fetch with automatic JSON parsing and native return values. Display methods format output for readability:

```mlld-run
/exe @get(@url) = js {
  fetch(url)
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.text();
    })
    .then(text => {
      try {
        return JSON.parse(text);
      } catch {
        return text;
      }
    })
    .catch(error => {
      throw new Error(`HTTP GET failed: ${error.message}`);
    })
}

/exe @post(@url, @data) = js {
  fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: typeof data === 'string' ? data : JSON.stringify(data)
  })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.text();
    })
    .then(text => {
      try {
        return JSON.parse(text);
      } catch {
        return text;
      }
    })
    .catch(error => {
      throw new Error(`HTTP POST failed: ${error.message}`);
    })
}

/exe @put(@url, @data) = js {
  fetch(url, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: typeof data === 'string' ? data : JSON.stringify(data)
  })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.text();
    })
    .then(text => {
      try {
        return JSON.parse(text);
      } catch {
        return text;
      }
    })
    .catch(error => {
      throw new Error(`HTTP PUT failed: ${error.message}`);
    })
}

/exe @delete(@url) = js {
  fetch(url, { method: 'DELETE' })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.text();
    })
    .then(text => {
      try {
        return JSON.parse(text);
      } catch {
        return text || 'Deleted successfully';
      }
    })
    .catch(error => {
      throw new Error(`HTTP DELETE failed: ${error.message}`);
    })
}

/exe @patch(@url, @data) = js {
  fetch(url, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: typeof data === 'string' ? data : JSON.stringify(data)
  })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.text();
    })
    .then(text => {
      try {
        return JSON.parse(text);
      } catch {
        return text;
      }
    })
    .catch(error => {
      throw new Error(`HTTP PATCH failed: ${error.message}`);
    })
}

/exe @authGet(@url, @token) = js {
  fetch(url, {
    headers: { 'Authorization': `Bearer ${token}` }
  })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.text();
    })
    .then(text => {
      try {
        return JSON.parse(text);
      } catch {
        return text;
      }
    })
    .catch(error => {
      throw new Error(`HTTP GET (auth) failed: ${error.message}`);
    })
}

/exe @authPost(@url, @token, @data) = js {
  fetch(url, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: typeof data === 'string' ? data : JSON.stringify(data)
  })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.text();
    })
    .then(text => {
      try {
        return JSON.parse(text);
      } catch {
        return text;
      }
    })
    .catch(error => {
      throw new Error(`HTTP POST (auth) failed: ${error.message}`);
    })
}

/exe @request(@url, @options) = js {
  fetch(url, options)
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.text();
    })
    .then(text => {
      try {
        return JSON.parse(text);
      } catch {
        return text;
      }
    })
    .catch(error => {
      throw new Error(`HTTP request failed: ${error.message}`);
    })
}

/exe @getData(@url) = js {
  fetch(url)
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.json();
    })
    .catch(error => { throw error; })
}

/exe @postData(@url, @data) = js {
  fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: typeof data === 'string' ? data : JSON.stringify(data)
  })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.json();
    })
    .catch(error => { throw error; })
}

/exe @putData(@url, @data) = js {
  fetch(url, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: typeof data === 'string' ? data : JSON.stringify(data)
  })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.json();
    })
    .catch(error => { throw error; })
}

/exe @patchData(@url, @data) = js {
  fetch(url, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: typeof data === 'string' ? data : JSON.stringify(data)
  })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.json();
    })
    .catch(error => { throw error; })
}

/exe @deleteData(@url) = js {
  fetch(url, {
    method: 'DELETE'
  })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.json();
    })
    .catch(error => { throw error; })
}
```

Display methods for formatted output:

```mlld-run
/exe @displayGet(@url) = js {
  fetch(url)
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.text();
    })
    .then(text => {
      try {
        const data = JSON.parse(text);
        console.log(JSON.stringify(data, null, 2));
        return data;
      } catch {
        console.log(text);
        return text;
      }
    })
    .catch(error => {
      console.error(`Error: ${error.message}`);
      throw error;
    })
}

/exe @displayPost(@url, @data) = js {
  fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: typeof data === 'string' ? data : JSON.stringify(data)
  })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.text();
    })
    .then(text => {
      try {
        const data = JSON.parse(text);
        console.log(JSON.stringify(data, null, 2));
        return data;
      } catch {
        console.log(text);
        return text;
      }
    })
    .catch(error => {
      console.error(`Error: ${error.message}`);
      throw error;
    })
}

>> Create structured export with nested organization
/var @http = {
  "get": @displayGet,
  "post": @displayPost,
  "put": @put,
  "patch": @patch,
  "delete": @delete,
  "auth": {
    "get": @authGet,
    "post": @authPost
  },
  "fetch": {
    "get": @getData,
    "post": @postData,
    "put": @putData,
    "patch": @patchData,
    "delete": @deleteData
  },
  "request": @request
}

>> Shadow environment - make functions available to each other
/exe js = { get, post, put, patch, authGet, authPost, request, getData, postData, putData, patchData, deleteData, displayGet, displayPost }
```

This module uses a structured export to provide both individual methods and organized interfaces, defined in the main `mlld-run` block above.