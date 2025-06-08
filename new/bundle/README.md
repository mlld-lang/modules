# @mlld/bundle

Bundle operations to format directory contents as XML or Markdown with proper structure and formatting.

## Installation

```mlld
@import { bundle } from @mlld/bundle
```

## Usage

### XML Format

Generate structured XML with SCREAMING_SNAKE_CASE tags:

```mlld
@run xml_output = @bundle.xml("./src")
@add [[{{xml_output}}]]
```

**Output:**
```xml
<SRC>
  <COMPONENTS>
    <BUTTON_JS name="Button.js">
    export const Button = () => <button>Click me</button>
    </BUTTON_JS>
  </COMPONENTS>
  <INDEX_JS name="index.js">
  import { Button } from './components/Button'
  </INDEX_JS>
</SRC>
```

### Markdown Format

Generate clean Markdown with headers and code blocks:

```mlld
@run md_output = @bundle.md("./docs")
@add [[{{md_output}}]]
```

**Output:**
````markdown
# docs

## api

### endpoints.md
```
# API Endpoints
GET /users
POST /users
```

## README.md
```
# Documentation
Welcome to our docs!
```
````

### Other Functions

```mlld
>> Directory tree structure
@run structure = @bundle.tree("./src")
```

## Use Cases

### Documentation Generation
```mlld
@run api_docs = @bundle.md("./api-docs")
@add [[## API Documentation]]
@add [[{{api_docs}}]]
```

### Code Review Context
```mlld
@text pr_files = "./src/components"
@run code_context = @bundle.xml(@pr_files)
>> Send to AI for review with full context
@run review = @ai.claude.ask("Review this code structure: {{code_context}}")
```

### Project Structure Export
```mlld
>> Export entire project as structured XML for AI analysis
@run project_xml = @bundle.xml(".")
@run analysis = @ai.llm.ask("You are a code analyst", "Analyze this project structure: {{project_xml}}")
```

## Features

- **Recursive directory traversal** with proper nesting
- **SCREAMING_SNAKE_CASE** XML tags for consistency
- **Clean Markdown** with appropriate header levels
- **File content preservation** with proper escaping
- **Fallback tree command** when tree utility available

## Requirements

- Standard Unix tools (`find`, `sed`, `tr`, `cat`)
- Optional: `tree` command for enhanced directory listing

## API Reference

- `bundle.xml(path)` - Generate XML structure with file contents
- `bundle.md(path)` - Generate Markdown structure with file contents  
- `bundle.tree(path)` - Show directory structure only
