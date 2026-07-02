# Fish Shell Language Reference for Script Authors

> A practitioner's reference to Fish (friendly interactive shell) syntax and semantics, written for engineers fluent in POSIX sh/bash. Every section calls out where Fish's behavior silently diverges from bash — those divergence points are where bash muscle memory produces scripts that parse but do the wrong thing.

## Table of Contents

1. [Syntax Overview](#1-syntax-overview)
2. [Variables](#2-variables)
3. [String Interpolation & Command Substitution](#3-string-interpolation--command-substitution)
4. [Brace Expansion](#4-brace-expansion)
5. [Conditionals](#5-conditionals)
6. [Loops](#6-loops)
7. [Functions](#7-functions)
8. [Pipes and Redirection](#8-pipes-and-redirection)
9. [Job Control and Background Processes](#9-job-control-and-background-processes)
10. [Error Handling and Status](#10-error-handling-and-status)
11. [Event Handlers](#11-event-handlers)
12. [Globbing and Wildcards](#12-globbing-and-wildcards)
13. [String Manipulation (`string`)](#13-string-manipulation-string)
14. [Arithmetic (`math`)](#14-arithmetic-math)
15. [Reading Input (`read`)](#15-reading-input-read)
16. [Abbreviations and Aliases](#16-abbreviations-and-aliases)
17. [No Heredocs — Fish Idioms](#17-no-heredocs--fish-idioms)
18. [Common Gotchas Checklist](#18-common-gotchas-checklist)
19. [Bash → Fish Quick-Translation Table](#19-bash--fish-quick-translation-table)

---

## 1. Syntax Overview

Fish scripts are sequences of commands, one per line (or separated by `;`), just like sh. The big structural differences are: no `then`/`do` keywords, no `[[ ]]`, and a completely different quoting/expansion model.

### Command structure

```fish
command arg1 arg2
command arg1; command arg2   # semicolon separates commands, same as bash
```

Every compound statement (`if`, `for`, `while`, `function`, `switch`, `begin`) is closed with a single keyword: **`end`**. There is no `fi`, `done`, or `esac`.

```fish
if true
    echo yes
end
```

### Comments

Only single-line comments starting with `#`. **There is no multiline comment syntax** — no `: ' ... '` trick, no block comment. Comment every line individually.

```fish
# this is a comment
echo hi # trailing comment works too
```

### Quoting

Fish has two quoting styles, and they behave differently from each other (this part matches bash's intuition, mostly):

- **Single quotes**: no expansion of any kind occurs. Only `\'` and `\\` are recognized as escapes.
- **Double quotes**: variable expansion and command substitution occur, but globbing/wildcard expansion and brace expansion do **not** happen inside double quotes.

```fish
echo 'no $expansion here'
echo "but $HOME expands here"
rm "my file.txt"        # quote filenames with spaces just like bash
```

Escapes recognized in double quotes: `\"`, `\$`, `\\`, and a backslash immediately followed by a newline (see line continuation below). Fish also supports rich escape sequences outside quotes / in unquoted or single-quoted contexts is not applicable — the escapes `\a \e \f \n \r \t \v`, `\xHH`, `\ooo`, `\uXXXX`, `\UXXXXXXXX`, `\cX` are recognized in general lexing, and characters special to Fish (`$ \ * ~ # ( ) { } & | ; < > space` and quotes) must be escaped with `\` when used unquoted and meant literally.

### Line continuation

A `\` immediately followed by a literal newline is a continuation — the line break disappears without inserting whitespace or ending the token, identical in spirit to bash's trailing backslash:

```fish
echo one \
    two
# => one two
```

### No `then`, no `do`

This is the single biggest structural surprise for bash users. Fish conditions are just commands; the block starts immediately:

```fish
# bash: if [ -e /etc/os-release ]; then ...; fi
# fish:
if test -e /etc/os-release
    cat /etc/os-release
end
```

Fish documents this explicitly: "the condition here is a *command* ... Unlike other shells, the condition command ends after the first job, there is no `then` here."

---

## 2. Variables

### The one fact that changes everything: all Fish variables are lists

Bash has scalars and (separately) arrays. **Fish has only lists.** A "scalar" is just a list with one element. This single design decision is responsible for most of the quoting/splitting differences from bash.

```fish
set foo hello        # $foo is a 1-element list: ("hello")
set foo a b c        # $foo is a 3-element list
```

### `set` — assignment

There is no `x=1` syntax in Fish (unlike bash). Assignment is always done via the `set` builtin:

```fish
set name "Christian"      # NOT: name="Christian"  (that's a bash-ism; fish treats `name=1` as a command name)
```

`set` requires **all flags before any arguments** — `set flags -l` sets `$flags` to the literal string `-l`, it does not apply the `-l` flag.

#### Scope flags

| Flag | Long form | Scope |
|---|---|---|
| `-l` | `--local` | Scoped to the current block (`if`/`for`/`while`/`begin`); erased when the block ends. Outside any block, behaves like `--function`. |
| `-f` | `--function` | Scoped to the executing function; erased when the function returns. This is Fish's closest analog to bash's `local`. |
| `-g` | `--global` | Visible to all functions in the current shell session. |
| `-U` | `--universal` | Shared across **all Fish sessions the user is running on the machine**, persisted to disk, and survives reboots. There is no bash equivalent — this is unique to Fish and is commonly misused by newcomers who expect `-g` semantics. |

When no scope flag is given: if a variable of that name already exists, its existing scope is reused (narrowest scope wins if defined in multiple); if it does not exist yet, it's created in function scope (or global scope if no function is running).

```fish
function greet
    set -l greeting "hello"   # local to this function call
    echo $greeting $argv
end
```

#### Export flags

Exporting is a separate axis from scope — you can have a local exported variable, a global exported variable, etc.

```fish
set -gx GOPATH ~/dev/go      # global AND exported (bash: export GOPATH=~/dev/go)
set -x  NAME value           # export in current scope
set -u  NAME                 # unexport (stop passing to children)
```

There is no separate `export` command — `set -x` (or `-gx`) is the whole story.

#### Erasing variables

```fish
set -e NAME          # erase entire variable
set -e smurf[1]      # erase just the first list element (fish supports index-erase; bash arrays need unset arr[i])
set -e -Ug smurf      # erase from a specific scope
```

#### Querying / checking existence

```fish
set -q MY_VAR          # returns 0 (true) if MY_VAR is defined, 1 otherwise — no output
if set -q MY_VAR
    echo "defined"
end
```
This is the idiomatic Fish replacement for bash's `[[ -n ${MY_VAR+x} ]]` / `[[ -z "$MY_VAR" ]]` existence checks.

#### Path variables

Any variable whose name ends in `PATH` is automatically treated as colon-delimited on display, even though internally it's still a Fish list:

```fish
set MYPATH 1 2 3
echo "$MYPATH"     # 1:2:3
echo $PATH          # displayed with each element newline-listed when unquoted, or colon-joined in double quotes
```
`--path` / `--unpath` force or unforce this treatment on arbitrary variable names.

#### Append / prepend

```fish
set -a foo there      # append "there" to $foo's list
set -p foo before     # prepend "before"
```
Append/prepend cannot be combined with slice assignment.

#### Showing variables

```fish
set -S PATH          # -S/--show: prints scope, export state, and every value; no other flags may combine with -S
set -n               # -n/--names: list only variable names (sorted)
```

### Indexing and slicing

**List indices in Fish start at 1, not 0.** This is the second most common bash-habit bug.

```fish
set var one two three four
echo $var[1]          # "one"   (NOT var[0])
echo $var[2]           # "two"
echo $var[-1]          # "four" — negative indices count from the end
echo $var[1..3]        # "one two three"   (range slice)
echo $var[2..-1]       # "two three four"
set var[2] TWO         # replace a single element by index
set PATH[1 4] /bin /sbin   # replace multiple indices in one call (list of indices)
```

### Variable expansion and lists vs. bash word-splitting

Fish splits a variable into list elements **when it is `set`**, not when it is used/expanded. Bash does the opposite — it stores a scalar string and splits it on `$IFS` at expansion time (word-splitting), which is exactly why bash scripts break on filenames with spaces unless everything is quoted. Fish's design avoids that class of bug entirely:

```fish
set foo 1 2 3
rm $foo        # runs: rm 1 2 3   → deletes three files: 1, 2, and 3
rm "$foo"      # runs: rm '1 2 3' → deletes ONE file literally named "1 2 3"
```

Because splitting already happened at `set` time, unquoted `$foo` in Fish is **safe** for values containing spaces (each list element is already a separate token) — the opposite of bash, where unquoted `$foo` is the dangerous case. Always know whether you want the elements separately (unquoted) or joined-with-spaces-into-one-argument (double-quoted).

### Dereferencing (indirect / variable variables)

```fish
set foo a b c
set a 10; set b 20; set c 30
set i 2
echo $$foo[$i]     # dereferences $foo[2] (= "b"), then reads $b => 20
```

---

## 3. String Interpolation & Command Substitution

### Command substitution: `(...)` is native; `$(...)` also works

Fish's native, idiomatic syntax is parentheses, **not** `$()`:

```fish
echo (pwd)                 # idiomatic fish
set current_dir (pwd)
```

Modern Fish (4.0+) also accepts `$(...)` as an alias for compatibility with pasted bash snippets:

```fish
echo $(pwd)                 # also works in current fish, but prefer (...) in new fish scripts
```

**Critical semantic difference from bash**: Fish command substitution splits output **on newlines**, not on `$IFS`. Multi-word single-line output from a command substitution becomes one list element (or is passed as one word) — it is not word-split character by character on spaces. This matters when capturing multi-line command output into a variable — you get a Fish *list*, one element per line:

```fish
set lines (grep foo file.txt)   # $lines is a list, one element per matched line
```

There is a default 1 GiB read limit on command substitution output (`fish_read_limit`); exceeding it sets `$status` to 122.

### No native process substitution (`<(...)`) — use `psub`

Bash's `<(command)` process substitution has no direct syntax equivalent. Fish provides the `psub` builtin, used inside a pipeline, to fake it via a temporary file/FIFO:

```fish
diff -u (grep fish myanimallist1 | psub) (grep fish myanimallist2 | psub)
```

### String interpolation

Double-quoted strings interpolate variables and command substitutions, same idea as bash:

```fish
set name world
echo "hello, $name!"
echo "today is (date)"        # command substitution also interpolates in double quotes... actually see note below
```
Note: unlike variable expansion, command substitution `(...)` inside a double-quoted string still runs and its output is joined by spaces into that one string argument (newline-split elements get space-joined when inside quotes, similar to how list variables collapse when quoted).

---

## 4. Brace Expansion

```fish
echo input.{c,h,txt}
# => input.c input.h input.txt

mv file.{txt,bak}
# => mv file.txt file.bak
```

Behaves like bash brace expansion for the common case. One Fish-specific wrinkle: if there is nothing between two braces after expansion (e.g. an empty alternative), that argument is dropped entirely rather than producing an empty string argument.

Brace expansion is **not** the same as globbing — braces don't test the filesystem, they're pure text expansion (same as bash).

---

## 5. Conditionals

### `if` / `else if` / `else` / `end`

No `then`, no `fi`. The condition is literally a command; its exit status decides the branch:

```fish
if test -e /etc/os-release
    cat /etc/os-release
else if test -e /etc/lsb-release
    cat /etc/lsb-release
else
    echo "unknown distro"
end
```

### `test` / `[` — the replacement for bash's `[[ ]]`

**Fish has no `[[ ]]` construct at all.** Everything conditional goes through `test` (or its `[` alias), which is a POSIX-similar builtin, not a shell keyword — so there's no special parsing magic; it is a command like any other, called as the argument to `if`/`while`, or standalone for its exit status.

String operators:
```fish
test -z $STRING         # true if STRING has zero length
test -n $STRING         # true if STRING has non-zero length
test "$a" = "$b"        # string equality
test "$a" != "$b"       # string inequality
```
Numeric operators (works on integers and floats):
```fish
test $number -eq 10
test $number -ne 10
test $number -gt 10
test $number -ge 10
test $number -lt 10
test $number -le 10
```
File-test operators: `-e` exists, `-f` regular file, `-d` directory, `-L` symlink, `-r` readable, `-w` writable, `-x` executable, `-s` size > 0, plus `-b/-c/-p/-S` device/pipe/socket type checks, `-g/-u/-k` for setgid/setuid/sticky, `-O/-G` ownership, and `-nt`/`-ot`/`-ef` for file comparisons.

Combining and negating:
```fish
test \( -f /foo -o -f /bar \) -a \( -f /baz -o -f /bat \)   # -a = AND, -o = OR; parens need \( \) escaping
test ! -f missing.txt        # ! negates, same as bash
```

**Quoting caveat** (a real Fish footgun): `test -n $MAYBE_UNSET` — if the variable is unset, it expands to *nothing*, and `test` then sees only `-n` with no argument, which some versions of `test` treat as true (checking whether the string `"-n"` itself is non-empty) rather than raising an error. **Always quote variables passed to `test`**: `test -n "$MAYBE_UNSET"`.

`test` implements a subset of POSIX.1-2008 test semantics (it deliberately omits `<`/`>` lexicographic string comparisons found in POSIX test). `command test` invokes the system `/usr/bin/test` binary instead of Fish's builtin, if ever needed.

### `and` / `or` / `not` — NOT `&&` / `||`

This is the headline divergence from bash for control flow. Fish does **not** use `&&`/`||` as its idiomatic combinators (though as of newer fish versions `&&`/`||` are also accepted as synonyms) — the native, documented style uses the words `and`, `or`, `not`:

```fish
# bash: cmd1 && cmd2 || cmd3
cmd1
and cmd2
or cmd3
```

```fish
set -q XDG_CONFIG_HOME
and set -l configdir $XDG_CONFIG_HOME
or set -l configdir ~/.config
```

Behavior: "`and` runs the second command if the first succeeded... `or` runs it if the first failed." They are **lazy** — only the portion needed to determine the final status runs, same short-circuit idea as bash's `&&`/`||`.

**Important trap**: unlike bash's left-to-right `&&`/`||` precedence chains, Fish combiners execute **step-by-step**, each looking only at the status of the immediately preceding command — so long chains can silently do the wrong thing:

```fish
test -e /etc/my.config
or echo "OH NO WE NEED A CONFIG FILE"
and return 1
```
This executes `return 1` even when the initial `test` **succeeded**, because `and return 1` looks at the status of the `echo`, not the original `test`. Fish's own docs recommend using `if`/`else` instead of chaining more than one combiner. **Prefer `if` for anything beyond a single `and`/`or` pair.**

`not` inverts a status (0 → 1, nonzero → 0), and can prefix any command:
```fish
if not test -f /tmp/lockfile
    touch /tmp/lockfile
end
```
Note: `not` applies to `$status` but **not** to `$pipestatus` (the per-stage pipeline statuses), because inverting would lose information about which stage failed.

### `switch` / `case`

```fish
switch (uname)
case Linux
    echo Hi Tux!
case Darwin
    echo Hi Hexley!
case DragonFly '*BSD'
    echo Hi Beastie!         # multiple glob patterns per case, space-separated
case '*'
    echo Hi, stranger!
end
```
Case patterns are glob-style (`*`, `?`, character classes), not regex. There is **no fallthrough** — the first matching `case` runs and control exits the `switch`, unlike C-style `switch`. There's no bash-style `;;` terminator needed either — the next `case` line ends the previous branch implicitly.

---

## 6. Loops

### `for` / `end`

Fish's `for` is closer to Python's `for x in iterable` than to POSIX sh's C-style arithmetic for-loop:

```fish
for file in *
    echo file: $file
end

for i in (seq 1 10)
    echo $i
end
```

### `while` / `end`

```fish
while true
    echo Still running
    sleep 1
end
```

Loops can have input redirected into them, just like blocks in bash:
```fish
while read -l line
    echo line: $line
end < file.txt
```

### `break` / `continue`

Work exactly as expected, same semantics as bash, usable inside `for` and `while`.

### `begin` / `end` — anonymous blocks

Fish has a bare block construct with no bash equivalent as a *statement* (bash's `{ ...; }` is the closest cousin) — useful for scoping `set -l` or for grouping redirection targets:

```fish
begin
    set -l foo bar
    echo $foo
end
# $foo is gone here

begin
    echo "line 1"
    echo "line 2"
end > output.txt
```

---

## 7. Functions

### Basic definition

```fish
function ll
    ls -l $argv
end
```

`$argv` is the list of all arguments passed to the function (equivalent to bash's `"$@"`, but note: it is genuinely a Fish list, so `$argv[1]` is the first argument, `$argv[2]` the second, etc. — 1-indexed, as with all Fish lists).

If a function shadows an existing command with the same name, call through to the real command with `command`:
```fish
function ls
    command ls --color=auto $argv
end
```

### `function` flags

| Flag | Long form | Purpose |
|---|---|---|
| `-d DESC` | `--description DESC` | Human-readable description, shown in completions / `functions` output |
| `-a NAMES` | `--argument-names NAMES` | Bind positional args to named variables instead of only `$argv[n]` |
| `-w CMD` | `--wraps CMD` | Inherit tab-completions from another command (used for alias-style functions) |
| `-e EVENT` | `--on-event EVENT` | Register as a handler for a Fish event (built-in or custom, via `emit`) |
| `-v VAR` | `--on-variable VAR` | Fire whenever `VAR`'s value changes |
| `-s SIGSPEC` | `--on-signal SIGSPEC` | Fire when the given signal (name or number) is delivered to fish |
| `-j PID` | `--on-job-exit PID` | Fire when the job containing process PID exits |
| `-p PID` | `--on-process-exit PID` | Fire when a specific fish child process exits (`%self` = `$fish_pid`) |
| `-S` | `--no-scope-shadowing` | Function can read/write the calling scope's variables directly |
| `-V NAME` | `--inherit-variable NAME` | Snapshot a variable's value at *definition* time into a local copy |

```fish
function debug --argument-names name val
    echo "[DEBUG] $name: $val" >&2
end
debug foo bar          # => [DEBUG] foo: bar

function ll --wraps ls --description "long listing"
    ls -l $argv
end

function on_prompt --on-event fish_prompt
    echo "about to show prompt"
end

function on_sigint --on-signal SIGINT
    echo "caught SIGINT"
end
```
Note on `--on-signal`: the signal must actually be delivered to the Fish process itself; e.g. Ctrl-C sends `SIGINT` to the foreground process group, which is not Fish if some other command is currently running in the foreground.

Note on `--no-scope-shadowing`: this is **not** a closure — "fish does not have any concept of closures, and variable lifetimes are never extended."

### Reserved words — cannot be used as function names

`[`, `_`, `and`, `argparse`, `begin`, `break`, `builtin`, `case`, `command`, `continue`, `else`, `end`, `eval`, `exec`, `for`, `function`, `if`, `not`, `or`, `read`, `return`, `set`, `status`, `string`, `switch`, `test`, `time`, `while`.

### Managing already-defined functions: `functions`

Distinct from the `function` keyword used to *define* one — `functions` (plural) inspects/manages existing functions:

```fish
functions -e myfunc          # -e/--erase: delete a function
functions -c old new         # -c/--copy: copy old's definition into new (does NOT copy its event handlers)
functions -d "desc" myfunc   # -d/--description: change description
functions -n                 # -n/--names: list all defined function names
functions -a                 # -a/--all: include underscore-prefixed (private) functions
functions -q myfunc          # -q/--query: test existence via exit status, like `set -q`
functions -H                 # -H/--handlers: list all event handlers
functions -D -v myfunc       # -D/--details (+-v/--verbose): show definition file/location
```

### Autoloading

Functions are **not** all loaded up front; Fish lazily loads them by filename the first time they're called. Place one function per file, named `<function-name>.fish`, in a directory on `$fish_function_path` (typically `~/.config/fish/functions/`):

> "fish will go through all directories in `$fish_function_path` looking for a file called `banana.fish`."

**Autoloading does not work for event handlers** — Fish can't know a function should run on an event if it hasn't been loaded yet (there's no name being called to trigger the lazy load). Event-handler functions typically need to be `source`d eagerly (e.g., from `config.fish`) rather than relying on autoload.

### Argument parsing: `argparse`

The idiomatic way to parse flags inside a function (there's no bash `getopts` equivalent syntax, but the concept maps to Fish's `argparse` builtin):

```fish
function mybetterfunction
    argparse h/help s/second -- $argv
    or return
    if set -q _flag_help
        echo "usage: ..."
        return 0
    end
    ...
end
```

---

## 8. Pipes and Redirection

### Redirection operators

| Fish | Meaning | Bash equivalent |
|---|---|---|
| `<SOURCE` | redirect stdin | `<file` |
| `>DEST` | redirect stdout (overwrite) | `>file` |
| `>>DEST` | redirect stdout (append) | `>>file` |
| `2>DEST` | redirect stderr | `2>file` |
| `2>>DEST` | append stderr | `2>>file` |
| `&>DEST` | redirect **both** stdout and stderr | `>file 2>&1` (bash also has `&>` in modern versions) |
| `>?DEST` | "noclobber" — like `>` but refuses to overwrite an existing file | bash `set -o noclobber` + `>` |
| `2>?DEST` | noclobber for stderr | — |

```fish
foo 2> output.stderr
make &>/log
```

It is an error to redirect a builtin, function, or block to a file descriptor above 2 (external commands support arbitrary FDs).

### Pipes

Standard `|` pipes stdout of one command to stdin of the next, same as bash:
```fish
grep fish file.txt | wc -l
```
Fish also supports combined stdout+stderr piping with `&|`, and FD-specific piping like `2>|`. `|&` is accepted as an alias for `&|` for bash-muscle-memory compatibility.

When both a pipe and redirections are on one line, the pipe is wired up first, then redirections are applied left-to-right — order matters, same trap as bash's `2>&1 | cmd` vs `| cmd 2>&1`.

### No process substitution — see `psub` in [Section 3](#3-string-interpolation--command-substitution)

---

## 9. Job Control and Background Processes

Background a job with `&`, same syntax as bash:
```fish
emacs &
```

**Fish-specific limitation**: "At the moment, functions cannot be started in the background" — only external commands / whole pipelines of them can be backgrounded, not a bare Fish function call.

`wait` behaves as in bash — waits for background jobs to complete. `jobs` lists active jobs. Fish also exposes `disown`.

---

## 10. Error Handling and Status

### `$status`

Holds the exit status of the last **foreground** job (matches bash's `$?`, different variable name):

```fish
some_command
if test $status -eq 0
    echo "succeeded"
end
```

Documented status meanings:
- `0` — success
- `121` — invalid arguments to a builtin
- `122` — command substitution output exceeded `fish_read_limit`
- `124` — no wildcard/glob matches
- `127` — command/function/builtin not found
- `128 + N` — process was killed by signal number `N` (e.g. `137` = killed by `SIGKILL`, `130` = `SIGINT`)

### `$pipestatus`

Holds a list of exit statuses for **every stage of the last pipeline**, analogous to bash's `${PIPESTATUS[@]}`:
```fish
false | true | false
echo $pipestatus     # => 1 0 1
```

### There is no `set -e` / `errexit` equivalent — this is a real trap for bash users

**In Fish, `set -e` means something completely different: it *erases a variable*** (`set -e VARNAME`), not "exit immediately on any command failure" as in bash (`set -e` / `set -o errexit`). Fish scripts do **not** abort automatically when a command fails partway through — execution always continues to the next line unless you explicitly check `$status` and `return`/`exit` yourself.

Idiomatic failure handling in Fish is therefore always explicit:
```fish
some_command
or return 1                      # bail out of the function/script on failure

# or, for setup sequences:
argparse h/help -- $argv
or return

mkdir -p $target
and cp $source $target
or begin
    echo "copy failed" >&2
    exit 1
end
```
There is no automatic "abort script on any nonzero exit" toggle in Fish — every failure path that should stop execution must be written explicitly with `or return`/`or exit`, `if not ...`, or similar.

### Negating with `not`

```fish
if not test -f /tmp/lockfile
    ...
end
```
Equivalent to bash's `if ! [ -f /tmp/lockfile ]; then`.

---

## 11. Event Handlers

Fish has a first-class pub/sub event system with no bash analog beyond trap-on-signal.

```fish
function on_path_change --on-variable PATH
    echo "PATH changed to $PATH"
end
```
Caveat: "fish makes no guarantees on any particular timing or even that the function will be run for every single set" of that variable — don't rely on it firing exactly once per assignment.

```fish
function notify --on-job-exit %self
    echo "a background job just exited"
end
```

Custom application-level events are emitted with `emit` and consumed with `--on-event`:
```fish
function on_my_event --on-event my_custom_event
    echo "my_custom_event fired with args: $argv"
end
emit my_custom_event foo bar
```

Common built-in events: `fish_prompt` (fires before each prompt is drawn), `fish_preexec`/`fish_postexec` (before/after each command), `fish_exit` (shell exiting).

**Reminder**: event-handler functions must actually be loaded (e.g. sourced from `config.fish`) — autoloading will not discover them, since nothing calls them by name to trigger the lazy load.

---

## 12. Globbing and Wildcards

- `*` matches any run of characters **except** `/` (does not cross directory boundaries)
- `**` recurses into subdirectories (Fish's equivalent of bash's `globstar` shopt, but on by default)
- `?` matches a single character (deprecated in modern Fish; can be disabled entirely with the `qmark-noglob` feature flag, since `?` is common in URLs/regex arguments)

```fish
ls *.txt
ls **/*.py            # recursive glob, no shopt needed
```

**Divergence from bash**: if a glob pattern matches nothing, Fish does **not** pass the literal, unexpanded pattern string through to the command (which is bash's default behavior unless `nullglob`/`failglob` is set) — instead, most commands **fail outright** with no matches (Fish's default is effectively bash's `failglob`). The exceptions that behave like bash's `nullglob` instead (silently producing zero arguments rather than erroring) are: `set`, `path`, `count`, `for`, and variable-override contexts.

```fish
rm *.doesnotexist    # errors — no files removed, nonzero status; script does NOT see the literal string "*.doesnotexist"
```

---

## 13. String Manipulation (`string`)

Fish provides a single multi-purpose `string` builtin replacing much of what bash farms out to `sed`/`awk`/`tr`/`cut`/parameter expansion:

```fish
string length "hello"                 # 5
string sub -s 2 -e 4 "hello"          # "ell"  (1-based start/end, negative indices supported)
string split "," "a,b,c"               # a\nb\nc  → a 3-element list
string join "-" a b c                  # a-b-c
string replace -a "o" "0" "foo bar"    # f00 bar
string match -r '(\d+)-(\d+)' "12-34"  # regex match; capture groups printed / assignable to a list
string trim "  hi  "                    # "hi"
string upper "abc"                     # ABC
string lower "ABC"                     # abc
string repeat -n 3 "ab"                 # ababab
string pad -w 10 -c "0" "42"            # 0000000042
string escape "a b"                     # a\ b  (shell-safe escaping)
string collect                          # gathers multiline command output into one argument
```

`string split` is Fish's replacement for `tr delimiter '\n'`, and `string match -r` is Fish's replacement for `grep -oP`/`sed -n` capture-group extraction. Capturing regex groups into named variables:

```fish
set -l parts (string match -r '(\d+)-(\d+)' -- "12-34")
# $parts[1] = full match, $parts[2] = first group, $parts[3] = second group
```

See `references/command-reference.md` for the full `string` subcommand list with flags.

---

## 14. Arithmetic (`math`)

Fish has **no `$((...))` arithmetic-expansion syntax**. Use the `math` builtin, feeding it through command substitution:

```fish
set result (math "1 + 2")           # 3
set result (math "10 / 3")           # 3      (integer division by default)
set result (math -s2 "10 / 3")       # 3.33   (-s/--scale sets decimal places)
set x (math $x + 1)                  # increment
```

See `references/command-reference.md` for the full operator/function list.

---

## 15. Reading Input (`read`)

```fish
read -l name                        # reads one line into a local variable $name
read -P "Enter name: " -l name       # -P/--prompt shows a prompt first
while read -l line
    echo "got: $line"
end < input.txt
echo $data | read -l first second rest   # splits fields across multiple variable names
```

---

## 16. Abbreviations and Aliases

Fish discourages bash-style `alias` for scripting (aliases don't survive well across shell instances and complicate completions); the interactive-friendly mechanism is `abbr`, which expands inline as you type, not at execution time — it's not really a scripting construct, more an interactive shortcut:

```fish
abbr -a gco git checkout
```
For actual reusable script logic, prefer a Fish **function** (see [Section 7](#7-functions)) over `alias`/`abbr` — functions are real, composable, arguments-aware units, whereas `alias` in Fish is implemented as a thin wrapper that itself just defines a function.

---

## 17. No Heredocs — Fish Idioms

Fish has **no heredoc (`<<EOF`) or here-string (`<<<`) syntax**. Common bash idiom:
```bash
cat <<EOF > file.txt
line 1
line 2
EOF
```
Fish equivalents:

**1. Multi-line quoted string** (Fish string literals can contain literal newlines, same as bash's `"$var"` across lines):
```fish
set text "line 1
line 2"
echo $text > file.txt
```

**2. `begin...end` block with output captured/redirected:**
```fish
begin
    echo "line 1"
    echo "line 2"
end > file.txt
```

**3. `printf` with explicit `\n`:**
```fish
printf '%s\n' "line 1" "line 2" > file.txt
```

---

## 18. Common Gotchas Checklist

A short list of exact bash reflexes that silently misbehave in Fish:

- `x=1` — does nothing useful in Fish; it's parsed as a command name. Use `set x 1`.
- `[[ -z $x ]]` — no `[[ ]]` exists. Use `test -z "$x"` and quote the variable.
- `local x=1` — no `local` keyword. Use `set -l x 1` (or `set -f x 1` for function-scope).
- `x=$((1+2))` — no arithmetic expansion. Use `set x (math "1 + 2")`.
- `&&` / `||` — accepted as synonyms in modern Fish, but the idiomatic, historically-documented forms are `and`/`or`; long `and`/`or` chains execute step-by-step against the *previous* command's status only, not the original condition — prefer `if`.
- `${arr[@]}` / `${arr[0]}` — Fish lists are `$arr` (unquoted, auto-splits) or `$arr[1]` for the first element (1-indexed, not 0-indexed).
- `export X=1` — no `export`. Use `set -gx X 1`.
- Heredocs (`<<EOF`) — not supported at all; use a multi-line quoted string, `begin...end > file`, or `printf`.
- `set -e` meaning "exit on error" — in Fish, `set -e NAME` **erases a variable**; there is no errexit toggle. Handle failures explicitly with `or return`/`or exit`.
- `$1`, `$2`, `$@`, `$#` — Fish has no positional parameters at the top level or numbered-arg shorthand; use `$argv`, `$argv[1]`, `count $argv`.
- Word-splitting on unquoted `$var` — the opposite risk profile from bash: Fish already split at `set` time, so unquoted `$var` is *usually* safe; it's **quoting** `"$var"` that joins a list back into one string.

---

## 19. Bash → Fish Quick-Translation Table

| Bash | Fish | Notes |
|---|---|---|
| `$1`, `$2`, ... | `$argv[1]`, `$argv[2]`, ... | 1-indexed in both, but Fish requires the bracket syntax |
| `$@` / `"$@"` | `$argv` | Fish argv is a list; unquoted `$argv` already preserves each arg as a separate token |
| `$#` | `count $argv` | No `#`-prefix shorthand; use the `count` builtin |
| `[[ -z $x ]]` | `test -z "$x"` | No `[[ ]]`; quote the variable to avoid the empty-arg trap |
| `[[ -n $x ]]` | `test -n "$x"` | same |
| `[ -f file ]` | `test -f file` | `test`/`[` exist in Fish too, just no `[[ ]]` superset |
| `local x=1` | `set -l x 1` | function-local: `set -f x 1` |
| `x=1` | `set x 1` | no bare `var=value` assignment |
| `export X=1` | `set -gx X 1` | no `export` keyword |
| `unset X` | `set -e X` | erase entire variable |
| `unset arr[2]` | `set -e arr[2]` | erase one list element |
| `x=$((1+2))` | `set x (math "1 + 2")` | no arithmetic expansion syntax |
| `((i++))` | `set i (math $i + 1)` | no `((...))`  |
| `case $x in ... esac` | `switch $x; case ...; end` | glob patterns, no fallthrough, no `;;` |
| `cmd1 && cmd2` | `cmd1; and cmd2` | or accepted synonym `cmd1 && cmd2`; avoid long chains |
| `cmd1 \|\| cmd2` | `cmd1; or cmd2` | same caveat |
| `if [ ... ]; then ... fi` | `if test ...; ... ; end` | no `then`/`fi` |
| `for i in "${arr[@]}"; do ... done` | `for i in $arr; ... end` | Fish lists don't need the `[@]` dance |
| `arr=(a b c)` | `set arr a b c` | Fish variables are always lists — no separate array declaration |
| `${arr[@]}` | `$arr` | unquoted list already expands to all elements |
| `${arr[0]}` | `$arr[1]` | Fish is 1-indexed |
| `${arr[-1]}` | `$arr[-1]` | negative indexing works the same way |
| `${arr[@]:1:3}` | `$arr[2..4]` | Fish slice syntax is 1-indexed and inclusive |
| `$(cmd)` | `(cmd)` (also `$(cmd)` works) | native form is parens; Fish splits on newlines, not `$IFS` |
| `` `cmd` `` | `(cmd)` | backticks don't exist in Fish |
| `<(cmd)` | `(cmd | psub)` | no native process substitution; `psub` builtin fakes it |
| `heredoc <<EOF ... EOF` | multi-line quoted string, or `begin...end > file`, or `printf` | no heredoc/here-string syntax |
| `set -e` (errexit) | *(no equivalent)* | must check `$status` / use `or return` explicitly after each risky command |
| `$?` | `$status` | last foreground job's exit code |
| `${PIPESTATUS[@]}` | `$pipestatus` | per-stage pipeline exit codes |
| `alias ll='ls -l'` | `function ll; ls -l $argv; end` (or `abbr -a` for interactive-only expansion) | Fish functions are the real scripting primitive |
| `trap 'cmd' SIGINT` | `function h --on-signal SIGINT; cmd; end` | event-handler function instead of `trap` |
| `type cmd` / `command -v cmd` | `type cmd` / `command -v cmd` | both exist in Fish too |
| `$IFS`-based `read -ra arr <<< "$str"` | `string split ...` or `set arr (string split sep $str)` | `string split` replaces `tr`/`IFS` splitting |
| `printf '%s\n' "$x"` | `printf '%s\n' $x` | printf itself is largely POSIX-compatible in Fish |
| `[[ $x =~ regex ]]` | `string match -r 'regex' -- $x` | regex matching via `string match -r`, with capture-group output |
| `$(( a > b ? a : b ))` | `math "max($a, $b)"` (or manual `if`) | `math` supports several functions; ternary itself doesn't exist — use `if`/`else` |
