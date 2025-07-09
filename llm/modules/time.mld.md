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

# Use the built-in @now
/var @today = @time.format(@now, "YYYY-MM-DD")
/var @tomorrow = @time.add(@now, { days: 1 })

# Compare dates
/when @time.compare.before(@dateA, @dateB) => /show "DateA is earlier"

# Work with timezones
/var @utc = @time.tz.convert(@now, "UTC")
/var @myTz = @time.tz.current()
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
  }
}

>> Shadow environment
/exe js = { format, parse, add, subtract, diff, before, after, equal, between, iso, unix, dateOnly, timeOnly, isBizDay, addBizDays, getCurrentTimezone, getOffset, startOf, endOf }
/exe node = { format, add, subtract, diff, addBizDays, getOffset, startOf, endOf }
```