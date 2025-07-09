---
name: time
author: mlld
version: 1.0.0
about: Time and date operations with structured exports
needs: ["js", "node"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["time", "date", "format", "parse", "timezone", "duration"]
license: CC0
mlldVersion: "*"
---

# @mlld/time

Comprehensive time and date operations with organized namespaces.

## tldr

```mlld
/import { time } from @mlld/time

>> Use the built-in @now
/var @today = @time.format(@now, "YYYY-MM-DD")
/var @tomorrow = @time.add(@now, { days: 1 })

>> Compare dates
/when @time.compare.before(@dateA, @dateB) => /show "DateA is earlier"

>> Human-readable relative time
/var @updated = @time.relative(@lastModified)  >> "2 hours ago"

>> Work with durations
/var @workWeek = @time.duration.days(5)
/var @deadline = @time.add(@now, @workWeek)
```

## docs

### Core Functions

#### `format(date, pattern)`

Format dates using pattern strings.

Pattern tokens:
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
/var @formatted = @time.format("2025-07-08T10:30:45Z", "YYYY-MM-DD HH:mm:ss")
>> "2025-07-08 10:30:45"
```

#### `parse(input, pattern)`

Parse date strings. Returns ISO string or "Invalid Date".
Note: Currently ignores pattern parameter and uses JavaScript Date parsing.

```mlld
/var @date = @time.parse("2025-07-08", "YYYY-MM-DD")
>> "2025-07-08T00:00:00.000Z"
```

#### `add(date, duration)`

Add duration to date. Duration object can contain:
- `years`, `months`, `weeks`, `days`, `hours`, `minutes`, `seconds`

```mlld
/var @nextWeek = @time.add(@now, { weeks: 1 })
/var @future = @time.add(@now, { years: 1, months: 2, days: 3 })
```

#### `subtract(date, duration)`

Subtract duration from date. Same duration format as `add`.

```mlld
/var @lastMonth = @time.subtract(@now, { months: 1 })
```

#### `diff(dateFrom, dateTo, unit)`

Calculate difference between dates.

Units: `years`, `months`, `weeks`, `days`, `hours`, `minutes`, `seconds`
Default: returns milliseconds

```mlld
/var @daysBetween = @time.diff("2025-07-01", "2025-07-10", "days")  >> 9
```

### Comparison Functions (`time.compare.*`)

All return boolean values.

#### `before(dateA, dateB)`
Returns true if dateA is before dateB.

#### `after(dateA, dateB)`
Returns true if dateA is after dateB.

#### `equal(dateA, dateB)`
Returns true if dates are exactly equal (same millisecond).

#### `between(date, start, end)`
Returns true if date is between start and end (inclusive).

```mlld
/when @time.compare.before(@deadline, @now) => /show "Deadline passed!"
```

### Business Days (`time.biz.*`)

#### `isBizDay(date)`
Returns true if date is Monday-Friday.

#### `addDays(date, days)`
Add business days, skipping weekends.

```mlld
/var @friday = "2025-07-11"
/var @nextBizDay = @time.biz.addDays(@friday, 1)  >> Monday 2025-07-14
```

### Timezone (`time.tz.*`)

#### `current()`
Returns current timezone string (e.g., "America/New_York").

#### `offset()`
Returns current UTC offset (e.g., "-05:00" or "+01:00").

### Shortcut Functions

#### `iso(date)`
Convert to ISO 8601 string.

#### `unix(date)`
Convert to Unix timestamp (seconds since epoch).

#### `date(date)`
Extract date portion as "YYYY-MM-DD".

#### `time(date)`
Extract time portion as "HH:mm:ss".

```mlld
/var @timestamp = @time.unix(@now)  >> 1735689600
/var @dateOnly = @time.date(@now)  >> "2025-07-08"
```

### Boundary Functions

#### `startOf(date, unit)`
Round down to start of unit. Units: `day`, `month`, `year`

#### `endOf(date, unit)`
Round up to end of unit. Units: `day`, `month`, `year`

```mlld
/var @dayStart = @time.startOf(@now, "day")  >> "2025-07-08T00:00:00.000Z"
/var @monthEnd = @time.endOf(@now, "month")  >> "2025-07-31T23:59:59.999Z"
```

### Relative Time

#### `relative(date, options)`
Human-readable relative time from now.

Options:
- `precise: true` - Include additional precision

```mlld
/var @ago = @time.relative("2025-07-07T10:00:00Z")  >> "1 day ago"
/var @precise = @time.relative(@date, { precise: true })  >> "1 day 3 hours ago"
```

### Duration Helpers (`time.duration.*`)

Create duration objects for use with `add` and `subtract`.

#### `weeks(count)`, `days(count)`, `hours(count)`, `minutes(count)`, `seconds(count)`

```mlld
/var @oneWeek = @time.duration.weeks(1)  >> { weeks: 1 }
/var @workDay = @time.duration.hours(8)  >> { hours: 8 }
```

#### `compose(parts)`
Create composite duration. Note: Currently just returns the input object.

```mlld
/var @duration = @time.duration.compose({ hours: 2, minutes: 30 })
```

#### `multiply(duration, factor)`
Multiply all duration values.

```mlld
/var @doubled = @time.duration.multiply({ hours: 2 }, 2)  >> { hours: 4 }
```

#### `divide(duration, divisor)`
Divide all duration values.

```mlld
/var @half = @time.duration.divide({ hours: 4 }, 2)  >> { hours: 2 }
```

## module

```mlld-run
# Core formatting
/exe @format(@date, @pattern) = node {
  const d = new Date(date);
  if (isNaN(d.getTime())) return 'Invalid Date';
  
  const pad = n => String(n).padStart(2, '0');
  
  const replacements = {
    'YYYY': d.getFullYear(),
    'YY': String(d.getFullYear()).slice(-2),
    'MM': pad(d.getMonth() + 1),
    'M': d.getMonth() + 1,
    'DD': pad(d.getDate()),
    'D': d.getDate(),
    'HH': pad(d.getHours()),
    'H': d.getHours(),
    'mm': pad(d.getMinutes()),
    'm': d.getMinutes(),
    'ss': pad(d.getSeconds()),
    's': d.getSeconds()
  };
  
  let result = pattern;
  for (const [key, value] of Object.entries(replacements)) {
    result = result.replace(new RegExp(key, 'g'), value);
  }
  return result;
}

# Parsing
/exe @parse(@input, @pattern) = js {
  const date = new Date(input);
  if (!isNaN(date.getTime())) {
    return date.toISOString();
  } else {
    return 'Invalid Date';
  }
}

# Date arithmetic
/exe @add(@date, @duration) = node {
  const d = new Date(date);
  if (duration.years) d.setFullYear(d.getFullYear() + duration.years);
  if (duration.months) d.setMonth(d.getMonth() + duration.months);
  if (duration.weeks) d.setDate(d.getDate() + duration.weeks * 7);
  if (duration.days) d.setDate(d.getDate() + duration.days);
  if (duration.hours) d.setHours(d.getHours() + duration.hours);
  if (duration.minutes) d.setMinutes(d.getMinutes() + duration.minutes);
  if (duration.seconds) d.setSeconds(d.getSeconds() + duration.seconds);
  return d.toISOString();
}

/exe @subtract(@date, @duration) = node {
  const d = new Date(date);
  if (duration.years) d.setFullYear(d.getFullYear() - duration.years);
  if (duration.months) d.setMonth(d.getMonth() - duration.months);
  if (duration.weeks) d.setDate(d.getDate() - duration.weeks * 7);
  if (duration.days) d.setDate(d.getDate() - duration.days);
  if (duration.hours) d.setHours(d.getHours() - duration.hours);
  if (duration.minutes) d.setMinutes(d.getMinutes() - duration.minutes);
  if (duration.seconds) d.setSeconds(d.getSeconds() - duration.seconds);
  return d.toISOString();
}

# Comparisons
/exe @before(@dateA, @dateB) = js {
  new Date(dateA) < new Date(dateB);
}

/exe @after(@dateA, @dateB) = js {
  new Date(dateA) > new Date(dateB);
}

/exe @equal(@dateA, @dateB) = js {
  new Date(dateA).getTime() === new Date(dateB).getTime();
}

/exe @between(@date, @start, @end) = js {
  const d = new Date(date);
  d >= new Date(start) && d <= new Date(end);
}

# Difference calculations
/exe @diff(@dateFrom, @dateTo, @unit) = node {
  const d1 = new Date(dateFrom);
  const d2 = new Date(dateTo);
  const diffMs = d2 - d1;
  
  switch(unit) {
    case 'years': return diffMs / (365.25 * 24 * 60 * 60 * 1000);
    case 'months': return diffMs / (30.44 * 24 * 60 * 60 * 1000);
    case 'weeks': return diffMs / (7 * 24 * 60 * 60 * 1000);
    case 'days': return diffMs / (24 * 60 * 60 * 1000);
    case 'hours': return diffMs / (60 * 60 * 1000);
    case 'minutes': return diffMs / (60 * 1000);
    case 'seconds': return diffMs / 1000;
    default: return diffMs;
  }
}

# Common shortcuts
/exe @iso(@date) = js {
  new Date(date).toISOString();
}

/exe @unix(@date) = js {
  Math.floor(new Date(date).getTime() / 1000);
}

/exe @dateOnly(@date) = js {
  const d = new Date(date);
  const pad = n => String(n).padStart(2, '0');
  const year = d.getFullYear();
  const month = pad(d.getMonth() + 1);
  const day = pad(d.getDate());
  return year + '-' + month + '-' + day;
}

/exe @timeOnly(@date) = js {
  const d = new Date(date);
  const pad = n => String(n).padStart(2, '0');
  const hours = pad(d.getHours());
  const minutes = pad(d.getMinutes());
  const seconds = pad(d.getSeconds());
  return hours + ':' + minutes + ':' + seconds;
}

# Start/End of period
/exe @startOf(@date, @unit) = node {
  const d = new Date(date);
  switch(unit) {
    case 'day':
      d.setHours(0, 0, 0, 0);
      break;
    case 'month':
      d.setDate(1);
      d.setHours(0, 0, 0, 0);
      break;
    case 'year':
      d.setMonth(0, 1);
      d.setHours(0, 0, 0, 0);
      break;
  }
  return d.toISOString();
}

/exe @endOf(@date, @unit) = node {
  const d = new Date(date);
  switch(unit) {
    case 'day':
      d.setHours(23, 59, 59, 999);
      break;
    case 'month':
      d.setMonth(d.getMonth() + 1, 0);
      d.setHours(23, 59, 59, 999);
      break;
    case 'year':
      d.setMonth(11, 31);
      d.setHours(23, 59, 59, 999);
      break;
  }
  return d.toISOString();
}

# Business days
/exe @isBizDay(@date) = js {
  const day = new Date(date).getDay();
  day !== 0 && day !== 6;
}

/exe @addBizDays(@date, @days) = node {
  const d = new Date(date);
  let remaining = Math.abs(days);
  const direction = days > 0 ? 1 : -1;
  
  while (remaining > 0) {
    d.setDate(d.getDate() + direction);
    if (d.getDay() !== 0 && d.getDay() !== 6) {
      remaining--;
    }
  }
  
  return d.toISOString();
}

# Relative time
/exe @relative(@date, @options) = node {
  const target = new Date(date);
  const now = new Date();
  const diffMs = target - now;
  const absDiffMs = Math.abs(diffMs);
  
  const seconds = Math.floor(absDiffMs / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);
  const weeks = Math.floor(days / 7);
  const months = Math.floor(days / 30.44);
  const years = Math.floor(days / 365.25);
  
  const isPast = diffMs < 0;
  const precise = options && options.precise;
  
  let result;
  
  if (years > 0) {
    result = years === 1 ? '1 year' : `${years} years`;
    if (precise && months % 12 > 0) {
      const remainingMonths = months % 12;
      result += remainingMonths === 1 ? ' 1 month' : ` ${remainingMonths} months`;
    }
  } else if (months > 0) {
    result = months === 1 ? '1 month' : `${months} months`;
    if (precise && days % 30 > 0) {
      const remainingDays = days % 30;
      result += remainingDays === 1 ? ' 1 day' : ` ${remainingDays} days`;
    }
  } else if (weeks > 0) {
    result = weeks === 1 ? '1 week' : `${weeks} weeks`;
    if (precise && days % 7 > 0) {
      const remainingDays = days % 7;
      result += remainingDays === 1 ? ' 1 day' : ` ${remainingDays} days`;
    }
  } else if (days > 0) {
    result = days === 1 ? '1 day' : `${days} days`;
    if (precise && hours % 24 > 0) {
      const remainingHours = hours % 24;
      result += remainingHours === 1 ? ' 1 hour' : ` ${remainingHours} hours`;
    }
  } else if (hours > 0) {
    result = hours === 1 ? '1 hour' : `${hours} hours`;
    if (precise && minutes % 60 > 0) {
      const remainingMinutes = minutes % 60;
      result += remainingMinutes === 1 ? ' 1 minute' : ` ${remainingMinutes} minutes`;
    }
  } else if (minutes > 0) {
    result = minutes === 1 ? '1 minute' : `${minutes} minutes`;
    if (precise && seconds % 60 > 0) {
      const remainingSeconds = seconds % 60;
      result += remainingSeconds === 1 ? ' 1 second' : ` ${remainingSeconds} seconds`;
    }
  } else if (seconds > 0) {
    result = seconds === 1 ? '1 second' : `${seconds} seconds`;
  } else {
    result = 'just now';
  }
  
  if (result === 'just now') {
    return result;
  }
  
  return isPast ? `${result} ago` : `in ${result}`;
}

# Timezone stubs (would need moment-timezone for full support)
/exe @getCurrentTimezone() = js {
  Intl.DateTimeFormat().resolvedOptions().timeZone;
}

/exe @getOffset() = node {
  const date = new Date();
  const offset = -date.getTimezoneOffset();
  const hours = Math.floor(Math.abs(offset) / 60);
  const minutes = Math.abs(offset) % 60;
  const sign = offset >= 0 ? '+' : '-';
  return `${sign}${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
}

# Duration helpers
/exe @durationWeeks(@count) = js {
  return { weeks: count };
}

/exe @durationDays(@count) = js {
  return { days: count };
}

/exe @durationHours(@count) = js {
  return { hours: count };
}

/exe @durationMinutes(@count) = js {
  return { minutes: count };
}

/exe @durationSeconds(@count) = js {
  return { seconds: count };
}

/exe @durationCompose(@parts) = js {
  return parts;
}

/exe @durationMultiply(@duration, @factor) = js {
  const result = {};
  for (const [unit, value] of Object.entries(duration)) {
    result[unit] = value * factor;
  }
  return result;
}

/exe @durationDivide(@duration, @divisor) = js {
  const result = {};
  for (const [unit, value] of Object.entries(duration)) {
    result[unit] = value / divisor;
  }
  return result;
}

>> Create structured export with organized namespaces
/var @time = {
  "format": @format,
  "parse": @parse,
  "add": @add,
  "subtract": @subtract,
  "diff": @diff,
  "iso": @iso,
  "unix": @unix,
  "date": @dateOnly,
  "time": @timeOnly,
  "startOf": @startOf,
  "endOf": @endOf,
  "relative": @relative,
  "compare": {
    "before": @before,
    "after": @after,
    "equal": @equal,
    "between": @between
  },
  "biz": {
    "isBizDay": @isBizDay,
    "addDays": @addBizDays
  },
  "tz": {
    "current": @getCurrentTimezone,
    "offset": @getOffset
  },
  "duration": {
    "weeks": @durationWeeks,
    "days": @durationDays,
    "hours": @durationHours,
    "minutes": @durationMinutes,
    "seconds": @durationSeconds,
    "compose": @durationCompose,
    "multiply": @durationMultiply,
    "divide": @durationDivide
  }
}

>> Shadow environment
/exe js = { format, parse, add, subtract, diff, before, after, equal, between, iso, unix, dateOnly, timeOnly, isBizDay, addBizDays, getCurrentTimezone, getOffset, startOf, endOf, relative, durationWeeks, durationDays, durationHours, durationMinutes, durationSeconds, durationCompose, durationMultiply, durationDivide }
/exe node = { format, add, subtract, diff, addBizDays, getOffset, startOf, endOf, relative }
```