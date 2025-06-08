# @mlld/core - Core Utilities

Essential utilities for mlld including conditional helpers, type checking, and basic operations.

## Installation

```mlld
@import { * } from @mlld/core
```

## Conditional Helpers

These functions are designed to work with mlld's `@when` directive, which only checks if a value is truthy (non-empty string) or falsy (empty string).

### Boolean Conditions

- `isTrue(value)` - Returns "true" if value is true, "true", "1", or 1
- `isFalse(value)` - Returns "true" if value is false, "false", "0", 0, "", null, or undefined
- `not(value)` - Negates a truthy/falsy value

### Comparisons

- `equals(a, b)` - Loose equality (==)
- `strictEquals(a, b)` - Strict equality (===)
- `notEquals(a, b)` - Not equal (!=)
- `gt(a, b)` - Greater than
- `gte(a, b)` - Greater than or equal
- `lt(a, b)` - Less than
- `lte(a, b)` - Less than or equal

### String Operations

- `contains(str, substring)` - Check if string contains substring
- `startsWith(str, prefix)` - Check if string starts with prefix
- `endsWith(str, suffix)` - Check if string ends with suffix
- `matches(str, pattern)` - Check if string matches regex pattern
- `isEmpty(value)` - Check if value is empty (works with strings, arrays, objects)
- `notEmpty(value)` - Check if value is not empty

### Array Operations

- `includes(array, item)` - Check if array includes item
- `hasLength(array, length)` - Check if array has specific length
- `hasMinLength(array, minLength)` - Check if array has minimum length

### Type Checking

- `isString(value)` - Check if value is a string
- `isNumber(value)` - Check if value is a number (not NaN)
- `isArray(value)` - Check if value is an array
- `isObject(value)` - Check if value is an object (not array or null)

### Logical Operations

- `and(a, b)` - Logical AND of two conditions
- `or(a, b)` - Logical OR of two conditions
- `xor(a, b)` - Logical XOR of two conditions

### Existence Checks

- `exists(value)` - Check if value is not null or undefined
- `defined(value)` - Check if value is not undefined

### File System Checks

- `fileExists(path)` - Check if file exists
- `dirExists(path)` - Check if directory exists
- `pathExists(path)` - Check if path exists (file or directory)

## Usage Examples

```mlld
@import { gt, contains, and } from @mlld/core

@data score = 85
@data grade = "A"

>> Simple comparison
@when @gt(@score, 90) => @add "Excellent!"

>> String check
@when @contains(@grade, "A") => @add "Top grade!"

>> Combined conditions
@data isHighScore = @gt(@score, 80)
@data isGradeA = @equals(@grade, "A")
@when @and(@isHighScore, @isGradeA) => @add "Outstanding performance!"

>> Multiple conditions with strategies
@when first: [
  @gt(@score, 90) => @add "Excellent!"
  @gt(@score, 80) => @add "Very good!"
  @gt(@score, 70) => @add "Good!"
  true => @add "Keep trying!"
]
```