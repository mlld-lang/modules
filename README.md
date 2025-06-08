# mlld Standard Library Modules

This document describes the official standard library modules for the mlld prompt scripting language.

## Module Organization

Modules are organized into three categories:

- **core/** - Stable, proven modules with reliable APIs
- **new/** - Experimental modules with promising but evolving APIs
- **ideas/** - Conceptual modules for exploration and validation

## Core Modules

These modules have stable APIs and are recommended for production use.

### @mlld/core
Essential utilities for mlld including conditional helpers, type checking, and basic operations.

**Key Features:**
- Boolean and comparison operators for `@when` conditions
- Type checking utilities
- String and array validation
- File system checks
- Logical operations (and, or, xor)

### @mlld/http
HTTP client using JavaScript fetch API for REST APIs and web requests.

**Key Features:**
- All standard HTTP methods (GET, POST, PUT, PATCH, DELETE)
- Authenticated requests with Bearer tokens
- Custom request options
- Data-returning variants for capturing responses
- Automatic JSON parsing and pretty-printing

### @mlld/string
Comprehensive string manipulation utilities for text processing and formatting.

**Key Features:**
- Case transformations (camelCase, snake_case, etc.)
- String splitting and joining
- Search and replace operations
- Padding and formatting
- Validation utilities
- URL encoding/decoding

### @mlld/array
Array manipulation utilities for data processing and transformation.

**Key Features:**
- Filtering and searching
- Mapping and transformation
- Aggregation (sum, avg, min, max)
- Grouping and partitioning
- Array utilities (range, chunk, zip)

## New Modules

These modules are experimental with evolving APIs. Use with caution in production.

### @mlld/bundle
Assemble code and directory contents for LLM context (formerly @mlld/fs).

**Key Features:**
- Convert directory structures to XML format
- Convert directory structures to Markdown format
- Tree view of directory structure

### @mlld/ai
Simple wrappers for AI CLI tools.

**Key Features:**
- LLM CLI (simonw/llm) integration
- Claude Code CLI wrapper
- Codex CLI (OpenAI) wrappers

## Ideas Modules

*Currently empty - future experimental concepts will be added here.*

## Usage Examples

### Using @mlld/core for Conditions

```mlld
@import { gt, contains, and, fileExists } from @mlld/core

@data score = 85
@data name = "Alice"

>> Simple conditions
@when @gt(@score, 80) => @add "Great score!"
@when @contains(@name, "li") => @add "Name contains 'li'"

>> Combined conditions
@data highScore = @gt(@score, 80)
@data hasA = @contains(@name, "A")
@when @and(@highScore, @hasA) => @add "High score AND name has 'A'"

>> File checks
@when @fileExists("config.json") => @import { config } from "./config.json"
```

### HTTP Requests with @mlld/http

```mlld
@import { get, post, getData } from @mlld/http

>> Simple GET request (prints response)
@run @get("https://api.github.com/users/github")

>> POST with data
@data payload = { "title": "New Issue", "body": "Description here" }
@run @post("https://api.example.com/issues", @payload)

>> Get data for processing
@data users = @getData("https://api.example.com/users")
@add [[Found {{users.length}} users]]
```

### String Processing with @mlld/string

```mlld
@import { upper, split, join, template } from @mlld/string

@text message = "hello world"
@text shouting = @upper(@message)
@data words = @split(@message, " ")
@text reversed = @join(@words, "-")

@text tmpl = "Welcome {{name}} to {{place}}!"
@data vars = { "name": "Alice", "place": "Wonderland" }
@text greeting = @template(@tmpl, @vars)
```

### Array Operations with @mlld/array

```mlld
@import { filter, pluck, sum, groupBy } from @mlld/array

@data orders = [
  { "product": "laptop", "price": 999, "category": "electronics" },
  { "product": "chair", "price": 299, "category": "furniture" },
  { "product": "phone", "price": 699, "category": "electronics" }
]

@data electronics = @filter(@orders, "category", "electronics")
@data prices = @pluck(@orders, "price")
@data total = @sum(@orders, "price")
@data byCategory = @groupBy(@orders, "category")
```

## Module Import Paths

Modules are imported based on their category:

```mlld
# Core modules
@import { gt, contains } from @mlld/core
@import { get, post } from @mlld/http

# New modules
@import { xml, md } from @mlld/new/bundle
@import { llm } from @mlld/new/ai

# Ideas modules (when available)
@import { consensus } from @mlld/ideas/orchestrate
```

## Philosophy

These modules follow mlld's core philosophy:
- **Simplicity** - Each function does one thing well
- **Orchestration** - Modules provide tools to extend mlld files' ability to serve as orchestration rather than programming
**Readable source** - Module source code should be understandable
- **Composable utilities** - Functions work well together

## Contributing

When creating new modules for the standard library:
1. Use the explicit `@data module` export pattern
2. Prefix internal helpers with underscore (e.g., `_helper`)
3. Include comprehensive documentation
4. Follow existing naming conventions
5. Keep functions focused and simple
