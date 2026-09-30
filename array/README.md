# @mlld/array

Array helpers that mlld's builtin methods don't cover. Everything else this module used to offer is now a builtin method; see [Moved to builtins](#moved-to-builtins).

## tldr

```mlld
import { @groupBy, @sortBy, @sum, @unique } from @mlld/array

const @sales = [
  { region: "north", amount: 100 },
  { region: "south", amount: 150 },
  { region: "north", amount: 200 }
]
show @sum(@sales, "amount")
show @groupBy(@sales, "region").mx.keys
show @sortBy(@sales, "amount").map(@item.region)
show @unique(@sales.map(@item.region))
```

## docs

Each function returns an empty result (`[]`, `0` or `{}`) when given something that is not an array.

- `@unique(array)`: elements in first-seen order, duplicates dropped.
- `@groupBy(array, key)`: an object from each element's `key` field, as text, to the elements that have it.
- `@sortBy(array, key)`: a copy ordered by each element's `key` field, ascending.
- `@sum(array, key?)`: the total of the elements, or of their `key` field; text such as `"3"` counts as a number.
- `@avg(array, key?)`: the mean, or `0` for an empty array.
- `@range(start, end, step?)`: numbers from `start` up to, not including, `end`. `step` defaults to 1 and may be negative.
- `@chunk(array, size)`: the array cut into pieces of `size`; the last may be shorter.
- `@zip(a, b)`: pairs `[a[i], b[i]]` for each element of `a`, with `null` past the end of `b`.

```mlld
import { @range, @chunk, @zip } from @mlld/array

show @range(1, 10, 2)
show @chunk([1, 2, 3, 4, 5], 2)
show @zip(["name", "age"], ["alice", 30])
```

## Moved to builtins

Version 3.0.0 drops the functions below. Each is a method on the array itself; see the mlld docs on builtin methods.

| Removed | Use instead |
|---|---|
| `@length(a)` | `@a.length` |
| `@first(a)` / `@last(a)` / `@at(a, i)` | `@a.at(0)` / `@a.at(-1)` / `@a.at(@i)` |
| `@slice(a, s, e)` | `@a.slice(@s, @e)` |
| `@reverse(a)` / `@sort(a)` | `@a.reverse()` / `@a.sort()` |
| `@filter(a, "k", v)` | `@a.filter(@item.k == @v)` |
| `@filterGreater(a, "k", v)` | `@a.filter(@item.k > @v)` |
| `@pluck(a, "k")` | `@a.map(@item.k)` |
| `@find(a, "k", v)` | `@a.find(@item.k == @v)` |
| `@every(a, "k", v)` / `@some(a, "k", v)` | `@a.every(@item.k == @v)` / `@a.some(@item.k == @v)` |
| `@includes(a, v)` / `@indexOf(a, v)` | `@a.includes(@v)` / `@a.indexOf(@v)` |
| `@join(a, sep)` / `@concat(a, b)` | `@a.join(@sep)` / `@a.concat(@b)` |
| `@flat(a, depth)` | `@a.flat(@depth)` |
| `@flatMap(a, "k")` | `@a.map(@item.k).flat()` |
| `@compact(a)` | `@a.filter(@item)` |
| `@push(a, v)` | `[...@a, @v]` |
| `@remove(a, i)` | `for @x in @a if @x.mx.index != @i => @x` |

## License

CC0 - Public Domain
