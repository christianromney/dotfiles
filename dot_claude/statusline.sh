#!/bin/bash

# Claude Code statusline inspired by starship configuration
# Colors match the starship theme with purple, blue, and green accents

# Parse JSON input
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model_name=$(echo "$input" | jq -r '.model.display_name')

# Color definitions (matching starship theme)
PURPLE_BG="\033[48;2;74;35;90m"     # #4A235A
BLUE_DARK_BG="\033[48;2;21;67;96m"  # #154360
BLUE_DARKER_BG="\033[48;2;15;45;70m"  # #0F2D46 - Much darker blue
BLUE_DARKEST_BG="\033[48;2;10;30;50m"  # #0A1E32 - Even darker blue  
BLUE_MID_BG="\033[48;2;26;82;118m"  # #1A5276
BLUE_LIGHT_BG="\033[48;2;45;125;175m" # #2D7DAF - More contrast with mid blue
BLUE_VERY_LIGHT_BG="\033[48;2;70;150;200m" # #4696C8 - Much lighter blue for better contrast
GRAY_BG="\033[48;2;66;73;73m"       # #424949
WHITE_FG="\033[38;2;255;255;255m"   # white text
BOLD_WHITE_FG="\033[1;38;2;255;255;255m" # bold white text
BRIGHT_WHITE_FG="\033[1;38;2;255;255;240m" # slightly warm white
YELLOW_FG="\033[38;2;241;196;15m"   # #F1C40F
GREEN_FG="\033[38;2;88;214;141m"    # #58D68D
ORANGE_FG="\033[38;2;243;156;18m"   # #F39C12
BRIGHT_ORANGE_FG="\033[38;2;255;193;7m" # #FFC107
BOLD_BRIGHT_ORANGE_FG="\033[1;38;2;255;165;0m" # Bold #FFA500
CUSTOM_BRIGHT_FG="\033[1;38;2;235;224;67m" # Bold RGB(235,224,67)
CUSTOM_BRIGHTER_FG="\033[38;2;255;255;100m" # No bold, brighter RGB(255,255,100)
CUSTOM_MAX_BRIGHT_FG="\033[1;38;2;255;255;0m" # Bold max bright yellow
MAX_YELLOW_NO_BOLD="\033[38;2;255;255;0m" # Max bright yellow without bold
FIERY_ORANGE_FG="\033[38;2;255;69;0m" # Fiery orange RGB(255,69,0)
BRIGHT_ORANGE_FG2="\033[38;2;255;140;0m" # More orange, less red RGB(255,140,0)
PALETTE_BRIGHT_YELLOW="\033[1;38;5;226m" # Bold 256-color bright yellow
PALETTE_YELLOW_NO_BOLD="\033[38;5;226m" # 256-color bright yellow without bold
PURPLE_FG="\033[38;2;175;122;197m"  # #AF7AC5
RED_FG="\033[38;2;231;76;60m"       # #E74C3C
RESET="\033[0m"

# Segment separators (Nerd Font powerline glyphs)
SEP_RIGHT=$'\uE0B0'  # Nerd Font powerline right separator
SEP_LEFT=$'\uE0B2'   # Nerd Font powerline left separator
# Alternative rounded separators:
# SEP_RIGHT=$'\uE0B4'  # Nerd Font powerline right separator (rounded)
# SEP_LEFT=$'\uE0B6'   # Nerd Font powerline left separator (rounded)

# Function to get username and hostname
get_user_host() {
    local user=$(whoami)
    local host=$(hostname -s)
    printf "${PURPLE_BG}${WHITE_FG}  ${user}@${host} ${RESET}"
}

# Function to get directory with icon substitutions
get_directory() {
    local dir_path="$cwd"
    local display_path="$dir_path"
    local nu_indicator=""
    
    # Check if we're in a Nubank project
    if [[ "$dir_path" == *"/dev/nu/"* ]]; then
        nu_indicator="🏦 "
    fi
    
    # Apply substitutions similar to starship config
    display_path=${display_path//$HOME/~}
    display_path=${display_path//Documents/󰈙 }
    display_path=${display_path//Downloads/ }
    display_path=${display_path//Music/ }
    display_path=${display_path//Pictures/ }
    
    # Truncate long paths
    if [[ ${#display_path} -gt 50 ]]; then
        display_path="…/${display_path##*/}"
    fi
    
    printf "${BLUE_MID_BG}${WHITE_FG} ${nu_indicator}${display_path} ${RESET}${BLUE_LIGHT_BG}\033[38;2;26;82;118m${SEP_RIGHT}${RESET}"
}

# Function to get git information
get_git_info() {
    if [[ ! -d "$cwd/.git" ]] && ! git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
        return
    fi
    
    local branch=$(git -C "$cwd" branch --show-current 2>/dev/null || echo "detached")
    local status_info=""
    
    # Get git status without locks
    local git_status=$(git -C "$cwd" status --porcelain 2>/dev/null)
    if [[ -n "$git_status" ]]; then
        local modified=$(echo "$git_status" | grep -c "^ M\| M\|^M ")
        local added=$(echo "$git_status" | grep -c "^A \|^M ")
        local deleted=$(echo "$git_status" | grep -c "^D \| D")
        local untracked=$(echo "$git_status" | grep -c "^??")
        
        [[ $modified -gt 0 ]] && status_info+="!$modified"
        [[ $added -gt 0 ]] && status_info+="+$added"
        [[ $deleted -gt 0 ]] && status_info+="-$deleted"
        [[ $untracked -gt 0 ]] && status_info+="?$untracked"
    fi
    
    # Get ahead/behind info
    local ahead_behind=$(git -C "$cwd" rev-list --left-right --count HEAD...@{upstream} 2>/dev/null || echo "0 0")
    local ahead=$(echo "$ahead_behind" | cut -d' ' -f1)
    local behind=$(echo "$ahead_behind" | cut -d' ' -f2)
    
    [[ $ahead -gt 0 ]] && status_info+="↑$ahead"
    [[ $behind -gt 0 ]] && status_info+="↓$behind"
    
    printf "${BLUE_LIGHT_BG}${WHITE_FG}  $branch "
    [[ -n "$status_info" ]] && printf "${WHITE_FG}[$status_info] "
    printf "${RESET}${BLUE_VERY_LIGHT_BG}\033[38;2;45;125;175m${SEP_RIGHT}${RESET}"
}

# Function to detect and show language versions
get_language_info() {
    local lang_info=""
    
    # Check for Clojure (prioritized for this project)
    if [[ -f "$cwd/deps.edn" ]] || [[ -f "$cwd/project.clj" ]]; then
        local clj_version=$(clojure -version 2>&1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 2>/dev/null || echo "")
        [[ -n "$clj_version" ]] && lang_info+="${GREEN_FG}󰗤${WHITE_FG} $clj_version "
    fi
    
    # Check for Python
    if [[ -f "$cwd/pyproject.toml" ]] || [[ -f "$cwd/requirements.txt" ]] || [[ -f "$cwd/setup.py" ]]; then
        local py_version=$(python3 --version 2>/dev/null | cut -d' ' -f2 || echo "")
        [[ -n "$py_version" ]] && lang_info+="${YELLOW_FG} ${WHITE_FG}$py_version "
    fi
    
    # Check for Node.js
    if [[ -f "$cwd/package.json" ]]; then
        local node_version=$(node --version 2>/dev/null | sed 's/v//' || echo "")
        [[ -n "$node_version" ]] && lang_info+="${GREEN_FG}⬢${WHITE_FG} $node_version "
    fi
    
    # Check for Java
    if [[ -f "$cwd/pom.xml" ]] || [[ -f "$cwd/build.gradle" ]]; then
        local java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1-2 2>/dev/null || echo "")
        [[ -n "$java_version" ]] && lang_info+="${YELLOW_FG} ${WHITE_FG}$java_version "
    fi
    
    if [[ -n "$lang_info" ]]; then
        printf "${BLUE_LIGHT_BG}$lang_info${RESET}"
    fi
}


# Function to get weather with caching
get_weather() {
    local cache_file="/tmp/statusline_weather_cache"
    local cache_duration=900  # 15 minutes in seconds
    local current_time=$(date +%s)
    
    # Check if cache exists and is still valid
    if [[ -f "$cache_file" ]]; then
        local cache_time=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null || echo 0)
        local age=$((current_time - cache_time))
        
        if [[ $age -lt $cache_duration ]]; then
            local cached_weather=$(cat "$cache_file" 2>/dev/null)
            if [[ -n "$cached_weather" && "$cached_weather" != "error" ]]; then
                printf "${BLUE_VERY_LIGHT_BG}${WHITE_FG} $cached_weather ${RESET}${PURPLE_BG}\033[38;2;70;150;200m${SEP_RIGHT}${RESET}"
                return
            fi
        fi
    fi
    
    # Fetch fresh weather data with timeout
    local weather_data=""
    weather_data=$(timeout 3s curl -s "wttr.in/?format=%c%t+(%f)" 2>/dev/null | tr -d '\n' | sed 's/[[:space:]]*$//')
    
    # Validate the response (should contain temperature and not be empty or error message)
    if [[ -n "$weather_data" && "$weather_data" != *"Unknown"* && "$weather_data" =~ [0-9].*°F ]]; then
        echo "$weather_data" > "$cache_file"
        printf "${BLUE_VERY_LIGHT_BG}${WHITE_FG} $weather_data ${RESET}${PURPLE_BG}\033[38;2;70;150;200m${SEP_RIGHT}${RESET}"
    else
        # Cache the error state briefly to avoid repeated failed requests
        echo "error" > "$cache_file"
    fi
}

# Function to get current time
get_time() {
    local current_time=$(date "+%I:%M:%S %p")
    printf "${PURPLE_BG}${WHITE_FG} ⏱️$current_time ${RESET}\033[38;2;74;35;90m${SEP_RIGHT}${RESET}"
}

# Function to get Claude model indicator (prominently displayed)
get_model_info() {
    # Keep the full model name for clarity
    printf "${BLUE_DARKEST_BG}${YELLOW_FG} 🤖 ${BRIGHT_ORANGE_FG2}$model_name ${RESET}${BLUE_MID_BG}\033[38;2;10;30;50m${SEP_RIGHT}${RESET}"
}

# Build the complete statusline
statusline=""
statusline+="\033[0m"  # Explicit reset at beginning
statusline+=$(get_model_info)  # Model info after reset
# statusline+=$(get_user_host)  # Removed user@host display
statusline+=$(get_directory)
statusline+=$(get_git_info)
# statusline+=$(get_language_info)  # Removed programming language section
statusline+=$(get_weather)
# Docker context removed as requested
statusline+=$(get_time)

# Output the statusline
printf "$statusline"
