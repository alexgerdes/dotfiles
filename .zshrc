# Powerlevel10k prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path
export PATH=$PATH:~/.ghcup/bin       # GHCup
export PATH=$PATH:~/.local/bin       # Cabal/Haskell
export PATH=$PATH:~/.cargo/bin       # Rust
export PATH=$PATH:/opt/homebrew/bin  # Homebrew
export PATH=$PATH:/usr/local/bin     # Put own binaries here

# Oh-my-zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
ENABLE_CORRECTION="true"
if [[ "$OSTYPE" == "darwin"* ]]; then
  plugins=(git fzf macos docker python)
  PYTHON_VENV_NAME=".venv"
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
else
  plugins=(git fzf)
fi
source $ZSH/oh-my-zsh.sh

# Environment variables
export SHELL=zsh
export EDITOR=nvim
export LANG=en_US.UTF-8
export BAT_THEME="ansi"
export COPYFILE_DISABLE=true  # Prevent hiden files to show up in tarballs
export TZ=Europe/Stockholm

# FZF key bindings and fuzzy completion
eval "$(fzf --zsh)"
export FZF_DEFAULT_OPTS='-m --height 80% --border --preview "bat --color=always {}"'
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target,Library
  --preview 'tree -C {}'"

# Some functions
weather() { curl "wttr.in/$@" }       # Display weather forecase for a given city
mcd () { mkdir -p "$1" && cd "$1"; }  # make and change to a directory

# Useful aliases
alias l='ls -lah --color'
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
alias ..='cd ..'
alias cd..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias md='mkdir -p'
alias :q='exit'
alias sc='source ~/.zshrc'

# Local (OS specific) configuration
[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
