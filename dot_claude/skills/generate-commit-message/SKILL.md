---
name: generate:commit-message
description: Generate a commit message for a version control system.
user_invocable: true
---
# Generate Commit Message

Understand the proposed changes by using the version control tool's commands for
viewing the pending commit. This is usually a combination of status or diff
commands.

Generate the message using the guidelines below.

## Content
Make sure you explain your solution and *why* you're doing what you're doing, as opposed to describing *what* you're doing. Reviewers and your future self can read the patch, but might not understand why a particular solution was implemented. 

Focus on the semantics, not the mechanics.

## Format

### What To Do
A good commit message looks like this:

    Header line explaining the commit in one line (use the imperative)

    Body of commit message is a few lines of text, explaining things
    in more detail, possibly giving some background about the issue
    being fixed, etc.

    The body of the commit message can be several paragraphs, and
    please do proper word-wrap and keep columns shorter than about
    74 characters or so. That way "git log" will show things
    nicely even when it's indented.

    Reported-by: {whoever-reported-it}
    Signed-off-by: Your Name <youremail@yourhost.com>

where that header line really should be meaningful, and really should be
just one line.  That header line is what is shown by tools like `gitk` and
`shortlog`, and should summarize the change in one readable line of text,
independently of the longer explanation. Please use verbs in the
imperative in the commit message, as in "Fix bug that...", "Add
file/feature ...", or "Make component..."

### What NOT To Do

- **NEVER** add a prefix like 'docs: <message>' or 'feat: <message>'
- **NEVER** include emojis in commit messages
