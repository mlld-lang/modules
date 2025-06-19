---
name: grab
author: mlld
version: 2.0.0
about: Directory scanning utilities with frontmatter support
needs: ["node"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["frontmatter", "grab", "directory", "files", "glob", "gray-matter"]
license: CC0
mlldVersion: ">=1.4.1"
---

# @mlld/grab

Directory scanning utilities that return structured data about files and directories, including frontmatter parsing using gray-matter.

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
@exec grabDir(path, pattern) = node [(
  const fs = require('fs');
  const path_mod = require('path');
  const matter = require('gray-matter');
  
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
          let fm = null;
          
          // Try to parse frontmatter
          try {
            const content = fs.readFileSync(fullPath, 'utf8');
            const parsed = matter(content);
            if (parsed.data && Object.keys(parsed.data).length > 0) {
              fm = parsed.data;
            }
          } catch (e) {
            // File might not be text or readable
          }
          
          results.push({
            path: fullPath,
            dir: searchPath,
            name: file,
            fm: fm
          });
        }
      }
    }
  } catch (err) {
    console.error('Error scanning directory:', err.message);
    return [];
  }
  
  return results; // Return the array directly!
)]

@exec grabFiles(basePath, globPattern) = node [(
  const fs = require('fs');
  const path_mod = require('path');
  const glob = require('glob');
  const matter = require('gray-matter');
  
  const base = basePath || '.';
  const pattern = globPattern || '**/*';
  
  try {
    // Now we can use the real glob module!
    const files = glob.sync(pattern, {
      cwd: base,
      nodir: true
    });
    
    const results = files.map(relativePath => {
      const fullPath = path_mod.join(base, relativePath);
      let fm = null;
      
      // Try to parse frontmatter
      try {
        const content = fs.readFileSync(fullPath, 'utf8');
        const parsed = matter(content);
        if (parsed.data && Object.keys(parsed.data).length > 0) {
          fm = parsed.data;
        }
      } catch (e) {
        // File might not be text or readable
      }
      
      return {
        path: relativePath,
        dir: path_mod.dirname(relativePath),
        name: path_mod.basename(relativePath),
        fm: fm
      };
    });
    
    return results; // Return the array directly!
  } catch (err) {
    console.error('Error scanning files:', err.message);
    return [];
  }
)]
```