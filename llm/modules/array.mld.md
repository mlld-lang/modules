---
name: array
author: mlld
version: 2.0.0
about: Array operations with native return values
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["arrays", "lodash", "filter", "map", "find", "includes", "math", "range", "zip", "range", "chunk"]
license: CC0
mlldVersion: ">=2.0.0-rc78"
---

/needs {
  js: []
}

# @mlld/array

Array operations for data processing, filtering, and transformation with native JavaScript return values. Version 2.0 leverages mlld 1.4.1+ return value support for cleaner data handling.

## tldr

Process data arrays with powerful operations:

```mlld
/import { filter, sortBy, pluck, sum, groupBy } from @mlld/array

/var @users = [
  {"name": "alice", "age": 30, "dept": "engineering"},
  {"name": "bob", "age": 25, "dept": "design"},
  {"name": "charlie", "age": 35, "dept": "engineering"}
]

/var @engineers = @filter(@users, "dept", "engineering")
/var @sortedByAge = @sortBy(@users, "age")
/var @names = @pluck(@users, "name")
/var @totalAge = @sum(@users, "age")

/show `Engineers: @engineers`
/show `Total age: @totalAge`
```

## docs

### Basic Operations

#### `length(array)`, `first(array)`, `last(array)`, `at(array, index)`

Essential array access and information.

```mlld
/var @items = ["apple", "banana", "cherry"]
/var @count = @length(@items)
/var @firstItem = @first(@items)
/var @lastItem = @last(@items)
/show `Count: @count`
/show `First: @firstItem`
/show `Last: @lastItem`
```

### Transformation

#### `sort(array)`, `sortBy(array, key)`, `reverse(array)`, `unique(array)`

Array reordering and deduplication.

```mlld
/var @numbers = [3, 1, 4, 1, 5]
/var @sorted = @sort(@numbers)
/var @deduplicated = @unique(@numbers)

/var @people = [{"name": "bob", "age": 25}, {"name": "alice", "age": 30}]
/var @byAge = @sortBy(@people, "age")
```

### Filtering

#### `filter(array, key, value)`, `filterGreater(array, key, value)`

Extract subsets based on conditions.

```mlld
/var @products = [
  {"name": "laptop", "price": 1000},
  {"name": "mouse", "price": 25},
  {"name": "keyboard", "price": 75}
]

/var @expensive = @filterGreater(@products, "price", 50)
/var @peripherals = @filter(@products, "category", "accessory")
```

### Data Extraction

#### `pluck(array, key)`, `find(array, key, value)`

Extract specific values from objects.

```mlld
/var @users = [{"id": 1, "name": "alice"}, {"id": 2, "name": "bob"}]
/var @names = @pluck(@users, "name")
/var @alice = @find(@users, "name", "alice")
```

### Aggregation

#### `sum(array, key)`, `avg(array, key)`, `groupBy(array, key)`

Calculate statistics and group data.

```mlld
/var @sales = [
  {"region": "north", "amount": 100},
  {"region": "south", "amount": 150},
  {"region": "north", "amount": 200}
]

/var @total = @sum(@sales, "amount")
/var @average = @avg(@sales, "amount")
/var @byRegion = @groupBy(@sales, "region")
```

### Array Building

#### `range(start, end, step)`, `push(array, value)`, `remove(array, index)`

Create and modify arrays.

```mlld
/var @numbers = @range(1, 10, 2)
/var @extended = @push(@numbers, 11)
/var @shortened = @remove(@extended, 0)
```

## module

All array operations return native JavaScript values and handle edge cases safely. Boolean operations return actual booleans, numeric operations return numbers, and array operations return arrays or objects:

```mlld-run
exe @length(array) = js {(Array.isArray(array) ? array.length : 0)}
exe @first(array) = js {(Array.isArray(array) && array.length > 0 ? array[0] : null)}
exe @last(array) = js {(Array.isArray(array) && array.length > 0 ? array[array.length - 1] : null)}
exe @at(array, index) = js {(Array.isArray(array) ? array[index] : null)}
exe @slice(array, start, end) = js {(Array.isArray(array) ? array.slice(start, end) : [])}

exe @reverse(array) = js {(Array.isArray(array) ? array.slice().reverse() : [])}
exe @sort(array) = js {(Array.isArray(array) ? array.slice().sort() : [])}
exe @sortBy(array, key) = js {(
  Array.isArray(array)
    ? array.slice().sort((a, b) => {
        const aVal = a[key];
        const bVal = b[key];
        if (aVal < bVal) return -1;
        if (aVal > bVal) return 1;
        return 0;
      })
    : []
)}
exe @unique(array) = js {(Array.isArray(array) ? [...new Set(array)] : [])}

exe @filter(array, key, value) = js {(
  Array.isArray(array)
    ? array.filter(item => item[key] == value)
    : []
)}
exe @filterGreater(array, key, value) = js {(
  Array.isArray(array)
    ? array.filter(item => Number(item[key]) > Number(value))
    : []
)}

exe @pluck(array, key) = js {(
  Array.isArray(array)
    ? array.map(item => item[key])
    : []
)}

exe @find(array, key, value) = js {(
  Array.isArray(array)
    ? array.find(item => item[key] == value) || null
    : null
)}
exe @includes(array, value) = js {(
  Array.isArray(array) && array.includes(value)
)}

exe @sum(array, key) = js {(
  Array.isArray(array)
    ? array.reduce((sum, item) => sum + Number(key ? item[key] : item), 0)
    : 0
)}
exe @avg(array, key) = js {(
  Array.isArray(array) && array.length > 0
    ? array.reduce((sum, item) => sum + Number(key ? item[key] : item), 0) / array.length
    : 0
)}

exe @groupBy(array, key) = js {(
  Array.isArray(array)
    ? array.reduce((groups, item) => {
        const group = String(item[key]);
        if (!groups[group]) groups[group] = [];
        groups[group].push(item);
        return groups;
      }, {})
    : {}
)}

exe @push(array, value) = js {(
  [...(Array.isArray(array) ? array : []), value]
)}
exe @remove(array, index) = js {(
  Array.isArray(array)
    ? array.filter((_, i) => i !== Number(index))
    : []
)}

exe @range(start, end, step) = js {(
  Array.from(
    { length: Math.ceil((end - start) / (step || 1)) },
    (_, i) => start + i * (step || 1)
  )
)}

>> Shadow environment to make functions available to each other
exe js = { length, first, last, at, slice, reverse, sort, sortBy, unique, filter, filterGreater, pluck, find, includes, sum, avg, groupBy, push, remove, range }

export { @length, @first, @last, @at, @slice, @reverse, @sort, @sortBy, @unique, @filter, @filterGreater, @pluck, @find, @includes, @sum, @avg, @groupBy, @push, @remove, @range }
```
