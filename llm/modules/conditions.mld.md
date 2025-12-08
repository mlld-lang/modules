---
name: conditions
author: mlld
version: 1.0.0
about: Conditional checks for /when
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["conditions", "checks", "tests", "when", "truthy", "equals", "includes", "has", "is"]
license: CC0
mlldVersion: ">=2.0.0-rc78"
---

/needs {
  js: []
}

# @mlld/conditions

Conditional checks and logical operations for use with `/when` directives. Converts various data types and comparisons into truthy/falsy values that work with mlld's condition system.

## tldr

Essential utilities for building complex conditional logic in mlld:

```mlld
/import { equals, contains, gt, and, isEmpty } from @mlld/conditions

/var @users = ["alice", "bob", "charlie"]
/var @threshold = 10
/var @count = 15

/when @and(@gt(@count, @threshold), @contains(@users, "alice")) => /show "High count with Alice present"
/when @isEmpty(@users) => /show "No users found"
/when @equals(@count, 15) => /show "Exact match!"
```

## docs

### Boolean Conditions

#### `isTrue(value)`

Check if a value represents true (handles various truthy representations).

```mlld
/when @isTrue(@config.enabled) => /show "Feature is enabled"
```

#### `isFalse(value)` / `not(value)`

Check if a value is falsy or negate a condition.

```mlld
/when @not(@isEmpty(@userList)) => /show [[Users are available]]
```

### Equality & Comparison

#### `equals(a, b)` / `strictEquals(a, b)` / `notEquals(a, b)`

Compare values for equality or inequality.

```mlld
/when @equals(@status, "ready") => /show [[System is ready]]
/when @notEquals(@env, "production") => /show [[Development mode]]
```

#### `gt(a, b)` / `gte(a, b)` / `lt(a, b)` / `lte(a, b)`

Numeric comparisons (greater than, less than, etc.).

```mlld
/when @gt(@score, 90) => /show [[Excellent score!]]
/when @lte(@attempts, 3) => /show [[Within retry limit]]
```

### String Operations

#### `contains(str, substring)` / `startsWith(str, prefix)` / `endsWith(str, suffix)`

String matching and pattern checks.

```mlld
/when @contains(@filename, ".test.") => /show [[Test file detected]]
/when @startsWith(@branch, "feature/") => /show [[Feature branch]]
```

#### `matches(str, pattern)`

Regular expression matching.

```mlld
/when @matches(@email, "^[^@]+@[^@]+$") => /show [[Valid email format]]
```

### Collection Operations

#### `isEmpty(value)` / `notEmpty(value)`

Check if arrays, objects, or strings are empty.

```mlld
/when @isEmpty(@errors) => /show [[No errors found]]
/when @notEmpty(@todoItems) => /show [[Tasks remaining]]
```

#### `includes(array, item)` / `hasLength(array, length)` / `hasMinLength(array, minLength)`

Array content and size checks.

```mlld
/when @includes(@tags, "urgent") => /show [[Urgent task]]
/when @hasMinLength(@results, 1) => /show [[Results available]]
```

### Type Checking

#### `isString(value)` / `isNumber(value)` / `isArray(value)` / `isObject(value)`

Runtime type validation.

```mlld
/when @isArray(@config.items) => /show [[Items is an array]]
/when @isNumber(@port) => /show [[Valid port number]]
```

### Logical Operations

#### `and(a, b)` / `or(a, b)` / `xor(a, b)`

Combine multiple conditions.

```mlld
/when @and(@fileExists("config.json"), @isTrue(@config.enabled)) => /show [[Config ready]]
/when @or(@isEmpty(@errors), @isEmpty(@warnings)) => /show [[Some issues cleared]]
```

### Existence Checks

#### `exists(value)` / `defined(value)`

Check for null/undefined values.

```mlld
/when @exists(@user.email) => /show [[Email available]]
/when @defined(@config.timeout) => /show [[Timeout configured]]
```

## module

These functions convert various conditions to empty/non-empty strings for mlld's `/when` directive:

```mlld-run
/exe @isTrue(@value) = js {(value === true || value === "true" || value === "1" || value === 1 ? "true" : "")}
/exe @isFalse(@value) = js {(value === false || value === "false" || value === "0" || value === 0 || value === "" || value === null || value === undefined ? "true" : "")}
/exe @not(@value) = js {(value === "" || value === false || value === "false" || value === "0" || value === 0 || value === null || value === undefined ? "true" : "")}

/exe @equals(@a, @b) = js {(a == b ? "true" : "")}
/exe @strictEquals(@a, @b) = js {(a === b ? "true" : "")}
/exe @notEquals(@a, @b) = js {(a != b ? "true" : "")}

/exe @gt(@a, @b) = js {(Number(a) > Number(b) ? "true" : "")}
/exe @gte(@a, @b) = js {(Number(a) >= Number(b) ? "true" : "")}
/exe @lt(@a, @b) = js {(Number(a) < Number(b) ? "true" : "")}
/exe @lte(@a, @b) = js {(Number(a) <= Number(b) ? "true" : "")}

/exe @contains(@str, @substring) = js {(String(str).includes(String(substring)) ? "true" : "")}
/exe @startsWith(@str, @prefix) = js {(String(str).startsWith(String(prefix)) ? "true" : "")}
/exe @endsWith(@str, @suffix) = js {(String(str).endsWith(String(suffix)) ? "true" : "")}
/exe @matches(@str, @pattern) = js {(new RegExp(pattern).test(String(str)) ? "true" : "")}
/exe @isEmpty(@value) = js {(value === "" || value === null || value === undefined || (Array.isArray(value) && value.length === 0) || (typeof value === "object" && Object.keys(value).length === 0) ? "true" : "")}
/exe @notEmpty(@value) = js {(value !== "" && value !== null && value !== undefined && !(Array.isArray(value) && value.length === 0) && !(typeof value === "object" && Object.keys(value).length === 0) ? "true" : "")}

/exe @includes(@array, @item) = js {(Array.isArray(array) && array.includes(item) ? "true" : "")}
/exe @hasLength(@array, @length) = js {(Array.isArray(array) && array.length === Number(length) ? "true" : "")}
/exe @hasMinLength(@array, @minLength) = js {(Array.isArray(array) && array.length >= Number(minLength) ? "true" : "")}

/exe @isString(@value) = js {(typeof value === "string" ? "true" : "")}
/exe @isNumber(@value) = js {(typeof value === "number" && !isNaN(value) ? "true" : "")}
/exe @isArray(@value) = js {(Array.isArray(value) ? "true" : "")}
/exe @isObject(@value) = js {(value !== null && typeof value === "object" && !Array.isArray(value) ? "true" : "")}

/exe @and(@a, @b) = js {(a !== "" && b !== "" ? "true" : "")}
/exe @or(@a, @b) = js {(a !== "" || b !== "" ? "true" : "")}
/exe @xor(@a, @b) = js {((a !== "" && b === "") || (a === "" && b !== "") ? "true" : "")}

/exe @exists(@value) = js {(value !== undefined && value !== null ? "true" : "")}
/exe @defined(@value) = js {(value !== undefined ? "true" : "")}

>> Shadow environment to make functions available to each other
/exe js = { isTrue, isFalse, not, equals, strictEquals, notEquals, gt, gte, lt, lte, contains, startsWith, endsWith, matches, isEmpty, notEmpty, includes, hasLength, hasMinLength, isString, isNumber, isArray, isObject, and, or, xor, exists, defined }

/export { @isTrue, @isFalse, @not, @equals, @strictEquals, @notEquals, @gt, @gte, @lt, @lte, @contains, @startsWith, @endsWith, @matches, @isEmpty, @notEmpty, @includes, @hasLength, @hasMinLength, @isString, @isNumber, @isArray, @isObject, @and, @or, @xor, @exists, @defined }
```
