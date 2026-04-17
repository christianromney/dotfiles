---
name: workflow-reinvention-sprint
description: "Run the Workflow Reinvention Playbook for the U.S. Product Development Workflow — status summary, phase transitions with gate checks, activity execution, and decision/variance recording. Use when Christian asks about workflow reinvention sprint status, wants to advance a phase, record a decision or variance, check what's required to advance, or execute a specific phase activity. Embeds Week 0 → Phase 5 playbook checklists; reads state/decisions/variance from basic-memory."
---

# /workflow-reinvention-sprint

On-demand sprint runner for the U.S. Product Development Workflow Reinvention. Reports status, proposes phase transitions when gates pass, walks through required activities, captures decisions, and records deliberate deviations from the generic playbook.

## Context

- **Flow:** U.S. Product Development Workflow
- **Playbook:** Google Doc `1nBL7nsJHn8zs3gUJca1VicYI14SB709s9Ozx7Th4mU8`, Tab `t.0`
- **Sibling skill:** `workflow-reinvention-weekly-report` — for weekly reporting ceremony
- **Design spec:** `nubank/process/workflow-reinvention/workflow-reinvention-plans-design-spec`

## The non-negotiables (playbook §1)

These override local preference. If Christian wants to break one, capture as a variance entry with strong reasoning:

1. **Sequence:** Eliminate → Simplify → Redesign → Pilot → Decide. Skipping Phase 1 is the #1 failure mode.
2. **Measure end-to-end, not step-by-step.** A faster step that doesn't reduce total cycle time is worthless.
3. **Eliminate waste before automating.**
4. **Kill criteria before pilot, not after.**

## Anti-patterns

- **Do not advance a phase without an explicit gate check.** Mechanical (outputs present) AND narrative (intent satisfied).
- **Do not lecture.** The user is the domain expert — surface playbook defaults + applicable variance, don't explain why the playbook is right.
- **Do not assign work or chase people.** The skill is a status + ceremony runner, not a PM.
- **Do not mirror the playbook doc.** Checklists embedded below are the skill's authoritative phase definitions; upstream playbook changes require a deliberate manual sync (edit this file), not an auto-pull.
- **Do not use plain `git`.** Christian uses jj colocated; invoke the `jujutsu:jujutsu` skill for commits.

## Flow

### Step 1: Load state (parallel reads)

`mcp__basic-memory__read_note` in parallel for:

- `nubank/process/workflow-reinvention/workflow-reinvention-state` — current phase, week, gates, next milestone
- `nubank/process/workflow-reinvention/workflow-reinvention-variance` — expert overrides
- `nubank/process/workflow-reinvention/workflow-reinvention-decisions` — accepted decisions

### Step 2: Present current status

One paragraph summary:

- Current phase (name + number) and week
- Gates passed / outstanding for this phase (from state.md)
- Open decisions awaiting resolution (from decisions.md where status is not "Accepted" or "Rejected")
- Applicable variance for current phase (from variance.md — entries with scope `sprint` or `phase:N`)
- Next milestone (date + description)

### Step 3: Offer the contextual menu

Ask Christian what he wants to do. Menu options (pick 1 or just chat):

| Option | What happens |
|---|---|
| **Advance phase** | Run gate check for current phase (§ Gate checks). If all pass, propose transition and update state.md. If not, list what's missing. |
| **Execute activity** | Pick a required activity from current phase checklist (§ Phase checklists). Walk through it, surface variance, help produce the output. |
| **Record decision** | Capture an ADR-style entry into decisions.md (§ Recording decisions). |
| **Record variance** | Capture a deliberate deviation from the playbook into variance.md (§ Recording variance). |
| **Just status** | No further action — the summary in Step 2 is the answer. |

Do not assume intent. If Christian's request is ambiguous, ask.

---

## Gate checks

Two-part check. Both must pass to advance a phase.

### Mechanical (outputs present)

Check that the required outputs listed in the current phase checklist exist:

- Basic-memory: `mcp__basic-memory__search` or `list_directory` for expected notes.
- Google Drive: `drive_search` in the Workflow Reinvention folder for expected deliverables.
- Confluence: `getConfluencePage` for updated VSM or phase artifacts.
- Jira: `searchJiraIssuesUsingJql` for expected tickets.

List each expected output and its status: ✅ found at `<path>`, ❌ missing, or ⚠️ partial.

### Narrative (intent satisfied)

Present what was produced in plain language and ask Christian:

> "The playbook's intent for this phase is [intent]. The outputs above attempt to satisfy that. In your judgment, does the actual content match the intent, or is there a gap the checklist doesn't catch?"

This is **Christian's call**, not the skill's. The skill never declares a gate "passed" without his explicit confirmation.

### On pass → propose transition

If both checks pass:

1. Update state.md via `write_note` with `overwrite=true`:
   - `Current phase` → N+1 (or "Phase 1" if transitioning from Phase 0)
   - `Phase started` → today's date
   - `Gates passed` → reset for new phase or append achievements
   - `Gates outstanding` → from new phase checklist
   - `Next milestone` → first milestone of new phase

2. Record the transition as a decision in decisions.md (e.g., `D-NNN · Advance to Phase 1 · YYYY-MM-DD · Phase 0`).

3. Commit via `jujutsu:jujutsu` skill, commit message: `Workflow Reinvention: advance to Phase N`.

### On fail → list gaps, don't pressure

Summarize what's missing. Offer to help produce the missing output via "Execute activity." Never suggest advancing anyway.

---

## Phase checklists

Embedded below per playbook §2–7 (as of 2026-04-16). Each checklist has 🔴 required items and 🔵 optional items. Gate requirements are per playbook §9.

### Week 0 — Pre-Sprint Setup

**Required (🔴):**
- [ ] Name one DRI (not a committee) who owns day-to-day execution
- [ ] Form team of 3–5 people, including ≥1 practitioner who does this workflow today
- [ ] Confirm AI expert with ≥2 days/week allocated
- [ ] Validate as-is workflow map with 2–3 practitioners (not just managers)
- [ ] Pull baseline metrics from system data (time per instance × frequency × people)
- [ ] Identify a control group (comparable team keeping current workflow during pilot)
- [ ] Executive sponsorship confirmed

**Optional (🔵):**
- [ ] System inventory (tools/platforms + API availability)
- [ ] Platform readiness assessment (integrations: exists vs. build)
- [ ] Weekly 30-min retro with transformation coordinator scheduled

**Gate to Phase 1:** DRI named, team formed, baseline metrics pulled, control group identified.

**Known variance for this flow:**
- V-001 `phase:0` — team assembly replaced by `#us-workflow-reinvention` channel launch
- V-002 `activity:set-baselines` — baselines from existing cycle time data + anecdata rather than survey

### Phase 1 — Eliminate & Simplify (Weeks 1–2)

**Goal:** Cut at least 20% of steps before touching AI.

**Required (🔴):**
- [ ] Audit every step with "Why does this step exist?"
- [ ] Classify each step: **KEEP** (value/legal), **ELIMINATE** (habit/legacy), **MERGE** (combinable), **AUTOMATE** (system gap)
- [ ] Target: ≥20% of steps eliminated or merged
- [ ] Map handoffs — quantify wait time at each transition point
- [ ] Answer the five Phase 1 questions:
  1. Which 1–3 outcome dimensions are you optimizing? (Throughput / Quality / CX)
  2. Which steps are pure waste to eliminate?
  3. Where is the biggest wait time — and can an agent eliminate it?
  4. What is the riskiest step to automate, and what's the fallback?
  5. What does the manager/lead role look like after transformation?

**Required outputs:**
- Annotated workflow map (every step tagged KEEP/ELIMINATE/MERGE/AUTOMATE)
- Wait time breakdown (active vs. waiting-blocked vs. waiting-queued)
- Step reduction estimate showing ≥20% fewer human steps

**Optional (🔵):**
- [ ] "Start from scratch" 2-hour north-star sketch session
- [ ] Full 5 Whys on every step (vs. quick judgment)

**Do not proceed if:** team can't agree on which steps to eliminate → escalate to sponsor.

**Gate to Phase 2:** ≥20% step reduction, wait time quantified, team agrees on direction.

### Phase 2 — AI-Native Redesign (Weeks 3–4)

**Goal:** Assign every step an actor type; design the handoffs.

**Required (🔴):**
- [ ] Write outcome in one sentence (end result, not steps or tools)
- [ ] Assign every step an actor type:
  - **Autonomous Agent** — reversible, structured data, low error risk
  - **Agent + Human Review (HITL)** — significant consequences, regulatory, unproven accuracy
  - **Human + Agent Assist (Copilot)** — judgment, creativity, high stakes
  - **Human Only** — leadership presence, ethical judgment, relationship-dependent
- [ ] Apply the 3am-Saturday diagnostic for each step: *"Would I be comfortable if the agent did this at 3am Saturday with no one watching?"*
- [ ] Specify every AI↔Human handoff: trigger in, what info transfers, what human decides, trigger out, fallback if human unavailable, timeout

**Required outputs:**
- Redesigned workflow map with actor types on every step
- Handoff specification for every AI↔human boundary
- Platform gap list (P0 blocks pilot, P1 enhances, P2 needed at scale)

**Optional (🔵):**
- [ ] AI pattern selection (Prompt Chaining / Routing / Parallelization / Orchestrator-Workers / Evaluator-Optimizer)
- [ ] Orchestration design (lifecycle, state, exceptions)
- [ ] Per-step risk assessment

**Do not proceed if:** >40% of redesigned workflow depends on integrations that can't be built in 2 weeks → reduce scope.

**Gate to Phase 3:** Actor types assigned, handoffs specified, platform gaps honestly assessed.

### Phase 3 — Prototype & Pilot (Weeks 5–6)

**Goal:** Smallest thing that tests the core hypothesis. Measure against control group.

**Required (🔴):**
- [ ] Define MVP scope — one or both hypothesis sentences:
  - "We believe [specific AI capability] will [improve metric] by [estimated amount]."
  - "We believe [eliminating/merging specific steps] will [improve metric] by [estimated amount], independent of AI."
- [ ] MVP tests hypothesis using **2–3 redesigned steps only**. Everything else stays manual.
- [ ] Select pilot team — willing volunteers, sufficient volume:
  - High freq (daily/weekly): ≥10 instances, ~2 weeks
  - Medium freq (monthly): 5–7 instances, 4–6 weeks
  - Low freq (quarterly): 3–5 instances, extend or add teams
- [ ] Run parallel operation: pilot team on new workflow, control team unchanged, same metrics from same sources
- [ ] Track weekly: primary outcome metric, AI accuracy (% not overridden), escape hatch rate (% fell back to manual)
- [ ] Maintain a friction log: one timestamped line per entry when AI helps/hinders/confuses

**Required outputs:**
- 2 weeks of pilot-vs-control data (or enough for ≥10 instances)
- Friction log entries
- Issues list: bugs, trust gaps, failure modes

**If logs don't exist** — three rules for manual logging:
1. Record at the time, not retrospectively.
2. Both pilot and control log the same way.
3. Flag manual-log origin in the Phase 4 report; weaker than system-derived.

**Optional (🔵):**
- [ ] Weekly 1-min survey ("How much did AI help this week?" 1–5 + two open-text)
- [ ] Formal escape hatch documentation protocol

**Gate to Phase 4:** ≥10 workflow instances measured, pilot vs. control data in hand.

**Never make Phase 4 decision on fewer than 10 instances.**

### Phase 4 — Iterate or Kill (Weeks 7–8)

**Goal:** Make an honest decision. Scale, iterate, or stop.

**Required (🔴):**
- [ ] Check kill criteria (set these **before pilot**, not after):

| ID | Criteria | Threshold | Action if triggered |
|---|---|---|---|
| K1 | Primary metric got worse | Any degradation vs. control | Stop. Diagnose. |
| K2 | Team trust critically low | Survey avg <2.5/5 for 2 weeks | Stop. Redesign implementation. |
| K3 | AI accuracy too low | >50% of agent actions overridden | Stop. AI creating work. |
| K4 | Escape hatch rate too high | >30% instances fell back to manual | Stop. Not production-ready. |
| K5 | New bottleneck created | Significant rework of AI outputs | Stop. Redesign affected steps. |

- [ ] Scale / Iterate / Pivot decision:
  - **Scale:** primary metric ≥target AND trust ≥3.5/5 AND AI accuracy ≥75%
  - **Iterate:** metric improved but below target, OR trust 2.5–3.5, OR accuracy 50–75%
  - **Pivot:** primary improved but different metric significantly worse
- [ ] Write 1-page case study: what we tried / what happened / what surprised us / what we'd do differently / what's replicable

**Required outputs:**
- Metrics comparison table (pilot vs. control)
- Explicit decision: Scale / Iterate (with specific changes) / Kill (with diagnosis)
- Case study
- Rollout plan (if scaling)

**Optional (🔵):**
- [ ] Statistical significance testing (usually unnecessary at 2-week pilots)
- [ ] Detailed pattern doc for central team's library

**Gate to Phase 5:** Kill criteria checked, explicit decision made, case study written.

### Phase 5 — Monitor & Evolve (Ongoing after Scale)

**Required (🔴):**
- [ ] Re-identify the bottleneck after AI breaks the prior constraint. Constraint moves; find the new one.
- [ ] If end-to-end metrics plateau ≥4 consecutive weeks → re-enter at Phase 1.

**Optional (🔵):**
- [ ] Quarterly audit: which approval processes / metrics / team structures were designed for the old workflow and are now obsolete?
- [ ] Function-level observation: document any accountabilities that shifted between teams.

---

## Common failure modes (playbook §8 — surface if Christian is sliding toward one)

| Failure | What it looks like | Prevention cue |
|---|---|---|
| Paving cow paths | Automating a broken process | Phase 1 must cut ≥20% first |
| AI generating work for humans | Long docs humans must review | Ask: "Does this output go to a human to read, or a system to act on?" |
| Perpetual pilot | "Needs more iteration" indefinitely | Hard 8-week timebox + kill criteria pre-set |
| Measurement theater | Metrics look great, nothing improved | System-derived metrics only; control groups; no surveys as primary data |
| Middle manager resistance | Adoption stalls despite exec support | Involve managers in Phase 2 design; role changes explicit before pilot |

---

## Recording decisions

When Christian picks "Record decision" or when a decision emerges from another activity:

```
mcp__basic-memory__edit_note
  identifier: nubank/process/workflow-reinvention/workflow-reinvention-decisions
  operation: append
  content: |

    ## D-NNN · [Title] · YYYY-MM-DD · Phase N
    **Context:** …
    **Decision:** …
    **Consequences:** …
    **Status:** Accepted | Superseded by D-0XX | Rejected
```

Auto-increment D-NNN from last entry in the file. Confirm all four fields with Christian before writing — a decision with a fuzzy context or vague consequences isn't worth recording.

## Recording variance

When Christian picks "Record variance" or when deliberately deviating from the playbook:

```
mcp__basic-memory__edit_note
  identifier: nubank/process/workflow-reinvention/workflow-reinvention-variance
  operation: append
  content: |

    ## V-NNN · [Activity or section] · YYYY-MM-DD · Phase N
    **Playbook says:** …
    **We're doing instead:** …
    **Why:** …
    **Scope:** phase:N | activity:<slug> | section:<name> | sprint
```

Rule: **only record variance that reoccurs or is material.** One-off tweaks, wording changes, stylistic preferences don't go in variance. Ask "will this deviation matter next time, or only this time?" If only this time → skip the variance entry.

## Commit discipline

After any state/decisions/variance update, invoke `Skill: jujutsu:jujutsu` with a scoped commit covering only the affected basic-memory files. Commit message format:

- Phase advance: `Workflow Reinvention: advance to Phase N`
- Decision: `Workflow Reinvention: D-NNN — <short title>`
- Variance: `Workflow Reinvention: V-NNN — <short title>`
- Multiple in one session: `Workflow Reinvention: phase 0 wrap (N decisions, M variance)`

## Known gotchas

- **Phase transitions are load-bearing.** State.md is the one mutable pointer; get it wrong and the weekly-report skill will produce a wrong report. Double-check the phase number and gate list after every transition.
- **Playbook upstream updates don't auto-sync.** When the playbook Google Doc changes, this skill doesn't know. Tell Christian to flag playbook changes; edit this file accordingly.
- **Week 0 has extensive existing variance** (V-001, V-002, V-003). Respect those before presenting default checklist items.
- **Jira board list may grow.** 28599 (upstream) and 30041 (downstream) confirmed as of 2026-04-16. When new boards are identified, update the weekly-report skill's JQL and this skill's gate-check helpers.

## Related files

- **Weekly report skill:** `~/.claude/skills/workflow-reinvention-weekly-report/SKILL.md` — sibling skill for weekly reporting
- **Design spec:** `nubank/process/workflow-reinvention/workflow-reinvention-plans-design-spec`
- **Resources reference:** `nubank/process/workflow-reinvention/workflow-reinvention-resources`
