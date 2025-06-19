---
name: fs
author: mlld
version: 1.0.0
about: Filesystem operations
needs: ["sh"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["fs", "filesystem"]
license: CC0
mlldVersion: "*"
---

# @mlld/fs

File system operations for checking the existence of files, directories, and paths. Useful for conditional logic in mlld workflows.

## tldr

Provides basic file system checks that return truthy/falsy values for use with `@when` conditions:

```mlld
@import { fileExists, dirExists, pathExists } from @mlld/fs

@when @fileExists("config.json") => @add [[Config file found!]]
@when @dirExists("src") => @add [[Source directory exists]]
@when @pathExists("README.md") => @add [[README is available]]
```

## docs

### `fileExists(path)`

Check if a regular file exists at the given path.

```mlld
@when @fileExists("package.json") => @add [[NPM project detected]]
```

Returns `"true"` if the file exists, empty string otherwise.

### `dirExists(path)`

Check if a directory exists at the given path.

```mlld
@when @dirExists("node_modules") => @add [[Dependencies installed]]
```

Returns `"true"` if the directory exists, empty string otherwise.

### `pathExists(path)`

Check if any file system object (file, directory, symlink, etc.) exists at the given path.

```mlld
@when @pathExists(".git") => @add [[Git repository]]
```

Returns `"true"` if anything exists at the path, empty string otherwise.

## module

These functions use shell commands to check file system state and return "true" or empty string for use in conditionals:

```mlld-run
@exec fileExists(path) = @run [(test -f "@path" && echo "true" || echo "")]
@exec dirExists(path) = @run [(test -d "@path" && echo "true" || echo "")]
@exec pathExists(path) = @run [(test -e "@path" && echo "true" || echo "")]
```

