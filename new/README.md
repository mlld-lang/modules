
## New Modules

These are experiments.

### [array.mld.md](./core/array.mld.md)

Process data arrays with powerful operations:

```mlld
@import { filter, sortBy, pluck, sum, groupBy } from @mlld/array

@data users = [
  {"name": "alice", "age": 30, "dept": "engineering"},
  {"name": "bob", "age": 25, "dept": "design"},
  {"name": "charlie", "age": 35, "dept": "engineering"}
]

@data engineers = @filter(@users, "dept", "engineering")
@data sortedByAge = @sortBy(@users, "age")
@data names = @pluck(@users, "name")
@data totalAge = @sum(@users, "age")

@add [[Engineers: {{engineers}}]]
@add [[Total age: {{totalAge}}]]
```

---

### [conditions.mld.md](./core/conditions.mld.md)

Essential utilities for building complex conditional logic in mlld:

```mlld
@import { equals, contains, gt, and, isEmpty } from @mlld/conditions

@data users = ["alice", "bob", "charlie"]
@data threshold = 10
@data count = 15

@when @and(@gt(@count, @threshold), @contains(@users, "alice")) => @add [[High count with Alice present]]
@when @isEmpty(@users) => @add [[No users found]]
@when @equals(@count, 15) => @add [[Exact match!]]
```

---

### [fs.mld.md](./core/fs.mld.md)

Provides basic file system checks that return truthy/falsy values for use with  conditions:

```mlld
@import { fileExists, dirExists, pathExists } from @mlld/fs

@when @fileExists("config.json") => @add [[Config file found!]]
@when @dirExists("src") => @add [[Source directory exists]]
@when @pathExists("README.md") => @add [[README is available]]
```

---

### [http.mld.md](./core/http.mld.md)

Quick HTTP requests with automatic JSON handling:

```mlld
@import { get, post, auth, data } from @mlld/http

@run @get("https://api.github.com/users/octocat")
@run @post("https://httpbin.org/post", {"message": "hello"})
@run @auth.get("https://api.github.com/user", @token)

@data userData = @data.get("https://api.github.com/users/octocat")
@add [[User: {{userData.name}}]]
```

---

### [string.mld.md](./core/string.mld.md)

Common string operations:

```mlld
@import { title, camelCase, split, join, trim, includes } from @mlld/string

@text name = "john doe smith"
@text formatted = @title(@name)
@text slug = @camelCase(@formatted)

@data words = @split(@name, " ")
@text rejoined = @join(@words, "-")

@when @includes(@name, "doe") => @add [[Contains 'doe']]
@add [[Formatted: {{formatted}}]]
```

---

### [ai.mld.md](./new/ai.mld.md)

Easy AI integration for your mlld scripts:

```mlld
@import { claude, llm, codex } from @mlld/ai

@text response = @claude.ask("What's the capital of France?")
@add [[Claude says: {{response}}]]

@text answer = @llm.ask("You are a helpful assistant", "Explain quantum computing in one sentence")
@add [[LLM says: {{answer}}]]
```

---

### [bundle.mld.md](./new/bundle.mld.md)

Bundle your project files for AI analysis or documentation:

```mlld
@import { xml, md, tree } from @mlld/bundle

@text src_xml = @xml("./src")
@add [[Project structure in XML:]]
@add [[{{src_xml}}]]

@text docs_md = @md("./docs")
@add [[Documentation structure:]]
@add [[{{docs_md}}]]
```

---

### [grab.mld.md](./new/grab.mld.md)

grab directories and get file listings:

```mlld
@import { grabDir, grabFiles } from @mlld/grab

@data moduleFiles = @grabDir("modules/core", "*.mld.md")
@data allFiles = @grabFiles(".", "**/*.md")

@add [[Found {{@length(@moduleFiles)}} modules]]
```
