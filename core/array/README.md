# @mlld/array - Array Utilities

Comprehensive array manipulation utilities for data processing and transformation.

## Installation

```mlld
@import { * } from @mlld/array
```

## API Reference

### Basic Operations

- `length(array)` - Get array length
- `first(array)` - Get first element
- `last(array)` - Get last element
- `at(array, index)` - Get element at index
- `slice(array, start, end)` - Get array slice
- `concat(array1, array2)` - Concatenate arrays

### Transformation

- `reverse(array)` - Reverse array order
- `sort(array)` - Sort array
- `sortBy(array, key)` - Sort objects by key
- `unique(array)` - Remove duplicates
- `flatten(array)` - Flatten one level
- `deepFlatten(array)` - Flatten all levels

### Filtering

- `filter(array, key, value)` - Filter by key-value equality
- `filterGreater(array, key, value)` - Filter where key > value
- `filterLess(array, key, value)` - Filter where key < value
- `filterContains(array, key, substring)` - Filter where key contains substring
- `filterTruthy(array, key)` - Filter where key is truthy
- `filterFalsy(array, key)` - Filter where key is falsy

### Mapping

- `pluck(array, key)` - Extract values by key
- `map(array, fromKey, toKey)` - Copy key value to new key
- `transform(array, key, prefix, suffix)` - Transform key values

### Searching

- `find(array, key, value)` - Find first matching object
- `findIndex(array, key, value)` - Find index of first match
- `includes(array, value)` - Check if includes value
- `includesAny(array, values)` - Check if includes any value
- `includesAll(array, values)` - Check if includes all values

### Aggregation

- `sum(array, key)` - Sum values (or object key values)
- `avg(array, key)` - Average values
- `min(array, key)` - Minimum value
- `max(array, key)` - Maximum value
- `count(array, key, value)` - Count occurrences

### Grouping

- `groupBy(array, key)` - Group objects by key value
- `partition(array, key, value)` - Split into true/false groups

### Manipulation

- `push(array, value)` - Add to end
- `unshift(array, value)` - Add to beginning
- `remove(array, index)` - Remove at index
- `removeValue(array, value)` - Remove all occurrences
- `insert(array, index, value)` - Insert at index

### Utilities

- `range(start, end, step)` - Generate numeric range
- `repeat(value, count)` - Create array with repeated value
- `zip(array1, array2)` - Combine arrays into pairs
- `chunk(array, size)` - Split into chunks

## Usage Examples

### Basic Array Operations

```mlld
@import { first, last, slice, unique } from @mlld/array

@data numbers = [1, 2, 3, 4, 5, 3, 2, 1]
@data head = @first(@numbers)
@data tail = @last(@numbers)
@data middle = @slice(@numbers, 2, 5)
@data deduped = @unique(@numbers)

@add [[First: {{head}}, Last: {{tail}}]]
@add [[Middle slice: {{middle}}]]
@add [[Unique values: {{deduped}}]]
```

### Filtering Data

```mlld
@import { filter, filterGreater, filterContains } from @mlld/array

@data users = [
  { "name": "Alice", "age": 30, "role": "admin" },
  { "name": "Bob", "age": 25, "role": "user" },
  { "name": "Charlie", "age": 35, "role": "admin" }
]

@data admins = @filter(@users, "role", "admin")
@data over30 = @filterGreater(@users, "age", 30)
@data namesWithA = @filterContains(@users, "name", "a")

@add [[Admins: {{admins}}]]
@add [[Over 30: {{over30}}]]
```

### Data Transformation

```mlld
@import { pluck, sortBy, groupBy } from @mlld/array

@data products = [
  { "name": "Laptop", "price": 999, "category": "Electronics" },
  { "name": "Desk", "price": 299, "category": "Furniture" },
  { "name": "Phone", "price": 699, "category": "Electronics" }
]

@data names = @pluck(@products, "name")
@data sorted = @sortBy(@products, "price")
@data byCategory = @groupBy(@products, "category")

@add [[Product names: {{names}}]]
@add [[By category: {{byCategory}}]]
```

### Aggregation

```mlld
@import { sum, avg, min, max, count } from @mlld/array

@data scores = [85, 92, 78, 95, 88]
@data total = @sum(@scores)
@data average = @avg(@scores)
@data lowest = @min(@scores)
@data highest = @max(@scores)

@add [[Stats - Total: {{total}}, Avg: {{average}}, Min: {{lowest}}, Max: {{highest}}]]

@data items = [
  { "type": "book", "price": 15 },
  { "type": "book", "price": 20 },
  { "type": "toy", "price": 25 }
]
@data bookCount = @count(@items, "type", "book")
@data totalPrice = @sum(@items, "price")
@add [[Books: {{bookCount}}, Total price: ${{totalPrice}}]]
```

### Array Utilities

```mlld
@import { range, chunk, zip } from @mlld/array

@data numbers = @range(1, 10, 2)
@add [[Odd numbers: {{numbers}}]]

@data data = [1, 2, 3, 4, 5, 6, 7, 8]
@data chunks = @chunk(@data, 3)
@add [[Chunks of 3: {{chunks}}]]

@data keys = ["a", "b", "c"]
@data values = [1, 2, 3]
@data pairs = @zip(@keys, @values)
@add [[Key-value pairs: {{pairs}}]]
```

### Complex Filtering

```mlld
@import { filter, filterGreater, includes } from @mlld/array
@import { and } from @mlld/core

@data employees = [
  { "name": "Alice", "dept": "Engineering", "years": 5, "skills": ["js", "python"] },
  { "name": "Bob", "dept": "Sales", "years": 3, "skills": ["communication"] },
  { "name": "Charlie", "dept": "Engineering", "years": 7, "skills": ["js", "rust"] }
]

>> Find senior engineers
@data engineers = @filter(@employees, "dept", "Engineering")
@data seniors = @filterGreater(@engineers, "years", 4)

>> Check for specific skills
@data jsDevs = []
@foreach emp in @employees:
  @when @includes(@emp.skills, "js") => @data jsDevs = @push(@jsDevs, @emp)
```

## Notes

- All functions return JSON strings for complex data types
- Array functions are non-mutating (return new arrays)
- Numeric operations convert values to numbers automatically
- Filter functions work with object arrays using key-value matching