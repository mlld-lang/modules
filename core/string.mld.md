---
name: string
author: mlld
version: 1.0.0
about: String operations
needs: ["js"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["length", "transformation", "camelCase", "snake_case", "kebab-case", "SCREAMING_SNAKE", "SNAKE-KEBAB", "substring", "slice", "split", "join", "pad", "replace", "starsWith", "endsWith", "escape", "unescape", "encode"]
license: CC0
mlldVersion: "*"
---

# @mlld/string

String manipulation utilities for text processing, formatting, and validation. Useful for data cleaning, URL building, and text transformation workflows.

## tldr

Common string operations:

```mlld
@import { title, camelCase, split, join, trim, includes } from @mlld/string

@text name = "john doe smith"
@text formatted = @title(@name)
@text slug = @camelCase(@formatted)

@data words = @split(@name, " ")
@text rejoined = @join(@words, "-")

@when @includes(@name, "doe") => @add [[Contains 'doe']]
@add [[Formatted: {{formatted}}]]
```

## docs

### Basic Operations

#### `length(str)`, `trim(str)`, `trimStart(str)`, `trimEnd(str)`

Essential string utilities for length and whitespace handling.

```mlld
@data name = "  John Doe  "
@add [[Length: {{@length(@name)}}]]
@add [[Trimmed: '{{@trim(@name)}}']]
```

### Case Transformations

#### `upper(str)`, `lower(str)`, `capitalize(str)`, `title(str)`

Text case conversion for formatting.

```mlld
@text message = "hello world"
@add [[Upper: {{@upper(@message)}}]]
@add [[Title: {{@title(@message)}}]]
@add [[Capitalized: {{@capitalize(@message)}}]]
```

#### `camelCase(str)`, `snakeCase(str)`, `kebabCase(str)`

Identifier formatting for different naming conventions.

```mlld
@text phrase = "user full name"
@add [[camelCase: {{@camelCase(@phrase)}}]]
@add [[snake_case: {{@snakeCase(@phrase)}}]]
@add [[kebab-case: {{@kebabCase(@phrase)}}]]
```

### Splitting and Joining

#### `split(str, separator)`, `splitLines(str)`, `splitWords(str)`

Break strings into arrays for processing.

```mlld
@data names = @split("alice,bob,charlie", ",")
@data lines = @splitLines(@fileContent)
@data words = @splitWords("The quick brown fox")
```

#### `join(array, separator)`, `joinLines(array)`

Combine arrays back into strings.

```mlld
@text combined = @join(@names, " and ")
@text document = @joinLines(@paragraphs)
```

### Search and Replace

#### `includes(str, search)`, `startsWith(str, prefix)`, `endsWith(str, suffix)`

String matching for conditional logic.

```mlld
@when @startsWith(@filename, "test_") => @add [[Test file detected]]
@when @endsWith(@url, ".json") => @add [[JSON endpoint]]
```

#### `replace(str, search, replacement)`, `replaceAll(str, search, replacement)`

Text substitution and cleaning.

```mlld
@text cleaned = @replaceAll(@input, " ", "-")
@text updated = @replace(@template, "{{name}}", @userName)
```

### Validation

#### `isEmpty(str)`, `isBlank(str)`, `isNumeric(str)`

Content validation for data processing.

```mlld
@when @isEmpty(@userInput) => @add [[Input required]]
@when @isNumeric(@value) => @add [[Valid number: {{@value}}]]
```

## module

All string operations use JavaScript's native string methods with consistent behavior:

```mlld-run
@exec length(str) = @run js [(String(str).length)]
@exec trim(str) = @run js [(String(str).trim())]
@exec trimStart(str) = @run js [(String(str).trimStart())]
@exec trimEnd(str) = @run js [(String(str).trimEnd())]

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

@exec split(str, separator) = @run js [(JSON.stringify(String(str).split(separator || '')))]
@exec splitLines(str) = @run js [(JSON.stringify(String(str).split(/\r?\n/)))]
@exec splitWords(str) = @run js [(JSON.stringify(String(str).match(/\S+/g) || []))]
@exec join(array, separator) = @run js [(Array.isArray(array) ? array.join(separator || '') : String(array))]
@exec joinLines(array) = @run js [(Array.isArray(array) ? array.join('\n') : String(array))]

@exec substring(str, start, end) = @run js [(String(str).substring(start, end))]
@exec slice(str, start, end) = @run js [(String(str).slice(start, end))]
@exec left(str, n) = @run js [(String(str).slice(0, n))]
@exec right(str, n) = @run js [(String(str).slice(-n))]

@exec indexOf(str, search) = @run js [(String(str).indexOf(search))]
@exec includes(str, search) = @run js [(String(str).includes(search) ? "true" : "")]
@exec startsWith(str, search) = @run js [(String(str).startsWith(search) ? "true" : "")]
@exec endsWith(str, search) = @run js [(String(str).endsWith(search) ? "true" : "")]
@exec replace(str, search, replacement) = @run js [(String(str).replace(search, replacement))]
@exec replaceAll(str, search, replacement) = @run js [(String(str).replaceAll(search, replacement))]

@exec padStart(str, length, padChar) = @run js [(String(str).padStart(length, padChar || ' '))]
@exec padEnd(str, length, padChar) = @run js [(String(str).padEnd(length, padChar || ' '))]
@exec repeat(str, count) = @run js [(String(str).repeat(count))]

@exec reverse(str) = @run js [(String(str).split('').reverse().join(''))]
@exec isEmpty(str) = @run js [(String(str).length === 0 ? "true" : "")]
@exec isBlank(str) = @run js [(String(str).trim().length === 0 ? "true" : "")]
@exec isNumeric(str) = @run js [(!isNaN(str) && !isNaN(parseFloat(str)) ? "true" : "")]

@exec escape(str) = @run js [(
  String(str)
    .replace(/\\/g, '\\\\')
    .replace(/"/g, '\\"')
    .replace(/'/g, "\\'")
    .replace(/\n/g, '\\n')
    .replace(/\r/g, '\\r')
    .replace(/\t/g, '\\t')
)]
@exec encodeUri(str) = @run js [(encodeURI(String(str)))]
@exec encodeUriComponent(str) = @run js [(encodeURIComponent(String(str)))]
```