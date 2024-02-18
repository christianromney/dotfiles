set fish_greeting ">>> Welcome back, "(whoami)". <<<"

# configure homebrew environment and add to path
set -gx HOMEBREW_PREFIX "/opt/homebrew";
set -gx HOMEBREW_CELLAR "/opt/homebrew/Cellar";
set -gx HOMEBREW_REPOSITORY "/opt/homebrew";
set -gx HOMEBREW_GITHUB_API_TOKEN (security find-internet-password -s api.github.com -w)
set PATH $HOME/bin $HOME/.config/emacs/bin $PATH
! set -q PATH; and set PATH ''; set -gx PATH "/opt/homebrew/bin" "/opt/homebrew/sbin" "/opt/homebrew/opt/grep/libexec/gnubin/" $PATH;
! set -q MANPATH; and set MANPATH ''; set -gx MANPATH "/opt/homebrew/share/man" $MANPATH;
! set -q INFOPATH; and set INFOPATH ''; set -gx INFOPATH "/opt/homebrew/share/info" $INFOPATH;

# ensure ssh and gpg are initialized
gpgconf --launch gpg-agent
set -x GPG_TTY (tty)
set -x GPG_AGENT_INFO "~/.gnupg/S.gpg-agent:"(pgrep gpg-agent)":1"
ssh-add -q

# configure development environment
set EDITOR emacs
if test -f $HOME/.nurc
  bass source $HOME/.nurc
end

# asdf general purpose environment manager
status --is-interactive; and source "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.fish"

# conda python environment manager
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f "$HOMEBREW_PREIX/Caskroom/miniconda/base/bin/conda"
    eval "$HOMEBREW_PREFIX/Caskroom/miniconda/base/bin/conda" "shell.fish" hook $argv | source
end
# <<< conda initialize <<<

# envionrment vars per directory
direnv hook fish | source

# configure prompt
if status is-interactive
 starship init fish | source
end

# additional cli tools and abbreviations
source /Users/christian/.config/op/plugins.sh
alias cm='chezmoi'
alias cma='chezmoi add -q -r --secrets error'
alias cms='chezmoi status'
alias ls='eza'
alias ll='eza -lah'
alias rf='rm -rf'
alias save-brews="list-brews | tee $HOME/.config/homebrew/formulae.txt"
alias save-casks="list-casks | tee $HOME/.config/homebrew/casks.txt"

# iTerm2 shell tools (e.g. imgcat)
test -e "$HOME/.iterm2_shell_integration.fish"; and source "$HOME/.iterm2_shell_integration.fish"

# zoxide & fzf
zoxide init fish --cmd=cd | source
