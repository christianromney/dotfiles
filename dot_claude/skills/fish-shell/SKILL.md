---
name: fish-shell
description: Write, review, or debug Fish shell scripts and functions correctly on the first try. Use this whenever writing or editing a .fish file, a function under ~/.config/fish/functions/, a script with a #!/usr/bin/env fish shebang, or any personal script under ~/bin/ (which default to Fish per this user's conventions) — even if the user just says "write a script" without naming the shell. Also use when a Fish script is failing, behaving unexpectedly, or when translating a bash/zsh snippet to Fish, since Fish's syntax looks similar to POSIX shell but silently diverges in ways that produce scripts which parse fine but do the wrong thing (variable assignment, list/array semantics, conditionals, arithmetic, string manipulation). Do not reach for plain bash/POSIX idioms in a Fish context without consulting this skill first.
---

# Fish Shell Scripting

Fish (the "friendly interactive shell") looks close enough to bash that it's easy to write something that *parses* but is subtly wrong — silent bugs, not syntax errors. This skill exists so that never happens again: the reference material here was built after a real incident where bash-shaped assumptions about shell scripting broke a script in a way that wasn't caught until data was already lost.

## Before writing or editing any Fish code

Read the relevant reference file below rather than relying on bash intuition or general training knowledge. Fish's design choices (all variables are lists, no `[[ ]]`, no `$(( ))`, no `then`/`fi`, 1-indexed arrays, no errexit) are consistent and learnable, but they are *not* what bash muscle memory expects, and guessing produces exactly the kind of silent, hard-to-catch bug this skill is meant to prevent.

- **`references/language-reference.md`** — core syntax: variables and scoping, quoting, conditionals (`if`/`test`/`and`/`or`), loops, functions, redirection, job control, `$status`/`$pipestatus`, globbing, event handlers, and a full bash→fish translation table. Read this for anything about how a script is *structured*.
- **`references/command-reference.md`** — the builtin commands that replace bash/coreutils idioms: `set`, `string` (replaces `sed`/`${var//x/y}`/`${#var}`), `math` (replaces `$(( ))`), `argparse` (replaces `getopts`), `count`, `contains`, `test`, `read`, `path`, `status`, and more, each with flags and examples. Read this for anything about *which command does X*.

Both files are long and organized with a table of contents — jump to the relevant section rather than reading start to finish, unless writing a nontrivial script from scratch, in which case skim the whole language reference first.

## Quick gotcha checklist (the 10 things that bite bash users first)

1. **No bare assignment.** `x=1` is a command name in Fish, not an assignment. Use `set x 1`.
2. **All variables are lists**, always — a "scalar" is just a 1-element list. `set foo a b c` makes a 3-element list; `$foo[1]` is the first element. **Indices start at 1, not 0.**
3. **No `[[ ]]`.** Use `test` (or `[`) for every condition, and quote variables passed to it: `test -n "$x"`.
4. **No `&&`/`||` as the idiomatic form** (they're accepted as synonyms, but long chains behave differently from bash — each `and`/`or` looks only at the *immediately preceding* command's status, not the original condition). Prefer `if`/`else` for anything beyond one `and`/`or` pair.
5. **No `then`/`fi`/`do`/`done`.** Every block (`if`, `for`, `while`, `function`, `switch`, `begin`) closes with a single `end`.
6. **No `$(( ))` arithmetic.** Use `math`, e.g. `set x (math $x + 1)`.
7. **No `set -e` errexit.** In Fish, `set -e NAME` *erases a variable* — it does not mean "abort on error." Fish never aborts automatically; check `$status` and use `or return`/`or exit` explicitly after anything that can fail.
8. **No heredocs.** Use a multi-line quoted string, a `begin...end > file` block, or `printf '%s\n'`.
9. **Command substitution is `(cmd)`**, not `` `cmd` ``, and splits on newlines (not `$IFS`) — so a command's multi-line output becomes a Fish list, one element per line, not a word-split mess.
10. **`string`/`math`/`count`/`contains`/`argparse` replace nearly everything bash farms out to `sed`/`awk`/`${...}` parameter expansion/`getopts`.** If reaching for a `sed` one-liner or `${var//x/y}`-style expansion, check `command-reference.md` first — there's almost certainly a `string` subcommand for it.

## Writing new scripts

Prefer Fish idioms over bash-then-translate — write directly in terms of `set`, `test`, `string`, `math`, `argparse`, and `and`/`or`/`not`, rather than drafting bash and mentally converting line by line. Translating line-by-line is exactly how the subtle bugs in the gotcha list above slip through, since a line can translate "successfully" into something that parses but means something different.

For personal utility scripts under `~/bin/`, use the `#!/usr/bin/env fish` shebang per this user's established convention; write portable POSIX `.sh` only when a script is explicitly meant to be shared or run in CI, per the user's own stated distinction between the two.
