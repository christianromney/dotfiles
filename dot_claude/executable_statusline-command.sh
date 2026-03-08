#!/usr/bin/env bash
# Claude Code status line — complements Starship / Catppuccin Frappe prompt
# Receives Claude Code session JSON on stdin

input=$(cat)

# ---------------------------------------------------------------------------
# Catppuccin Frappe palette (ANSI approximations, dimmed for status bar)
# ---------------------------------------------------------------------------
reset="\e[0m"
dim="\e[2m"
peach="\e[38;2;239;159;118m"      # #ef9f76
yellow="\e[38;2;229;200;144m"     # #e5c890
green="\e[38;2;166;209;137m"      # #a6d189
teal="\e[38;2;129;200;190m"       # #81c8be
lavender="\e[38;2;186;187;241m"   # #babbf1
sapphire="\e[38;2;133;193;220m"   # #85c1dc
mauve="\e[38;2;202;158;230m"      # #ca9ee6
overlay1="\e[38;2;131;139;167m"   # #838ba7  (separators / dim text)

sep="${dim}${overlay1} ${reset}"

# ---------------------------------------------------------------------------
# Extract fields from JSON
# ---------------------------------------------------------------------------
cwd=$(echo "$input"             | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input"           | jq -r '.model.display_name // ""')
remaining=$(echo "$input"       | jq -r '.context_window.remaining_percentage // empty')
total_in=$(echo "$input"        | jq -r '.context_window.total_input_tokens // empty')
total_out=$(echo "$input"       | jq -r '.context_window.total_output_tokens // empty')
cost_usd=$(echo "$input"        | jq -r '.cost.total_cost_usd // empty')
transcript=$(echo "$input"      | jq -r '.transcript_path // empty')
vim_mode=$(echo "$input"        | jq -r '.vim.mode // empty')
session_name=$(echo "$input"    | jq -r '.session_name // empty')

# ---------------------------------------------------------------------------
# Directory: truncate to last 3 segments (mirrors Starship truncation_length=3)
# ---------------------------------------------------------------------------
home="${HOME}"
cwd_display="${cwd/#$home/\~}"
IFS='/' read -ra parts <<< "$cwd_display"
num=${#parts[@]}
if [ "$num" -gt 3 ]; then
    truncated="…/${parts[$num-3]}/${parts[$num-2]}/${parts[$num-1]}"
else
    truncated="$cwd_display"
fi

# ---------------------------------------------------------------------------
# Git branch + status (skip optional locks to avoid blocking)
# ---------------------------------------------------------------------------
git_info=""
if git --no-optional-locks -C "$cwd" rev-parse --git-dir &>/dev/null; then
    branch=$(git --no-optional-locks -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
             || git --no-optional-locks -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        dirty=""
        if ! git --no-optional-locks -C "$cwd" diff --quiet 2>/dev/null \
          || ! git --no-optional-locks -C "$cwd" diff --cached --quiet 2>/dev/null; then
            dirty="*"
        fi
        untracked=""
        if [ -n "$(git --no-optional-locks -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | head -1)" ]; then
            untracked="?"
        fi
        git_info="${yellow} ${branch}${dirty}${untracked}${reset}"
    fi
fi

# ---------------------------------------------------------------------------
# Context window
# ---------------------------------------------------------------------------
ctx_info=""
if [ -n "$remaining" ]; then
    remaining_int=${remaining%.*}
    used_int=$((100 - remaining_int))
    if   [ "$used_int" -ge 90 ]; then color="\e[38;2;231;130;132m"   # red
    elif [ "$used_int" -ge 75 ]; then color="\e[38;2;239;159;118m"   # peach/orange
    else                              color="$green"
    fi
    ctx_info="${color}Context: ${used_int}% used${reset}"
fi

# ---------------------------------------------------------------------------
# Token counts (cumulative session totals)
# ---------------------------------------------------------------------------
token_info=""
if [ -n "$total_in" ] && [ -n "$total_out" ]; then
    in_k=$(echo "$total_in"  | awk '{printf "%.1fk", $1/1000}')
    out_k=$(echo "$total_out" | awk '{printf "%.1fk", $1/1000}')
    token_info="${overlay1}Tokens: ${in_k}↑ ${out_k}↓${reset}"
fi

# ---------------------------------------------------------------------------
# Cost
# ---------------------------------------------------------------------------
cost_info=""
if [ -n "$cost_usd" ]; then
    cost_fmt=$(echo "$cost_usd" | awk '{printf "$%.4f", $1}')
    cost_info="${mauve}Cost: ${cost_fmt}${reset}"
fi

# ---------------------------------------------------------------------------
# Turn count (assistant messages in transcript)
# ---------------------------------------------------------------------------
turn_info=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
    turns=$(grep -c '"role":"assistant"\|"role": "assistant"' "$transcript" 2>/dev/null || true)
    [ -n "$turns" ] && [ "$turns" -gt 0 ] && turn_info="${overlay1}Turns: ${turns}${reset}"
fi

# ---------------------------------------------------------------------------
# Vim mode
# ---------------------------------------------------------------------------
vim_info=""
if [ -n "$vim_mode" ]; then
    case "$vim_mode" in
        NORMAL)  vim_info="${green}NORMAL${reset}" ;;
        INSERT)  vim_info="${sapphire}INSERT${reset}" ;;
        *)       vim_info="${overlay1}${vim_mode}${reset}" ;;
    esac
fi

# ---------------------------------------------------------------------------
# Session name
# ---------------------------------------------------------------------------
name_info=""
if [ -n "$session_name" ]; then
    name_info="${dim}${overlay1}[${session_name}]${reset}"
fi

# ---------------------------------------------------------------------------
# Assemble
# ---------------------------------------------------------------------------
user=$(whoami)

parts_out=()
parts_out+=("${overlay1}${user}${reset}")
parts_out+=("${peach}${truncated}${reset}")
[ -n "$git_info"    ] && parts_out+=("$git_info")
[ -n "$name_info"   ] && parts_out+=("$name_info")
parts_out+=("${lavender}${model}${reset}")
[ -n "$ctx_info"    ] && parts_out+=("$ctx_info")
[ -n "$token_info"  ] && parts_out+=("$token_info")
[ -n "$cost_info"   ] && parts_out+=("$cost_info")
[ -n "$turn_info"   ] && parts_out+=("$turn_info")
[ -n "$vim_info"    ] && parts_out+=("$vim_info")

# Join with separator and print (no trailing newline)
result=""
for i in "${!parts_out[@]}"; do
    if [ "$i" -eq 0 ]; then
        result="${parts_out[$i]}"
    else
        result="${result}${sep}${parts_out[$i]}"
    fi
done

printf "%b" "$result"
