---
name: pipelog
author: mlld
version: 1.0.0
about: Pass-through pipeline debugging for mlld
needs: ["js"]
bugs: https://github.com/mlld-lang/modules/issues
repo: https://github.com/mlld-lang/modules
keywords: ["logging", "debug", "pipeline", "stderr", "pass-through", "development", "testing", "verbose", "json"]
license: CC0
mlldVersion: "*"
---

# @mlld/pipelog

Pass-through debugging functions for mlld pipelines that log to stderr without affecting data flow. Insert between pipeline steps to see what data is passing through.

## tldr

Debug your pipelines by inserting logging between transformations:

```mlld
/import { log, logVerbose, logJson } from @mlld/pipelog

>> Simple pipeline debugging
/var @result = @data | @json | @log | @uppercase | @log

>> Verbose logging with full context
/var @processed = @fetchData() | @logVerbose | @transform

>> Structured JSON logging for parsing
/var @output = @input | @logJson | @process
```

All loggers output to stderr, ensuring your pipeline data flows unchanged to stdout.

## docs

### Core Concepts

The @mlld/pipelog module provides **pass-through functions** that log to stderr while returning input unchanged. This design enables:

- Zero side effects on pipeline data
- Clean separation of debug output from pipeline output
- Simple debugging of mlld pipeline transformations

### Basic Logger

#### `log(input)`

Concise logging with essential information about the data passing through.

```mlld
/import { log } from @mlld/pipelog

/var @data = run {curl -s https://api.example.com/data}
/var @result = @data | @json | @log | @uppercase

>> Stderr output:
>> ================================================================================
>> [2024-01-20T10:30:45.123Z] PIPELINE LOG
>> ================================================================================
>> Type: string | Length: 245 chars
>> Preview: "{"users": [{"id": 1, "name": "Alice"}, {"id": 2, "nam..."
>> ================================================================================
```

### Verbose Logger

#### `logVerbose(input)`

Detailed analysis with data type detection and content preview.

```mlld
/import { logVerbose } from @mlld/pipelog

/var @complexData = { users: @users, config: @config }
/var @processed = @complexData | @json | @logVerbose | @transform

>> Stderr output includes:
>> - Detailed type information
>> - Content format detection (JSON, XML, CSV)
>> - Line counts and structure analysis
>> - First 5 lines of content preview
>> - Helpful debugging tips
```

### JSON Logger

#### `logJson(input)`

Structured logging output for parsing by log aggregation systems.

```mlld
/import { logJson } from @mlld/pipelog

>> Produces JSON log entries on stderr
/var @result = @data | @logJson | @process

>> Stderr output:
>> {"timestamp":"2024-01-20T10:30:45.123Z","type":"pipeline_log","input":{...}}
```

### Usage Examples

#### Debugging Pipeline Transformations

```mlld
/import { log, logVerbose } from @mlld/pipelog

>> Debug each transformation stage
/exe @processUsers(data) = js {
  JSON.parse(data).users.map(u => ({
    ...u,
    processed: true
  }))
)}

/var @result = run {cat users.json} 
  | @log           >> Log raw input
  | @json          >> Parse JSON
  | @log           >> Log parsed data
  | @processUsers  >> Transform
  | @logVerbose    >> Detailed view of result
```

#### Comparing with mlld's @DEBUG

The loggers complement mlld's built-in @DEBUG variable:

```mlld
/import { log } from @mlld/pipelog

>> The logger shows immediate pipeline state
/var @result = @data | @log | @transform

>> While @DEBUG shows complete execution context
/show @DEBUG  >> Shows all variables, pipeline context, etc.
```

## module

```mlld-run
>> Basic logger - concise output
/exe @log(input) = js {
  const timestamp = new Date().toISOString();
  const separator = '='.repeat(80);
  
  console.error(`\n${separator}`);
  console.error(`[${timestamp}] PIPELINE LOG`);
  console.error(`${separator}`);
  console.error(`Type: ${typeof input} | Length: ${
    typeof input === 'string' ? input.length + ' chars' : 
    Array.isArray(input) ? input.length + ' items' : 'N/A'
  }`);
  
  // Smart preview based on data type
  if (input === null || input === undefined) {
    console.error(`Value: ${input}`);
  } else if (typeof input === 'string') {
    if (input.length <= 100) {
      console.error(`Value: "${input}"`);
    } else {
      console.error(`Preview: "${input.substring(0, 50)}..."`);
      console.error(`(${input.length - 50} more characters)`);
    }
  } else {
    try {
      const preview = JSON.stringify(input, null, 2);
      if (preview.length <= 200) {
        console.error(`Value:\n${preview}`);
      } else {
        console.error(`Preview:\n${preview.substring(0, 200)}...\n(truncated)`);
      }
    } catch (e) {
      console.error(`Value: [${typeof input}] - Unable to stringify`);
    }
  }
  
  console.error(`${separator}\n`);
  return input;
}

>> Verbose logger - detailed analysis
/exe @logVerbose(input) = js {
  const timestamp = new Date().toISOString();
  const separator = '='.repeat(80);
  
  console.error(`\n${separator}`);
  console.error(`[${timestamp}] VERBOSE PIPELINE LOG`);
  console.error(`${separator}\n`);
  
  // Detailed input analysis
  console.error(`INPUT ANALYSIS:`);
  console.error(`  Type: ${typeof input}`);
  console.error(`  Constructor: ${input?.constructor?.name || 'N/A'}`);
  
  if (typeof input === 'string') {
    console.error(`  Length: ${input.length} characters`);
    console.error(`  Lines: ${input.split('\n').length}`);
    
    // Content type detection
    const trimmed = input.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      console.error(`  Format: Likely JSON`);
      try {
        JSON.parse(input);
        console.error(`  Valid: ✓ Parseable as JSON`);
      } catch {
        console.error(`  Valid: ✗ Invalid JSON syntax`);
      }
    } else if (trimmed.includes('<') && trimmed.includes('>')) {
      console.error(`  Format: Likely XML/HTML`);
    } else if (input.includes(',') && input.split('\n')[0]?.includes(',')) {
      console.error(`  Format: Likely CSV`);
    } else {
      console.error(`  Format: Plain text or unknown`);
    }
  } else if (Array.isArray(input)) {
    console.error(`  Length: ${input.length} items`);
    if (input.length > 0) {
      console.error(`  First item type: ${typeof input[0]}`);
    }
  } else if (input && typeof input === 'object') {
    const keys = Object.keys(input);
    console.error(`  Keys: ${keys.length} properties`);
    if (keys.length > 0 && keys.length <= 10) {
      console.error(`  Properties: ${keys.join(', ')}`);
    } else if (keys.length > 10) {
      console.error(`  Properties: ${keys.slice(0, 10).join(', ')}... (${keys.length - 10} more)`);
    }
  }
  
  console.error(`\nDATA PREVIEW:`);
  if (typeof input === 'string') {
    const lines = input.split('\n');
    const preview = lines.slice(0, 5).map((line, i) => 
      `  ${(i + 1).toString().padStart(3)}: ${line}`
    ).join('\n');
    console.error(preview);
    if (lines.length > 5) {
      console.error(`  ... (${lines.length - 5} more lines)`);
    }
  } else {
    try {
      const stringified = JSON.stringify(input, null, 2);
      const lines = stringified.split('\n');
      if (lines.length <= 10) {
        console.error(stringified);
      } else {
        console.error(lines.slice(0, 10).join('\n'));
        console.error(`... (${lines.length - 10} more lines)`);
      }
    } catch {
      console.error(`  [Complex object - unable to stringify]`);
    }
  }
  
  console.error(`\nDEBUG TIPS:`);
  console.error(`  • Use /show @DEBUG to see full pipeline context`);
  console.error(`  • Pipe to @json for pretty-printing`);
  console.error(`  • Check mlld's built-in @DEBUG variable for environment info`);
  console.error(`${separator}\n`);
  
  return input;
}

>> JSON logger - structured output
/exe @logJson(input) = js {
  const logEntry = {
    timestamp: new Date().toISOString(),
    type: 'pipeline_log',
    level: 'debug',
    input: {
      dataType: typeof input,
      constructor: input?.constructor?.name,
      length: typeof input === 'string' ? input.length : 
              Array.isArray(input) ? input.length : null,
      preview: null,
      metadata: {}
    }
  };
  
  // Add preview based on type
  if (typeof input === 'string') {
    logEntry.input.preview = input.length > 100 ? 
      input.substring(0, 100) + '...' : input;
    logEntry.input.metadata.lines = input.split('\n').length;
  } else if (input !== null && input !== undefined) {
    try {
      const stringified = JSON.stringify(input);
      logEntry.input.preview = stringified.length > 100 ?
        stringified.substring(0, 100) + '...' : stringified;
      if (Array.isArray(input)) {
        logEntry.input.metadata.firstItemType = input[0] ? typeof input[0] : null;
      } else if (typeof input === 'object') {
        logEntry.input.metadata.keys = Object.keys(input);
      }
    } catch {
      logEntry.input.preview = '[Unable to stringify]';
    }
  } else {
    logEntry.input.preview = String(input);
  }
  
  console.error(JSON.stringify(logEntry));
  return input;
}

>> Shadow environment to make functions available to each other
/exe js = { log, logVerbose, logJson }
```

## interface

### Design Philosophy

The @mlld/pipelog module follows these principles:

1. **Zero Side Effects**: All loggers are pure pass-through functions
2. **Stderr Only**: Debug output never pollutes pipeline data  
3. **Progressive Detail**: Choose verbosity level based on needs
4. **Simple and Focused**: Designed specifically for debugging mlld pipelines

### Common Usage Patterns

#### Development Debugging
```mlld
>> See what's happening at each step
/var @result = @input 
  | @validate 
  | @log 
  | @transform 
  | @log 
  | @format
```

#### Debugging Failed Transformations
```mlld
>> Use verbose logging to understand data structure
/var @result = @complexData | @logVerbose | @transform
```

### Tips for Using with Unix Tools

1. **Save debug output**: `mlld script.mld 2>debug.log`
2. **View logs and output**: `mlld script.mld 2>&1 | tee output.txt`
3. **Filter logs**: `mlld script.mld 2>&1 | grep "PIPELINE LOG"`
4. **Silent operation**: `mlld script.mld 2>/dev/null`
