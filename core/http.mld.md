---
name: http
author: mlld
version: 1.0.0
about: HTTP methods using fetch
needs: ["js"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["http", "api", "get", "put", "post", "delete", "rest"]
license: CC0
mlldVersion: "*"
---

# @mlld/http

HTTP methods using the fetch API for making REST calls. Provides both simple methods that print results and data-returning variants for processing.

## tldr

Quick HTTP requests with automatic JSON handling:

```mlld
@import { get, post, auth, data } from @mlld/http

@run @get("https://api.github.com/users/octocat")
@run @post("https://httpbin.org/post", {"message": "hello"})
@run @auth.get("https://api.github.com/user", @token)

@data userData = @data.get("https://api.github.com/users/octocat")
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

### Data-Returning Methods

#### `data.get(url)`, `data.post(url, data)`

Return response data instead of printing, useful for processing responses.

```mlld
@data userData = @data.get("https://api.github.com/users/octocat")
@data response = @data.post("https://httpbin.org/post", {"test": true})

@add [[User: {{userData.name}} has {{userData.public_repos}} repos]]
```

## module

All HTTP methods use fetch with automatic JSON parsing and error handling:

```mlld-run
@exec get(url) = @run js [(
  fetch(url)
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.text();
    })
    .then(text => {
      try {
        return JSON.stringify(JSON.parse(text), null, 2);
      } catch {
        return text;
      }
    })
    .then(result => console.log(result))
    .catch(error => console.error(`Error: ${error.message}`))
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
        return JSON.stringify(JSON.parse(text), null, 2);
      } catch {
        return text;
      }
    })
    .then(result => console.log(result))
    .catch(error => console.error(`Error: ${error.message}`))
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
        return JSON.stringify(JSON.parse(text), null, 2);
      } catch {
        return text;
      }
    })
    .then(result => console.log(result))
    .catch(error => console.error(`Error: ${error.message}`))
)]

@exec delete(url) = @run js [(
  fetch(url, { method: 'DELETE' })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.text();
    })
    .then(text => {
      try {
        return JSON.stringify(JSON.parse(text), null, 2);
      } catch {
        return text || 'Deleted successfully';
      }
    })
    .then(result => console.log(result))
    .catch(error => console.error(`Error: ${error.message}`))
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
        return JSON.stringify(JSON.parse(text), null, 2);
      } catch {
        return text;
      }
    })
    .then(result => console.log(result))
    .catch(error => console.error(`Error: ${error.message}`))
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
        return JSON.stringify(JSON.parse(text), null, 2);
      } catch {
        return text;
      }
    })
    .then(result => console.log(result))
    .catch(error => console.error(`Error: ${error.message}`))
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
        return JSON.stringify(JSON.parse(text), null, 2);
      } catch {
        return text;
      }
    })
    .then(result => console.log(result))
    .catch(error => console.error(`Error: ${error.message}`))
)]

@exec request(url, options) = @run js [(
  fetch(url, options)
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.text();
    })
    .then(text => {
      try {
        return JSON.stringify(JSON.parse(text), null, 2);
      } catch {
        return text;
      }
    })
    .then(result => console.log(result))
    .catch(error => console.error(`Error: ${error.message}`))
)]

@exec getData(url) = @run js [(
  fetch(url)
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      return response.json();
    })
    .then(data => JSON.stringify(data))
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
    .then(data => JSON.stringify(data))
    .catch(error => { throw error; })
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
  
  data: {
    get: @getData,
    post: @postData
  }
}
```
