---
name: conditions
author: mlld
version: 1.0.0
about: Conditional checks for @when
needs: ["js"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["conditions", "checks", "tests", "when", "truthy", "equals", "includes", "has", "is"]
license: CC0
mlldVersion: "*"
---

# @mlld/conditions

Conditional checks and logical operations for use with `@when` directives. Converts various data types and comparisons into truthy/falsy values that work with mlld's condition system.

## tldr

Essential utilities for building complex conditional logic in mlld:

```mlld
@import { equals, contains, gt, and, isEmpty } from @mlld/conditions

@data users = ["alice", "bob", "charlie"]
@data threshold = 10
@data count = 15

@when @and(@gt(@count, @threshold), @contains(@users, "alice")) => @add [[High count with Alice present]]
@when @isEmpty(@users) => @add [[No users found]]
@when @equals(@count, 15) => @add [[Exact match!]]
```

## docs

### Boolean Conditions

#### `isTrue(value)`

Check if a value represents true (handles various truthy representations).

```mlld
@when @isTrue(@config.enabled) => @add [[Feature is enabled]]
```

#### `isFalse(value)` / `not(value)`

Check if a value is falsy or negate a condition.

```mlld
@when @not(@isEmpty(@userList)) => @add [[Users are available]]
```

### Equality & Comparison

#### `equals(a, b)` / `strictEquals(a, b)` / `notEquals(a, b)`

Compare values for equality or inequality.

```mlld
@when @equals(@status, "ready") => @add [[System is ready]]
@when @notEquals(@env, "production") => @add [[Development mode]]
```

#### `gt(a, b)` / `gte(a, b)` / `lt(a, b)` / `lte(a, b)`

Numeric comparisons (greater than, less than, etc.).

```mlld
@when @gt(@score, 90) => @add [[Excellent score!]]
@when @lte(@attempts, 3) => @add [[Within retry limit]]
```

### String Operations

#### `contains(str, substring)` / `startsWith(str, prefix)` / `endsWith(str, suffix)`

String matching and pattern checks.

```mlld
@when @contains(@filename, ".test.") => @add [[Test file detected]]
@when @startsWith(@branch, "feature/") => @add [[Feature branch]]
```

#### `matches(str, pattern)`

Regular expression matching.

```mlld
@when @matches(@email, "^[^@]+@[^@]+$") => @add [[Valid email format]]
```

### Collection Operations

#### `isEmpty(value)` / `notEmpty(value)`

Check if arrays, objects, or strings are empty.

```mlld
@when @isEmpty(@errors) => @add [[No errors found]]
@when @notEmpty(@todoItems) => @add [[Tasks remaining]]
```

#### `includes(array, item)` / `hasLength(array, length)` / `hasMinLength(array, minLength)`

Array content and size checks.

```mlld
@when @includes(@tags, "urgent") => @add [[Urgent task]]
@when @hasMinLength(@results, 1) => @add [[Results available]]
```

### Type Checking

#### `isString(value)` / `isNumber(value)` / `isArray(value)` / `isObject(value)`

Runtime type validation.

```mlld
@when @isArray(@config.items) => @add [[Items is an array]]
@when @isNumber(@port) => @add [[Valid port number]]
```

### Logical Operations

#### `and(a, b)` / `or(a, b)` / `xor(a, b)`

Combine multiple conditions.

```mlld
@when @and(@fileExists("config.json"), @isTrue(@config.enabled)) => @add [[Config ready]]
@when @or(@isEmpty(@errors), @isEmpty(@warnings)) => @add [[Some issues cleared]]
```

### Existence Checks

#### `exists(value)` / `defined(value)`

Check for null/undefined values.

```mlld
@when @exists(@user.email) => @add [[Email available]]
@when @defined(@config.timeout) => @add [[Timeout configured]]
```

## module

These functions convert various conditions to empty/non-empty strings for mlld's `@when` directive:

```mlld-run
@exec isTrue(value) = @run js [(value === true || value === "true" || value === "1" || value === 1 ? "true" : "")]
@exec isFalse(value) = @run js [(value === false || value === "false" || value === "0" || value === 0 || value === "" || value === null || value === undefined ? "true" : "")]
@exec not(value) = @run js [(value === "" || value === false || value === "false" || value === "0" || value === 0 || value === null || value === undefined ? "true" : "")]

@exec equals(a, b) = @run js [(a == b ? "true" : "")]
@exec strictEquals(a, b) = @run js [(a === b ? "true" : "")]
@exec notEquals(a, b) = @run js [(a != b ? "true" : "")]

@exec gt(a, b) = @run js [(Number(a) > Number(b) ? "true" : "")]
@exec gte(a, b) = @run js [(Number(a) >= Number(b) ? "true" : "")]
@exec lt(a, b) = @run js [(Number(a) < Number(b) ? "true" : "")]
@exec lte(a, b) = @run js [(Number(a) <= Number(b) ? "true" : "")]

@exec contains(str, substring) = @run js [(String(str).includes(String(substring)) ? "true" : "")]
@exec startsWith(str, prefix) = @run js [(String(str).startsWith(String(prefix)) ? "true" : "")]
@exec endsWith(str, suffix) = @run js [(String(str).endsWith(String(suffix)) ? "true" : "")]
@exec matches(str, pattern) = @run js [(new RegExp(pattern).test(String(str)) ? "true" : "")]
@exec isEmpty(value) = @run js [(value === "" || value === null || value === undefined || (Array.isArray(value) && value.length === 0) || (typeof value === "object" && Object.keys(value).length === 0) ? "true" : "")]
@exec notEmpty(value) = @run js [(value !== "" && value !== null && value !== undefined && !(Array.isArray(value) && value.length === 0) && !(typeof value === "object" && Object.keys(value).length === 0) ? "true" : "")]

@exec includes(array, item) = @run js [(Array.isArray(array) && array.includes(item) ? "true" : "")]
@exec hasLength(array, length) = @run js [(Array.isArray(array) && array.length === Number(length) ? "true" : "")]
@exec hasMinLength(array, minLength) = @run js [(Array.isArray(array) && array.length >= Number(minLength) ? "true" : "")]

@exec isString(value) = @run js [(typeof value === "string" ? "true" : "")]
@exec isNumber(value) = @run js [(typeof value === "number" && !isNaN(value) ? "true" : "")]
@exec isArray(value) = @run js [(Array.isArray(value) ? "true" : "")]
@exec isObject(value) = @run js [(value !== null && typeof value === "object" && !Array.isArray(value) ? "true" : "")]

@exec and(a, b) = @run js [(a !== "" && b !== "" ? "true" : "")]
@exec or(a, b) = @run js [(a !== "" || b !== "" ? "true" : "")]
@exec xor(a, b) = @run js [((a !== "" && b === "") || (a === "" && b !== "") ? "true" : "")]

@exec exists(value) = @run js [(value !== undefined && value !== null ? "true" : "")]
@exec defined(value) = @run js [(value !== undefined ? "true" : "")]
```

