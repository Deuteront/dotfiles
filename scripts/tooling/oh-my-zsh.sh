#!/usr/bin/env bash
set -euo pipefail

# Oh My Zsh — the framework the linked .zshrc is built on (it sources
# $ZSH/oh-my-zsh.sh and uses the "cloud" theme + git plugin).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  log_success "Oh My Zsh is already installed"
  exit 0
fi

log_step "Installing Oh My Zsh..."
# KEEP_ZSHRC keeps our own .zshrc (symlinked later) instead of replacing it;
# RUNZSH/CHSH stop the installer from launching a shell or changing it.
RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
log_success "Oh My Zsh installed"
