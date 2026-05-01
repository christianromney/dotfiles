# Basic Memory Configuration

## Deployment
- Local only — never cloud routing or cloud authentication.
- If a tool call fails with a cloud credentials error, stop and report.

## Project Routing

Four registered projects. Apply the first matching rule:

| Rule | Signal | Project |
|------|--------|---------|
| 1 | Note is a dated journal entry, standup, or daily reflection | `journal` |
| 2 | Skill is `/standup`, `/journal:*`, or topic is personal (hobbies, career development, family, health, finance — not employer-specific) | `personal` |
| 3 | Skill is `/workflow-reinvention-*` or content relates to Nubank work (engineering, business, process, tools used at work) | `nubank` |
| 4 | Content is an AI-assisted project plan or docs created by a planning skill, for a project that doesn't belong to nubank | `ai-projects` |
| 5 | No rule matched | `nubank` |

### Project descriptions

| Project | Local Path | Purpose | Example content |
|---------|-----------|---------|----------------|
| `nubank` | `~/Documents/work/notes/basic-memory/nubank/` | Work knowledge — Nubank engineering, business, regulatory, processes | OCC exam responses, architecture docs, WR artifacts |
| `personal` | `~/Documents/personal/notes/basic-memory/personal/` | Personal knowledge — career, hobbies, non-work topics | Performance reviews about Christian, golf notes, personal finance |
| `journal` | `~/Documents/personal/notes/basic-memory/journal/` | Dated working notes — standups, reflections, daily logs | `2026-04-16.md` entries |
| `ai-projects` | `~/Documents/personal/notes/basic-memory/ai-projects/` | AI-assisted project plans and docs for non-nubank projects | Plan files, design docs for new personal or OSS projects |

Following the note-segregation of 2026-04-29, the `nubank` project lives in the work-notes repo (`~/Documents/work/notes/`); the other three live in the personal-notes repo. Cross-repo references between work and personal content are intentionally severed (see `~/Documents/_archive/severed-links-inventory-2026-04-28.md`).

### Disambiguation (topic-based, rule B)

Classification follows employer-specificity, not origin/use. A note created during work hours about a generic topic is classified by content, not context.

- **Performance reviews about Christian himself** → `personal` (his own career, even though sourced from employer systems)
- **Performance reviews about Christian's reports / team** → `nubank` (employer artifact about employees)
- **Blog posts about Claude Code** → `personal` unless the post discusses Nubank-specific engineering practice or tooling configuration
- **Tool notes (jujutsu, chezmoi, nucli)** → `personal` (generic tooling), unless the note documents Nubank-specific configuration or integration
- **Workflow Reinvention** → `nubank` (Nubank-specific process improvement; hardcoded in skills)
- **Generic CS / language / library knowledge** (Clojure, Datomic, AWS, distributed systems) → `personal` even when learned at work — generic content is portable, not employer property
- **Nubank-specific application of generic tech** (e.g., Nubank's Datomic deployment, Nubank's AWS architecture) → `nubank`

## Nubank Project Structure

```
nubank/
├── business/
│   ├── bank-charter/         # Regulatory: OCC, FFIEC, bank charter application
│   │   └── occ/              # OCC-specific examination documents
│   └── management/
│       ├── business-continuity/  # BCP, disaster recovery
│       └── risk/              # Risk frameworks, cybersecurity
├── engineering/
│   ├── architecture/          # System/network architecture, diagrams
│   ├── artificial-intelligence/
│   │   ├── blog/              # Published blog posts
│   │   └── debugging/         # Investigation notes
│   ├── mobile/                # iOS, Flutter, BDC
│   └── tools/                 # Flat — jujutsu, chezmoi, nucli, etc.
└── process/
    └── workflow-reinvention/  # WR initiative (protected paths — do not move)
        └── weekly-reports/
```

### Content placement (nubank)

1. Regulatory, compliance, bank charter → `business/bank-charter/`
2. Risk management, governance → `business/management/risk/`
3. BCP, resilience → `business/management/business-continuity/`
4. System architecture → `engineering/architecture/`
5. AI blog posts → `engineering/artificial-intelligence/blog/`
6. AI debugging/investigation → `engineering/artificial-intelligence/debugging/`
7. Mobile (iOS/Flutter/BDC) → `engineering/mobile/`
8. Tools and utilities → `engineering/tools/` (flat, no subdirs)
9. Workflow reinvention → `process/workflow-reinvention/`

## Faceted Tag Vocabulary

Tags use 4 orthogonal facets. Each note gets 1+ tags per relevant facet. Tags complement folders (cross-cutting bridges); folders provide hierarchy.

**Initiative** (bounded efforts): `bank-charter`, `workflow-reinvention`
**Concern** (cross-cutting): `compliance`, `risk`, `security`, `resilience`, `architecture`
**Technology** (specific tools/platforms): `ios`, `flutter`, `claude-code`, `occ`, `ffiec`, `jujutsu`, `nucli`, `chezmoi`
**Activity** (one per note): `investigation`, `reference`, `decision`, `assessment`, `blog`, `specification`

## Knowledge Graph

Every note should have `## Observations` and `## Relations` sections.

**Observation categories:** `[fact]`, `[decision]`, `[risk]`, `[requirement]`, `[finding]`, `[status]`
**Relation types:** `relates_to`, `supports`, `depends_on`, `elaborates`, `supersedes`

Use `[[Title of Note]]` wiki-link syntax in Relations.
