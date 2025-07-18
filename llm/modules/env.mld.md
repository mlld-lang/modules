---
name: env
author: mlld
version: 1.0.0
about: Environment variable validation and management
needs: ["js"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["environment", "env", "validation", "config", "secrets", "ci", "variables"]
license: CC0
mlldVersion: "*"
---

# @mlld/env

Environment variable validation and management for mlld workflows. Ensures required variables exist, provides secure access, and helps detect CI environments.

## tldr

Essential environment management:

```mlld
/import { env } from @mlld/env

>> Validate required variables
/var @valid = @env.validate(["API_KEY", "DATABASE_URL"])
/when @valid.valid => /show "All environment variables present"
/when !@valid.valid => /show `Missing: @valid.missing`

>> Get with fallback
/var @port = @env.get("PORT", "3000")
/show `Server running on port @port`

>> Check if in CI
/when @env.isCI() => /show "Running in CI environment"
```

## docs

### Validation

#### `validate(variables)`

Validate that environment variables exist and have content. Accepts a single variable name or an array.

```mlld
>> Single variable
/var @check = @env.validate("API_KEY")
/show @check.summary

>> Multiple variables
/var @validation = @env.validate(["DATABASE_URL", "REDIS_URL", "SECRET_KEY"])
/when !@validation.valid => /show `Missing variables: @validation.missing`

>> Access detailed results
/var @details = @env.validate(["API_KEY", "TOKEN"])
/show `Checked: @details.checked, Found: @details.found`
```

The validation result includes:
- `valid`: Boolean indicating if all variables are present
- `checked`: Number of variables checked
- `found`: Number of variables found
- `missing`: Array of missing variable names
- `summary`: Human-readable summary message

#### `require(variables)`

Like validate, but shows an error and returns empty string if any variables are missing. Useful for fail-fast scenarios.

```mlld
>> This will show error and stop if variables are missing
/var @ready = @env.require(["API_KEY", "DATABASE_URL"])
/when @ready => /show "Environment ready"
```

### Access

#### `get(name, fallback?)`

Get an environment variable with optional fallback value.

```mlld
/var @apiUrl = @env.get("API_URL", "https://api.example.com")
/var @debug = @env.get("DEBUG", "false")
/var @workers = @env.get("WORKER_COUNT", "4")
```

#### `getAll(names)`

Get multiple environment variables at once.

```mlld
/var @config = @env.getAll(["PORT", "HOST", "PROTOCOL"])
/show `Server: @config.PROTOCOL://@config.HOST:@config.PORT`
```

### Security

#### `mask(value)`

Mask sensitive values for logging (shows first 3 and last 3 characters).

```mlld
/var @token = @env.get("API_TOKEN")
/var @masked = @env.mask(@token)
/show `Using token: @masked`  >> "Using token: abc***xyz"
```

#### `exists(name)`

Check if an environment variable exists without retrieving its value.

```mlld
/when @env.exists("PRODUCTION") => /show "Production mode enabled"
```

### CI/CD Detection

#### `isCI()`

Detect if running in a continuous integration environment.

```mlld
/var @ci = @env.isCI()
/when @ci => /show "Running in CI"
/when !@ci => /show "Running locally"
```

#### `ciProvider()`

Get the name of the CI provider if detected.

```mlld
/var @provider = @env.ciProvider()
/show `CI Provider: @provider`  >> "GitHub Actions", "GitLab CI", etc.
```

### Configuration

#### `load(path)`

Load environment variables from a file (like .env).

```mlld
/run @env.load(".env.local")
/var @loaded = @env.get("NEW_VARIABLE")
```

#### `export(name, value)`

Export a new environment variable for child processes.

```mlld
/run @env.export("MY_VAR", "my-value")
/run {echo $MY_VAR}  >> "my-value"
```

## module

Environment variable utilities:

```mlld-run
>> Validation
/exe @validate(@required) = js {
  // Handle both single string and array inputs
  const vars = Array.isArray(required) ? required : [required];
  
  const results = vars.map(varName => {
    const value = process.env[varName];
    const exists = value && value.trim().length > 0;
    
    return {
      name: varName,
      exists: exists,
      length: exists ? value.length : 0
    };
  });
  
  const missing = results.filter(r => !r.exists).map(r => r.name);
  const allValid = missing.length === 0;
  
  return {
    valid: allValid,
    checked: vars.length,
    found: vars.length - missing.length,
    missing: missing,
    results: results,
    summary: allValid 
      ? `✅ All ${vars.length} environment variables are present`
      : `❌ Missing ${missing.length} of ${vars.length} required variables: ${missing.join(', ')}`
  };
}

/exe @require(@variables) = js {
  const result = @validate(variables);
  if (!result.valid) {
    console.error(result.summary);
    return "";
  }
  return "true";
}

>> Access
/exe @get(@name, @fallback) = js {
  return process.env[name] || fallback || '';
}

/exe @getAll(@names) = js {
  const result = {};
  const varNames = Array.isArray(names) ? names : [names];
  varNames.forEach(name => {
    result[name] = process.env[name] || '';
  });
  return result;
}

>> Security
/exe @mask(@value) = js {
  if (!value || value.length < 8) {
    return '***';
  }
  return value.substring(0, 3) + '***' + value.substring(value.length - 3);
}

/exe @exists(@name) = js {
  return process.env.hasOwnProperty(name) ? "true" : "";
}

>> CI/CD Detection
/exe @isCI() = js {
  // Check common CI environment variables
  const ciVars = ['CI', 'CONTINUOUS_INTEGRATION', 'BUILD_ID', 'CI_NAME'];
  const providers = {
    'GITHUB_ACTIONS': 'GitHub Actions',
    'GITLAB_CI': 'GitLab CI',
    'CIRCLE': 'CircleCI',
    'TRAVIS': 'Travis CI',
    'JENKINS_URL': 'Jenkins',
    'TEAMCITY_VERSION': 'TeamCity',
    'BUILDKITE': 'Buildkite',
    'DRONE': 'Drone',
    'CODEBUILD_BUILD_ID': 'AWS CodeBuild',
    'TF_BUILD': 'Azure DevOps'
  };
  
  // Check generic CI vars
  for (const ciVar of ciVars) {
    if (process.env[ciVar] === 'true' || process.env[ciVar] === '1') {
      return "true";
    }
  }
  
  // Check provider-specific vars
  for (const providerVar of Object.keys(providers)) {
    if (process.env[providerVar]) {
      return "true";
    }
  }
  
  return "";
}

/exe @ciProvider() = js {
  const providers = {
    'GITHUB_ACTIONS': 'GitHub Actions',
    'GITLAB_CI': 'GitLab CI',
    'CIRCLE': 'CircleCI',
    'TRAVIS': 'Travis CI',
    'JENKINS_URL': 'Jenkins',
    'TEAMCITY_VERSION': 'TeamCity',
    'BUILDKITE': 'Buildkite',
    'DRONE': 'Drone',
    'CODEBUILD_BUILD_ID': 'AWS CodeBuild',
    'TF_BUILD': 'Azure DevOps',
    'BITRISE_IO': 'Bitrise',
    'BUDDY_WORKSPACE_ID': 'Buddy',
    'WERCKER': 'Wercker',
    'SEMAPHORE': 'Semaphore',
    'APPVEYOR': 'AppVeyor'
  };
  
  for (const [envVar, name] of Object.entries(providers)) {
    if (process.env[envVar]) {
      return name;
    }
  }
  
  // Check for generic CI
  if (process.env.CI === 'true' || process.env.CI === '1') {
    return 'Unknown CI';
  }
  
  return 'Not in CI';
}

>> Configuration
/exe @load(@path) = sh {
  if [ -f "$path" ]; then
    # Export variables from file
    set -a
    source "$path"
    set +a
    echo "✅ Loaded environment from $path"
  else
    echo "❌ File not found: $path"
  fi
}

/exe @export(@name, @value) = sh {
  export "$name"="$value"
  echo "✅ Exported $name"
}

>> Export module structure
/var @env = {
  validate: @validate,
  require: @require,
  get: @get,
  getAll: @getAll,
  mask: @mask,
  exists: @exists,
  isCI: @isCI,
  ciProvider: @ciProvider,
  load: @load,
  export: @export
}
```