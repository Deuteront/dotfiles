#!/usr/bin/env bash
set -euo pipefail

# Install everything declared in the Brewfile.
#
# Safe to run on its own any time you add a new entry — `brew bundle` only
# installs what's missing, so it's quick and idempotent:
#
#   ~/dotfiles/scripts/brew.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib/log.sh
source "$SCRIPT_DIR/lib/log.sh"

BREWFILE="$DOTFILES_DIR/configuration/homebrew/Brewfile"

# Put brew on PATH even in a fresh shell that hasn't loaded the user's profile.
if ! command -v brew &>/dev/null; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

if ! command -v brew &>/dev/null; then
  log_error "Homebrew is not installed."
  log_info "Install it from https://brew.sh or run bootstrap.sh first."
  exit 1
fi

if [[ ! -f "$BREWFILE" ]]; then
  log_error "Brewfile not found: $BREWFILE"
  exit 1
fi

log_section "Installing Homebrew packages"
log_info "Brewfile: $BREWFILE"
brew bundle --file="$BREWFILE"
log_success "Homebrew packages up to date"
