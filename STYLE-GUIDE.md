# mlld Module Style Guide

## Structure

Every module must have exactly three sections:
1. `## tldr` - What it does and why you'd use it
2. `## docs` - Function reference with examples
3. `## module` - The implementation in `mlld-run` blocks

## Writing Style

- **Be terse**: Write like man pages, not blog posts
- **No marketing**: "Parse JSON" not "Powerful JSON parsing for modern workflows"
- **Use imperatives**: "Format dates" not "Formats dates"
- **Show, don't explain**: Examples > explanations

## Documentation Rules

### tldr Section
- 2-3 sentences max describing the module's purpose
- One clear example showing primary use case
- No feature lists or sales pitch

### docs Section
- List functions with signatures: `functionName(param1, param2)`
- One-line description per function
- Show input → output with examples
- Note limitations or quirks inline

### module Section
- No debug code (`console.log`, etc.)
- Export all public functions
- Use shadow environments for complex modules

## Examples

❌ **Bad**: "This amazing module provides cutting-edge functionality for handling arrays with unprecedented ease!"

✅ **Good**: "Array manipulation utilities."

❌ **Bad**: Long explanations of what each parameter does

✅ **Good**: 
```mlld
/var @sorted = @sort([3, 1, 2])  >> [1, 2, 3]
```

## Common Mistakes

1. Adding extra sections beyond the required three
2. Writing conversational error messages
3. Leaving debug statements in code
4. Over-explaining instead of showing examples
5. Using marketing language ("powerful", "easy", "amazing")

## Error Messages

Keep them technical and actionable:
- ❌ "Oops! Something went wrong!"
- ✅ "Invalid date format"
- ✅ "File not found: config.json"