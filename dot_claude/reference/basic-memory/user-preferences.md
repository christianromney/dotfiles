# Basic Memory Configuration

## Deployment
- Local only — never cloud routing or cloud authentication.
- If a tool call fails with a cloud credentials error, stop and report.

## Project Routing

Two registered projects. Apply the first matching rule:

| Rule | Signal | Project |
|------|--------|---------|
| 1 | Topic is personal (hobbies, career development, family, health, finance — not employer-specific) | `personal` |
| 2 | Skill is `/workflow-reinvention-*` or content relates to Nubank work (engineering, business, process, tools used at work) | `nubank` |
| 3 | Content is an AI-assisted project plan for a Nubank project (planning skill) — see [Project plans routing](#project-plans-routing) | `nubank` |
| 4 | No rule matched | `nubank` |

> Only `nubank` and `personal` exist in Basic Memory.

### Project descriptions

| Project | Local Path | Purpose | Example content |
|---------|-----------|---------|----------------|
| `nubank` | `~/Documents/work/notes/basic-memory/nubank/` | Work knowledge — Nubank engineering, business, regulatory, processes | OCC exam responses, architecture docs, WR artifacts |
| `personal` | `~/Documents/personal/notes/basic-memory/personal/` | Personal knowledge — career, hobbies, non-work topics | Performance reviews about Christian, golf notes, personal finance |

Following the note-segregation of 2026-04-29, the `nubank` project lives in the work-notes repo (`~/Documents/work/notes/`); the `personal` project lives in the personal-notes repo. Cross-repo references between work and personal content are intentionally severed (see `~/Documents/_archive/severed-links-inventory-2026-04-28.md`).

### Path correctness rule

**Paths inside a project are always relative to the project root — never include the project name as a path component.**

- Correct (nubank project): `engineering/architecture/fin-connect.md`
- Wrong: `nubank/engineering/architecture/fin-connect.md`
- Correct (personal project): `career/2026-performance-review.md`
- Wrong: `personal/career/2026-performance-review.md`

The project is always specified separately via the `project` parameter. Embedding the project name in the path creates a doubly-nested directory (`nubank/nubank/...`) that is invisible in the filesystem but corrupts BM's search index.

### Project plans routing

AI-assisted project plans and design docs (typically created by superpowers planning skills) for **Nubank** projects route to the `nubank` project:

| Project type | Project | Directory |
|-------------|---------|-----------|
| Nubank work project (bank charter, WR, internal tooling) | `nubank` | `project-plans/{project-name}/` |

**Never use `docs/superpowers/` as the directory.** The superpowers plugin defaults to this path; always override it to the correct `project-plans/{project-name}/` path in the `nubank` project.

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
├── process/
│   └── workflow-reinvention/  # WR initiative (protected paths — do not move)
│       └── weekly-reports/
└── project-plans/             # AI-assisted plans for Nubank projects
    ├── note-segregation/
    ├── nubank-bcm-chapter/
    └── {project-name}/        # one subfolder per project
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
10. AI-assisted plans for Nubank projects → `project-plans/{project-name}/`

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
