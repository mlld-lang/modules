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
/import { title, camelCase, split, join, trim, includes } from @mlld/string

/var @name = "john doe smith"
/var @formatted = @title(@name)
/var @slug = @camelCase(@formatted)

/var @words = @split(@name, " ")
/var @rejoined = @join(@words, "-")

/when @includes(@name, "doe") => /show [[Contains 'doe']]
/show `Formatted: @formatted`
```

## docs

### Basic Operations

#### `length(str)`, `trim(str)`, `trimStart(str)`, `trimEnd(str)`

Essential string utilities for length and whitespace handling.

```mlld
/var @name = "  John Doe  "
/show `Length: @length(@name)`
/show `Trimmed: '@trim(@name)'`
```

### Case Transformations

#### `upper(str)`, `lower(str)`, `capitalize(str)`, `title(str)`

Text case conversion for formatting.

```mlld
/var @message = "hello world"
/show `Upper: @upper(@message)`
/show `Title: @title(@message)`
/show `Capitalized: @capitalize(@message)`
```

#### `camelCase(str)`, `snakeCase(str)`, `kebabCase(str)`

Identifier formatting for different naming conventions.

```mlld
/var @phrase = "user full name"
/show `camelCase: @camelCase(@phrase)`
/show `snake_case: @snakeCase(@phrase)`
/show `kebab-case: @kebabCase(@phrase)`
```

### Splitting and Joining

#### `split(str, separator)`, `splitLines(str)`, `splitWords(str)`

Break strings into arrays for processing.

```mlld
/var @names = @split("alice,bob,charlie", ",")
/var @lines = @splitLines(@fileContent)
/var @words = @splitWords("The quick brown fox")
```

#### `join(array, separator)`, `joinLines(array)`

Combine arrays back into strings.

```mlld
/var @combined = @join(@names, " and ")
/var @document = @joinLines(@paragraphs)
```

### Search and Replace

#### `includes(str, search)`, `startsWith(str, prefix)`, `endsWith(str, suffix)`

String matching for conditional logic.

```mlld
/when @startsWith(@filename, "test_") => /show [[Test file detected]]
/when @endsWith(@url, ".json") => /show [[JSON endpoint]]
```

#### `replace(str, search, replacement)`, `replaceAll(str, search, replacement)`

Text substitution and cleaning.

```mlld
/var @cleaned = @replaceAll(@input, " ", "-")
/var @updated = @replace(@template, "@name", @userName)
```

### Validation

#### `isEmpty(str)`, `isBlank(str)`, `isNumeric(str)`

Content validation for data processing.

```mlld
/when @isEmpty(@userInput) => /show [[Input required]]
/when @isNumeric(@value) => /show `Valid number: @value`
```

## module

All string operations use JavaScript's native string methods with consistent behavior:

```mlld-run
/exe @length(@str) = js {(String(str).length)}
/exe @trim(@str) = js {(String(str).trim())}
/exe @trimStart(@str) = js {(String(str).trimStart())}
/exe @trimEnd(@str) = js {(String(str).trimEnd())}

/exe @upper(@str) = js {(String(str).toUpperCase())}
/exe @lower(@str) = js {(String(str).toLowerCase())}
/exe @capitalize(@str) = js {(String(str).charAt(0).toUpperCase() + String(str).slice(1).toLowerCase())}
/exe @title(@str) = js {(
  String(str).split(' ').map(word => 
    word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
  ).join(' ')
)}
/exe @camelCase(@str) = js {(
  String(str)
    .replace(/[^a-zA-Z0-9]+(.)/g, (m, chr) => chr.toUpperCase())
    .replace(/^[A-Z]/, chr => chr.toLowerCase())
)}
/exe @snakeCase(@str) = js {(
  String(str)
    .replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`)
    .replace(/^_/, '')
    .replace(/[^a-zA-Z0-9]+/g, '_')
    .toLowerCase()
)}
/exe @kebabCase(@str) = js {(
  String(str)
    .replace(/[A-Z]/g, letter => `-${letter.toLowerCase()}`)
    .replace(/^-/, '')
    .replace(/[^a-zA-Z0-9]+/g, '-')
    .toLowerCase()
)}

/exe @split(@str, @separator) = js {(JSON.stringify(String(str).split(separator || '')))}
/exe @splitLines(@str) = js {(JSON.stringify(String(str).split(/\r?\n/)))}
/exe @splitWords(@str) = js {(JSON.stringify(String(str).match(/\S+/g) || []))}
/exe @join(@array, @separator) = js {(Array.isArray(array) ? array.join(separator || '') : String(array))}
/exe @joinLines(@array) = js {(Array.isArray(array) ? array.join('\n') : String(array))}

/exe @substring(@str, @start, @end) = js {(String(str).substring(start, end))}
/exe @slice(@str, @start, @end) = js {(String(str).slice(start, end))}
/exe @left(@str, @n) = js {(String(str).slice(0, n))}
/exe @right(@str, @n) = js {(String(str).slice(-n))}

/exe @indexOf(@str, @search) = js {(String(str).indexOf(search))}
/exe @includes(@str, @search) = js {(String(str).includes(search) ? "true" : "")}
/exe @startsWith(@str, @search) = js {(String(str).startsWith(search) ? "true" : "")}
/exe @endsWith(@str, @search) = js {(String(str).endsWith(search) ? "true" : "")}
/exe @replace(@str, @search, @replacement) = js {(String(str).replace(search, replacement))}
/exe @replaceAll(@str, @search, @replacement) = js {(String(str).replaceAll(search, replacement))}

/exe @padStart(@str, @targetLength, @padChar) = js {(String(str).padStart(targetLength, padChar || ' '))}
/exe @padEnd(@str, @targetLength, @padChar) = js {(String(str).padEnd(targetLength, padChar || ' '))}
/exe @repeat(@str, @count) = js {(String(str).repeat(count))}

/exe @reverse(@str) = js {(String(str).split('').reverse().join(''))}
/exe @isEmpty(@str) = js {(String(str).length === 0 ? "true" : "")}
/exe @isBlank(@str) = js {(String(str).trim().length === 0 ? "true" : "")}
/exe @isNumeric(@str) = js {(!isNaN(str) && !isNaN(parseFloat(str)) ? "true" : "")}

/exe @escape(@str) = js {(
  String(str)
    .replace(/\\/g, '\\\\')
    .replace(/"/g, '\\"')
    .replace(/'/g, "\\'")
    .replace(/\n/g, '\\n')
    .replace(/\r/g, '\\r')
    .replace(/\t/g, '\\t')
)}
/exe @encodeUri(@str) = js {(encodeURI(String(str)))}
/exe @encodeUriComponent(@str) = js {(encodeURIComponent(String(str)))}

>> Email and URL validation
/exe @isEmail(@str) = js {(
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  emailRegex.test(String(str)) ? "true" : ""
)}
/exe @isUrl(@str) = js {(
  try {
    new URL(String(str));
    return "true";
  } catch {
    return "";
  }
)}

>> Slugify for URL-friendly strings
/exe @slugify(@str) = js {(
  String(str)
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_-]+/g, '-')
    .replace(/^-+|-+$/g, '')
)}

>> Shadow environment to make functions available to each other
/exe js = { length, trim, trimStart, trimEnd, upper, lower, capitalize, title, camelCase, snakeCase, kebabCase, split, splitLines, splitWords, join, joinLines, substring, slice, left, right, indexOf, includes, startsWith, endsWith, replace, replaceAll, padStart, padEnd, repeat, reverse, isEmpty, isBlank, isNumeric, escape, encodeUri, encodeUriComponent, isEmail, isUrl, slugify }
```

## Module Export

All functions are exported by default in mlld modules. The @module pattern would require grammar updates to support variable references in object literals.