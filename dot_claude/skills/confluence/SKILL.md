---
name: confluence
description: Read, edit, validate, and publish changes to an existing Confluence page.
user_invocable: true
arguments:
  - name: page
    description: The title or URL of the Confluence page to edit
    required: true
  - name: changes
    description: What changes to make (natural language description)
    required: true
---

# Confluence Page Edit Workflow

You are editing an existing Confluence page. Follow each step sequentially. Do not skip the validation checklist.

## Step 1: Locate the Page

- If `$ARGUMENTS.page` is a URL, extract the page ID from the URL path.
- If it is a title, search using `searchConfluenceUsingCql` with a `title = "$ARGUMENTS.page"` CQL query.
- If multiple pages match, present them to the user and ask which one to edit.
- Once identified, read the full page content using `getConfluencePage` with `include_body=true`.

## Step 2: Understand Current State

Before making any changes, analyze the page:

1. **Sections**: Identify all headings and their hierarchy.
2. **Diagrams**: Find all mermaid code blocks and image/attachment macros.
3. **Tables**: Locate all tables and note what data they contain.
4. **Errata / Limitations**: Check for an errata, corrections, or known-issues section.
5. **Version history table**: Check if the page has a version/changelog table.
6. **Terminology inventory**: Scan the page for domain-specific terms, proper nouns, acronyms, and naming conventions. Record these — you must preserve them during editing.

## Step 3: Apply Changes

Apply the changes described in `$ARGUMENTS.changes`. While editing:

- **Preserve terminology**: Never substitute a generic synonym for a domain-specific term already used in the page (e.g., do not replace "squad" with "team", "chapter" with "department", "runbook" with "guide") unless the user explicitly requests the substitution.
- **Keep tables and narrative consistent**: If you change data in a table, update any prose that references that data, and vice versa.
- **Errata are mandatory**: If you corrected a factual error in the content, add an entry to the errata/corrections section. If no such section exists and you corrected a factual error, create one.
- **Version history**: If the page has a version history or changelog table, add a new row documenting this edit.
- **No silent fixes**: Every change you make must appear in the diff you show the user later. Do not make undocumented "cleanup" changes.

## Step 4: Validation Checklist (MANDATORY)

This checklist is **not optional**. Run every check and present results to the user in this table format:

| Check | Status | Detail |
|-------|--------|--------|
| Diagrams render | PASS/FAIL | For each mermaid code block, verify the syntax is valid. For image macros, verify the attachment or URL reference exists. List each diagram and its status. |
| Errata current | PASS/FAIL | If content was corrected, confirm the errata section reflects the correction. If no factual errors were corrected, mark N/A. |
| Tables consistent | PASS/FAIL | Verify that narrative text referencing table data matches the table contents. No stale references. |
| Terminology stable | PASS/FAIL | Compare domain terms in the edited content against the terminology inventory from Step 2. Flag any unintended substitutions. |
| Links valid | PASS/FAIL | Check that internal anchor links (e.g., `#section-name`) and cross-page links reference valid targets. |
| Version history | PASS/FAIL | If a version history table exists, confirm a new row was added for this edit. If no such table exists, mark N/A. |

**If any check fails**: Fix the issue, then re-run only the failed checks. Repeat until all checks pass. Do not proceed to Step 5 with any failures.

## Step 5: Show Diff and Confirm

Present a clear summary of all changes:

- List each section that was modified, added, or removed.
- Show key content differences (what was there before vs. what is there now).
- Highlight any errata entries or version history rows that were added.

Ask the user: **"Ready to publish these changes? (yes/no)"**

Do not proceed without explicit confirmation.

## Step 6: Publish

- Update the page using `updateConfluencePage`.
- After a successful update, display the page URL so the user can verify the result in their browser.
- If the update fails, show the error and ask the user how to proceed.
