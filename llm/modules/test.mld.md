# @mlld/test

Core assertion functions for mlld testing framework. All functions return native booleans for simple test assertions.

## Basic Assertions

@exec eq(a, b) = javascript [(
  return a === b
)]

@exec deepEq(a, b) = javascript [(
  return JSON.stringify(a) === JSON.stringify(b)
)]

@exec ok(value) = javascript [(
  return !!value
)]

@exec notOk(value) = javascript [(
  return !value
)]

## Comparison Assertions

@exec gt(a, b) = javascript [(
  return a > b
)]

@exec gte(a, b) = javascript [(
  return a >= b
)]

@exec lt(a, b) = javascript [(
  return a < b
)]

@exec lte(a, b) = javascript [(
  return a <= b
)]

## Container Assertions

@exec includes(container, item) = javascript [(
  if (typeof container === 'string') {
    return container.includes(item)
  }
  if (Array.isArray(container)) {
    return container.includes(item)
  }
  return false
)]

@exec contains(haystack, needle) = javascript [(
  return String(haystack).includes(String(needle))
)]

@exec len(value) = javascript [(
  if (typeof value === 'string' || Array.isArray(value)) {
    return value.length
  }
  if (typeof value === 'object' && value !== null) {
    return Object.keys(value).length
  }
  return 0
)]

## Error Assertions

@exec throws(fn) = javascript [(
  try {
    fn()
    return false
  } catch {
    return true
  }
)]