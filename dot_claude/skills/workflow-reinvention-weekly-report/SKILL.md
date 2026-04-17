---
name: workflow-reinvention-weekly-report
description: "Draft and persist the weekly Workflow Reinvention status report for the U.S. Product Development Workflow. Use when Christian asks to prepare this week's update, draft the Friday report, generate the weekly workflow reinvention report, or similar. Gathers activity from Slack, basic-memory, Google Drive, Confluence, and Jira; drafts an 8-section report against the Playbook Tab 2 template; surfaces RAG / kill-criteria / next-week priorities for user judgment before persisting."
---

# /workflow-reinvention-weekly-report

Produce the weekly status report for the U.S. Product Development Workflow Reinvention sprint. Gather evidence, draft against the playbook template, surface the judgment calls generic templates get wrong, persist on approval.

## Context

- **Flow:** U.S. Product Development Workflow
- **Playbook template:** Tab `t.cfkmheyt2r9d` of Google Doc `1nBL7nsJHn8zs3gUJca1VicYI14SB709s9Ozx7Th4mU8` (8-section markdown)
- **Deadline:** Friday noon BRT, weekly
- **Basic-memory project:** `nubank`
- **Design spec:** `nubank/process/workflow-reinvention/workflow-reinvention-plans-design-spec`

## Anti-patterns

Do NOT do any of these:

- **Do not auto-fill RAG, kill criteria, or next-week priorities.** These are always the user's judgment call. A plausible guess locks in the wrong framing for the week.
- **Do not mirror external artifacts into basic-memory.** Confluence, Drive, Jira stay authoritative in their original tools. The skill orchestrates reads.
- **Do not auto-send Slack messages.** Always draft, show, confirm, then send.
- **Do not use plain `git`.** Christian uses jj colocated; invoke the `jujutsu:jujutsu` skill for commits.
- **Do not lecture.** The user is the domain expert. Surface playbook defaults + applicable variance; don't explain why the playbook is right.

## Flow

### Step 1: Load state (parallel reads)

Call `mcp__basic-memory__read_note` in parallel for:

- `nubank/process/workflow-reinvention/workflow-reinvention-state` — current phase, week, gates, next milestone
- `nubank/process/workflow-reinvention/workflow-reinvention-variance` — expert overrides (apply at relevant sections)
- `nubank/process/workflow-reinvention/workflow-reinvention-decisions` — accepted decisions

Also `mcp__basic-memory__list_directory` for `process/workflow-reinvention/weekly-reports/` and read the most recent report (if any) for continuity.

If `state.md` is missing, stop and ask Christian to initialize it before proceeding.

### Step 2: Gather in parallel (scope: last 7 days)

Single message, all calls in parallel:

**Slack** (`mcp__plugin_slack_slack__slack_read_channel`):
- `#us-workflow-reinvention` — `C0ATDGGT84A`
- `#us-market-ai-first` — `C0AJN6SLL0P`
- `#us-market-muon` — `C0AHQDN6R7B` (private channel; CTO-office engineers experimenting with AI-first workflows alongside the team)

Follow threads selectively — use `slack_read_thread` when the parent looks load-bearing (governance, decisions, kickoffs, hygiene observations with replies). Not every thread.

Skip noise: join/leave, bot noise, reaction-only events.

**Basic-memory** (`mcp__basic-memory__recent_activity`):
- project `nubank`, `timeframe="7d"`, `output_format="json"`. Filter to items touching `workflow-reinvention`.

**Google Drive** (`mcp__google-workspace__drive_search`):
- Folder `19FBU-8_NP-Cp5XoC-BlTFzcn63ECabPb`, files modified in last 7 days.

**Confluence** (`mcp__plugin_atlassian_atlassian__getConfluencePage`):
- pageId `264810299811`. Check `version.number` / `version.when` against prior week's report.

**Jira** (`mcp__plugin_atlassian_atlassian__searchJiraIssuesUsingJql`):
- JQL: `project = TROY AND (board = 28599 OR board = 30041) AND updated >= -7d ORDER BY updated DESC`
- Boards: 28599 (upstream) and 30041 (downstream) confirmed as of 2026-04-16. Add more when identified.

### Step 3: Classify gathered content

Sort into buckets:

| Bucket | Destination in report |
|---|---|
| New decisions made | §6 Decisions (+ append to `decisions.md`) |
| Risks surfaced | §6 Risks |
| Governance / global dependency items | §6 Risks → Global dependencies subsection (persistent, per V-003) |
| Experiments completed | §5 Outputs, §8 Learnings |
| Metric movements | §3 Metrics Snapshot |
| AI-first wins from team | §8 Learnings (and candidates for `#us-market-ai-first` summary) |
| Jira hygiene / upstream data | §6 Risks, §8 Signals, potentially D-NNN |

### Step 4: Draft the 8-section report

Filename: `us-product-development-week-YYYY-MM-DD.md` where the date is **Thursday of the reporting week** (sort-stability choice — not calendar accuracy).

**Required disclosure block** at top (per global disclosure rules):

```markdown
> **AI Disclosure**: Claude [model] co-authored this report with Christian Romney (direction and review).
> **Last Review**: Reviewed by Christian Romney on YYYY-Mon-DD.
> **[Version History](#version-history)**
```

**Template structure:**

1. **Metadata** — flow, sprint started, current phase, week #, report period, report date, owner, cadence
2. **Overall Status** — `RAG: [NEEDS YOUR JUDGMENT]` + proposed color with rationale; 1-2 paragraph narrative
3. **Metrics Snapshot** — persistent baseline block (from assessment) + "This week" block
4. **Phase Milestone Status** — gates passed / outstanding for current phase; `Earliest phase advance: [NEEDS YOUR JUDGMENT]`
5. **Outputs vs Playbook** — table of expected vs produced; reference variance IDs (V-NNN) for overrides
6. **Decisions / Risks / Kill Criteria**:
   - Decisions (this week): short form with reference to `decisions.md` full entries
   - Variance captured (V-NNN bullets)
   - Risks (always include **Global dependencies / governance** subsection per V-003 — scope `section:risks`)
   - Kill criteria
7. **Plan for Next Week** — `[NEEDS YOUR JUDGMENT — top 1-3]` with 3-4 candidate options (A/B/C/D) drawn from gathered signals
8. **Learnings & Signals** — AI-first wins (with team attribution), process learnings, gaps to resolve, `[NEEDS YOUR JUDGMENT]` on signals to promote

**Version History table** at bottom:

```markdown
## Version History
| Date | Description | Changes | Review |
|------|-------------|---------|--------|
| YYYY-Mon-DD | Initial Week N report | +~N lines | Reviewed by Christian Romney on YYYY-Mon-DD |
```

### Step 5: Present draft with judgment callouts

Present the full draft. Then explicitly ask Christian to fill:

1. **RAG** (🟢 / 🟡 / 🔴) + one-line rationale
2. **Earliest phase advance date** (§4)
3. **Kill criteria** — accept, adjust, or replace
4. **Next week top 1-3** — pick from candidates (A/B/C/D) or propose others
5. **Signals to act on** (§8) — which team AI-first wins to promote to experiments
6. Any **narrative edits**

Wait for his fills. Do not guess.

### Step 6: Persist atomically on approval

Integrate Christian's judgment calls into the draft. Then in parallel:

1. **Write final report**:
   ```
   mcp__basic-memory__write_note
     project: nubank
     title: us-product-development-week-YYYY-MM-DD
     directory: process/workflow-reinvention/weekly-reports
     tags: ["workflow-reinvention", "weekly-report", "week-N", "<phase-slug>"]
     content: <full report>
   ```
   (Basic-memory slugifies the title — `us-product-development-week-YYYY-MM-DD` produces `us-product-development-week-YYYY-MM-DD.md` exactly. Do not use descriptive titles.)

2. **Append new decisions** to `decisions.md`:
   ```
   mcp__basic-memory__edit_note
     identifier: nubank/process/workflow-reinvention/workflow-reinvention-decisions
     operation: append
     content: <D-NNN block(s)>
   ```
   Auto-increment D-NNN based on last ID in the file.

3. **Append new variance entries** (if any captured this week) to `variance.md` via `edit_note` append.

4. **Update `state.md`** via `write_note` with `overwrite=true`:
   - `Current week #`
   - `Gates passed` (add this week's published report)
   - `Gates outstanding`
   - `Open decisions`
   - `Next milestone`

### Step 7: Commit via jujutsu skill

Invoke `Skill: jujutsu:jujutsu` with a scoped commit covering only the four affected files:

- `content/basic-memory/nubank/process/workflow-reinvention/weekly-reports/us-product-development-week-YYYY-MM-DD.md`
- `content/basic-memory/nubank/process/workflow-reinvention/workflow-reinvention-decisions.md`
- `content/basic-memory/nubank/process/workflow-reinvention/workflow-reinvention-variance.md` (if modified)
- `content/basic-memory/nubank/process/workflow-reinvention/workflow-reinvention-state.md`

Commit message format: `Workflow Reinvention: Week N report`. Never use plain `git`.

### Step 8: Drive upload (manual handoff)

The Google Workspace MCP cannot upload arbitrary `.md` files (`docs_create` creates Google Docs, not markdown). Give Christian the local path:

```markdown
[Open folder in Finder](file:///Users/christian.romney/Documents/personal/notes/content/basic-memory/nubank/process/workflow-reinvention/weekly-reports/)

File to upload: us-product-development-week-YYYY-MM-DD.md
```

Target Drive path: `Workflow Reinvention / Weekly Reporting Routine / U.S. Product Development Workflow /`.

### Step 9: Offer Slack summary

Draft two compact summaries (~100-150 words each), **no `@mentions`** (Christian will add them if desired):

- **For `#us-workflow-reinvention` (C0ATDGGT84A)** — coordination framing; key decision + next-week focus + phase target
- **For `#us-market-ai-first` (C0AJN6SLL0P)** — reporting framing; ties team AI-first wins to this phase's direction

Present both drafts. Ask Christian which (if either) to send.

**Required footer** on any message sent:

```
_AI Disclosure: Claude [model] drafted this message with Christian Romney (direction & review)_
*Sent using* <@U0AJJ37DCKX|Claude>
```

Send via `mcp__plugin_slack_slack__slack_send_message`. Return the `message_link` to Christian.

## Variance application

At every section that has relevant variance scope, show the override inline with its ID:

- `sprint` scope → always apply
- `phase:N` → apply if current phase matches N
- `activity:<slug>` → apply when executing named activity
- `section:<name>` → apply when drafting named section (e.g., `V-003 section:risks` requires Global dependencies subsection every week)

Example: when drafting §6 Risks, always include a subsection labelled "Global dependencies / governance (persistent — per V-003)" even if no new governance items arose this week; reference the persistent constraint.

## Known gotchas

- **Private channels may not appear in `slack_search_channels`** results. Channel IDs for known private channels are listed inline in Step 2. Ask Christian directly if a new private channel needs to be added to gathering.
- **Basic-memory slugifies titles** into filenames. For weekly reports, title = `us-product-development-week-YYYY-MM-DD`, not descriptive.
- **Google Drive `.md` upload is manual.** Skill provides the local path; Christian uploads.
- **Thursday-of-week dating.** For a report drafted Friday or over the weekend, use the Thursday immediately prior as the filename date.
- **Jira board list may be incomplete.** 28599 and 30041 are confirmed. If gathering misses obvious activity, ask Christian for additional board IDs.

## Failure modes

- **One MCP source fails after one retry:** proceed with what's available; note the missing source in §8 Gaps to resolve. Don't block the report.
- **No weekly-reports directory yet:** basic-memory creates on first write.
- **First-time run, no prior decisions/variance:** seed from the design spec's initial entries (V-001, V-002, V-003).
- **User wants to skip a section entirely:** record as variance (e.g., `section:metrics-snapshot`, "Playbook says include; we skip because…") and apply going forward.

## Related files

- **Design spec:** `nubank/process/workflow-reinvention/workflow-reinvention-plans-design-spec` — defines the architecture; read if anything in this skill is ambiguous.
- **Resources reference:** `nubank/reference/workflow-reinvention-resources` — canonical URLs and IDs for all external artifacts.
