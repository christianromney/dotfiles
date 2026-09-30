#!/bin/sh
# Clone the agent-skills store to ~/.agents on a machine that does not have it.
# The ~/.claude/skills symlinks that chezmoi manages point into this directory.
# Never touches an existing ~/.agents.
set -eu

store="$HOME/.agents"
url="git@github.com:christianromney/agent-skills.git"

if [ -d "$store/.git" ] || [ -d "$store/.jj" ]; then
  exit 0
fi

if [ -e "$store" ]; then
  echo "clone-agent-skills: $store exists but is not a repository; leaving it alone."
  echo "To adopt the agent-skills store later, move it aside and run:"
  echo "  jj git clone --colocate $url $store"
  exit 0
fi

if command -v jj >/dev/null 2>&1; then
  jj git clone --colocate "$url" "$store"
else
  git clone "$url" "$store"
fi
