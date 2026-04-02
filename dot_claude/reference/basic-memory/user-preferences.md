# Basic Memory User Preferences

## Deployment

- **Local only** — Basic Memory runs locally; never use cloud routing or cloud-based authentication.
- If a tool call fails with a cloud credentials error, that indicates misconfiguration — stop and report the error; do not attempt to fix or work around it.

## Default Project

- The default project is `nubank`. Always pass `project: "nubank"` to Basic Memory tools unless the user explicitly names a different project.
- There is no project named `kb`; that was a retired project.

---

# Basic Memory Note Organization

When working with basic-memory notes, follow these organizational principles:

#### 1. Domain-Based Architecture
- Top-level folders represent major knowledge domains
- Current domains: `business/`, `engineering/`
- Use clear, hierarchical structures within each domain

#### 2. Sub-Domain Structure
- Group related content within domains using descriptive subfolders
- Examples:
  - `business/bank-charter/occ/` for regulatory documents
  - `business/management/business-continuity/` for BCP resources
  - `business/management/risk/` for risk management
  - `engineering/architecture/` for system design docs
  - `engineering/tools/version-control/` for VCS documentation
  - `engineering/tools/development/` for development tools

#### 3. Naming Conventions
- **Filenames**: Use kebab-case (lowercase-with-hyphens)
- **Permalinks**: Mirror folder structure in kebab-case format
  - Example: File at `engineering/architecture/backup-infrastructure.md` has permalink `engineering/architecture/backup-infrastructure`
- **Titles**: Use natural capitalization (Title Case or Sentence case as appropriate)
- **Avoid redundancy**: Title "Backup Infrastructure" in folder `engineering/architecture/` (not "Backup Infrastructure Architecture")

#### 4. Eliminate Redundancy
- Never create root-level alias folders that duplicate nested locations
- Don't repeat parent folder concepts in child folder names or titles
- Consolidate related content under canonical paths

#### 5. Tag Strategy
- Tags should follow hierarchical structure: `domain → sub-domain → specific`
- Examples:
  - `engineering/architecture/cloud`
  - `business/bank-charter/occ/compliance`
  - `business/management/risk/operational`
- Tags should complement (not duplicate) folder structure

#### 6. Cross-References
- Always use full path format for wikilinks: `[[full/path/to/note|Display Text]]`
- Never rely on bare note titles: `[[Note Title]]` breaks when files move
- Update all references when moving notes

#### 7. Content Placement
Decision tree for note placement:
1. Is this about business operations, management, strategy, or regulatory compliance? → `business/`
2. Is this about technical systems or engineering practices? → `engineering/`

Within business:
- Bank charter, regulatory compliance, examination prep → `business/bank-charter/`
- Management practices, governance, risk → `business/management/`
- Product management, market analysis → `business/product/`
- Strategy, organizational development → `business/strategy/`

Within engineering:
- System design, architecture, diagrams → `engineering/architecture/`
- Development tools, debugging techniques → `engineering/tools/development/`
- Version control practices → `engineering/tools/version-control/`
- Application-specific implementation → `engineering/applications/{app-name}/`

#### 8. When to Create New Structure
Create new subfolders when:
- You have 3+ notes on closely related sub-topics
- Content forms a coherent category distinct from existing structure
- Grouping improves discoverability and reduces clutter

Don't create new structure when:
- Only 1-2 notes exist on a topic (use existing parent folder)
- Content could reasonably fit in existing categories
- New structure would create redundancy

#### 9. Domain Definitions
Current domains serve these purposes:

**business/**: All business-related content including operations, management, strategy, regulatory compliance, and organizational development
- Sub-domains:
  - bank-charter/ (regulatory compliance, OCC examination preparation)
  - management/ (organizational management, business continuity, risk management)

**engineering/**: Technical systems, architecture, tools, and development practices
- Sub-domains: architecture/, tools/, applications/

#### 10. Future Domain Considerations
If notes accumulate in areas not well-served by current domains, consider:

- **personal/**: Personal knowledge management (finances, hobbies, house, medical)
- **technology/**: General technology exploration not specific to work projects (AI research, programming languages, tools evaluation)
- **thinking/**: Conceptual frameworks, mental models, philosophy

When considering new domains, ensure:
- Sufficient volume (10+ notes) justifies the domain
- Content doesn't fit naturally in existing structure
- Domain represents a fundamental category of knowledge distinct from others
