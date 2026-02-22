# Writing Nushell Scripts: Full Reference

## Contents

- [Script Structure](#script-structure)
- [Shebang and Execution](#shebang-and-execution)
- [Variables and Mutability](#variables-and-mutability)
- [Types and Annotations](#types-and-annotations)
- [Custom Commands](#custom-commands)
- [Parameters and Flags](#parameters-and-flags)
- [Input and Output Types](#input-and-output-types)
- [Subcommands](#subcommands)
- [String Interpolation and String Types](#string-interpolation-and-string-types)
- [Pipelines and Structured Data](#pipelines-and-structured-data)
- [Control Flow](#control-flow)
- [Error Handling](#error-handling)
- [External Commands](#external-commands)
- [Environment Variables](#environment-variables)
- [Modules](#modules)
- [Attributes and Documentation](#attributes-and-documentation)
- [Style and Naming](#style-and-naming)

---

## Script Structure

Canonical script template:

```nushell
#!/usr/bin/env nu

# Brief one-line description of the script.
#
# Longer explanation if needed.
def main [
  input: string,           # The input value to process
  --verbose (-v),          # Enable verbose output
  --output (-o): string,   # Output file path
] {
  if $verbose {
    print --stderr $"Processing: ($input)"
  }

  # last expression is the implicit return value
  process $input $output
}

# Internal helper — not exported, not callable from CLI.
def process [input: string, output: string] {
  # ...
}
```

Layout order:

1. Shebang
2. Top-level `use` / `source` imports (if any)
3. Internal helper `def` commands (private)
4. `def main` (always last definition)

---

## Shebang and Execution

Make a script directly executable:

```nushell
#!/usr/bin/env nu
```

For scripts that need to read from stdin:

```nushell
#!/usr/bin/env -S nu --stdin
```

Run a script explicitly:

```sh
nu myscript.nu arg1 arg2
```

Source into the current shell session (shares environment):

```nushell
source myscript.nu
```

---

## Variables and Mutability

Prefer `let` (immutable) for all bindings:

```nushell
let name = "world"
let count = 42
let items = [1, 2, 3]
```

Use `mut` only when a value must change in place:

```nushell
mut total = 0
for item in $items {
  $total += $item
}
```

`mut` variables cannot be captured in closures. If a closure needs a value,
bind it with `let` first:

```nushell
let snapshot = $total
let doubled = $items | each { |x| $x + $snapshot }
```

---

## Types and Annotations

Annotate variable declarations for clarity:

```nushell
let count: int = 0
let label: string = "ready"
```

Built-in scalar types:

| Type         | Example literal             |
| ------------ | --------------------------- |
| `int`        | `42`                        |
| `float`      | `3.14`                      |
| `bool`       | `true`, `false`             |
| `string`     | `"hello"`, `'hello'`        |
| `duration`   | `2min`, `500ms`             |
| `filesize`   | `1mb`, `512kb`              |
| `datetime`   | `2024-01-01`                |
| `range`      | `1..10`, `1..<10`           |
| `binary`     | `0x[FF 00]`                 |
| `nothing`    | `null`                      |

Compound types:

```nushell
list<string>
record<name: string, age: int>
table<name: string, score: float>
closure
```

Use `any` only when the type is genuinely dynamic and cannot be narrowed.

---

## Custom Commands

Basic syntax:

```nushell
# One-line description shown in `help`.
def command-name [parameters] {
  # body
  # last expression is the implicit return value
}
```

The value of the last expression is the return value. Use `return` only for
early exits; it is not needed at the end of a function body.

Commands are parsed before execution, so a command defined anywhere in the
file is callable from any other definition in the same file.

---

## Parameters and Flags

### Positional parameters

```nushell
def greet [name: string] {
  $"Hello, ($name)!"
}
```

### Optional parameters

```nushell
def greet [name?: string] {
  $"Hello, ($name | default 'world')!"
}
```

### Parameters with defaults

```nushell
def greet [name: string = "Nushell"] {
  $"Hello, ($name)!"
}
```

### Rest parameters

```nushell
def sum [...numbers: int] {
  $numbers | math sum
}
```

Pass a list to a rest parameter with the spread operator:

```nushell
sum ...$my_list
```

### Boolean flags (switches)

Present → `true`; absent → `false`. Do not annotate with `: bool`.

```nushell
def build [--release] {
  if $release { "optimized" } else { "debug" }
}
```

### Flags with values

```nushell
def connect [--host (-h): string, --port (-p): int = 5432] {
  $"($host):($port)"
}
```

Flags with dashes map to underscore variables:
`--all-caps` → `$all_caps`

### Documentation comments

```nushell
def deploy [
  env: string,           # Target environment (staging, prod)
  --dry-run (-n),        # Print actions without executing
  --timeout (-t): int,   # Timeout in seconds
] {
  # ...
}
```

Comments immediately after each parameter appear in `help deploy`.

---

## Input and Output Types

Declare pipeline input and output types for type-safe pipelines:

```nushell
# Accepts a string from the pipeline; returns a record.
def parse-entry []: string -> record {
  # $in holds the pipeline input
  $in | parse "{key}={value}" | first
}
```

Multiple accepted input types:

```nushell
def word-count []: [string -> int, list<string> -> int] {
  # ...
}
```

No pipeline input or output:

```nushell
def init-db []: nothing -> nothing {
  # ...
}
```

Access pipeline input inside the body:

```nushell
$in
```

---

## Subcommands

Use space-separated names. A base `main` must exist for the CLI to expose
subcommands:

```nushell
def main [] {}

def "main build" [target: string] {
  print $"Building ($target)"
}

def "main test" [--watch] {
  print "Testing..."
}
```

Called as: `nu myscript.nu build myapp`

Non-main subcommands follow the same pattern using a namespace prefix:

```nushell
def "db migrate" [] { ... }
def "db rollback" [] { ... }
```

---

## String Interpolation and String Types

| Syntax         | Escapes | Use case                          |
| -------------- | ------- | --------------------------------- |
| `"hello"`      | Yes     | Standard double-quoted string     |
| `'hello'`      | No      | Literal single-quoted string      |
| `r#'...'#`     | No      | Raw string (allows inner `'`)     |
| `` `path` ``   | No      | Backtick string (paths with spaces)|
| `$"...(expr)"` | Yes     | Interpolation with escapes        |
| `$'...(expr)'` | No      | Interpolation without escapes     |

String interpolation wraps expressions in `()`:

```nushell
let user = "alice"
let msg = $"Hello, ($user)! Today is (date now | format date '%Y-%m-%d')."
```

Escape literal parentheses with `\`:

```nushell
$"Value: \(not interpolated\)"
```

Key string commands:

```nushell
"hello world" | str upcase          # HELLO WORLD
"hello world" | str downcase        # hello world
"  trim me  " | str trim            # trim me
"a,b,c" | split row ","             # [a, b, c]
"hello" | str contains "ell"        # true
"hello" | str replace "ell" "ELL"   # hELLo
"hello world" | str substring 6..   # world
```

---

## Pipelines and Structured Data

Nushell pipelines carry structured values (tables, records, lists), not raw
text. Prefer native Nushell commands over parsing text with `grep`/`awk`.

Iterate and transform:

```nushell
ls | where size > 1mb | sort-by modified | select name size modified
```

Apply a closure to each row:

```nushell
$items | each { |item| $item.name | str upcase }
```

Filter rows:

```nushell
$items | where { |row| $row.score > 90 }
# or with field shorthand:
$items | where score > 90
```

Reduce to a single value:

```nushell
$numbers | reduce { |acc, x| $acc + $x }
```

Build a record:

```nushell
{name: "alice", score: 42}
```

Build a table (list of records):

```nushell
[
  {name: "alice", score: 42},
  {name: "bob",   score: 38},
]
```

Access fields with dot notation or cell paths:

```nushell
$record.name
$table.0.score
$table | get score
```

---

## Control Flow

Conditional:

```nushell
if $flag {
  "yes"
} else if $count > 0 {
  "some"
} else {
  "no"
}
```

Match (structural pattern matching):

```nushell
match $status {
  "ok"    => { print "success" }
  "error" => { print "failed" }
  _       => { print "unknown" }
}
```

For loop (blocks, not closures — cannot capture `mut`):

```nushell
for item in $list {
  print $item
}
```

While loop:

```nushell
mut i = 0
while $i < 10 {
  print $i
  $i += 1
}
```

---

## Error Handling

### Built-in commands — try/catch

```nushell
try {
  open missing-file.txt
} catch { |e|
  print --stderr $"Error: ($e.msg)"
}
```

Access error fields: `$e.msg`, `$e.debug`, `$e.raw`.

### Raise an error explicitly

```nushell
error make {
  msg: "Something went wrong",
  label: { text: "here", span: (metadata $value).span },
}
```

### External commands — complete

Wrap external commands with `complete` to capture stdout, stderr, and exit
code as a record:

```nushell
let result = do { ^git status } | complete
if $result.exit_code != 0 {
  print --stderr $"git failed: ($result.stderr)"
  exit 1
}
$result.stdout
```

The `complete` record fields: `stdout`, `stderr`, `exit_code`.

### Strict external pipelines — do -c

`do -c` cancels the entire pipeline if any external command fails. Use
sparingly — it cannot be caught with `try/catch`:

```nushell
do -c { ^curl -sSf https://example.com | ^jq '.name' }
```

### Checking exit codes after the fact

```nushell
^some-command
let code = $env.LAST_EXIT_CODE
if $code != 0 { exit $code }
```

---

## External Commands

Prefix external commands with `^` to disambiguity from Nushell builtins:

```nushell
^git status
^docker ps
^curl -sSf $url
```

Pass a list as arguments with the spread operator:

```nushell
let args = ["--all", "--format=json"]
^git log ...$args
```

Capture output:

```nushell
let out = ^git rev-parse HEAD | str trim
```

Always use `complete` when the exit code matters:

```nushell
let res = do { ^npm install } | complete
if $res.exit_code != 0 { exit 1 }
```

---

## Environment Variables

Read an environment variable:

```nushell
$env.HOME
$env.PATH
```

Set environment variables (scoped to the current command's block):

```nushell
with-env {MY_VAR: "value"} { ^some-command }
```

Persist environment changes beyond a command's scope with `def --env`:

```nushell
def --env activate [] {
  $env.VENV_ACTIVE = true
  $env.PATH = ($env.PATH | prepend "/path/to/bin")
}
```

---

## Modules

Create a module file (`mylib.nu`):

```nushell
# Public command — importable.
export def greet [name: string] {
  $"Hello, ($name)!"
}

# Private — only visible inside this module.
def helper [] { ... }

# Export environment setup.
export-env {
  $env.MY_LIB_VERSION = "1.0.0"
}
```

Import in a script or config:

```nushell
use mylib.nu                   # imports all exports as "mylib greet"
use mylib.nu greet             # imports only greet, callable as "greet"
use mylib.nu [greet, other]    # selective import
```

---

## Attributes and Documentation

Nushell 0.103+ supports `@` attributes before `def`:

```nushell
@example "Greet a user" { greet "alice" } --result "Hello, alice!"
@category "utilities"
@deprecated "Use new-greet instead"
def greet [name: string] { $"Hello, ($name)!" }
```

Documentation conventions:

- One-line summary as the first comment line before `def`.
- Blank comment line, then extended description if needed.
- Inline `# comment` after each parameter for per-parameter help.
- Use `# =>` to show expected output in examples within comments.

```nushell
# Convert a list of numbers to their squares.
#
# Returns a list<int> of the same length.
# => [1, 4, 9, 16]
def squares [...nums: int] {
  $nums | each { |n| $n * $n }
}
```

---

## Style and Naming

- Command names: `kebab-case` (`parse-entry`, `build-image`)
- Variable names: `kebab-case` (`$file-path`, `$item-count`)
- Constants: `kebab-case` (Nushell has no `readonly`; use `let` at module
  level)
- Indent with 2 spaces
- Max line length: 80 characters; break long pipelines across lines
- One pipeline stage per line for multi-stage pipelines:

```nushell
ls
| where size > 1mb
| sort-by modified --reverse
| select name size
| first 10
```

- Prefer native Nushell commands over shelling out for text processing
- Add a blank line between `def` blocks
- Group related commands; put `def main` last
