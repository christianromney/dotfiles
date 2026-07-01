# Pull Request Scope and Size

Default to small, single-purpose PRs. A reviewer should be able to understand
and approve a PR in one sitting. Large PRs hide bugs, delay review, and erode
review quality — keeping them small is a hard requirement, not a preference.

## Plan the split before writing code
- For any non-trivial task, first decompose the work into the smallest
  independently reviewable PRs and present that plan. State the dependency
  order and whether the PRs are **stacked** (each builds on the previous) or
  **independent** (each lands on main on its own). Recommend whichever fits the
  task and explain why.
- Wait for confirmation of the breakdown before implementing, unless the change
  is trivially small.

## One concern per PR
- Each PR makes one logical change: a single feature slice, a single fix, or a
  single refactor — not a mix.
- Never combine refactoring with behavior changes. Land mechanical changes
  (renames, moves, formatting, dependency bumps, generated code) as their own
  PRs so the behavior-changing diff stays small and easy to read.
- Pull out prerequisite groundwork (new helpers, scaffolding, interface
  changes) into earlier PRs rather than bundling it with the change that uses it.

## Size budget
- Treat **~400 lines changed** as the point to stop and split. Past that,
  review effectiveness drops sharply. Generated files, lockfiles, and
  vendored code don't count toward the budget.
- Line count is a trigger, not a target: a 60-line PR that mixes two concerns
  should still be split. Split on logical boundaries first; size is the backstop.
- If a change genuinely cannot be split below the budget, say so explicitly and
  explain why before proceeding.

## Work in reviewable increments
- Commit at logical checkpoints rather than accumulating one giant diff.
- When a session's work has grown large, stop and propose carving it into a
  series of PRs rather than opening one sprawling PR.
- Write a PR description that states the single purpose and what was
  deliberately left out of scope (and which follow-up PR will cover it).
