# @mlld/string

String helpers that mlld's builtin methods don't cover. Everything else this module used to offer is now a builtin method; see [Moved to builtins](#moved-to-builtins).

## tldr

```mlld
import { @camelCase, @snakeCase, @slugify, @isEmail } from @mlld/string

show @camelCase("user first name")
show @snakeCase("userFirstName")
show @slugify("Hello, World!")
show @isEmail("ada@example.com")
```

## docs

Each function reads its input as text.

- `@trimStart(str)` / `@trimEnd(str)`: without leading / trailing whitespace.
- `@capitalize(str)`: first letter upper case, the rest lower case.
- `@title(str)`: each space-separated word capitalized.
- `@camelCase(str)`: `"hello world"` → `"helloWorld"`.
- `@snakeCase(str)`: `"helloWorld"` → `"hello_world"`.
- `@kebabCase(str)`: `"helloWorld"` → `"hello-world"`.
- `@slugify(str)`: `"Hello, World!"` → `"hello-world"`.
- `@reverse(str)`: the characters in reverse order.
- `@escape(str)`: backslashes, quotes, newlines, carriage returns and tabs as escapes.
- `@encodeUri(str)` / `@encodeUriComponent(str)`: URI encoding, as JavaScript's functions of the same name.
- `@isEmail(str)`: `true` for text shaped like `name@domain.tld`.
- `@isUrl(str)`: `true` when the text parses as an absolute URL.
- `@isNumeric(str)`: `true` when the text reads as a number (`"42"`, `"1e3"`).
- `@splitLines(str)`: an array of lines, split on `\n` or `\r\n`.

The checks return `true` or `false`, and `@splitLines` returns an array; in 1.x they returned `"true"`/`""` and JSON text.

```mlld
import { @title, @splitLines } from @mlld/string

show @title("the quick fox")
show @splitLines("one\r\ntwo\nthree").length
```

## Moved to builtins

Version 2.0.0 drops the functions below. Each is a method on the string itself; see the mlld docs on builtin methods.

| Removed | Use instead |
|---|---|
| `@length(s)` | `@s.length` |
| `@trim(s)` | `@s.trim()` |
| `@upper(s)` / `@lower(s)` | `@s.toUpperCase()` / `@s.toLowerCase()` |
| `@split(s, sep)` | `@s.split(@sep)` |
| `@splitWords(s)` | `@s.match(/\S+/g)` |
| `@join(a, sep)` / `@joinLines(a)` | `@a.join(@sep)` / `@a.join("\n")` |
| `@substring(s, a, b)` / `@slice(s, a, b)` | `@s.substring(@a, @b)` / `@s.slice(@a, @b)` |
| `@left(s, n)` / `@right(s, n)` | `@s.slice(0, @n)` / `@s.slice(-@n)` |
| `@indexOf(s, x)` / `@includes(s, x)` | `@s.indexOf(@x)` / `@s.includes(@x)` |
| `@startsWith(s, x)` / `@endsWith(s, x)` | `@s.startsWith(@x)` / `@s.endsWith(@x)` |
| `@replace(s, a, b)` / `@replaceAll(s, a, b)` | `@s.replace(@a, @b)` / `@s.replaceAll(@a, @b)` |
| `@padStart(s, n, c)` / `@padEnd(s, n, c)` | `@s.padStart(@n, @c)` / `@s.padEnd(@n, @c)` |
| `@repeat(s, n)` | `@s.repeat(@n)` |
| `@isEmpty(s)` / `@isBlank(s)` | `@s == ""` / `@s.trim() == ""` |

## License

CC0 - Public Domain
