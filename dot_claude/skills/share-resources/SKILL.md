---
name: share-resources
description: Sync selected Claude skills, agents, and reference files to the US market team repo.
user_invocable: true
---
# Share Resources

Sync selected personal Claude resources to the team repository for colleagues
to adopt. Only resources listed in the manifest are shared.

## Files

- **Manifest**: `~/.claude/share-manifest.txt` — lists resources to share, one
  per line (relative to `~/.claude/`). Lines starting with `#` and blank lines
  are ignored.
- **Team repo target**: `~/dev/nu/us-market-ai-resources/resources/christian.romney/`

## Steps

1. **Read the manifest** at `~/.claude/share-manifest.txt`. Parse it into a list
   of source paths (relative to `~/.claude/`).

2. **Preview changes.** For each manifest entry, compare the source
   (`~/.claude/<entry>`) against the target
   (`~/dev/nu/us-market-ai-resources/resources/christian.romney/<entry>`).
   Classify each as: `new`, `modified`, or `unchanged`. Also identify any
   files/directories in the target that are NOT in the manifest — these are
   candidates for removal.

3. **Show the user a summary table:**

   | Resource | Status |
   |----------|--------|
   | skills/generate-diagram | modified |
   | skills/socratic-partner | unchanged |
   | agents/web-quality-tester | not in manifest (remove?) |
   | ... | ... |

4. **Ask for confirmation** before making changes. If there are items in the
   target not in the manifest, ask whether to remove them.

5. **Sync.** For each manifest entry:
   - If the entry is a directory: `rsync -a --delete` from source to target
   - If the entry is a file: `cp` from source to target
   Create parent directories in the target as needed.

6. **Remove** any target items the user confirmed for deletion.

7. **Show the result.** Run `git -C ~/dev/nu/us-market-ai-resources status`
   to show what changed. Ask the user if they want to commit and push.

8. **If the user confirms**, commit with a descriptive message and push.

## Important

- Never copy personal-only resources (sync-dotfiles, sync-notes, chezmoi,
  jujutsu, find-skills, basic-memory) unless they are explicitly in the manifest.
- The manifest is the single source of truth for what gets shared.
- Always preview before syncing. Never auto-commit.
