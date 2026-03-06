---
name: sync:notes
description: Sync personal notes repository to GitHub using jujutsu
user_invocable: true
---

# Sync Personal Notes to GitHub

Syncing the personal notes repository to GitHub using jujutsu (jj).

## Steps

### 1. Change to Notes Repository

Navigate to the personal notes directory:

```bash
cd $HOME/Documents/personal/notes
```

If the directory doesn't exist, inform the user and stop.

### 2. Fetch Remote Changes

Always fetch latest changes from GitHub:

```bash
jj git fetch
```

This updates the view of remote branches without modifying local work.

### 3. Check Working Copy Status

Check for local changes:

```bash
jj status
```

### 4. Handle Changes

#### If Working Copy Has Changes:

**a) Summarize Changes**

Run these commands to understand the changes:
```bash
jj diff --stat
jj status
```

**b) Analyze and Generate Description**

Review the output and generate an appropriate commit message.

- Include bulleted details for multi-part changes
- Be specific about what changed (e.g., "Update journal entries for October")

**c) Present Description for Approval**

**IMPORTANT**: Do not automatically apply the description. Instead:

1. Show the user your proposed description
2. Explain what changes you found
3. Ask if they want to use this description or modify it
4. Wait for user confirmation before proceeding

**d) Apply Description**

Once approved, apply the description using a heredoc for proper formatting:

```bash
jj describe -m "$(cat <<'EOF'
<approved description here>
EOF
)"
```

**e) Check if Rebase is Needed**

Check whether the remote has new commits that our working copy is not based on:

```bash
jj log -r '@..main@origin'
```

If this is non-empty, remote has moved ahead and we need to rebase. If empty,
we can push directly.

**f) Rebase if Needed**

If remote has new commits, rebase onto the remote main:

```bash
jj rebase -d main@origin
```

Without `-r` or `-b`, this rebases the entire branch (equivalent to `-b @`),
moving all local commits on top of the updated remote.

Note: Jujutsu handles conflicts gracefully. If conflicts occur, they're tracked
in the working copy and can be resolved in a subsequent change. The world
doesn't stop.

**g) Update Bookmark**

Move the main bookmark to the current change:

```bash
jj bookmark set main -r @
```

**h) Push to GitHub**

Push the changes explicitly by bookmark name:

```bash
jj git push --bookmark main
```

After pushing, jujutsu will automatically create a new empty working copy
commit on top.

**i) Report Success**

Inform the user what was synced and show the final status:

```bash
jj log --limit 3
```

#### If Working Copy Has No Changes:

**a) Check for committed-but-unpushed changes**

Check whether the working copy parent (`@-`) is ahead of `main`:

```bash
jj log -r 'main..@-'
```

- **If non-empty** (commits exist between `main` and `@-`): push those commits.

  1. Check if remote has moved ahead:
     ```bash
     jj log -r '@-..main@origin'
     ```
  2. If remote is ahead, rebase:
     ```bash
     jj rebase -d main@origin
     ```
  3. Move `main` bookmark to working copy parent:
     ```bash
     jj bookmark set main -r @-
     ```
  4. Push:
     ```bash
     jj git push --bookmark main
     ```
  5. Report success with `jj log --limit 3`

- **If empty** (no committed-but-unpushed changes): check whether the remote
  moved ahead of the local bookmark:

  ```bash
  jj log -r 'main@origin..main'
  ```

  - **If non-empty** (remote moved): update the local bookmark to match remote,
    then inform the user:
    ```bash
    jj bookmark set main -r main@origin
    ```
    Report that the local bookmark was fast-forwarded to match remote.

  - **If empty** (fully up to date): inform the user:
    - Repository is already synced
    - Remote was fetched (up to date)
    - No local changes to push

### 5. Error Handling

Handle these scenarios gracefully:

- **Directory not found**: Inform user the notes directory doesn't exist at `$HOME/Documents/personal/notes`
- **Push fails**: Show the error and suggest checking:
  - Remote is accessible
  - SSH keys are configured
  - Network connection is working
- **No remote configured**: Inform user to set up the origin remote

## Important Notes

- Use `$HOME` environment variable for portability across different machines
- Always present descriptions for user approval before applying
- When working copy is clean, check `main..@-` first — committed-but-unpushed
  changes live between `main` and `@-`, not in the working copy
- Rebase is triggered when `@..main@origin` (has changes) or `@-..main@origin`
  (no working copy changes) is non-empty (remote ahead of us)
- Jujutsu's conflict model means conflicts don't stop the workflow
- After push, a new empty working copy is automatically created
- The command works from any directory (changes to notes dir first)

## Example Output

When successful, provide clear feedback like:

```
✓ Changed to notes repository
✓ Fetched remote changes
✓ Found changes in working copy
✓ Generated description (presented for approval)
✓ Applied description
✓ Rebased onto main@origin
✓ Moved bookmark to current change
✓ Pushed to GitHub

Synced commit: 07cea23a "Add project documentation and sync recent notes"
```
