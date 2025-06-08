# @mlld/string - String Utilities

Comprehensive string manipulation utilities for text processing and formatting.

## Installation

```mlld
@import { * } from @mlld/string
```

## API Reference

### Basic Operations

- `length(str)` - Get string length
- `trim(str)` - Remove whitespace from both ends
- `trimStart(str)` - Remove whitespace from start
- `trimEnd(str)` - Remove whitespace from end

### Case Transformations

- `upper(str)` - Convert to uppercase
- `lower(str)` - Convert to lowercase
- `capitalize(str)` - Capitalize first letter
- `title(str)` - Title case (capitalize each word)
- `camelCase(str)` - Convert to camelCase
- `snakeCase(str)` - Convert to snake_case
- `kebabCase(str)` - Convert to kebab-case

### Splitting and Joining

- `split(str, separator)` - Split string into array
- `splitLines(str)` - Split by line breaks
- `splitWords(str)` - Split into words
- `join(array, separator)` - Join array into string
- `joinLines(array)` - Join with newlines

### Substring Operations

- `substring(str, start, end)` - Extract substring
- `slice(str, start, end)` - Extract slice
- `left(str, n)` - Get first n characters
- `right(str, n)` - Get last n characters
- `mid(str, start, length)` - Get middle substring

### Search and Replace

- `indexOf(str, search)` - Find first occurrence
- `lastIndexOf(str, search)` - Find last occurrence
- `includes(str, search)` - Check if contains (returns "true" or "")
- `startsWith(str, search)` - Check if starts with (returns "true" or "")
- `endsWith(str, search)` - Check if ends with (returns "true" or "")
- `replace(str, search, replacement)` - Replace first occurrence
- `replaceAll(str, search, replacement)` - Replace all occurrences
- `replaceRegex(str, pattern, replacement)` - Replace using regex

### Padding and Formatting

- `padStart(str, length, padChar)` - Pad start to length
- `padEnd(str, length, padChar)` - Pad end to length
- `center(str, length, padChar)` - Center string
- `repeat(str, count)` - Repeat string n times

### Character Operations

- `charAt(str, index)` - Get character at index
- `reverse(str)` - Reverse string

### Validation

- `isEmpty(str)` - Check if empty (returns "true" or "")
- `isBlank(str)` - Check if blank/whitespace only
- `isNumeric(str)` - Check if numeric
- `isAlpha(str)` - Check if alphabetic only
- `isAlphanumeric(str)` - Check if alphanumeric

### Encoding

- `escape(str)` - Escape special characters
- `unescape(str)` - Unescape special characters
- `encodeUri(str)` - URI encode
- `decodeUri(str)` - URI decode
- `encodeUriComponent(str)` - URI component encode
- `decodeUriComponent(str)` - URI component decode

### Templates

- `template(template, data)` - Simple template replacement

## Usage Examples

### Basic String Operations

```mlld
@import { trim, length, upper } from @mlld/string

@text input = "  Hello World  "
@text cleaned = @trim(@input)
@data len = @length(@cleaned)
@text shouting = @upper(@cleaned)

@add [[Original length: {{length(@input)}}]]
@add [[Cleaned: "{{cleaned}}" (length: {{len}})]]
@add [[SHOUTING: {{shouting}}]]
```

### Case Conversions

```mlld
@import { camelCase, snakeCase, kebabCase, title } from @mlld/string

@text input = "convert THIS to different cases"
@add [[camelCase: {{camelCase(@input)}}]]
@add [[snake_case: {{snakeCase(@input)}}]]
@add [[kebab-case: {{kebabCase(@input)}}]]
@add [[Title Case: {{title(@input)}}]]
```

### Working with Arrays

```mlld
@import { split, join, splitWords } from @mlld/string

@text sentence = "The quick brown fox"
@data words = @splitWords(@sentence)
@text reversed = @join(@words, " <- ")
@add [[Reversed: {{reversed}}]]

@text csv = "apple,banana,cherry"
@data fruits = @split(@csv, ",")
@text list = @join(@fruits, "\n- ")
@add [[Fruits:\n- {{list}}]]
```

### Search and Replace

```mlld
@import { replace, replaceAll, includes } from @mlld/string
@import { equals } from @mlld/core

@text text = "The cat in the hat"
@text single = @replace(@text, "the", "a")
@text all = @replaceAll(@text, "the", "a")

@when @includes(@text, "cat") => @add "Found a cat!"

@add [[Single replace: {{single}}]]
@add [[Replace all: {{all}}]]
```

### Validation

```mlld
@import { isNumeric, isAlpha, isEmpty } from @mlld/string
@import { not } from @mlld/core

@text input = "12345"

@when @isNumeric(@input) => @add "Input is numeric"
@when @isAlpha(@input) => @add "Input is alphabetic"
@when @not(@isEmpty(@input)) => @add "Input is not empty"
```

### Template Processing

```mlld
@import { template } from @mlld/string

@text tmpl = "Hello {{name}}, welcome to {{place}}!"
@data vars = {
  "name": "Alice",
  "place": "Wonderland"
}
@text result = @template(@tmpl, @vars)
@add [[{{result}}]]
```

### URL Encoding

```mlld
@import { encodeUriComponent, decodeUriComponent } from @mlld/string

@text param = "hello world & special=chars"
@text encoded = @encodeUriComponent(@param)
@text decoded = @decodeUriComponent(@encoded)

@add [[Original: {{param}}]]
@add [[Encoded: {{encoded}}]]
@add [[Decoded: {{decoded}}]]
```