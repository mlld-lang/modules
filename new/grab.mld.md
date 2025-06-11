---
name: grab
author: mlld
version: 1.0.0
about: Directory grabning utilities
needs: ["node", "glob", "gray-matter"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["frontmatter", "grab", "directory", "files"]
license: CC0
mlldVersion: "*"
---

# @mlld/grabfm

Directory grabning utilities that return structured data about files and directories, including frontmatter parsing.

## tldr

grab directories and get file listings:

```mlld
@import { grabDir, grabFiles } from @mlld/grab

@data moduleFiles = @grabDir("modules/core", "*.mld.md")
@data allFiles = @grabFiles(".", "**/*.md")

@add [[Found {{@length(@moduleFiles)}} modules]]
```

## docs

### `grabDir(path, pattern)`

grab a directory for files matching a pattern and return an array of file objects.

```mlld
@data modules = @grabDir("modules", "*.mld.md")
```

Returns array of objects with:
- `path`: relative path to file
- `dir`: directory containing the file ("." for current)
- `name`: filename
- `fm`: parsed frontmatter object (null if no frontmatter)

### `grabFiles(basePath, globPattern)`

Recursively grab directories using glob patterns.

```mlld
@data allMarkdown = @grabFiles("docs", "**/*.md")
@data configFiles = @grabFiles(".", "**/config.{json,yaml,yml}")
```

## module

Directory grabning capabilities:

```mlld-run
@exec grabDir(path, pattern) = @run node [(
  const fs = require('fs');
  const path_mod = require('path');
  
  const searchPath = path || '.';
  const searchPattern = pattern || '*';
  
  const results = [];
  
  try {
    const files = fs.readdirSync(searchPath);
    
    for (const file of files) {
      // Simple pattern matching - just check if filename matches pattern
      const fullPath = path_mod.join(searchPath, file);
      const stat = fs.statSync(fullPath);
      
      if (stat.isFile()) {
        // Basic pattern matching (supports * wildcard)
        const regex = new RegExp('^' + searchPattern.replace(/\*/g, '.*') + '$');
        if (regex.test(file)) {
          results.push({
            path: fullPath,
            dir: searchPath,
            name: file,
            fm: null // TODO: Add frontmatter parsing
          });
        }
      }
    }
  } catch (err) {
    console.error('Error grabning directory:', err.message);
  }
  
  console.log(JSON.stringify(results, null, 2));
)]

@exec grabFiles(basePath, globPattern) = @run node [(
  const fs = require('fs');
  const path_mod = require('path');
  
  const base = basePath || '.';
  const pattern = globPattern || '**/*';
  
  // For mlld modules, we can use a simple recursive grabner
  // since we don't have glob available by default
  function grabRecursive(dir, results = []) {
    try {
      const files = fs.readdirSync(dir);
      
      for (const file of files) {
        const fullPath = path_mod.join(dir, file);
        const stat = fs.statSync(fullPath);
        
        if (stat.isDirectory()) {
          // Recurse into subdirectories
          grabRecursive(fullPath, results);
        } else if (stat.isFile()) {
          // Calculate relative path from base
          const relativePath = path_mod.relative(base, fullPath);
          
          // Simple pattern matching for common cases
          // Handle **/*.ext patterns
          if (pattern.includes('**')) {
            const ext = pattern.split('**/')[1];
            if (ext && ext.startsWith('*')) {
              const extension = ext.substring(1);
              if (relativePath.endsWith(extension)) {
                results.push({
                  path: relativePath,
                  dir: path_mod.dirname(relativePath),
                  name: file,
                  fm: null // TODO: Add frontmatter parsing
                });
              }
            }
          }
        }
      }
    } catch (err) {
      // Silently skip directories we can't read
    }
    
    return results;
  }
  
  const results = grabRecursive(base);
  console.log(JSON.stringify(results));
)]
```