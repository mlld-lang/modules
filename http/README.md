# @mlld/http

Simple HTTP client wrappers for REST APIs and web requests.

## Installation

```mlld
@import { http } from @mlld/http
```

## Usage

### Basic HTTP Methods

```mlld
>> GET request
@run response = @http.get("https://api.example.com/users")

>> POST with JSON data
@data payload = {"name": "Alice", "email": "alice@example.com"}
@run result = @http.post("https://api.example.com/users", @payload)

>> PUT to update
@data update = {"name": "Alice Smith"}
@run updated = @http.put("https://api.example.com/users/123", @update)

>> DELETE resource
@run deleted = @http.delete("https://api.example.com/users/123")
```

### Authenticated Requests

```mlld
@text token = "your-api-token-here"
@path api_url = "https://api.github.com"

>> Authenticated GET
@run repos = @http.auth.get("@api_url/user/repos", @token)

>> Authenticated POST
@data new_repo = {"name": "my-project", "private": false}
@run created = @http.auth.post("@api_url/user/repos", @token, @new_repo)
```

### Real-World Examples

#### GitHub API Integration
```mlld
@text github_token = $GITHUB_TOKEN
@run issues = @http.auth.get("https://api.github.com/repos/owner/repo/issues", @github_token)
@add [[Found {{issues.length}} issues]]
```

#### Webhook Notifications
```mlld
@data notification = {
  "text": "Deployment completed successfully",
  "channel": "#alerts"
}
@run webhook_result = @http.post("https://hooks.slack.com/services/...", @notification)
```

#### Health Checks
```mlld
@run health = @http.get("https://api.myservice.com/health")
@add [[Service status: {{health.status}}]]
```

## API Reference

- `http.get(url)` - GET request
- `http.post(url, data)` - POST with JSON data
- `http.put(url, data)` - PUT with JSON data  
- `http.delete(url)` - DELETE request
- `http.auth.get(url, token)` - Authenticated GET with Bearer token
- `http.auth.post(url, token, data)` - Authenticated POST with Bearer token

## Requirements

- `curl` command-line tool (available on most systems)

## Notes

- All requests return raw response text
- JSON data is automatically serialized
- Bearer token authentication is used for auth methods
- Responses include HTTP headers by default