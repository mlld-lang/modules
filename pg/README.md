# @mlld/pg

Postgres-backed artifact storage.

## tldr

```mlld
import { @init, @putArtifact, @appendArtifact, @getArtifact, @listArtifacts } from @mlld/pg

var @db = {
  host: "/tmp",
  port: 5432,
  database: "mlld",
  user: "mlld"
}

run @init(@db)

var @saved = @putArtifact(@db, "runs", "scan-123", { status: "ok" }, { source: "demo" })
var @event = @appendArtifact(@db, "events", { kind: "done" })
show @getArtifact(@db, "runs", "scan-123")
show @listArtifacts(@db, "events", 10)
```

## docs

### `@init(config)`

Create the schema, table, and indexes if they do not exist.

`config.connectionString` or standard `pg` connection fields are accepted.
`config.socketPath` maps to `host` for local Unix-socket setups.
`config.schema` defaults to `public`. `config.table` defaults to `artifacts`.

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
