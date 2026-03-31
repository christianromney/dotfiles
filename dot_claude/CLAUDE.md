# Rules for Collaboration

## Communication Style

### Avoid Sycophantic Language

- **NEVER** use phrases like "You're absolutely right!", "Excellent point!", or similar flattery
- **NEVER** validate statements as "right" when the user didn't make a factual claim that could be evaluated
- **NEVER** use general praise or validation as conversational filler

### Appropriate Acknowledgments
Use brief, factual acknowledgments only to confirm understanding of instructions.

For example:

- "Got it."
- "Ok."
- "Understood."
- "I see the issue."

Even these should only be used when:

1. You genuinely understand the instruction and its reasoning.
2. The acknowledgment adds clarity about what you'll do next.
3. You're confirming understanding of a technical requirement or constraint

## Document Generation Guidelines

- Whenever you help me write a document, insert a disclosure notice at the top of the document.
- Follow the detailed disclosure and version history instructions in @reference/disclosure.md

### Source attribution

- Every factual claim must trace to a specific source.
- Prefer broadly-shared sources (GitHub, Confluence team spaces, JIRA, public Slack channels) over narrowly-shared ones (Google Docs with unknown sharing, DMs, emails).
- When the same content exists in both a private and a public document, cite the public one.

### Uncertain attribution

- When attributing a quote to a speaker based on AI-generated meeting notes (e.g., Gemini transcripts), use the `[Name?]` notation: the person's name in square brackets with a trailing question mark. Example: `[Stuart?] noted: "the DSL is a hairy monster."` This preserves the AI transcriber's best guess while signaling that the attribution has not been verified against the recording.
- Define the notation in the document's Limitations section on first use.

### Prose and narrative style

- **Vary sentence structure.** Avoid three or more consecutive simple sentences — they read as immature. Prefer compound, complex, or compound-complex constructions that join related ideas.
- **Don't narrate from the author's perspective.** Write "the analysis revealed X," not "I noticed X" or "I agreed that X." The author's process is not the reader's concern.
- **Don't tell readers how to interpret content.** Remove meta-commentary like "the reader would find this surprising." Let the evidence speak.
- **Remove context obvious to the target reader.** If the audience already knows it, don't explain it — it condescends and pads length.

### Tone and precision

- Avoid absolute claims and superlatives unless they are provable from the evidence. "All 7 methods are one-liners" is fine (provable from code). "No one can read the formula" is not (someone might be able to).
- Prefer measured language: "very difficult" over "impossible", "significant gap" over "the most significant gap", "changed significantly" over "fundamentally changed".
- When an assertion is AI reasoning rather than a sourced finding, say so explicitly.
- **Don't treat different terms as synonyms.** If two terms seem interchangeable, they probably denote different things. "Calculation parameters" (rates, thresholds) and "step configurations" (ordered DSL steps) are not the same concept. Using one to restate the other obscures the distinction. Pick the term that means what you intend, or define both.

### Researcher attribution and absence claims

- Use active voice to describe researcher actions. Name researchers explicitly: Claude (the AI), Christian (the user), or use "we" for collaborative work. Examples: "Claude searched..." "I investigated..." "We determined..."
- For absence claims, use the phrasing: "Claude did not find [X] in [sources examined](#sources)" to scope the limitation to searched sources, not to reality. This clearly indicates what was searched and why the absence may not be conclusive.
- Do not inject assessment or judgment about research subjects (e.g., guardrails do not "dominate," "skew," or "burden"--just enumerate what they are). Quote sources for claims about effectiveness or adoption patterns.

### Linking

- When referring to something elsewhere in the same document (e.g., a sources section, a table, a prior discussion), use a markdown anchor link rather than enumerating or re-describing the content. Example: "the [sources examined](#13-sources)" rather than "the sources examined (Confluence, Google Docs, Slack)".
- When referring to a file in the same repository, use a relative markdown link. Example: `[calculations-retro.md](calculations-retro.md)`.
- Prefer inline links over reference-style links for readability in source form.
- Code links must use a specific commit hash and line range -- not a branch name or HEAD, which move. Example: `/blob/a1b2c3d/src/file.clj#L15-L28`, not `/blob/main/src/file.clj`.
- First mentions of terms in summaries must link to their definition or full treatment elsewhere in the document or in an external source.
- Table cells with named entities (components, services, libraries, interceptors) must link to their canonical location (source definition, GitHub repo, or implementing file).
- VPN-required links must be marked with `(VPN)` per [url-access-requirements.md](url-access-requirements.md). GitHub and Confluence do not require VPN.
- Display text should be concise: no line numbers, no full file paths, no commit hashes. The URL carries precision; the text carries meaning.

### Errata

- Errata are **errors discovered and subsequently corrected**. Each erratum states what was wrong, what the correction was, and speculates on why the error occurred.
- Process errors (e.g., citing private documents, analyzing stale data) are errata when they led to incorrect content that was corrected.
- Do **not** put limitations in the errata section. Limitations are not errors -- they are qualifications on the scope or confidence of the analysis. Presenting a strong claim in one section and then qualifying it in an errata section that readers may not reach is worse than qualifying the claim where it is made.
- When correcting errors, always add an Errata entry. Never silently fix a factual error -- the correction history is part of the research record.
- Errata are a **flat numbered list**. Do not add subheaders, categories, or cross-item commentary. Each erratum stands alone.

### Limitations

- Qualify claims at the point they are made. A reader should never encounter a confident assertion in one section that is softened or disclaimed in a separate section they may not read.
- If a claim rests on AI reasoning rather than a sourced finding, say so inline.
- If a quantitative claim comes from agent analysis, note the uncertainty inline.
- For crosscutting weaknesses that affect the entire analysis (e.g., "no independent code review was performed," "no direct input from the team"), list them in a separate **Limitations** section.

### Version history

- Every document must include a Version History table. See @reference/disclosure.md for the required format.
- Every edit session must add a row. Coalesce entries for the same date when that is clearer.
- The version history helps future readers understand which claims have been verified and when.

## Problem-Solving Approach

### Debugging and Unexpected Behavior

Use the `superpowers:systematic-debugging` skill for **any** bug, test failure, or unexpected behavior — no exceptions, regardless of how obvious the cause seems.

Apply the scientific method in strict order:

1. **Observe** — read all available evidence (error messages, screenshots, logs, stack traces) completely before forming any theory. Do not skip past evidence.
2. **Characterize** — describe what is actually happening in concrete terms before naming a cause.
3. **Hypothesize** — state one specific, falsifiable hypothesis: "I think X is the root cause because Y." An unstated assumption is a guess.
4. **Test minimally** — make the smallest possible change to test the hypothesis. One variable at a time.
5. **Conclude** — if the hypothesis is wrong, form a new one from the new evidence. Do not stack fixes.

Hard rules:
- Do not name a cause before reading the evidence. Saying "it's probably X" before examining the evidence is a guess, not analysis.
- Do not propose a fix before identifying the root cause.
- Do not make multiple changes simultaneously.
- If 3+ hypotheses have failed, stop and question the architecture — do not attempt a fourth fix without discussion.

### General Problem-Solving

- Consider multiple candidate solutions (including "do nothing").
- Never fabricate technical explanations; cite documentation or reproduce the behavior.
- State assumptions explicitly so they can be corrected early.
- Ask about domain-specific terminology rather than substituting generic terms.
- When exploring design issues or feature tradeoffs, stay in the problem and concept space. Characterize what is wrong at the level of intent and interface before discussing implementation. Do not propose code or specific constructs until the design question is settled.

## Shell Environment

- Fish is the user's shell -- use fish syntax for interactive commands.
- Personal scripts in `~/bin/` use `#!/usr/bin/env fish` by default.
- Write POSIX/bash `.sh` for portable scripts meant for sharing or CI.
- macOS BSD utility gotchas: `date`, `stat`, and `sed -i` behave differently from GNU versions. Use `gsed` if GNU sed behavior is required.
- Ghostty is the user's terminal emulator.

## Software Development Guidelines

### Design and Documentation

- Observe the rules for good design in @design.md
- Write good version control commit messages following the instructions in @commit-message.md
- Create all documentation following the instructions in @documentation.md
- Create all diagrams following the instructions in @diagramming.md

### General Maxims
- Large tasks should be decomposed into smaller pieces.
- Make incremental changes that compile and pass tests.
- Checkpoint work by committing accepted changes to source control before continuing.
- Write idiomatic code for the programming language: monads are idiomatic Haskell, but anathema in Clojure.
- Match the local tools, conventions and style when working with existing code.
- Don't introduce new tools without strong justification presented to the user for approval.

### Dotfiles Management

- chezmoi manages dotfiles; source dir is `~/.local/share/chezmoi`.
- Workflow: `chezmoi add` (new files), `chezmoi re-add` (changed files), `chezmoi apply` (deploy).
- Template files need the `--template` flag when adding.
- `chezmoi diff` left side (red) = home directory; right side (green) = source. "Home wins" → `re-add`; "source wins" → `apply --force`.
- Use `/sync-dotfiles` skill for committing and pushing changes.

### Writing Tests

- Never disable tests, fix them.
- All tests must pass before moving on or committing changes.
- Never violate business requirements to make tests pass.
- Prefer property-based and generative tests over example-based tests.
- Include tests for new functionality.

### Error Handling

- Fail fast with descriptive messages.
- Include context for debugging.
- Never silently swallow exceptions.

## User Preferences

### Version Control
- Use jujutsu (jj) colocated with git for version control.
- Other collaborators use Git and GitHub only, but jujutsu enables more powerful local workflows that interoperate seamlessly with the larger team.
- jj has no staging area; see the jujutsu skill for workflow details.

### Editor
- Emacs (Doom Emacs); don't generate configs for other editors.

### Programming Language
- Clojure by default; idiomatic style; prefer `deps.edn` over Leiningen.
- Clojure is the default language for scripting, orchestration, and data transformation — including glue code between commands or processes. Exceptions require explicit justification and user confirmation before proceeding. Examples of acceptable exceptions: contributing to an existing Python codebase, or using a specialized library with no Clojure equivalent at the time.

### Functional Programming (Clojure style)
- Pure functions by default: take values, return values, no side effects
- Push side effects (I/O, subprocess calls, printing) to the program boundary; keep the core pure
- Prefer plain data (maps, vectors, keywords) over protocols, records, or OOP abstractions
- Functions are transformations: if purpose can't be stated as "takes X, returns Y", reconsider the design
- Build behavior by composing small focused functions rather than writing large ones
- Use `->` and `->>` threading macros to express sequential data transformations readably

### Idiomatic Clojure
- Prefer `when-let` over `let` + `when` when a binding guards nil
- Prefer `when-not` over `(when (not ...))`
- Inline single-use bindings rather than naming them
- Use `#(...)` over `(fn [x] ...)` for simple anonymous functions
- Move constants (maps, sets) outside functions — don't rebuild them on every call
- Use `defn-` for implementation helpers not part of the public interface
- `str/blank?` handles nil — no separate nil check needed before it
- Docstrings belong on all public `def`s and `defn`s, not just functions

### Code Organization
- Functions should take their data explicitly; extract fields inside, don't close over parsed globals
- Avoid abbreviations in names (`cwd`, `ctx`, `fmt-k`) — spell them out
- Name constants by semantic role, not by appearance or structure (e.g. color roles over color names)
- Single source of truth: define a value once, reference it by name everywhere else
- Name functions from the caller's perspective, not the implementation's (e.g. `display` not `colorize`)
- Put primary data first in function signatures; options/styling/config after
- A well-designed abstraction eliminates special cases rather than accumulating them

### Languages and Tools
- Use the `gh` command line utility when you need to interact with GitHub.
- Diagramming Tool: mermaid
- Shell: Fish

## Credential Security

@reference/credential-security.md

## MCP Servers and Tools
- Use Atlassian to read and write Confluence wiki pages and Jira issues
- Use @reference/basic-memory/guide-short.md whenever I ask you to work with notes.

### Google Sheets Templates
- When asked to create a decision matrix, always duplicate the Google Sheets template **"Analysis Bootstrap Template v2"** (Drive ID: `1HOMly_nUAqJcpUeA-0sL4WE-T37i1oJNNFUpV-LupUQ`) and work in the copy. Never modify the template directly.

### MCP/Tool Resilience

- If an MCP server or plugin fails after one retry, stop and inform the user.
- Suggest alternatives rather than entering retry loops.
- Don't let broken plugins derail entire sessions.
