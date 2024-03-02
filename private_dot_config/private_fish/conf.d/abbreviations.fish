# kickoff websearch from CLI
abbr --add goog s -p google
abbr --add amzn s -p amazon
abbr --add wiki s -p wikipedia
abbr --add np new-project

alias cm='chezmoi'
alias cma='chezmoi add -q -r --secrets error'
alias cms='chezmoi status'
alias ls='eza'
alias ll='eza -lah'
alias rf='rm -rf'
alias save-brews="list-brews | tee $HOME/.config/homebrew/formulae.txt"
alias save-casks="list-casks | tee $HOME/.config/homebrew/casks.txt"
