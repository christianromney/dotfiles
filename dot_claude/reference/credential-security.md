## Security

### Credential Access

- **NEVER** access a credential store (`op`, macOS `security`, Vault, GPG decryption)
  via Bash without explicit user authorization in the current conversation.
- When a credential is genuinely needed, state: what the credential is, which store it
  lives in, and why it is required. Wait for explicit user approval before running any
  retrieval command.
- Prefer MCP-server-managed credentials over manual retrieval. If an MCP server already
  handles authentication (e.g., Atlassian MCP), do not redundantly look up the
  underlying token.
- Do not spawn `general-purpose` agents (unrestricted Bash access) for tasks that only
  require direct MCP tool calls.
- All restrictions in this section apply equally to spawned sub-agents and task agents.
