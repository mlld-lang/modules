---
name: fm-dir
author: mlld
version: 3.0.0
about: Advanced directory scanning with frontmatter parsing, filtering, and grouping
needs: ["node"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["frontmatter", "directory", "files", "glob", "gray-matter", "filter", "sort", "group"]
license: CC0
mlldVersion: ">=1.4.1"
---

# @mlld/fm-dir

Directory scanning utilities that return structured data about files and directories, including frontmatter parsing using gray-matter.

## tldr

grab directories with advanced frontmatter support:

```mlld
/import { grab, grabDir, grabFiles, filterByFrontmatter, sortByField, groupByField } from @mlld/fm-dir

>> Basic file grabbing
/var @modules = @grabDir("modules", "*.mld.md")
/var @allDocs = @grabFiles(".", "**/*.md")

>> Advanced usage with shadow environment
/var @published = @grab("posts", "*.md", { "fm": { "published": true } })
/var @byAuthor = @groupByField(@allDocs, "author")
/var @recent = @sortByField(@published, "date", "desc")

/show [[Found {{@length(@modules)}} modules and {{@length(@published)}} published posts]]
```

## docs

### Core Functions

#### `grab(path, pattern, options)`

Most flexible file grabbing with options:

```mlld
/var @files = @grab(".", "**/*.md", {
  "includeFrontmatter": true,
  "includeContent": false,
  "contentPreview": 50,
  "fm": { "published": true }  >> Filter by frontmatter
})
```

Options:
- `includeFrontmatter`: Parse frontmatter (default: true)
- `includeContent`: Include full content (default: false)
- `contentPreview`: Number of chars for preview (default: 50)
- `fm`: Object to filter by frontmatter fields
- `ignore`: Array of glob patterns to ignore

#### `grabDir(path, pattern)`

Simple directory scan (non-recursive):

```mlld
/var @modules = @grabDir("modules", "*.mld.md")
```

#### `grabFiles(basePath, globPattern)`

Recursive file grabbing:

```mlld
/var @allMarkdown = @grabFiles("docs", "**/*.md")
```

### Filtering & Sorting Functions

#### `filterByFrontmatter(files, field, value)`

Filter files by frontmatter field:

```mlld
/var @published = @filterByFrontmatter(@files, "published", true)
/var @hasAuthor = @filterByFrontmatter(@files, "author")  >> Just check existence
```

#### `sortByField(files, field, order)`

Sort files by frontmatter field:

```mlld
/var @byDate = @sortByField(@files, "date", "desc")
/var @byTitle = @sortByField(@files, "title", "asc")
```

#### `groupByField(files, field)`

Group files by frontmatter field:

```mlld
/var @byCategory = @groupByField(@files, "category")
/var @byAuthor = @groupByField(@files, "author")
```

### Utility Functions

#### `extractField(files, field)`

Extract all values for a field:

```mlld
/var @allTitles = @extractField(@files, "title")
/var @allDates = @extractField(@files, "date")
```

#### `uniqueValues(files, field)`

Get unique values for a field (flattens arrays):

```mlld
/var @allTags = @uniqueValues(@files, "tags")
/var @allAuthors = @uniqueValues(@files, "author")
```

### Return Format

All grab functions return arrays of objects with:
- `path`: Full or relative path to file
- `dir`: Directory containing the file
- `name`: Filename
- `ext`: File extension
- `size`: File size in bytes
- `modified`: ISO date string of last modification
- `fm`: Parsed frontmatter object (null if none)
- `preview`: Content preview (if requested)
- `content`: Full content (if requested)

## module

Advanced directory scanning with shadow environment for complex operations:

```mlld-run
/exe @grabDir(path, pattern) = node {(
  const fs = require('fs');
  const path_mod = require('path');
  const matter = require('gray-matter');
  
  const searchPath = @path || '.';
  const searchPattern = @pattern || '*';
  
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
            fm: fm,
            ext: path_mod.extname(file),
            size: stat.size,
            modified: stat.mtime.toISOString()
          });
        }
      }
    }
  } catch (err) {
    console.error('Error scanning directory:', err.message);
    return [];
  }
  
  return results;
)}

/exe @grabFiles(basePath, globPattern) = node {(
  const fs = require('fs');
  const path_mod = require('path');
  const glob = require('glob');
  const matter = require('gray-matter');
  
  const base = @basePath || '.';
  const pattern = @globPattern || '**/*';
  
  try {
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
      
      const stat = fs.statSync(fullPath);
      
      return {
        path: relativePath,
        dir: path_mod.dirname(relativePath),
        name: path_mod.basename(relativePath),
        fm: fm,
        ext: path_mod.extname(relativePath),
        size: stat.size,
        modified: stat.mtime.toISOString()
      };
    });
    
    return results;
  } catch (err) {
    console.error('Error scanning files:', err.message);
    return [];
  }
)}

/exe @grab(searchPath, pattern, options) = node {(
  const fs = require('fs');
  const path = require('path');
  const matter = require('gray-matter');
  const glob = require('glob');
  
  const cwd = @searchPath || '.';
  const globPattern = @pattern || '**/*.md';
  const opts = @options || {};
  
  try {
    // Default options
    const config = {
      includeFrontmatter: opts.includeFrontmatter !== false,
      includeContent: opts.includeContent || false,
      contentPreview: opts.contentPreview || 50,
      nodir: opts.nodir !== false,
      ignore: opts.ignore,
      ...opts
    };
    
    // Find files using glob
    const files = glob.sync(globPattern, { 
      cwd: cwd,
      nodir: config.nodir,
      ignore: config.ignore
    });
    
    // Process each file
    const results = files.map(file => {
      const fullPath = path.join(cwd, file);
      const stat = fs.statSync(fullPath);
      
      const result = {
        path: fullPath,
        dir: path.dirname(fullPath),
        name: path.basename(file),
        ext: path.extname(file),
        size: stat.size,
        modified: stat.mtime.toISOString()
      };
      
      // Parse frontmatter if requested
      if (config.includeFrontmatter && !stat.isDirectory()) {
        try {
          const content = fs.readFileSync(fullPath, 'utf8');
          const parsed = matter(content);
          
          result.fm = parsed.data;
          
          if (config.includeContent) {
            result.content = parsed.content;
          } else if (config.contentPreview > 0) {
            const preview = parsed.content.trim()
              .split('\n')[0]
              .substring(0, config.contentPreview);
            result.preview = preview + (preview.length < parsed.content.length ? '...' : '');
          }
        } catch (e) {
          // If file can't be read as text, skip frontmatter
          result.fm = null;
        }
      }
      
      // Apply frontmatter filter if specified
      if (config.fm && result.fm) {
        for (const [key, value] of Object.entries(config.fm)) {
          if (result.fm[key] !== value) {
            return null;
          }
        }
      }
      
      return result;
    }).filter(Boolean);
    
    return results;
  } catch (err) {
    console.error('Error in grab:', err.message);
    return [];
  }
)}

/exe @filterByFrontmatter(files, field, value) = node {(
  // Debug parameters
  console.log('filterByFrontmatter called with:');
  console.log('files type:', typeof @files);
  console.log('field:', @field, 'type:', typeof @field);
  console.log('value:', @value, 'type:', typeof @value);
  
  // Ensure files is an array (might be JSON string)
  const fileArray = Array.isArray(@files) ? @files : JSON.parse(@files || '[]');
  
  return fileArray.filter(file => {
    if (!file.fm) return false;
    
    // Support nested field access (e.g., "author.name")
    const fields = @field.split('.');
    let current = file.fm;
    
    for (const f of fields) {
      if (current && typeof current === 'object' && f in current) {
        current = current[f];
      } else {
        return false;
      }
    }
    
    // If value is provided, check equality
    if (@value !== undefined) {
      return current === @value;
    }
    
    // Otherwise just check if field exists and is truthy
    return !!current;
  });
)}

/exe @extractField(files, field) = node {(
  const fileArray = Array.isArray(@files) ? @files : JSON.parse(@files || '[]');
  const values = [];
  
  fileArray.forEach(file => {
    if (!file.fm) return;
    
    // Support nested field access
    const fields = @field.split('.');
    let current = file.fm;
    
    for (const f of fields) {
      if (current && typeof current === 'object' && f in current) {
        current = current[f];
      } else {
        return;
      }
    }
    
    if (current !== undefined) {
      values.push(current);
    }
  });
  
  return values;
)}

/exe @uniqueValues(files, field) = node {(
  const fileArray = Array.isArray(@files) ? @files : JSON.parse(@files || '[]');
  const allValues = [];
  
  fileArray.forEach(file => {
    if (!file.fm) return;
    
    // Support nested field access
    const fields = @field.split('.');
    let current = file.fm;
    
    for (const f of fields) {
      if (current && typeof current === 'object' && f in current) {
        current = current[f];
      } else {
        return;
      }
    }
    
    if (Array.isArray(current)) {
      allValues.push(...current);
    } else if (current !== undefined) {
      allValues.push(current);
    }
  });
  
  return [...new Set(allValues)];
)}

/exe @sortByField(files, field, order) = node {(
  const fileArray = Array.isArray(@files) ? @files : JSON.parse(@files || '[]');
  const sortOrder = @order || 'asc';
  
  return [...fileArray].sort((a, b) => {
    // Extract field values
    const getFieldValue = (file) => {
      if (!file.fm) return undefined;
      
      const fields = @field.split('.');
      let current = file.fm;
      
      for (const f of fields) {
        if (current && typeof current === 'object' && f in current) {
          current = current[f];
        } else {
          return undefined;
        }
      }
      
      return current;
    };
    
    const aVal = getFieldValue(a);
    const bVal = getFieldValue(b);
    
    // Handle undefined values
    if (aVal === undefined && bVal === undefined) return 0;
    if (aVal === undefined) return 1;
    if (bVal === undefined) return -1;
    
    // Compare values
    let result = 0;
    if (aVal < bVal) result = -1;
    else if (aVal > bVal) result = 1;
    
    return sortOrder === 'desc' ? -result : result;
  });
)}

/exe @groupByField(files, field) = node {(
  const fileArray = Array.isArray(@files) ? @files : JSON.parse(@files || '[]');
  const groups = {};
  
  fileArray.forEach(file => {
    if (!file.fm) {
      groups['_no_frontmatter'] = groups['_no_frontmatter'] || [];
      groups['_no_frontmatter'].push(file);
      return;
    }
    
    // Extract field value
    const fields = @field.split('.');
    let current = file.fm;
    
    for (const f of fields) {
      if (current && typeof current === 'object' && f in current) {
        current = current[f];
      } else {
        current = undefined;
        break;
      }
    }
    
    const key = current === undefined ? '_no_value' : String(current);
    groups[key] = groups[key] || [];
    groups[key].push(file);
  });
  
  return groups;
)}

>> Shadow environment to make functions available to each other
/exe node = { grabDir, grabFiles, grab, filterByFrontmatter, extractField, uniqueValues, sortByField, groupByField }
```