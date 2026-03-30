# AI Disclosure Instructions

## Disclosure Block

Insert the following blockquote immediately after the primary heading of every
document you help create or edit:

```markdown
> **AI Disclosure**: <model-version> <model-role> this document with <human> <human-role>. 
> **Last Review**: <review-status>
> **[Version History](#version-history)**
```

- `<model-version>`: Model name and version (e.g., "Claude Sonnet 4.6")
- `<model-role>`: The AI's contribution level — choose the most accurate:
  - "authored" — primarily AI-generated content
  - "co-authored" — substantial AI contribution alongside human authorship
  - "edited" — AI revised or restructured human-written content
  - "reviewed" — AI checked grammar, style, or internal consistency only
- `<human>` - the name of the person supplying the prompt
- `<human-role>` - characterize the human's contribution. It's especially
  important to know if the human reviewed the output or only the input. Review
  can be explicit or implicit, such as when an artifact is produced iteratively
  with human guidance along the way.

If agents or a team assisted, append these lines to the blockquote:

```markdown
> Agents: <comma-separated agent names>
> Team: <team-name> (<comma-separated teammate names>)
```

## Version History

Append a Version History section at the end of every document you help create
or edit:

```markdown
## Version History

| Date | Description | Changes | Review |
|------|-------------|---------|--------|
| YYYY-MMM-DD | Initial draft | +N lines | <review-status> |
```

**Column definitions:**

- **Date**: YYYY-MMM-DD format
- **Description**: Brief plain-language summary of what changed
- **Changes**: A diffstat-style summary of change volume in the format
  `+N / -N lines`, where `+N` is the number of lines added and `-N` is the
  number of lines removed. For initial document creation, use `+N lines` (no
  deletions). This conveys volume, not significance — large values signal the
  reader to read more carefully.
- **Review**: "Unreviewed" or "Reviewed by [Full Name] on YYYY-MMM-DD". This
   should account for implicit incremental review when appropriate.

Add one row per editing session. Use judgment to batch small related changes
into a single row.

**Keeping the disclosure block current:** The `Last Review` field in the
disclosure block at the top must always the reflect most recent "Reviewed by" entry in the
version history table.
