# Writing Bash Scripts: Full Reference

## Contents

- [Script Structure](#script-structure)
- [Strict Mode](#strict-mode)
- [Variables and Quoting](#variables-and-quoting)
- [Conditionals](#conditionals)
- [Loops](#loops)
- [Functions](#functions)
- [Argument Parsing](#argument-parsing)
- [Input and Output](#input-and-output)
- [Arrays](#arrays)
- [String Manipulation](#string-manipulation)
- [Traps and Signals](#traps-and-signals)
- [Temporary Files](#temporary-files)
- [Error Handling and Exit Codes](#error-handling-and-exit-codes)
- [Security](#security)
- [Debugging](#debugging)
- [Portability](#portability)
- [Style and Formatting](#style-and-formatting)

---

## Script Structure

Canonical script template:

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <arg>

Options:
  -h, --help    Show this help
EOF
}

main() {
  # parse args, then logic
}

main "$@"
```

Define `main` and all functions before calling them. Always invoke with
`main "$@"` at the bottom so `"$@"` is the original argument list.

---

## Strict Mode

Enable immediately after the shebang:

```bash
set -euo pipefail
```

| Option         | Meaning                                    |
| -------------- | ------------------------------------------ |
| `-e`           | Exit immediately on any command failure    |
| `-u`           | Treat unset variables as errors            |
| `-o pipefail`  | Pipeline fails if any stage fails          |

To intentionally ignore a failure: `command || true`.

---

## Variables and Quoting

Always quote variable expansions:

```bash
# Good
echo "${name}"
cp "${src}" "${dest}"

# Bad
echo $name
cp $src $dest
```

Declare constants with `readonly`:

```bash
readonly MAX_RETRIES=3
readonly BASE_DIR="/opt/app"
```

Default and required values via parameter expansion:

```bash
name="${NAME:-default}"               # use default if unset or empty
name="${NAME:?'NAME is required'}"    # exit with error message if unset
first="${str:0:5}"                    # substring: first 5 chars
```

Prefer `${var}` over `$var` for clarity and safe adjacency.

---

## Conditionals

Use `[[ ]]` exclusively in bash scripts:

```bash
# String equality
if [[ "${var}" == "value" ]]; then ...

# Numeric comparison
if (( count > 5 )); then ...

# File tests
if [[ -f "${file}" ]]; then ...     # is regular file
if [[ -d "${dir}"  ]]; then ...     # is directory
if [[ -x "${bin}"  ]]; then ...     # is executable
if [[ -z "${str}"  ]]; then ...     # is empty string
if [[ -n "${str}"  ]]; then ...     # is non-empty string

# Regex match
if [[ "${str}" =~ ^[0-9]+$ ]]; then ...
```

Avoid `[ ]` and `test` — they have quoting pitfalls and lack `&&`/`||`/`=~`.

---

## Loops

Iterate over an array:

```bash
for item in "${items[@]}"; do
  echo "${item}"
done
```

Iterate over files safely (glob-safe, handles spaces):

```bash
for file in /path/*.txt; do
  [[ -f "${file}" ]] || continue
  process "${file}"
done
```

While loop reading a file line by line:

```bash
while IFS= read -r line; do
  echo "${line}"
done < "${input_file}"
```

C-style numeric loop:

```bash
for (( i = 0; i < 10; i++ )); do
  echo "${i}"
done
```

Never use `for file in $(ls ...)` — breaks on spaces and special characters.

---

## Functions

```bash
# Process a single record and print the result.
process_record() {
  local record="${1:?'record argument required'}"
  local mode="${2:-default}"
  local output

  output=$(transform "${record}" "${mode}")
  echo "${output}"
}
```

Rules:

- Every variable inside a function must be declared `local`.
- Return values via `echo`/`printf` (captured with `$()`), a nameref
  (`local -n`), or a global result variable.
- Use `return N` for exit codes (0 = success, non-zero = failure).
- Functions should do one thing; compose them with pipes or sequencing.

---

## Argument Parsing

### getopts (short flags, POSIX-compatible)

```bash
usage() { echo "Usage: $0 [-v] [-o output] <file>" >&2; }

verbose=false
output=""

while getopts ":vo:" opt; do
  case "${opt}" in
    v) verbose=true ;;
    o) output="${OPTARG}" ;;
    :) echo "Option -${OPTARG} requires an argument" >&2; exit 1 ;;
    ?) echo "Unknown option: -${OPTARG}" >&2; usage; exit 1 ;;
  esac
done
shift $(( OPTIND - 1 ))
# Positional args now in "$@"
```

### Manual long-option parsing

```bash
while [[ $# -gt 0 ]]; do
  case "${1}" in
    --verbose|-v) verbose=true; shift ;;
    --output|-o)  output="${2}"; shift 2 ;;
    --)           shift; break ;;
    -*)           echo "Unknown flag: ${1}" >&2; exit 1 ;;
    *)            break ;;
  esac
done
```

---

## Input and Output

Stderr for errors and diagnostics; stdout for data:

```bash
log_info()  { echo "[INFO]  $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }
```

Heredoc for multiline output (with variable expansion):

```bash
cat <<EOF
Host:    ${host}
Port:    ${port}
EOF
```

Heredoc without expansion (quoted delimiter):

```bash
cat <<'EOF'
No ${expansion} happens here.
EOF
```

Read from stdin:

```bash
while IFS= read -r line; do
  process "${line}"
done
```

Use `printf` over `echo` for arbitrary data — `echo` interprets `-n`, `-e`:

```bash
printf '%s\n' "${value}"
```

---

## Arrays

Indexed arrays:

```bash
items=("alpha" "beta" "gamma")
items+=("delta")

echo "${items[0]}"        # first element
echo "${items[@]}"        # all elements (each as separate word)
echo "${#items[@]}"       # length
echo "${items[@]:1:2}"    # slice: elements 1 and 2
```

Read file lines into an array (bash 4.0+):

```bash
mapfile -t lines < "${file}"
```

Associative arrays (bash 4.0+):

```bash
declare -A config
config[host]="localhost"
config[port]="5432"

for key in "${!config[@]}"; do
  echo "${key}=${config[${key}]}"
done
```

Always use `"${array[@]}"` — never `"${array[*]}"` — to preserve word boundaries.

---

## String Manipulation

Parameter expansion avoids subshells:

```bash
str="hello world"

${str^^}           # UPPERCASE: HELLO WORLD
${str,,}           # lowercase: hello world
${str:0:5}         # substring: hello
${str#hello }      # strip shortest prefix match: world
${str##*/}         # strip longest prefix: basename equivalent
${str%/world}      # strip shortest suffix match
${str%%.*}         # strip longest suffix: extension strip
${str/world/bash}  # replace first occurrence: hello bash
${str//l/L}        # replace all: heLLo worLd
${#str}            # length: 11
```

Trim leading and trailing whitespace (no subshell):

```bash
trimmed="${str#"${str%%[![:space:]]*}"}"
trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
```

---

## Traps and Signals

Cleanup on exit (fires on normal exit, errors, and signals):

```bash
cleanup() {
  rm -f "${tmpfile:-}"
  rm -rf "${tmpdir:-}"
}
trap cleanup EXIT
```

Also trap interrupts explicitly if the cleanup needs different behavior:

```bash
trap 'cleanup; exit 130' INT TERM
```

Trap on error for debugging:

```bash
trap 'echo "Error at line ${LINENO}" >&2' ERR
```

`trap ... EXIT` is preferred over `trap ... INT TERM` alone — EXIT fires
in all termination paths including normal exit and `set -e` failures.

---

## Temporary Files

```bash
tmpfile="$(mktemp)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpfile}" "${tmpdir}"' EXIT
```

Never hardcode `/tmp/myapp.tmp` — race condition and collision risk.
Set `umask 077` before `mktemp` to prevent world-readable temp files.

---

## Error Handling and Exit Codes

Conventional exit codes:

| Code  | Meaning                          |
| ----- | -------------------------------- |
| 0     | Success                          |
| 1     | General error                    |
| 2     | Misuse of shell built-in         |
| 126   | Command found but not executable |
| 127   | Command not found                |
| 128+N | Fatal signal N                   |
| 130   | SIGINT (Ctrl-C)                  |

Check command existence before use:

```bash
require_cmd() {
  command -v "${1}" &>/dev/null || {
    echo "Required command not found: ${1}" >&2
    exit 1
  }
}
require_cmd jq
require_cmd curl
```

Propagate meaningful exit codes:

```bash
result=$(some_command) || {
  echo "some_command failed" >&2
  exit 1
}
```

Capture exit code explicitly when needed under `set -e`:

```bash
set +e
some_command
exit_code=$?
set -e
if (( exit_code != 0 )); then ...
```

---

## Security

- Never use `eval` with untrusted or user-supplied data.
- Validate and sanitize all external input before use in paths or commands.
- Use `"${array[@]}"` not `"${array[*]}"` to prevent word-splitting.
- Use `printf '%s'` over `echo` for arbitrary data.
- Pass `--` before variables used as command arguments: `rm -- "${file}"`.
- Set `IFS` explicitly when splitting: `IFS=',' read -ra parts <<< "${csv}"`.
- Set `umask 077` before creating temp files with sensitive content.
- Avoid world-readable or world-writable intermediate files.
- Prefer absolute paths for critical commands in sensitive scripts.

---

## Debugging

```bash
set -x        # print every command before executing
PS4='+(${BASH_SOURCE}:${LINENO}): '  # richer trace prefix
set +x        # disable tracing
```

Dry-run pattern:

```bash
DRY_RUN="${DRY_RUN:-false}"

run() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "[DRY RUN] $*"
  else
    "$@"
  fi
}

run rm -rf "${target_dir}"
```

Run shellcheck:

```bash
shellcheck -x -S warning script.sh
```

The `-x` flag follows sourced files; `-S warning` includes all warnings.

---

## Portability

| Feature                    | Bash 3 | Bash 4+ | Notes                          |
| -------------------------- | ------ | ------- | ------------------------------ |
| `declare -A` (associative) | No     | Yes     | Use parallel arrays for bash 3 |
| `mapfile` / `readarray`    | No     | Yes     | Use `while read` loop instead  |
| `{a..z}` brace expansion   | Yes    | Yes     | Not POSIX sh                   |
| `[[ ]]`                    | Yes    | Yes     | Not POSIX sh                   |
| `(( ))`                    | Yes    | Yes     | Not POSIX sh                   |
| `${var^^}` / `${var,,}`    | No     | Yes     | Use `tr` for bash 3            |
| `local -n` (nameref)       | No     | Yes     | Bash 4.3+                      |

macOS ships bash 3.2 by default. If targeting macOS without Homebrew bash,
avoid bash 4+ features or add a version guard:

```bash
if (( BASH_VERSINFO[0] < 4 )); then
  echo "Requires bash 4.0 or later" >&2
  exit 1
fi
```

---

## Style and Formatting

- Indent with 2 spaces.
- Max line length: 80 characters; break long commands with `\`.
- Name functions and variables with `snake_case`.
- Name constants with `UPPER_SNAKE_CASE` and declare `readonly`.
- Add a one-line comment before each function describing its purpose.
- Group related functions; separate logical groups with a blank line.
- One logical operation per line; avoid semicolons to chain commands inline.
- Place `main "$@"` as the last line of the script.
