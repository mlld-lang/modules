---
name: array
author: mlld
version: 2.0.0
about: Array operations with native return values
needs: ["js"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["arrays", "lodash", "filter", "map", "find", "includes", "math", "range", "zip", "range", "chunk"]
license: CC0
mlldVersion: ">=1.4.1"
---

# @mlld/array

Array operations for data processing, filtering, and transformation with native JavaScript return values. Version 2.0 leverages mlld 1.4.1+ return value support for cleaner data handling.

## tldr

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

## docs

### Basic Operations

#### `length(array)`, `first(array)`, `last(array)`, `at(array, index)`

Essential array access and information.

```mlld
@data items = ["apple", "banana", "cherry"]
@add [[Count: {{@length(@items)}}]]
@add [[First: {{@first(@items)}}]]
@add [[Last: {{@last(@items)}}]]
```

### Transformation

#### `sort(array)`, `sortBy(array, key)`, `reverse(array)`, `unique(array)`

Array reordering and deduplication.

```mlld
@data numbers = [3, 1, 4, 1, 5]
@data sorted = @sort(@numbers)
@data deduplicated = @unique(@numbers)

@data people = [{"name": "bob", "age": 25}, {"name": "alice", "age": 30}]
@data byAge = @sortBy(@people, "age")
```

### Filtering

#### `filter(array, key, value)`, `filterGreater(array, key, value)`

Extract subsets based on conditions.

```mlld
@data products = [
  {"name": "laptop", "price": 1000},
  {"name": "mouse", "price": 25},
  {"name": "keyboard", "price": 75}
]

@data expensive = @filterGreater(@products, "price", 50)
@data peripherals = @filter(@products, "category", "accessory")
```

### Data Extraction

#### `pluck(array, key)`, `find(array, key, value)`

Extract specific values from objects.

```mlld
@data users = [{"id": 1, "name": "alice"}, {"id": 2, "name": "bob"}]
@data names = @pluck(@users, "name")
@data alice = @find(@users, "name", "alice")
```

### Aggregation

#### `sum(array, key)`, `avg(array, key)`, `groupBy(array, key)`

Calculate statistics and group data.

```mlld
@data sales = [
  {"region": "north", "amount": 100},
  {"region": "south", "amount": 150},
  {"region": "north", "amount": 200}
]

@data total = @sum(@sales, "amount")
@data average = @avg(@sales, "amount")
@data byRegion = @groupBy(@sales, "region")
```

### Array Building

#### `range(start, end, step)`, `push(array, value)`, `remove(array, index)`

Create and modify arrays.

```mlld
@data numbers = @range(1, 10, 2)
@data extended = @push(@numbers, 11)
@data shortened = @remove(@extended, 0)
```

## module

All array operations return native JavaScript values and handle edge cases safely. Boolean operations return actual booleans, numeric operations return numbers, and array operations return arrays or objects:

```mlld-run
@exec length(array) = @run js [(return Array.isArray(array) ? array.length : 0)]
@exec first(array) = @run js [(return Array.isArray(array) && array.length > 0 ? array[0] : null)]
@exec last(array) = @run js [(return Array.isArray(array) && array.length > 0 ? array[array.length - 1] : null)]
@exec at(array, index) = @run js [(return Array.isArray(array) ? array[index] : null)]
@exec slice(array, start, end) = @run js [(return Array.isArray(array) ? array.slice(start, end) : [])]

@exec reverse(array) = @run js [(return Array.isArray(array) ? array.slice().reverse() : [])]
@exec sort(array) = @run js [(return Array.isArray(array) ? array.slice().sort() : [])]
@exec sortBy(array, key) = @run js [(
  return Array.isArray(array) 
    ? array.slice().sort((a, b) => {
        const aVal = a[key];
        const bVal = b[key];
        if (aVal < bVal) return -1;
        if (aVal > bVal) return 1;
        return 0;
      })
    : []
)]
@exec unique(array) = @run js [(return Array.isArray(array) ? [...new Set(array)] : [])]

@exec filter(array, key, value) = @run js [(
  return Array.isArray(array) 
    ? array.filter(item => item[key] == value)
    : []
)]
@exec filterGreater(array, key, value) = @run js [(
  return Array.isArray(array) 
    ? array.filter(item => Number(item[key]) > Number(value))
    : []
)]

@exec pluck(array, key) = @run js [(
  return Array.isArray(array) 
    ? array.map(item => item[key])
    : []
)]

@exec find(array, key, value) = @run js [(
  return Array.isArray(array) 
    ? array.find(item => item[key] == value) || null
    : null
)]
@exec includes(array, value) = @run js [(
  return Array.isArray(array) && array.includes(value)
)]

@exec sum(array, key) = @run js [(
  return Array.isArray(array) 
    ? array.reduce((sum, item) => sum + Number(key ? item[key] : item), 0)
    : 0
)]
@exec avg(array, key) = @run js [(
  return Array.isArray(array) && array.length > 0
    ? array.reduce((sum, item) => sum + Number(key ? item[key] : item), 0) / array.length
    : 0
)]

@exec groupBy(array, key) = @run js [(
  return Array.isArray(array) 
    ? array.reduce((groups, item) => {
        const group = String(item[key]);
        if (!groups[group]) groups[group] = [];
        groups[group].push(item);
        return groups;
      }, {})
    : {}
)]

@exec push(array, value) = @run js [(
  return [...(Array.isArray(array) ? array : []), value]
)]
@exec remove(array, index) = @run js [(
  return Array.isArray(array) 
    ? array.filter((_, i) => i !== Number(index))
    : []
)]

@exec range(start, end, step) = @run js [(
  return Array.from(
    { length: Math.ceil((end - start) / (step || 1)) },
    (_, i) => start + i * (step || 1)
  )
)]
```