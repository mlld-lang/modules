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
@import { get, post, auth, fetch } from @mlld/http

@run @get("https://api.github.com/users/octocat")
@run @post("https://httpbin.org/post", {"message": "hello"})
@run @auth.get("https://api.github.com/user", @token)

@data userData = @fetch.get("https://api.github.com/users/octocat")
@add [[User: {{userData.name}}]]
```

## docs

### Basic HTTP Methods

#### `get(url)`, `post(url, data)`, `put(url, data)`, `patch(url, data)`, `delete(url)`

Standard HTTP methods that print formatted responses to console.

```mlld
@run @get("https://api.github.com/users/octocat")
@run @post("https://httpbin.org/post", {"key": "value"})
@run @delete("https://httpbin.org/delete")
```

### Authenticated Requests

#### `auth.get(url, token)`, `auth.post(url, token, data)`

HTTP methods with Bearer token authentication.

```mlld
@run @auth.get("https://api.github.com/user", @githubToken)
@run @auth.post("https://api.github.com/user/repos", @token, {"name": "new-repo"})
```

### Advanced Requests

#### `request(url, options)`

Full control over fetch options.

```mlld
@data customOptions = {
  "method": "POST",
  "headers": {"Custom-Header": "value"},
  "body": "raw data"
}
@run @request("https://httpbin.org/post", @customOptions)
```

### Fetch Methods (Data-Returning)

#### `fetch.get(url)`, `fetch.post(url, data)`, `fetch.put(url, data)`, `fetch.patch(url, data)`, `fetch.delete(url)`

Return response data as native JavaScript objects for easy processing.

```mlld
@data userData = @fetch.get("https://api.github.com/users/octocat")
@data response = @fetch.post("https://httpbin.org/post", {"test": true})

@add [[User: {{userData.name}} has {{userData.public_repos}} repos]]
@add [[Posted data echo: {{response.json.test}}]]
```

### Display Methods

#### `display.get(url)`, `display.post(url, data)`

Format and display HTTP responses with pretty printing.

```mlld
@run @display.get("https://api.github.com/users/octocat")
@run @display.post("https://httpbin.org/post", {"message": "hello"})
```

## module

All HTTP methods use fetch with automatic JSON parsing and native return values. Display methods format output for readability:

```mlld-run
@exec get(url) = @run js [(
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
)]

@exec post(url, data) = @run js [(
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
)]

@exec put(url, data) = @run js [(
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
)]

@exec delete(url) = @run js [(
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
)]

@exec patch(url, data) = @run js [(
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
)]

@exec authGet(url, token) = @run js [(
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
)]

@exec authPost(url, token, data) = @run js [(
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
)]

@exec request(url, options) = @run js [(
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
)]

@exec getData(url) = @run js [(
  fetch(url)
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.json();
    })
    .catch(error => { throw error; })
)]

@exec postData(url, data) = @run js [(
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
)]

@exec putData(url, data) = @run js [(
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
)]

@exec patchData(url, data) = @run js [(
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
)]

@exec deleteData(url) = @run js [(
  fetch(url, {
    method: 'DELETE'
  })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.json();
    })
    .catch(error => { throw error; })
)]
```

Display methods for formatted output:

```mlld-run
@exec displayGet(url) = @run js [(
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
)]

@exec displayPost(url, data) = @run js [(
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
)]
```

This module uses a structured export to provide both individual methods and organized interfaces:

```mlld-run
@data module = {
  get: @get,
  post: @post,
  put: @put,
  patch: @patch,
  delete: @delete,
  
  auth: {
    get: @authGet,
    post: @authPost
  },
  
  request: @request,
  
  fetch: {
    get: @getData,
    post: @postData,
    put: @putData,
    patch: @patchData,
    delete: @deleteData
  },
  
  display: {
    get: @displayGet,
    post: @displayPost
  }
}
```
