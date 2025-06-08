---
author: mlld
module: @mlld/string
description: String manipulation utilities for text processing and formatting
version: 1.0.0
---

# @mlld/string - String Utilities

Comprehensive string manipulation utilities for text processing and formatting in mlld pipelines.

## Installation

```mlld
@import { * } from @mlld/string
```

## API Reference

### Basic Operations

Essential string operations for common tasks:

@exec length(str) = @run js [(String(str).length)]
@exec trim(str) = @run js [(String(str).trim())]
@exec trimStart(str) = @run js [(String(str).trimStart())]
@exec trimEnd(str) = @run js [(String(str).trimEnd())]

- `length(str)` - Get string length
- `trim(str)` - Remove whitespace from both ends
- `trimStart(str)` - Remove whitespace from start
- `trimEnd(str)` - Remove whitespace from end

### Case Transformations

Convert strings between different naming conventions:

@exec upper(str) = @run js [(String(str).toUpperCase())]
@exec lower(str) = @run js [(String(str).toLowerCase())]
@exec capitalize(str) = @run js [(
  const s = String(str);
  s.charAt(0).toUpperCase() + s.slice(1).toLowerCase()
)]
@exec title(str) = @run js [(
  String(str).split(' ').map(word => 
    word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
  ).join(' ')
)]
@exec camelCase(str) = @run js [(
  String(str)
    .replace(/[^a-zA-Z0-9]+(.)/g, (m, chr) => chr.toUpperCase())
    .replace(/^[A-Z]/, chr => chr.toLowerCase())
)]
@exec snakeCase(str) = @run js [(
  String(str)
    .replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`)
    .replace(/^_/, '')
    .replace(/[^a-zA-Z0-9]+/g, '_')
    .toLowerCase()
)]
@exec kebabCase(str) = @run js [(
  String(str)
    .replace(/[A-Z]/g, letter => `-${letter.toLowerCase()}`)
    .replace(/^-/, '')
    .replace(/[^a-zA-Z0-9]+/g, '-')
    .toLowerCase()
)]

- `upper(str)` - Convert to UPPERCASE
- `lower(str)` - Convert to lowercase  
- `capitalize(str)` - Capitalize first letter
- `title(str)` - Title Case Each Word
- `camelCase(str)` - Convert to camelCase
- `snakeCase(str)` - Convert to snake_case
- `kebabCase(str)` - Convert to kebab-case

#### Example: Case Conversions

```mlld
@import { camelCase, snakeCase, kebabCase, title } from @mlld/string

@text input = "convert THIS to different cases"
@add [[camelCase: {{camelCase(@input)}}]]     # convertThisToDifferentCases
@add [[snake_case: {{snakeCase(@input)}}]]    # convert_this_to_different_cases
@add [[kebab-case: {{kebabCase(@input)}}]]    # convert-this-to-different-cases
@add [[Title Case: {{title(@input)}}]]        # Convert This To Different Cases
```

### String Splitting and Joining

Parse and reconstruct strings:

@exec split(str, separator) = @run js [(JSON.stringify(String(str).split(separator || '')))]
@exec splitLines(str) = @run js [(JSON.stringify(String(str).split(/\r?\n/)))]
@exec splitWords(str) = @run js [(JSON.stringify(String(str).match(/\S+/g) || []))]
@exec join(array, separator) = @run js [(Array.isArray(array) ? array.join(separator || '') : String(array))]
@exec joinLines(array) = @run js [(Array.isArray(array) ? array.join('\n') : String(array))]

- `split(str, separator)` - Split string into array
- `splitLines(str)` - Split by line breaks
- `splitWords(str)` - Split into words
- `join(array, separator)` - Join array into string
- `joinLines(array)` - Join with newlines

### Substring Operations

Extract portions of strings:

@exec substring(str, start, end) = @run js [(String(str).substring(start, end))]
@exec slice(str, start, end) = @run js [(String(str).slice(start, end))]
@exec left(str, n) = @run js [(String(str).slice(0, n))]
@exec right(str, n) = @run js [(String(str).slice(-n))]
@exec mid(str, start, length) = @run js [(String(str).substr(start, length))]

- `substring(str, start, end)` - Extract substring
- `slice(str, start, end)` - Extract slice
- `left(str, n)` - Get first n characters
- `right(str, n)` - Get last n characters
- `mid(str, start, length)` - Get middle substring

### Search and Replace

Find and modify string content:

@exec indexOf(str, search) = @run js [(String(str).indexOf(search))]
@exec lastIndexOf(str, search) = @run js [(String(str).lastIndexOf(search))]
@exec includes(str, search) = @run js [(String(str).includes(search) ? "true" : "")]
@exec startsWith(str, search) = @run js [(String(str).startsWith(search) ? "true" : "")]
@exec endsWith(str, search) = @run js [(String(str).endsWith(search) ? "true" : "")]
@exec replace(str, search, replacement) = @run js [(String(str).replace(search, replacement))]
@exec replaceAll(str, search, replacement) = @run js [(String(str).replaceAll(search, replacement))]
@exec replaceRegex(str, pattern, replacement) = @run js [(String(str).replace(new RegExp(pattern, 'g'), replacement))]

- `indexOf(str, search)` - Find first occurrence (-1 if not found)
- `lastIndexOf(str, search)` - Find last occurrence
- `includes(str, search)` - Check if contains (returns "true" or "")
- `startsWith(str, search)` - Check if starts with (returns "true" or "")
- `endsWith(str, search)` - Check if ends with (returns "true" or "")
- `replace(str, search, replacement)` - Replace first occurrence
- `replaceAll(str, search, replacement)` - Replace all occurrences
- `replaceRegex(str, pattern, replacement)` - Replace using regex

### Padding and Formatting

Format strings with padding:

@exec padStart(str, length, padChar) = @run js [(String(str).padStart(length, padChar || ' '))]
@exec padEnd(str, length, padChar) = @run js [(String(str).padEnd(length, padChar || ' '))]
@exec center(str, length, padChar) = @run js [(
  const s = String(str);
  const pad = padChar || ' ';
  const totalPad = Math.max(0, length - s.length);
  const padLeft = Math.floor(totalPad / 2);
  const padRight = totalPad - padLeft;
  pad.repeat(padLeft) + s + pad.repeat(padRight)
)]
@exec repeat(str, count) = @run js [(String(str).repeat(count))]

- `padStart(str, length, padChar)` - Pad start to length
- `padEnd(str, length, padChar)` - Pad end to length
- `center(str, length, padChar)` - Center string
- `repeat(str, count)` - Repeat string n times

### Character Operations

Work with individual characters:

@exec charAt(str, index) = @run js [(String(str).charAt(index))]
@exec reverse(str) = @run js [(String(str).split('').reverse().join(''))]

- `charAt(str, index)` - Get character at index
- `reverse(str)` - Reverse string

### Validation

Check string properties:

@exec isEmpty(str) = @run js [(String(str).length === 0 ? "true" : "")]
@exec isBlank(str) = @run js [(String(str).trim().length === 0 ? "true" : "")]
@exec isNumeric(str) = @run js [(!isNaN(str) && !isNaN(parseFloat(str)) ? "true" : "")]
@exec isAlpha(str) = @run js [(/^[a-zA-Z]+$/.test(String(str)) ? "true" : "")]
@exec isAlphanumeric(str) = @run js [(/^[a-zA-Z0-9]+$/.test(String(str)) ? "true" : "")]

- `isEmpty(str)` - Check if empty (returns "true" or "")
- `isBlank(str)` - Check if blank/whitespace only
- `isNumeric(str)` - Check if numeric
- `isAlpha(str)` - Check if alphabetic only
- `isAlphanumeric(str)` - Check if alphanumeric

### Encoding and Escaping

Handle special characters and encoding:

@exec escape(str) = @run js [(
  String(str)
    .replace(/\\/g, '\\\\')
    .replace(/"/g, '\\"')
    .replace(/'/g, "\\'")
    .replace(/\n/g, '\\n')
    .replace(/\r/g, '\\r')
    .replace(/\t/g, '\\t')
)]
@exec unescape(str) = @run js [(
  String(str)
    .replace(/\\n/g, '\n')
    .replace(/\\r/g, '\r')
    .replace(/\\t/g, '\t')
    .replace(/\\'/g, "'")
    .replace(/\\"/g, '"')
    .replace(/\\\\/g, '\\')
)]
@exec encodeUri(str) = @run js [(encodeURI(String(str)))]
@exec decodeUri(str) = @run js [(decodeURI(String(str)))]
@exec encodeUriComponent(str) = @run js [(encodeURIComponent(String(str)))]
@exec decodeUriComponent(str) = @run js [(decodeURIComponent(String(str)))]

- `escape(str)` - Escape special characters
- `unescape(str)` - Unescape special characters
- `encodeUri(str)` - URI encode
- `decodeUri(str)` - URI decode
- `encodeUriComponent(str)` - URI component encode
- `decodeUriComponent(str)` - URI component decode

### Template Operations

Simple template replacement:

@exec template(template, data) = @run js [(
  String(template).replace(/\{\{(\w+)\}\}/g, (match, key) => 
    data && data[key] !== undefined ? data[key] : match
  )
)]

- `template(template, data)` - Simple {{variable}} template replacement

#### Example: Template Processing

```mlld
@import { template } from @mlld/string

@text tmpl = "Hello {{name}}, welcome to {{place}}!"
@data vars = {
  "name": "Alice",
  "place": "Wonderland"
}
@text result = @template(@tmpl, @vars)
@add [[{{result}}]]  # Hello Alice, welcome to Wonderland!
```

## Complete Example

Here's a practical example using multiple string utilities:

```mlld
@import { trim, capitalize, split, join, template } from @mlld/string

# Process user input
@text rawInput = "  john doe  "
@text cleaned = @trim(@rawInput)
@data nameParts = @split(@cleaned, " ")

# Format each part
@data formatted = []
@foreach part in @nameParts:
  @data formatted = @push(@formatted, @capitalize(@part))

@text fullName = @join(@formatted, " ")

# Create greeting
@text greetingTmpl = "Welcome, {{name}}! Your username is {{username}}."
@data vars = {
  "name": @fullName,
  "username": @snakeCase(@cleaned)
}
@text greeting = @template(@greetingTmpl, @vars)
@add [[{{greeting}}]]  # Welcome, John Doe! Your username is john_doe.
```

## Module Export

@data module = {
  >> Basic operations
  length: @length,
  trim: @trim,
  trimStart: @trimStart,
  trimEnd: @trimEnd,
  
  >> Case transformations
  upper: @upper,
  lower: @lower,
  capitalize: @capitalize,
  title: @title,
  camelCase: @camelCase,
  snakeCase: @snakeCase,
  kebabCase: @kebabCase,
  
  >> Splitting and joining
  split: @split,
  splitLines: @splitLines,
  splitWords: @splitWords,
  join: @join,
  joinLines: @joinLines,
  
  >> Substring operations
  substring: @substring,
  slice: @slice,
  left: @left,
  right: @right,
  mid: @mid,
  
  >> Search and replace
  indexOf: @indexOf,
  lastIndexOf: @lastIndexOf,
  includes: @includes,
  startsWith: @startsWith,
  endsWith: @endsWith,
  replace: @replace,
  replaceAll: @replaceAll,
  replaceRegex: @replaceRegex,
  
  >> Padding and formatting
  padStart: @padStart,
  padEnd: @padEnd,
  center: @center,
  repeat: @repeat,
  
  >> Character operations
  charAt: @charAt,
  reverse: @reverse,
  
  >> Validation
  isEmpty: @isEmpty,
  isBlank: @isBlank,
  isNumeric: @isNumeric,
  isAlpha: @isAlpha,
  isAlphanumeric: @isAlphanumeric,
  
  >> Encoding
  escape: @escape,
  unescape: @unescape,
  encodeUri: @encodeUri,
  decodeUri: @decodeUri,
  encodeUriComponent: @encodeUriComponent,
  decodeUriComponent: @decodeUriComponent,
  
  >> Templates
  template: @template
}