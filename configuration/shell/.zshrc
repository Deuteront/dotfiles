# --- Oh My Zsh

export ZSH="$HOME/.oh-my-zsh"

HIST_STAMPS="yyyy-mm-dd"
ZSH_CUSTOM="$HOME/dotfiles/configuration/shell/zsh"
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="cloud"

plugins=(git)

source "$ZSH/oh-my-zsh.sh"

# --- Shell Options

setopt AUTO_CD
setopt AUTO_PUSHD
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt SHARE_HISTORY

# --- Tools

# FNM (Change node version when changing directory)
eval "$(fnm env --use-on-cd --shell zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Homebrew Bash
if [[ -f "/opt/homebrew/bash" ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

export COLOR=true
export FORCE_COLOR=true

# --- Key Bindings

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# --- Path

typeset -U path

export PATH

