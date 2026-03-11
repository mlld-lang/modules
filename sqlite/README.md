# @mlld/sqlite

SQLite-backed artifact storage.

## tldr

```mlld
import { @init, @putArtifact, @appendArtifact, @getArtifact, @listArtifacts } from @mlld/sqlite

var @db = { path: "/tmp/artifacts.sqlite" }
run @init(@db)

var @saved = @putArtifact(@db, "runs", "scan-123", { status: "ok" }, { source: "demo" })
var @event = @appendArtifact(@db, "events", { kind: "done" })
show @getArtifact(@db, "runs", "scan-123")
show @listArtifacts(@db, "events", 10)
```

## docs

### `@init(config)`

Create the table and indexes if they do not exist.

`config.path` is required. `config.table` defaults to `artifacts`.

### `@putArtifact(config, collection, key, payload, meta)`

Upsert one artifact record at `collection/key`.

Stores:
- `payload`
- `meta`
- `labels` from `@mx.labels`
- `provenance` from `@mx.taint` and `@mx.sources`
- full `mx`
- timestamps

### `@appendArtifact(config, collection, payload, meta)`

Insert one artifact with an auto-generated key.

### `@getArtifact(config, collection, key)`

Load one artifact record. Returns `null` if missing.

### `@listArtifacts(config, collection, limit)`

List recent artifacts for one collection. `limit` defaults to `50`.

## License

CC0 - Public Domain
