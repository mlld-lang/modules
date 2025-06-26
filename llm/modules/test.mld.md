---
name: test
author: mlld
version: 1.0.0
about: Core assertion functions for mlld testing framework
needs: ["js"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["test", "assert", "testing", "assertions", "unit-test"]
license: CC0
mlldVersion: "*"
---

# @mlld/test

Core assertion functions for mlld testing framework. All functions return native booleans for simple test assertions.

## tldr

Test your mlld scripts with simple assertions:

```mlld
/import { eq, deepEq, ok, contains } from @mlld/test

/var @result = @calculateSum(2, 3)
/when @eq(@result, 5) => /show [[✓ Sum calculation correct]]

/var @data = { "name": "test", "items": [1, 2, 3] }
/when @deepEq(@data.items, [1, 2, 3]) => /show [[✓ Array matches]]

/when @contains(@output, "success") => /show [[✓ Output contains success message]]
```

## docs

### Basic Assertions

#### `eq(a, b)`
Strict equality check (===).

```mlld
/when @eq(@status, "ready") => /show [[✓ Status is ready]]
```

#### `deepEq(a, b)`
Deep equality check using JSON comparison.

```mlld
/when @deepEq(@config, @expectedConfig) => /show [[✓ Config matches expected]]
```

#### `ok(value)` / `notOk(value)`
Truthy/falsy checks.

```mlld
/when @ok(@user.isActive) => /show [[✓ User is active]]
/when @notOk(@errors) => /show [[✓ No errors]]
```

### Comparison Assertions

#### `gt(a, b)` / `gte(a, b)` / `lt(a, b)` / `lte(a, b)`
Numeric comparisons.

```mlld
/when @gt(@score, 90) => /show [[✓ High score achieved]]
/when @lte(@retries, 3) => /show [[✓ Within retry limit]]
```

### Container Assertions

#### `includes(container, item)`
Check if array or string contains an item.

```mlld
/when @includes(@tags, "important") => /show [[✓ Has important tag]]
/when @includes(@message, "error") => /show [[✓ Error detected]]
```

#### `contains(haystack, needle)`
String substring check.

```mlld
/when @contains(@log, "SUCCESS") => /show [[✓ Log shows success]]
```

#### `len(value)`
Get length of strings, arrays, or object keys.

```mlld
/when @eq(@len(@items), 5) => /show [[✓ Exactly 5 items]]
```

### Error Assertions

#### `throws(fn)`
Check if a function throws an error.

```mlld
/exe @badOperation() = js { throw new Error("fail") }
/when @throws(@badOperation) => /show [[✓ Function throws as expected]]
```

## module

```mlld-run
>> Basic Assertions
/exe @eq(a, b) = js {
  return @a === @b
}

/exe @deepEq(a, b) = js {
  return JSON.stringify(@a) === JSON.stringify(@b)
}

/exe @ok(value) = js {
  return !!@value
}

/exe @notOk(value) = js {
  return !@value
}

>> Comparison Assertions
/exe @gt(a, b) = js {
  return @a > @b
}

/exe @gte(a, b) = js {
  return @a >= @b
}

/exe @lt(a, b) = js {
  return @a < @b
}

/exe @lte(a, b) = js {
  return @a <= @b
}

>> Container Assertions
/exe @includes(container, item) = js {
  if (typeof @container === 'string') {
    return @container.includes(@item)
  }
  if (Array.isArray(@container)) {
    return @container.includes(@item)
  }
  return false
}

/exe @contains(haystack, needle) = js {
  return String(@haystack).includes(String(@needle))
}

/exe @len(value) = js {
  if (typeof @value === 'string' || Array.isArray(@value)) {
    return @value.length
  }
  if (typeof @value === 'object' && @value !== null) {
    return Object.keys(@value).length
  }
  return 0
}

>> Error Assertions
/exe @throws(fn) = js {
  try {
    @fn()
    return false
  } catch {
    return true
  }
}

>> Shadow environment to make functions available to each other
/exe js = { eq, deepEq, ok, notOk, gt, gte, lt, lte, includes, contains, len, throws }
```