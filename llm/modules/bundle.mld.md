---
name: bundle
author: mlld-dev
version: 1.0.0
about: Bundle directory contents into XML or Markdown
needs: ["sh"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["bundle", "repo", "concatenation", "code", "package", "glob", "xml"]
license: CC0
mlldVersion: "*"
---

# @mlld/bundle

Bundle operations to format directory contents as XML or Markdown with proper structure and formatting. Useful for creating context for analysis, documentation generation, or code reviews.

## tldr

Bundle your project files for AI analysis or documentation:

```mlld
/import { xml as toXml, md, tree } from @mlld/bundle

/var @src_xml = @toXml("./src")
/show [[Project structure in XML:]]
/show `@src_xml`

/var @docs_md = @toMd("./docs")
/show [[Documentation structure:]]
/show `@docs_md`
```

## docs

### XML Bundling

#### `xml(path)`

Generate structured XML with SCREAMING_SNAKE_CASE tags for consistency and clarity.

```mlld
/var @project_context = @toXml("./src")
/show [[<project-context>]]
/show `@project_context`
/show [[</project-context>]]
```

**Example output:**
```xml
<SRC>
  <COMPONENTS>
    <BUTTON_JS name="Button.js">
    export const Button = () => <button>Click me</button>
    </BUTTON_JS>
    <HEADER_JS name="Header.js">
    export const Header = () => <h1>Welcome</h1>
    </HEADER_JS>
  </COMPONENTS>
  <APP_JS name="App.js">
  import { Button } from './components/Button'
  import { Header } from './components/Header'
  </APP_JS>
</SRC>
```

### Markdown Bundling

#### `md(path)`

Generate clean Markdown with appropriate header levels and code blocks.

```mlld
/var @api_docs = @toMd("./api")
/show [[## API Documentation Bundle]]
/show `@api_docs`
```

**Example output:**
````markdown
# api

## endpoints

### users.js
```javascript
router.get('/users', async (req, res) => {
  const users = await db.users.findAll()
  res.json(users)
})
```

### auth.js
```javascript
router.post('/login', async (req, res) => {
  // Authentication logic
})
```
````

### Directory Structure

#### `tree(path)`

Show directory structure without file contents.

```mlld
/var @structure = @tree("./src")
/show [[Project structure:]]
/show `@structure`
```

### Use Cases

#### AI Code Review
```mlld
/import { xml } from @mlld/bundle
/import { claude } from @mlld/ai

/var @changes = @toXml("./src/components")
/var @review = @claude.ask(`Review this React component structure for best practices: @changes`)
/show [[Code Review Results:]]
/show `@review`
```

#### Documentation Generation
```mlld
/import { md } from @mlld/bundle

/var @api_bundle = @toMd("./api")
/var @lib_bundle = @toMd("./lib")

/show [[# Complete API Documentation]]
/show `@api_bundle`
/show [[# Library Documentation]]
/show `@lib_bundle`
```

#### Project Analysis
```mlld
/import { xml } from @mlld/bundle
/import { llm } from @mlld/ai

/var @full_project = @toXml(".")
/var @analysis = @llm.ask("You are a senior architect", `Analyze this project structure and suggest improvements: @full_project`)
/show [[Architecture Analysis:]]
/show `@analysis`
```

## module

Bundle implementation using shell utilities:

```mlld-run
/exe @toXml(@path) = sh {
  # Generate XML representation of directory structure
  # Uses SCREAMING_SNAKE_CASE for XML tags
  
  function to_xml_tag() {
    echo "$1" | sed 's/[^a-zA-Z0-9_]/_/g' | tr '[:lower:]' '[:upper:]'
  }
  
  function process_dir() {
    local dir="$1"
    local indent="$2"
    
    # Process files first
    find "$dir" -maxdepth 1 -type f ! -name ".*" 2>/dev/null | sort | while IFS= read -r file; do
      local basename=$(basename "$file")
      local tag=$(to_xml_tag "$basename")
      echo "${indent}<${tag} name=\"${basename}\">"
      # Escape XML special characters in content
      cat "$file" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&apos;/g' | sed "s/^/${indent}  /"
      echo "${indent}</${tag}>"
    done
    
    # Then process subdirectories
    find "$dir" -maxdepth 1 -type d ! -name ".*" ! -path "$dir" 2>/dev/null | sort | while IFS= read -r subdir; do
      local basename=$(basename "$subdir")
      local tag=$(to_xml_tag "$basename")
      echo "${indent}<${tag}>"
      process_dir "$subdir" "${indent}  "
      echo "${indent}</${tag}>"
    done
  }
  
  # Start processing
  if [ -d "$path" ]; then
    local root_name=$(basename "$path")
    local root_tag=$(to_xml_tag "$root_name")
    echo "<${root_tag}>"
    process_dir "$path" "  "
    echo "</${root_tag}>"
  else
    echo "Error: Directory not found: $path"
  fi
}

/exe @toMd(@path) = sh {
  # Generate Markdown representation of directory structure
  
  function process_md_dir() {
    local dir="$1"
    local level="$2"
    local prefix=""
    
    # Create header prefix based on level
    for ((i=0; i<level; i++)); do
      prefix="${prefix}#"
    done
    
    # Process files in current directory
    find "$dir" -maxdepth 1 -type f ! -name ".*" 2>/dev/null | sort | while IFS= read -r file; do
      local basename=$(basename "$file")
      local extension="${basename##*.}"
      
      echo ""
      echo "${prefix} ${basename}"
      
      # Determine language for syntax highlighting
      local lang=""
      case "$extension" in
        js|jsx) lang="javascript" ;;
        ts|tsx) lang="typescript" ;;
        py) lang="python" ;;
        rb) lang="ruby" ;;
        go) lang="go" ;;
        rs) lang="rust" ;;
        java) lang="java" ;;
        cpp|cc|cxx) lang="cpp" ;;
        c|h) lang="c" ;;
        sh|bash) lang="bash" ;;
        yml|yaml) lang="yaml" ;;
        json) lang="json" ;;
        xml) lang="xml" ;;
        html) lang="html" ;;
        css) lang="css" ;;
        md) lang="markdown" ;;
        *) lang="" ;;
      esac
      
      echo '```'"$lang"
      cat "$file"
      echo '```'
    done
    
    # Process subdirectories
    find "$dir" -maxdepth 1 -type d ! -name ".*" ! -path "$dir" 2>/dev/null | sort | while IFS= read -r subdir; do
      local basename=$(basename "$subdir")
      echo ""
      echo "${prefix} ${basename}"
      process_md_dir "$subdir" $((level + 1))
    done
  }
  
  # Start processing
  if [ -d "$path" ]; then
    local root_name=$(basename "$path")
    echo "# ${root_name}"
    process_md_dir "$path" 2
  else
    echo "Error: Directory not found: $path"
  fi
}

/exe @tree(@path) = sh {
  # Show directory tree structure
  # Try to use tree command if available, otherwise fallback
  
  if command -v tree >/dev/null 2>&1; then
    tree -a -I '.git|node_modules|__pycache__|.DS_Store' "$path" 2>/dev/null || echo "Error: Cannot access $path"
  else
    # Fallback implementation
    function show_tree() {
      local dir="$1"
      local prefix="$2"
      local is_last="$3"
      
      local basename=$(basename "$dir")
      if [ -n "$prefix" ]; then
        echo "${prefix}${is_last:+└── }${is_last:-├── }${basename}"
      else
        echo "$basename"
      fi
      
      local new_prefix="${prefix}${is_last:+    }${is_last:-│   }"
      
      local items=()
      while IFS= read -r item; do
        items+=("$item")
      done < <(find "$dir" -maxdepth 1 ! -path "$dir" ! -name ".*" 2>/dev/null | sort)
      
      local count=${#items[@]}
      local index=0
      
      for item in "${items[@]}"; do
        index=$((index + 1))
        if [ -d "$item" ]; then
          show_tree "$item" "$new_prefix" $([[ $index -eq $count ]] && echo "1" || echo "")
        else
          local name=$(basename "$item")
          echo "${new_prefix}${index:=$count:+└── }${index:=$count:-├── }${name}"
        fi
      done
    }
    
    if [ -e "$path" ]; then
      show_tree "$path" "" ""
    else
      echo "Error: Path not found: $path"
    fi
  fi
}

/var @module = {
  toXml: @toXml,
  toMd: @toMd,
  tree: @tree
}
```