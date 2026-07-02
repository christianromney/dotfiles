# Fish Shell Command Reference for Script Authors

A practical reference to fish's builtin commands, written for engineers who know POSIX shell (bash/zsh) well and need to map that muscle memory onto fish's different syntax and semantics. Fish has **no** `$(( ))` arithmetic, **no** `${var//search/replace}` parameter expansion, **no** `${#var}` length syntax, and **no** `getopts` — dedicated builtins (`math`, `string`, `count`, `argparse`) replace all of these. Source: [fishshell.com/docs/current](https://fishshell.com/docs/current/commands.html) (fish 4.8.0).

## Table of Contents

1. [set](#set)
2. [string](#string)
3. [test / \[](#test--)
4. [math](#math)
5. [argparse](#argparse)
6. [functions](#functions)
7. [type](#type)
8. [command](#command)
9. [status](#status)
10. [read](#read)
11. [count](#count)
12. [contains](#contains)
13. [source and eval](#source-and-eval)
14. [path](#path)
15. [set_color, history, fish_config](#set_color-history-fish_config)
16. [abbr, bind, complete (interactive/config-time)](#abbr-bind-complete-interactiveconfig-time)
17. [Common bash/coreutils → fish builtin mapping](#common-bashcoreutils--fish-builtin-mapping)

---

## `set`

**Purpose:** Declare, assign, scope, export, query, and erase shell variables — fish's single builtin for everything bash spreads across bare assignment, `export`, `local`, `declare`, and `unset`.

### Synopsis

```
set [(-f | --function) (-l | --local) (-g | --global) (-U | --universal)]
    [(-x | --export) (-u | --unexport)]
set (-S | --show) (-L | --long) [NAME ...]
set [-Uflg] [-xu] [--no-event] NAME [VALUE ...]
set [-Uflg] [--no-event] NAME[[INDEX ...]] [VALUE ...]
set (-a | --append) (-p | --prepend) [-Uflg] [--no-event] NAME VALUE ...
set (-e | --erase) [-Uflg] [--no-event] NAME[[INDEX]] ...
set (-q | --query) [-Uflg] [-xu] NAME[[INDEX]] ...
```

### Scoping flags

| Flag | Scope |
|---|---|
| `-l`/`--local` | Current **block**; erased when the block ends. Outside a block, behaves like `-f`. |
| `-f`/`--function` | Current function; erased when it returns. |
| `-g`/`--global` | All functions in this shell session. |
| `-U`/`--universal` | Persisted across restarts and shared with every fish instance on the machine. |

If no scope flag is given and the name already exists, fish reuses the existing variable's scope (narrowest wins if defined in multiple). If it doesn't exist, a new one defaults to function-local (or global outside any function) — **not** block-local like explicit `-l`.

### Export flags

`-x`/`--export` marks the variable for child processes' environment; `-u`/`--unexport` (default for new vars) keeps it out. `--path`/`--unpath` treat the variable as colon-delimited (auto-applied to names ending in `PATH`).

### Other flags

- `-a`/`--append` and `-p`/`--prepend` — add values to a list variable without destroying existing entries.
- `-e`/`--erase` — unset a variable (or scope-qualified, or a specific list index).
- `-q`/`--query` — test existence; no output, exit status = number of names not found.
- `-n`/`--names` — list only variable names.
- `-S`/`--show` — show scope/value/export status.
- Options **must** precede the name: `set flags -l` sets `flags` to the literal string `"-l"`, it does not declare `flags` local.

### Examples

```fish
set foo hi                  # set $foo to "hi"
set -a foo there             # append "there" -> list append (no bash equivalent syntax)
set -p foo before            # prepend "before" -> list prepend
set -e smurf                 # unset $smurf
set -e -Ug smurf             # unset $smurf from global AND universal scopes
set PATH[4] ~/bin            # replace just the 4th element of a list variable
set -gx EDITOR (which nvim)  # global + exported, like `export EDITOR=$(which nvim)` in bash

# scoped/exported for one command only, like bash `VAR=val cmd`
HOME=(mktemp -d) fish
# equivalent to:
begin; set -lx HOME (mktemp -d); fish; end

# existence check replacing bash's [ -z "${VAR+x}" ]
if set -q MY_VAR
    echo "MY_VAR is defined"
end
```

`set` itself never touches `$status`; only command substitutions inside a `set` call can:

```fish
> false
> set foo bar
> echo $status
1
> true
> set foo banana (false)
> echo $status
1
```

---

## `string`

**Purpose:** Fish's string-manipulation swiss-army-knife — replaces bash's `${var//x/y}`, `${#var}`, `${var:0:3}`, `${var^^}`/`${var,,}`, and most `sed`/`grep -o`/`tr` one-liners. All subcommands accept multiple STRING arguments (or stdin) and process each independently, one per output line.

### `string split` / `string split0`

```
string split [(-f | --fields) FIELDS] [(-m | --max) MAX] [-n | --no-empty] [-q | --quiet] [-r | --right] SEP [STRING ...]
string split0 [(-f | --fields) FIELDS] [(-m | --max) MAX] [-n | --no-empty] [-q | --quiet] [-r | --right] [STRING ...]
```
Replaces bash's `IFS`-based `read -ra arr <<< "$s"` or `${s//,/ }` + array splitting. `split0` is NUL-delimited, immune to further splitting in command substitution.

```fish
string split . example.com
# example
# com

set -l parts (string split ':' $PATH_LIKE_VAR)
```

### `string join` / `string join0`

```
string join [-q | --quiet] [-n | --no-empty] [--] SEP [STRING ...]
string join0 [-q | --quiet] [-n | --no-empty] [--] [STRING ...]
```
Replaces bash's `IFS=,; echo "${arr[*]}"`.

```fish
string join '' a b c        # abc
string join , $mylist       # comma-join a list
```

### `string replace`

```
string replace [-a | --all] [-f | --filter] [-i | --ignore-case] [-r | --regex] [(-m | --max-matches) MAX] [-q | --quiet] PATTERN REPLACEMENT [STRING ...]
```
This is the direct replacement for bash's `${var//search/replace}` (use `-a`/`--all`) and `${var/search/replace}` (single replacement, the default). PATTERN is a literal substring by default; add `-r`/`--regex` for PCRE2 (supports `$1`, `$2` group refs).

```fish
string replace is was 'blue is my favorite'      # blue was my favorite
string replace -a o 0 'foo bar boo'               # f0o bar b0o -> all matches
string replace -r '(\w+)@(\w+)' '$2@$1' user@host # regex with capture-group swap
```

### `string match`

```
string match [-a | --all] [-e | --entire] [-i | --ignore-case] [-g | --groups-only] [-r | --regex] [-n | --index] [-q | --quiet] [-v | --invert] [(-m | --max-matches) MAX] PATTERN [STRING ...]
```
Replaces `[[ $var == pattern ]]` (glob) and `grep -oE` (with `-r`). By default PATTERN is a glob matched against the *entire* string.

```fish
string match -r 'cat|dog|fish' 'nice dog'    # dog
string match -q 'foo*' $x; and echo "matches"  # boolean test, no output
```

### `string sub`

```
string sub [(-s | --start) START] [(-e | --end) END] [(-l | --length) LENGTH] [-q | --quiet] [STRING ...]
```
Replaces bash's `${var:0:3}` substring slicing. Indices are 1-based; negative indices count from the end.

```fish
string sub --length 2 abcde     # ab
string sub --start -3 abcde     # cde
```

### `string length`

```
string length [-q | --quiet] [-V | --visible] [STRING ...]
```
This is the direct replacement for bash's `${#var}`.

```fish
string length "hello"           # 5
if test (string length -- $x) -eq 0
    echo "empty"
end
```

### `string trim`

```
string trim [-l | --left] [-r | --right] [(-c | --chars) CHARS] [-q | --quiet] [STRING ...]
```
Bash has no direct equivalent short of `sed`/parameter-expansion tricks.

```fish
string trim '  abc  '           # abc
string trim -c '/' '/usr/bin/'  # usr/bin
```

### `string pad`

```
string pad [-r | --right] [-C | --center] [(-c | --char) CHAR] [(-w | --width) INTEGER] [STRING ...]
```
Left-pads by default (like `printf '%5s'`).

```fish
string pad -w 10 -c '0' 42      # 0000000042
```

### `string repeat`

```
string repeat [(-n | --count) COUNT] [(-m | --max) MAX] [-N | --no-newline] [-q | --quiet] [STRING ...]
```

```fish
string repeat -n 3 'ab'         # ababab
```

### `string escape` / `string unescape`

```
string escape [-n | --no-quoted] [--style=STYLE] [STRING ...]
string unescape [--style=STYLE] [STRING ...]
```
STYLE is `script` (default), `var` (hex-encode for safe variable-name use), `url`, or `regex`.

```fish
string escape --style=var 'a1 b2'    # a1_20_b2...  (safe as a variable name suffix)
```

### `string collect`

```
string collect [-a | --allow-empty] [-N | --no-trim-newlines] [STRING ...]
```
Collects multi-line command substitution output into one argument instead of splitting it — needed when wrapping a command substitution in `""` isn't an option, e.g. inside `argparse` or function calls that expect one value.

### `string lower` / `string upper`

```
string lower [-q | --quiet] [STRING ...]
string upper [-q | --quiet] [STRING ...]
```
Replaces bash's `${var,,}` / `${var^^}`.

### `string shorten`

```
string shorten [(-c | --char) CHARS] [(-m | --max) INTEGER] [-N | --no-newline] [-l | --left] [-q | --quiet] [STRING ...]
```
Truncates to a max width and appends an ellipsis (`…`).

---

## `test` / `[`

**Purpose:** Condition evaluation for `if`/`while`, same role as bash's `test`/`[[`/`[`.

### Synopsis

```
test [EXPRESSION]
[ [EXPRESSION] ]
```

`test` is preferred; `[ ... ]` exists only for cross-shell familiarity. There is **no** `[[ ... ]]` in fish — `test` covers that ground (and its glob/regex needs are delegated to `string match`).

### Operators

**File tests:** `-b` block device, `-c` char device, `-d` directory, `-e` exists, `-f` regular file, `-g` setgid, `-G` owned by your group, `-k` sticky bit, `-L` symlink, `-O` owned by you, `-p` named pipe, `-r` readable, `-s` size > 0, `-S` socket, `-t FD` is a terminal, `-u` setuid, `-w` writable, `-x` executable.

**File comparisons:** `FILE1 -nt FILE2` (newer than), `-ot` (older than), `-ef` (same file).

**String tests:** `STRING1 = STRING2`, `!=`, `-n STRING` (non-empty), `-z STRING` (empty).

**Numeric:** `-eq`, `-ne`, `-gt`, `-ge`, `-lt`, `-le` (works on both ints and floats).

**Combining:** `-a` (and), `-o` (or), `!` (negate), `\( ... \)` grouping — parens must be escaped or fish treats them as command substitution.

### Key differences from bash

- **No `<`/`>` string comparison operators** — POSIX defines them but fish doesn't implement them.
- Fish's `test` has **no `[[ ]]` construct**; use `string match`/`string match -r` for globbing/regex instead of `[[ $x == pat* ]]`.
- Always quote variables/substitutions passed to `test` — an unquoted empty/multi-word expansion silently changes the arity of the expression fish parses, e.g. `test -n $foo` still evaluates true if `$foo` is unset (a known "confusing misfeature," gated behind the `test-require-arg` feature flag for future removal).

```fish
if test -d /tmp
    cp /etc/motd /tmp/motd
end

if test \( -f /foo -o -f /bar \) -a \( -f /baz -o -f /bat \)
    echo Success.
end

if test $status -eq 0
    echo "Previous command succeeded"
end
```

---

## `math`

**Purpose:** Arithmetic evaluation — the direct replacement for bash's `$(( ))`. Fish has no arithmetic expansion syntax at all; every calculation goes through `math`.

### Synopsis

```
math [(-s | --scale) N] [(-b | --base) BASE] [(-m | --scale-mode) MODE] EXPRESSION ...
```

### Flags

- `-s`/`--scale N` — decimal places in the result (or `max`); default effectively 6. Scale 0 **truncates** rather than rounds (`math -s0 10/6` → `1`, not `2`).
- `-b`/`--base BASE` — output base, `hex`/`16` or `octal`/`8` (implies scale 0).
- `-m`/`--scale-mode MODE` — `truncate`, `round`, `floor`, `ceiling`.

### Operators

`+ - * / ^ %`, plus `x` as an alternative multiplication symbol (must have surrounding whitespace so it isn't parsed as hex). **Parentheses and `*` must be quoted or escaped** since fish's own parameter expansion (globbing) runs first.

### Constants

`e`, `pi`, `tau` (no `$` prefix — they're evaluated by `math`, not fish variables).

### Functions

`abs acos asin atan atan2 bitand bitor bitxor ceil cos cosh exp fac floor ln log`/`log10 log2 max min ncr npr pow(x,y) round sin sinh sqrt tan tanh`. Trig functions use radians. `max`/`min` accept any number of arguments.

### Examples

```fish
math 1+1                     # 2
math "10 / 6"                # 1.666667
math -s0 10.0 / 6.0           # 1  (truncates, doesn't round)
math "sin(pi)"                # 0
math 5 \* 2                   # 10  (escape the glob char)
math $status - 128            # arithmetic on a status code
math --base=hex 192           # 0xc0
set -l total (math $a + $b)   # capture result like $(( a + b ))
```

---

## `argparse`

**Purpose:** Fish's builtin flag/argument parser for functions — the idiomatic replacement for hand-rolled `getopts`/`while [[ $1 == -* ]]` loops in bash.

### Synopsis

```
argparse [OPTIONS] OPTION_SPEC ... -- $argv
```
The `--` before the arguments to parse is **mandatory**, even with zero specs and zero args.

### Parser options (must precede OPTION_SPECs)

- `-n`/`--name NAME` — name used in error messages.
- `-x`/`--exclusive OPTIONS` — comma-separated mutually exclusive set (repeatable).
- `-N`/`--min-args` / `-X`/`--max-args` — bound the count of leftover positional args.
- `-s`/`--stop-nonopt` — stop parsing at the first non-option arg (for subcommand-style CLIs).
- `-i`/`--ignore-unknown`, `-u`/`--move-unknown`, `--unknown-arguments KIND` — control handling of unrecognized flags instead of erroring.

### Option spec syntax

`[SHORT][/LONG][=|=?|=+|=*][&][!SCRIPT]`

- No suffix → boolean flag.
- `=` → required value, last one wins. `=?` → optional value. `=+`/`=*` → repeatable (required/optional).
- `&` → excludes the flag from `$argv_opts` (still sets `_flag_X`).
- `!SCRIPT` → validation script; nonzero exit = invalid.

Parsed results land in `_flag_X` variables (one per short/long name given), leftover positionals in `$argv`, and all consumed option text in `$argv_opts` (useful for forwarding to a wrapped command).

### Example

```fish
function greet
    argparse 'h/help' 'n/name=' -- $argv
    or return

    if set -q _flag_help
        echo "Usage: greet [-h|--help] [-n|--name=NAME]"
        return 0
    end

    set -l who world
    set -q _flag_name[1]
    and set who $_flag_name[-1]   # last --name= wins

    echo "Hello, $who!"
end

greet --name=Fish     # Hello, Fish!
```

Validated flag value:

```fish
argparse 'p/path=!test -d "$_flag_value"' -- --path /tmp
```

---

## `functions`

**Purpose:** Introspect, copy, describe, or erase defined fish functions — replaces bash's `declare -f`, `unset -f`, and `type -t` (for the function-erasure part).

### Synopsis

```
functions [-a | --all] [-n | --names] [--color WHEN]
functions [-D | --details] [-v] FUNCTION
functions -c OLDNAME NEWNAME
functions -d DESCRIPTION FUNCTION
functions [-e | -q] FUNCTION ...
```

### Flags

- `-n`/`--names` — list just the names of all defined functions.
- `-a`/`--all` — include functions starting with `_` (hidden by default).
- `-c`/`--copy OLDNAME NEWNAME` — duplicate a function's body under a new name (event handlers are not copied).
- `-d`/`--description DESCRIPTION` — set/change a function's description.
- `-e`/`--erase` — remove a function definition for the session (does not touch an on-disk autoload file — use `funcsave` for that).
- `-q`/`--query` — test existence; exit status = count of names not found.
- `-D`/`--details` [`-v`] — report where a function is defined (path, line number, whether it shadows another).

```fish
functions -n              # list function names
functions -c foo bar      # copy 'foo' to 'bar'
functions -e bar          # erase 'bar'
functions -q mycmd; and echo "mycmd is defined"
```

---

## `type`

**Purpose:** Determine how a name would be interpreted if run — fish's version of bash's `type`/`command -v`/`which`.

### Synopsis

```
type [OPTIONS] NAME [...]
```

### Flags

- `-a`/`--all` — print all definitions matching NAME.
- `-t`/`--type` — print just `function`, `builtin`, or `file`.
- `-p`/`--path` — print the resolved path (works for `PATH` executables and on-disk autoloaded function files).
- `-P`/`--force-path` — resolve **only** against `PATH`, ignoring any shadowing function/builtin.
- `-q`/`--query` — silent; exit status only.
- `-s`/`--short` — suppress printing function bodies.

Mutually exclusive: `-q`, `-p`, `-t`, `-P` — only one may be used per call.

```fish
type fg                 # fg is a builtin
type -q git; and echo "git is installed"
type -p python3          # prints the resolved path, like `command -v python3`
```

---

## `command`

**Purpose:** Bypass any function/builtin of the same name and run the actual executable — fish's `command`, roughly equivalent to bash's `command` builtin (not `\cmd` backslash-escaping, which fish doesn't support the same way).

### Synopsis

```
command [OPTIONS] [COMMANDNAME [ARG ...]]
```

### Flags

- `-a`/`--all` — print every match found in `PATH`, in order.
- `-s`/`--search` (alias `-v`) — print the resolved external path or nothing.
- `-q`/`--query` — silent existence check; exit 0 if found, 127 otherwise.

```fish
command ls                    # run the real ls, bypassing any `ls` function
command -q git; and command git log
```

---

## `status`

**Purpose:** Introspect the running fish shell/script/function — no single bash equivalent; combines bits of `$0`, `$BASH_LINENO`, `$FUNCNAME`, `$-` (interactive flag), and `set -o` job-control queries.

### Synopsis (key subcommands)

```
status is-login
status is-interactive
status is-block
status is-breakpoint
status is-command-substitution
status current-command
status current-function
status filename        # (alias: current-filename)
status basename
status dirname
status fish-path
status line-number      # (alias: current-line-number)
status stack-trace
status job-control CONTROL_TYPE
status features
status test-feature FEATURE
```

- `status is-interactive` — 0 if fish is attached to a keyboard; use to skip prompt-only setup in scripts sourced by both interactive and non-interactive contexts.
- `status is-login` — 0 if this is a login shell.
- `status current-command` — name of the currently executing function/command.
- `status filename` — path of the running script (or `-` if fed via `source` from a pipe).
- `status line-number` — current line number in the running script, useful in error messages.

```fish
if status is-interactive
    # only set up interactive things like abbreviations, prompt, etc.
end

echo "error at "(status current-filename)":"(status line-number)
```

---

## `read`

**Purpose:** Read a line (or a delimited/tokenized/list of values) from stdin into variables — fish's `read` builtin, with meaningfully different defaults from bash's.

### Synopsis

```
read [OPTIONS] [VARIABLE ...]
```

### Key differences from bash's `read`

- **No `REPLY` fallback.** If no variable name is given, the result is printed to stdout instead of auto-populating a variable — enables patterns like `mysql -p(read)`.
- Splitting defaults to `$IFS` (space/tab/newline) only if no other splitting method is specified — but relying on `$IFS` is explicitly called out as deprecated in favor of `-d`/`--delimiter`.
- `-l`/`--local`, `-g`/`--global`, `-U`/`--universal`, `-x`/`--export` mirror `set`'s scoping flags directly (bash's `read` has no scoping concept at all).
- `-a`/`--list` stores all remaining tokens into a **single** list variable (like bash's `read -a arr`, but fish lists are native, not a separate array type).
- `-t`/`--tokenize` splits using fish's own quoting-aware tokenizer, not naive whitespace splitting.
- `-L`/`--line` reads one raw line per variable (successive variables get successive lines) instead of splitting one line across variables.
- Input is capped at 100 MiB by default (`fish_read_limit`, override or set to 0 to disable) — bash has no such built-in ceiling.

### Other flags

`-p`/`--prompt`, `-P`/`--prompt-str`, `-s`/`--silent` (mask input, e.g. for passwords), `-n`/`--nchars`, `-z`/`--null` (NUL-terminated, e.g. paired with `find -print0`).

```fish
echo hello | read foo
echo $foo                          # hello

printf '%s\n' line1 line2 line3 | while read -l line
    echo "Got: $line"
end

echo a==b==c | read -d == -l a b c
echo $a $b $c                       # a b c

set -l pass (read -s -P 'Password: ')
```

---

## `count`

**Purpose:** Count elements in a list or lines from stdin — the direct replacement for bash's `${#arr[@]}` / `$#`.

### Synopsis

```
count STRING1 STRING2 ...
COMMAND | count
count [...] < FILE
```

`count` takes **no options at all** (not even `-h`/`--help`). It sums the number of arguments passed plus the number of newlines received on stdin.

Exit status is non-zero exactly when there were zero arguments — this is the idiomatic way to test for an empty list, since fish has no `[ ${#arr[@]} -eq 0 ]` equivalent:

```fish
count $PATH                    # replaces ${#PATH_ARR[@]} — element count
count $argv                    # replaces bash's $# inside a function

if test (count $argv) -eq 0
    echo "no arguments given"
end

# or, leveraging exit status directly:
if not count $mylist >/dev/null
    echo "mylist is empty"
end

git ls-files --others --exclude-standard | count   # count lines of output
```

---

## `contains`

**Purpose:** Test list membership — replaces bash's manual `[[ " ${arr[@]} " =~ " $x " ]]` or loop-based membership check.

### Synopsis

```
contains [OPTIONS] KEY [VALUES ...]
```

### Flags

- `-i`/`--index` — print the (1-based) index of the first match instead of nothing.
- Use `--` before KEY if it looks like a flag (e.g. starts with `-`), otherwise `contains` will try to parse it as an option to itself.

```fish
if contains cat $animals
    echo "cat is in the list"
end

# building a PATH-like variable idempotently
for dir in ~/bin /usr/local/bin
    if not contains $dir $PATH
        set PATH $PATH $dir
    end
end

# checking for a flag-like value safely
if contains -- -q $argv
    echo '$argv contains a -q option'
end

set -l idx (contains -i needle $haystack)   # index of first match, or empty + status 1
```

---

## `source` and `eval`

**Purpose:** Run fish code from a file (`source`) or from a dynamically-built string (`eval`) in the current shell.

### `source`

```
source FILE [ARGUMENTS ...]
SOMECOMMAND | source
. FILE [ARGUMENTS ...]
```
Runs FILE's contents in the current shell — variable changes are visible afterward, unlike executing the file as a subprocess. Extra ARGUMENTS populate `$argv` (not including the filename itself). `source` creates a new **local** scope, so `set --local` inside a sourced file does not leak into the caller. The `.` alias is deprecated in favor of `source` and slated for removal.

```fish
source ~/.config/fish/config.fish
```

### `eval`

```
eval [COMMANDS ...]
```
Joins all arguments with a space and executes the result as a fish command — used when you must construct a command string dynamically and `source` (file-based) doesn't fit. For the common case of "run whatever is in this variable," prefer plain variable expansion (`set cmd ls -la; $cmd`) over `eval`, since fish variables can hold command names directly.

```fish
set cmd ls \| cut -c 1-12
eval $cmd
```

---

## `path`

**Purpose:** Manipulate and test filesystem paths as strings or on disk — a builtin family with no single bash equivalent (replaces ad hoc `basename`/`dirname`/`realpath`/manual string-slicing).

### Synopsis

```
path basename [-E | --no-extension] [PATH ...]
path dirname [PATH ...]
path extension [PATH ...]
path filter [-v | --invert] [-d] [-f] [-l] [-r] [-w] [-x] [(-t | --type) TYPE] [(-p | --perm) PERMISSION] [--all] [PATH ...]
path is [same flags as filter, status-only]
path mtime [-R | --relative] [PATH ...]
path normalize [PATH ...]
path resolve [PATH ...]
path change-extension EXTENSION [PATH ...]
path sort [-r | --reverse] [-u | --unique] [--key=(basename | dirname | path)] [PATH ...]
```
All subcommands accept `-z`/`--null-in` and `-Z`/`--null-out` for NUL-delimited piping (composes cleanly with `find -print0`), and `-q`/`--quiet` for status-only checks. Paths can come from arguments or stdin (one per line, or NUL-delimited).

```fish
path basename ./foo.mp4          # foo.mp4
path dirname /usr/bin/           # /usr
path extension ~/.config.d       # .d
path change-extension mp4 ./foo.wmv   # ./foo.mp4

path filter --type file,dir --perm exec,write /usr/bin/fish /home/me
path is -fx /bin/sh              # true if /bin/sh exists, is a file, and is executable

path normalize /usr/bin//../../etc/fish   # /etc/fish  (string-only, no symlink resolution)
path resolve /bin//sh                      # like realpath — resolves symlinks, absolute

path sort --unique --key=basename $fish_function_path/*.fish

# combine filter + resolve to find all executables on PATH
path filter -zZ -xf -- $PATH/* | path resolve -z
```

---

## `set_color`, `history`, `fish_config`

Session/environment builtins used heavily in interactive scripting and prompt functions.

### `set_color`

**Purpose:** Emit terminal color/style escape sequences — replaces raw ANSI codes or `tput`.

```
set_color [OPTIONS] [VALUE]
```
VALUE is a named color (`red green blue yellow magenta cyan white black`, plus `br`-prefixed bright variants) or 3/6-digit hex RGB. Key flags: `-b`/`--background`, `-o`/`--bold`, `-u`/`--underline[=STYLE]`, `--reset` (preferred over the `normal` keyword).

```fish
set_color red; echo "Roses are red"
set_color --bold blue; echo "Violets are blue"
set_color normal   # reset
```

### `history`

**Purpose:** Search, delete, and manage the interactive command history.

```
history [search] [--exact | --prefix | --contains] [--max N] [--reverse] [SEARCH_STRING ...]
history delete [--exact | --case-sensitive] SEARCH_STRING ...
history merge | save | clear | clear-session
history append COMMAND ...
```

```fish
history search --contains "docker"
history delete --prefix "rm -rf"
```
Fish's `fish_history` variable sets a *session name*, not a file path like bash's `HISTFILE` — setting it to `""` disables history like a private browsing session.

### `fish_config`

**Purpose:** Configure prompt/theme, interactively or from scripts.

```
fish_config [browse]
fish_config prompt (choose | list | save | show)
fish_config theme (choose | demo | dump | list | show)
```

```fish
fish_config theme dump > ~/.config/fish/themes/my.theme
```

---

## `abbr`, `bind`, `complete` (interactive/config-time)

Lower priority for scripting since these configure interactive behavior, not script logic — but common in `config.fish`.

- **`abbr`** — define expand-on-space text shortcuts (interactive only, not scripts): `abbr --add gco git checkout` makes typing `gco<space>` expand to `git checkout`.
- **`bind`** — assign key sequences to fish input functions or commands: `bind ctrl-d 'exit'`.
- **`complete`** — define tab-completions for a command: `complete -c grep -s d -x -a "read skip recurse"` (the `-d` flag to `grep` must be one of those three values).

---

## Common bash/coreutils → fish builtin mapping

| Bash / coreutils | Fish equivalent |
|---|---|
| `$(( a + b ))` | `math $a + $b` |
| `${#var}` | `string length $var` |
| `${#arr[@]}` | `count $arr` |
| `$#` (inside a function) | `count $argv` |
| `${var//search/replace}` | `string replace -a search replace $var` |
| `${var/search/replace}` | `string replace search replace $var` |
| `${var^^}` / `${var,,}` | `string upper $var` / `string lower $var` |
| `${var:0:3}` | `string sub -l 3 $var` |
| `${var# }` / trim | `string trim $var` |
| `IFS=, read -ra arr <<< "$s"` | `string split , $s` |
| `IFS=,; echo "${arr[*]}"` | `string join , $arr` |
| `[[ $x == pat* ]]` | `string match -q 'pat*' $x` |
| `grep -oE 'regex'` on a string | `string match -r 'regex' $x` |
| `sed 's/x/y/'` on a variable | `string replace -r 'x' 'y' $var` |
| `[[ " ${arr[@]} " =~ " $x " ]]` | `contains $x $arr` |
| `getopts` / manual `while [[ $1 == -* ]]` | `argparse 'h/help' 'n/name=' -- $argv` |
| `export VAR=val` | `set -gx VAR val` |
| `local VAR=val` | `set -l VAR val` |
| `unset VAR` | `set -e VAR` |
| `declare -f` / `type -t foo` | `functions -n` / `type -t foo` |
| `command -v foo`, `which foo` | `type -p foo`, `command -sq foo` |
| `[ -z "${VAR+x}" ]` (defined check) | `set -q VAR` |
| `read -r line` | `read -l line` |
| `read -a arr` | `read -la arr` |
| `read` (bash, no var → `$REPLY`) | `read` with no var → prints to stdout |
| `basename`/`dirname` (coreutils) | `path basename` / `path dirname` |
| `realpath` | `path resolve` |
| `. file.sh` / `source file.sh` | `source file.fish` (`.` is deprecated in fish) |
| `eval "$cmd"` | `eval $cmd`, or prefer `$cmd` directly if simple |
| `$0`, `$BASH_SOURCE` | `status current-filename` / `status filename` |
| `$BASH_LINENO` | `status line-number` |
| `$-` (interactive check: `[[ $- == *i* ]]`) | `status is-interactive` |
| `[[ $PS1 ]]` / login-shell test | `status is-login` |
| array append `arr+=(x)` | `set -a arr x` |
| array prepend | `set -p arr x` |
| `printf '%*s'` padding | `string pad -w N` |
| `tr '[:upper:]' '[:lower:]'` | `string lower` |
| `wc -l < file` (count lines) | `count < file` |
