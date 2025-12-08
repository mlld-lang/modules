---
name: fs
author: mlld
version: 1.0.0
about: Filesystem operations
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["fs", "filesystem"]
license: CC0
mlldVersion: "*"
---

/needs {
  sh
}

# @mlld/fs

File system operations for checking the existence of files, directories, and paths. Useful for conditional logic in mlld workflows.

## tldr

Provides basic file system checks that return truthy/falsy values for use with `@when` conditions:

```mlld
/import { fileExists, dirExists, pathExists } from @mlld/fs

/when @fileExists("config.json") => /show "Config file found!"
/when @dirExists("src") => /show "Source directory exists"
/when @pathExists("README.md") => /show "README is available"
```

## docs

### `fileExists(path)`

Check if a regular file exists at the given path.

```mlld
/when @fileExists("package.json") => /show "NPM project detected"
```

Returns `"true"` if the file exists, empty string otherwise.

### `dirExists(path)`

Check if a directory exists at the given path.

```mlld
/when @dirExists("node_modules") => /show "Dependencies installed"
```

Returns `"true"` if the directory exists, empty string otherwise.

### `pathExists(path)`

Check if any file system object (file, directory, symlink, etc.) exists at the given path.

```mlld
/when @pathExists(".git") => /show "Git repository"
```

Returns `"true"` if anything exists at the path, empty string otherwise.

## module

These functions use shell commands to check file system state and return "true" or empty string for use in conditionals:

```mlld-run
/exe @fileExists(@path) = sh {
  if test -f "$path"; then
    echo "true"
  else
    echo ""
  fi
}
/exe @dirExists(@path) = sh {
  if test -d "$path"; then
    echo "true"
  else
    echo ""
  fi
}
/exe @pathExists(@path) = sh {
  if test -e "$path"; then
    echo "true"
  else
    echo ""
  fi
}

/export { @fileExists, @dirExists, @pathExists }
```
