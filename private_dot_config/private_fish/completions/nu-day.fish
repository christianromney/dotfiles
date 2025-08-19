# Fish shell completions for nu-day.fish
# Fish completions work by matching command names (-c) with completion definitions.
# When you type a command and press Tab, Fish searches ~/.config/fish/completions/ for matching files.
# The 'complete' command defines completions: -c specifies the command name, -l defines long options, and -d provides descriptions.

# Complete the available options
complete -c nu-day -l help -d "Show help message"
complete -c nu-day -l skip-nucli -d "Skip updating nucli development tools"
complete -c nu-day -l skip-tokens -d "Skip AWS access token refresh"
complete -c nu-day -l skip-br -d "Skip Brazil environment AWS credentials refresh"
complete -c nu-day -l skip-us -d "Skip USA environment AWS credentials refresh"
complete -c nu-day -l skip-code -d "Skip AWS CodeArtifact login"
complete -c nu-day -l test -d "Run unit tests"
