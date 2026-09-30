# @mlld/time

Date and time operations: formatting, arithmetic, comparisons, business days, relative time and durations, grouped under one `@time` namespace.

## tldr

```mlld
import { @time } from @mlld/time

>> Use the built-in @now
const @today = @time.format(@now, "YYYY-MM-DD")
const @tomorrow = @time.add(@now, { days: 1 })

>> Compare dates
const @dateA = "2025-07-01"
const @dateB = "2025-07-08"
if @time.compare.before(@dateA, @dateB) [ show "DateA is earlier" ]

>> Human-readable relative time
const @updated = @time.relative("2025-07-07T10:00:00Z", { now: "2025-07-08T10:00:00Z" })    >> "1 day ago"

>> Work with durations
const @workWeek = @time.duration.days(5)
const @deadline = @time.add(@now, @workWeek)
```

Every function is also exported by its own name (`@format`, `@add`, `@before`, …), so `import { @format, @add } from @mlld/time` works too.

## dates in, dates out

A date can be anything JavaScript's `Date` accepts: an ISO string, a date-only string such as `"2025-07-08"`, or epoch milliseconds. Functions that return a date return an ISO 8601 string in UTC, such as `"2025-07-08T10:30:45.000Z"`, or `"Invalid Date"` when the input is not a date. For an invalid date, comparisons and `isBizDay` return `false`, `diff` and `unix` return `null`, and `relative` returns `"Invalid Date"`.

`format`, `date`, `time`, `startOf`, `endOf` and the business-day functions read the date in the machine's local timezone. A string without an offset (`"2025-07-08T10:30:45"`) is local time; one ending in `Z` is UTC. A date-only string is UTC midnight, which is the previous day in timezones west of UTC.

## docs

### Core functions

#### `format(date, pattern)`

Format a date with pattern tokens:

- `YYYY` - 4-digit year (2025)
- `YY` - 2-digit year (25)
- `MM` - 2-digit month (01-12)
- `M` - Month (1-12)
- `DD` - 2-digit day (01-31)
- `D` - Day (1-31)
- `HH` - 2-digit hour (00-23)
- `H` - Hour (0-23)
- `mm` - 2-digit minute (00-59)
- `m` - Minute (0-59)
- `ss` - 2-digit second (00-59)
- `s` - Second (0-59)

```mlld
import { @time } from @mlld/time
const @formatted = @time.format("2025-07-08T10:30:45", "YYYY-MM-DD HH:mm:ss")
>> "2025-07-08 10:30:45"
```

#### `parse(input, pattern)`

Returns the ISO string for `input`, or `"Invalid Date"`. `pattern` is accepted for compatibility and ignored: parsing is JavaScript's `Date`.

```mlld
import { @time } from @mlld/time
const @date = @time.parse("2025-07-08", "YYYY-MM-DD")
>> "2025-07-08T00:00:00.000Z"
```

#### `add(date, duration)`

Add a duration. It is an object with any of `years`, `months`, `weeks`, `days`, `hours`, `minutes`, `seconds`.

```mlld
import { @time } from @mlld/time
const @nextWeek = @time.add(@now, { weeks: 1 })
const @future = @time.add(@now, { years: 1, months: 2, days: 3 })
```

#### `subtract(date, duration)`

Subtract a duration. Same duration shape as `add`.

```mlld
import { @time } from @mlld/time
const @lastMonth = @time.subtract(@now, { months: 1 })
```

#### `diff(dateFrom, dateTo, unit)`

`dateTo` minus `dateFrom`, in `years`, `months`, `weeks`, `days`, `hours`, `minutes` or `seconds`; any other unit gives milliseconds. Months and years use average lengths (30.44 and 365.25 days), so they are approximate.

```mlld
import { @time } from @mlld/time
const @daysBetween = @time.diff("2025-07-01", "2025-07-10", "days")    >> 9
```

### Comparisons (`@time.compare.*`)

All return booleans.

- `before(dateA, dateB)` - true if dateA is earlier than dateB
- `after(dateA, dateB)` - true if dateA is later than dateB
- `equal(dateA, dateB)` - true if both are the same millisecond
- `between(date, start, end)` - true if date is within start and end, inclusive

```mlld
import { @time } from @mlld/time
const @deadline = "2025-07-01T17:00:00Z"
if @time.compare.before(@deadline, @now) [ show "Deadline passed!" ]
```

### Business days (`@time.biz.*`)

- `isBizDay(date)` - true Monday to Friday
- `addDays(date, days)` - add business days, skipping weekends; a negative count goes backwards

```mlld
import { @time } from @mlld/time
const @friday = "2025-07-11T10:00:00"
const @nextBizDay = @time.biz.addDays(@friday, 1)    >> Monday 2025-07-14
```

### Timezone (`@time.tz.*`)

- `current()` - the machine's timezone name, such as `"America/New_York"`
- `offset()` - its current UTC offset, such as `"-05:00"` or `"+01:00"`

### Shortcuts

- `iso(date)` - ISO 8601 string
- `unix(date)` - seconds since the epoch
- `date(date)` - the local date, `"YYYY-MM-DD"` (also exported as `@dateOnly`)
- `time(date)` - the local time, `"HH:mm:ss"` (also exported as `@timeOnly`)

```mlld
import { @time } from @mlld/time
const @timestamp = @time.unix(@now)    >> 1751970645
const @day = @time.date(@now)          >> "2025-07-08"
```

### Boundaries

- `startOf(date, unit)` - the first millisecond of the local `day`, `month` or `year`
- `endOf(date, unit)` - the last millisecond of the local `day`, `month` or `year`

```mlld
import { @time } from @mlld/time
const @dayStart = @time.startOf(@now, "day")
const @monthEnd = @time.endOf(@now, "month")
```

### Relative time

#### `relative(date, options)`

A phrase such as `"3 hours ago"`, `"in 2 days"` or `"just now"`. Options:

- `precise: true` - add the next unit down (`"1 day 3 hours ago"`)
- `now` - the instant to measure from; defaults to the current time. Pass it for output that does not change from run to run.

```mlld
import { @time } from @mlld/time
const @ago = @time.relative("2025-07-07T10:00:00Z", { now: "2025-07-08T13:00:00Z" })
>> "1 day ago"
const @precise = @time.relative("2025-07-07T10:00:00Z", { now: "2025-07-08T13:00:00Z", precise: true })
>> "1 day 3 hours ago"
```

### Durations (`@time.duration.*`, also exported as `@duration`)

Build duration objects for `add` and `subtract`.

- `weeks(n)`, `days(n)`, `hours(n)`, `minutes(n)`, `seconds(n)` - `{ weeks: n }` and so on
- `compose(parts)` - returns `parts` as the duration
- `multiply(duration, factor)` - every value times `factor`
- `divide(duration, divisor)` - every value divided by `divisor`

```mlld
import { @time } from @mlld/time
const @oneWeek = @time.duration.weeks(1)                        >> { weeks: 1 }
const @shift = @time.duration.compose({ hours: 2, minutes: 30 })
const @doubled = @time.duration.multiply({ hours: 2 }, 2)       >> { hours: 4 }
const @half = @time.duration.divide({ hours: 4 }, 2)            >> { hours: 2 }
```

## license

CC0 - Public Domain
