# @mlld/shelf

A shelf is a mlld `state` built from records, with one slot per record family (`contact`, `note`, …). A program files tool results into it with `@observe`, which also says whether a result added anything new, shows them to an agent with `@render`, and the agent cites what it has seen by address — `"contact:69d3c20c81180863"` — or by `{ ref: { address, field } }`. This module finds the record at an address and resolves a ref to the field value it names. A resolved value is the stored field itself, so it keeps its labels and proof, and can be used where proof is required, such as in a grant. This is the same resolution `@mlld/authorize` uses, duplicated on purpose: authorize is bundled into the mlld binary and cannot import a module. Core mlld owns the state, its labels and its write permissions; the module only organises the data.

Every export takes untrusted input and answers `null` or `false` for anything malformed rather than throwing. Exports that take `families` limit lookups to those families; leave it out, or pass anything that is not a list, to allow every slot of the shelf.

## tldr

```mlld
import { @find, @resolveRef } from @mlld/shelf

record @contact [
  key id
  id: string [ kind "contact" ]
  name: string
  * { read: [id, name] }
  .role:worker { write: { state: [upsert] } }
]
exe @mkContact(i, n) = { id: @i, name: @n } => contact
const @recs = { contact: @contact }
state @st from @recs

exe .role:worker @file(s, r) = [
  let @w = @s.upsert("contact", @r)
  => "stored"
]
const @done = @file(@st, @mkContact("c1", "Ann"))
const @addr = @st.contact[0].mx.address.string

show @find(@st, @addr).name
show @resolveRef({ ref: { address: @addr, field: "id" } }, @st)
```

## Security

- **Runs as the caller's role.** No exe in the module carries a role label, so every write through `@put` or `@observe` is checked against the role of the code that calls it. A caller without the record's write grant is refused by core.
- **Keeps labels and proof.** The module is written in mlld only, with no `js` or shell blocks: a value that crosses into js loses its proof. A record found with `@find`, or a field resolved with `@resolveRef`, is the stored value itself and can be used where proof is required.
- **Renders only the active role's view.** `@render` takes no role argument. It shows what the role active at the call may read, so a caller cannot ask for a wider view than its own. Every `<` in the output is escaped, so stored data cannot close the `<observed>` block.
- **Never throws on untrusted input.** Addresses, refs and arguments an agent wrote get `null`, `false`, `[]` or `""` back when malformed, including a plain object passed where a state belongs.

## docs

### `@familyOf(address)`

The record family of an address: the text before the first `:`. `null` for an empty string, a non-string, a string with no `:`, or an empty family (`":x"`). A `{ handle: … }` object is not an address; core mlld resolves such an argument before the function runs and refuses an unknown handle, so wrap the call in `try` if the input may be one.

```mlld
show @familyOf("contact:c1")   >> contact
show @familyOf("contact")      >> null
```

### `@families(st)`

The names of the shelf's record slots, as a list. A plain state such as `state @s = { label: string?, contact: contact[] }` also has ordinary slots; they are not families, so no export lists, renders or counts them.

```mlld
show @families(@st)   >> ["contact"]
```

### `@find(st, address, families?)`

The stored record at `address`, or `null` when the address has no family, its family is not in `families` or not a slot of the shelf, or nothing is stored there.

```mlld
show @find(@st, @addr).name           >> Ann
show @find(@st, @addr, ["note"])      >> null
show @find(@st, "../x")               >> null
```

### `@isRef(v)`

`true` exactly for `{ ref: { address: <string>, field: <string> } }`.

```mlld
show @isRef({ ref: { address: "contact:c1", field: "id" } })   >> true
show @isRef("contact:c1")                                       >> false
```

### `@resolveRef(refObj, st, families?)`

The value of `field` on the record that `@find` returns for `address`, with its labels and proof intact. `null` if `refObj` is not a ref, no record is found, or the record has no such field. Only the record's own fields count, so a ref cannot read metadata such as `mx`.

```mlld
const @to = @resolveRef({ ref: { address: @addr, field: "id" } }, @st)
const @g = { args: { to: @to } } as grant for @send
```

The same text typed by hand carries no proof, and the grant refuses it.

### `@firstUnresolved(args, st, families?)`

Over an object of args, the first `{ arg, addr }` whose value is a ref that does not resolve, or `null` when every ref resolves. Lets a caller deny with the address in hand instead of a bare grant refusal. Values that are not refs are skipped.

```mlld
const @miss = @firstUnresolved({ to: { ref: { address: "contact:gone", field: "id" } } }, @st)
show @miss   >> { "arg": "to", "addr": "contact:gone" }
```

### Writes and permissions

`@put` and `@observe` carry no role label, so they write as whoever calls them. Core checks the record's write grant against the caller's role and ends the run on a refusal (`WRITE_DENIED_*`; `try` does not catch it). Call them from an exe labelled with a role the record grants, as `@file` does in the tldr above.

The grant is spelled `.role:<name> { write: { state: [upsert] } }` (`shelves` is its older name). There is no separate `append` capability: appending to a keyless record's slot is checked against `upsert` too.

### `@addsData(st, record)`

`true` when writing `record` would change what the shelf holds: nothing is stored at its address, or one of its non-null fields is missing from the stored record or differs from it. Fields that are `null` on `record` don't count, and its metadata (`mx`) is ignored. Values are compared by structure: arrays element by element in order, objects by keys and values. `false` for anything that is not a record.

```mlld
show @addsData(@st, @mkContact("c1", "Ann"))   >> false, already stored
show @addsData(@st, @mkContact("c1", "Anne"))  >> true, the name changed
```

### `@put(st, record, families?)`

Writes `record` into the slot for its family and returns `{ address, family, written, redundant }`. `redundant` is `true` when the record added nothing, judged before the write. A record whose family is not allowed or not a slot of the shelf, or a value that is not a record, returns `written: false` and writes nothing.

A record type that declares a `key` replaces the stored record with the same key; a keyless one is appended, so the same keyless record put twice is stored twice (the second put reports `redundant: true`).

```mlld
exe .role:worker @fileOne(s, r) = @put(@s, @r)
show @fileOne(@st, @mkContact("c2", "Bo"))
>> { "address": "contact:…", "family": "contact", "written": true, "redundant": false }
```

### `@observe(st, records, families?)`

`@put` over a list of records, or a single record. Returns `{ addresses, written, redundant }`: the addresses written, how many, and whether the batch added nothing new. `redundant` is `true` only when at least one record was written and none of them added data, so a tool result that repeats what the shelf holds can be reported as such.

```mlld
exe .role:worker @fileAll(s, rs) = @observe(@s, @rs)
show @fileAll(@st, [@mkContact("c1", "Ann")]).redundant   >> true
```

Records holding a `.secret` value are filed into a plain state and keep the label, however the list arrived: written out in place, or returned by an exe (the usual shape of a tool result).

Once a slot holds a `.secret` value, everything read from that slot directly is labeled `.secret`, including its records that hold no secret (`@st.locker[0].label`), and so is the text `@render` returns for that slot. `@find` returns a record with its own labels only. Other slots are not affected. Under a policy that blocks secrets from leaving (such as `@noSecretExfil`, see the mlld security guide), that slot's whole content is then treated as a secret, so keep secret-holding record types in their own slot, apart from the ones the agent must be free to pass on.

### `@render(st, families?, options?)`

The stored records in `families` (default: every slot), as the role active where `@render` is called may see them: one JSON line per record, in slot order then storage order, inside `<observed>` tags. `""` when no record is stored there.

```
<observed>
{"address":"card:3f2a…","fields":{"name":"Ada"},"ref_fields":["email","phone"]}
</observed>
```

- `fields` holds the values the role may read (`bare` and `value` read modes).
- `ref_fields` names the fields the role may cite with a `{ref}` but not see (`mask`, `handle` and `protected` modes). Their values, previews and handles never appear.
- A field in `omit` mode appears in neither.
- With no role active, the record's `*` read rule decides.
- Every `<` in a line is written as `\u003c` (the same character in JSON), so a stored value cannot close the `<observed>` block.

It renders only the active role's view and takes no role argument on purpose: a string carries nothing that would re-project it for the reader, so a role argument would let a caller render a wider view than its own.

To show the shelf to an agent, put the call in a `fyi` field. Core evaluates the field when an `llm` call reads it, as that call's role, so each agent sees its own view:

```mlld
fyi @shelfView = { observed: @render(@st), push: [observed] }

llm .role:planner @planner(prompt, config) = …
show @planner("Plan the next step", { fyi: @shelfView })
```

### Caching renders: `options.cache`

A program that renders the same shelf on every llm call can cache the rendered text per role. Pass the roles to cache:

```mlld
fyi @shelfView = { observed: @render(@st, null, { cache: [".role:planner"] }), push: [observed] }
```

- The cache is used only when the role active at the call is listed in `cache`. Otherwise `@render` renders as usual.
- Each slot's text is kept per state, role and slot. A state is told apart by its id (`@st.mx.id`), which stays the same when the state is passed as a parameter or as `.readonly()`, and is new for each call of an exe that declares the state. Every write to a slot bumps its version (see Versions), so a write is always shown on the next render, and the old text is replaced.
- `key` is optional: `{ cache: [...], key: { id: "…" } }` keys the entries by `key.id` instead of the state's id. `@cacheFor(st)` returns `{ id }` holding the state's id, so `key: @cacheFor(@st)` still works and is no longer needed.
- The cache lives in the module's own state, so the caller needs no write grant for it. Cached text keeps every label of the uncached render, and also carries `.src:state:@renderCache.…` labels naming that state.
- A rendered line never contains a handle; a slot whose text would hold one of the session's handles is not cached.

Rendering 200 records five times took about 3.1s cached against 10.6s uncached (debug build).

### Versions: `@version`, `@versions`, `@changedSince`

Core counts every write applied to a slot (`upsert`, `append`, `set`, `remove`, `clear`) and these read that count. Versions count writes, not changes: an `upsert` of a record identical to the stored one still bumps it. Use `@put`'s `redundant` to detect writes that changed nothing.

- `@version(st, family)`: the slot's write count, `0` if never written; `null` for a family the shelf lacks.
- `@versions(st, families?)`: `{ <family>: <count> }` for each family (default: every slot). A plain object the caller can keep as a snapshot.
- `@changedSince(st, snapshot, families?)`: the families whose count is higher than in `snapshot`. A family missing from `snapshot` counts as `0`.

```mlld
const @before = @versions(@st)
exe .role:worker @fileAll(s, rs) = @observe(@s, @rs)
const @w = @fileAll(@st, [@mkContact("c3", "Cy")])
show @changedSince(@st, @before)   >> ["contact"]
```

## Migrating from `with { versioned, projection_cache }`

Shelves used to take these options on their declaration. Both now live in this module:

- `with { versioned: true }`: delete it. Every record slot counts its writes; read the count with `@version`, `@versions` or `@changedSince`.
- `with { projection_cache: [roles] }`: delete it, and pass `{ cache: [roles] }` on the program's `@render` calls. No key is needed.

## License

CC0 - Public Domain
