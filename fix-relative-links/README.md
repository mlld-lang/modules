# @mlld/fix-relative-links

Adjusts relative paths in markdown links when content moves to a different folder, so each link still points at the same file.

## tldr

```mlld
import { @fixRelativeLinks } from @mlld/fix-relative-links

const @content = "See the [docs](../docs/guide.md) for details."

>> Where the content was written, then where it is going.
>> From dist/, the file src/modules/../docs/guide.md is ../src/docs/guide.md.
const @fixed = @fixRelativeLinks(@content, "src/modules", "dist")
show @fixed
```

## docs

### `@fixRelativeLinks(content, sourceDir, destDir)`

When markdown moves from one folder to another, its relative links break. This recalculates each one so it still points at the same file.

- `content`: the markdown text.
- `sourceDir`: the folder the links were written for.
- `destDir`: the folder the content is moving to.

Returns the text with every relative link rewritten. A link like `../docs/guide.md` means different things in different folders; this keeps what the link points at, not its text.

Links are left alone when they are URLs of any scheme (`https:`, `ftp:`, `mailto:`), start with `/`, or start with `#`. Rewritten paths use forward slashes and start with `./` when they don't go up a folder.

### In a pipeline

The piped value becomes `content`:

```mlld
import { @fixRelativeLinks } from @mlld/fix-relative-links

const @readme = <templates/README.md> | @fixRelativeLinks("templates", "output/docs")
output @readme to "output/docs/README.md"
```

### Examples

Content written from `modules/llm/`, published as `modules/core/README.md`:

```mlld
import { @fixRelativeLinks } from @mlld/fix-relative-links

const @readme = `- [Array utilities](../core/array.mld.md)
- [String helpers](../core/string.mld.md)
See the [main docs](../../README.md) for more.`

show @fixRelativeLinks(@readme, "modules/llm", "modules/core")
```

The first two links become `./array.mld.md` and `./string.mld.md`; the last is unchanged.

More moves:
- `modules/llm/` → `modules/`: `../core/file.md` becomes `./core/file.md`
- `modules/llm/` → `modules/core/`: `../core/file.md` becomes `./file.md`
- `src/docs/` → `dist/`: `../../lib/util.js` becomes `../lib/util.js`

### Limitations

- Handles inline links `[text](path)`. The same pattern also catches the `[alt](path)` inside an image `![alt](path)`, so image paths are rewritten too.
- Reference-style links `[text][ref]` and their `[ref]: path` definitions are not rewritten.
- A link with a title, `[text](path "title")`, is read as one path and comes out wrong.
- Links inside code blocks are rewritten like any other.

## License

CC0 - Public Domain
