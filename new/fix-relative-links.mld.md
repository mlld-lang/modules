---
name: fix-relative-links
author: mlld
version: 1.0.0
about: Fix relative markdown links based on context
needs: ["node", "path"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["markdown", "links", "paths", "pipeline"]
license: CC0
mlldVersion: "*"
---

# @mlld/fix-relative-links

Pipeline transformer that adjusts relative paths in markdown links to be correct for different output contexts.

## tldr

Recalculates relative links when moving content between directories:

```mlld
@import [fix-relative-links.mld.md]

@text content = [[See the [docs](../docs/guide.md) for details.]]

>> The function asks: "How do I get from dist/ to src/docs/guide.md?"
>> Answer: "../src/docs/guide.md"
@text fixed = @fixRelativeLinks(@content, "src/modules", "dist")
>>                                        ↑                ↑
>>                   where content thinks it is    where it's actually going
```

## docs

### `fixRelativeLinks(content, sourceDir, destDir)`

**What it does:** When you move markdown content from one directory to another, relative links break. This function recalculates all relative paths so they still point to the same target files.

Parameters:
- `content`: The markdown content with relative links
- `sourceDir`: Where the content was written (its current context)
- `destDir`: Where the content is moving to (its new context)

**Bottom line:** A link like `../docs/guide.md` means different things depending on which directory you're in. This function preserves what the link *points to*, not just the link text.

### Usage in Pipelines

This module is designed to work as a pipeline transformer:

```mlld
# Generate content and fix paths in one operation
@text readme = @run [cat template.md] with {
  pipeline: [@fixRelativeLinks(@input, "templates", "output/docs")]
}

# Or use with other transformers
@exec processDoc(content) = @run [echo "@content"] with {
  pipeline: [
    @replaceVars(@input),
    @fixRelativeLinks(@input, "src", "dist"),
    @addFooter(@input)
  ]
}
```

### Examples

**Basic usage:**
```mlld
@text content = [[Check out [the guide](../docs/guide.md)]]
@text fixed = @fixRelativeLinks(@content, "src/pages", "dist")
# Result: "Check out [the guide](../src/docs/guide.md)]"
```

**Real-world example - README generation:**
```mlld
# Content written from modules/llm/ perspective
@text readme = [[
## Modules

- [Array utilities](../core/array.mld.md)
- [String helpers](../core/string.mld.md)
See the [main docs](../../README.md) for more.
]]

# Fix paths for output to modules/core/README.md
@text fixedReadme = @fixRelativeLinks(@readme, "modules/llm", "modules/core")
# Results in:
# - [Array utilities](./array.mld.md)
# - [String helpers](./string.mld.md)
# - [main docs](../../README.md) - unchanged
```

**Path resolution examples:**
- `modules/llm/` → `modules/`: `../core/file.md` becomes `./core/file.md`
- `modules/llm/` → `modules/core/`: `../core/file.md` becomes `./file.md`
- `src/docs/` → `dist/`: `../../lib/util.js` becomes `../src/lib/util.js`

### Limitations

- Only processes standard markdown links `[text](path)`
- Does not process image links `![alt](path)` (could be added if needed)
- Does not process reference-style links `[text][ref]`

## module

```mlld-run
@exec fixRelativeLinks(content, sourceDir, destDir) = @run node [(
  const path = require('path');
  
  // Parameters are injected as variables by mlld
  const markdownContent = content || '';
  const fromDir = sourceDir || '.';
  const toDir = destDir || '.';
  
  // Regex to match markdown links: [text](path)
  const linkRegex = /\[([^\]]+)\]\(([^)]+)\)/g;
  
  // Process the content
  const result = markdownContent.replace(linkRegex, (match, linkText, linkPath) => {
    // Skip absolute paths and URLs
    if (linkPath.startsWith('http://') || 
        linkPath.startsWith('https://') || 
        linkPath.startsWith('/')) {
      return match;
    }
    
    // Skip non-relative paths (like #anchors)
    if (linkPath.startsWith('#')) {
      return match;
    }
    
    try {
      // Calculate the absolute path from source directory
      const absolutePath = path.resolve(fromDir, linkPath);
      
      // Calculate the new relative path from destination directory
      const newRelativePath = path.relative(toDir, absolutePath);
      
      // Ensure forward slashes for consistency
      const normalizedPath = newRelativePath.replace(/\\/g, '/');
      
      // Add ./ prefix if the path doesn't go up directories
      const finalPath = normalizedPath.startsWith('.') ? 
        normalizedPath : 
        './' + normalizedPath;
      
      return `[${linkText}](${finalPath})`;
    } catch (err) {
      // If path resolution fails, keep original
      return match;
    }
  });
  
  console.log(result);
)]
```
