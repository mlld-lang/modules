# @mlld/http - HTTP Client

HTTP client using JavaScript fetch API for REST APIs and web requests (v2.0).

## Installation

```mlld
@import { * } from @mlld/http
```

## Basic Usage

```mlld
@import { get, post, put, delete } from @mlld/http

>> GET request
@run @get("https://api.example.com/users")

>> POST request
@data userData = { "name": "John", "email": "john@example.com" }
@run @post("https://api.example.com/users", @userData)

>> PUT request
@run @put("https://api.example.com/users/123", @userData)

>> DELETE request
@run @delete("https://api.example.com/users/123")

>> PATCH request
@run @patch("https://api.example.com/users/123", { "name": "John Doe" })
```

## Authenticated Requests

```mlld
@import { authGet, authPost } from @mlld/http

@data token = "your-api-token"

>> Authenticated GET
@run @authGet("https://api.example.com/profile", @token)

>> Authenticated POST
@data data = { "message": "Hello" }
@run @authPost("https://api.example.com/messages", @token, @data)
```

## Advanced Usage

### Custom Request Options

```mlld
@import { request } from @mlld/http

@data options = {
  "method": "POST",
  "headers": {
    "Content-Type": "application/json",
    "X-API-Key": "secret-key"
  },
  "body": "{\"custom\": \"data\"}"
}

@run @request("https://api.example.com/custom", @options)
```

### Getting Data (Return Values)

For cases where you need to capture the response data instead of printing it:

```mlld
@import { getData, postData } from @mlld/http

>> Get data and store in variable
@data users = @getData("https://api.example.com/users")
@add [[Found {{users.length}} users]]

>> Post and get response
@data newUser = { "name": "Jane", "email": "jane@example.com" }
@data created = @postData("https://api.example.com/users", @newUser)
@add [[Created user with ID: {{created.id}}]]
```

## API Reference

### Basic Methods (Print Results)
- `get(url)` - GET request
- `post(url, data)` - POST request with JSON data
- `put(url, data)` - PUT request with JSON data
- `patch(url, data)` - PATCH request with JSON data
- `delete(url)` - DELETE request

### Authenticated Methods
- `authGet(url, token)` - GET with Bearer token
- `authPost(url, token, data)` - POST with Bearer token

### Advanced Methods
- `request(url, options)` - Custom request with full fetch options

### Data Methods (Return Results)
- `getData(url)` - GET request that returns JSON data
- `postData(url, data)` - POST request that returns JSON data

## Real-World Examples

### GitHub API Integration
```mlld
@import { authGet } from @mlld/http

@text github_token = $GITHUB_TOKEN
@run @authGet("https://api.github.com/user/repos", @github_token)
```

### Webhook Notifications
```mlld
@import { post } from @mlld/http

@data notification = {
  "text": "Deployment completed successfully",
  "channel": "#alerts"
}
@run @post("https://hooks.slack.com/services/...", @notification)
```

### Data Processing
```mlld
@import { getData } from @mlld/http

@data users = @getData("https://api.example.com/users")
@data activeUsers = @run js [(JSON.parse(users).filter(u => u.active).length)]
@add [[Active users: {{activeUsers}}]]
```

## Migration from v1

Version 2.0 uses JavaScript fetch instead of curl:
- No longer requires curl to be installed
- Better error handling and JSON parsing
- Consistent behavior across platforms
- New `patch()` method and data-returning variants

## Notes

- All methods automatically parse JSON responses when possible
- Non-JSON responses are returned as plain text
- Pretty-printing is applied to JSON responses for readability
- The data methods (`getData`, `postData`) return stringified JSON for use with mlld variables
- Error messages include HTTP status codes and descriptions