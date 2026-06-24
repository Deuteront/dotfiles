#!/usr/bin/env bash
set -euo pipefail

# Main setup orchestrator. Run by bootstrap.sh on a fresh machine, but also
# safe to run on its own at any time to re-apply the configuration:
#
#   ~/dotfiles/scripts/setup.sh
#
# It performs three steps, in order:
#   1. Apply the macOS system defaults.
#   2. Install all tooling (Homebrew packages + language/CLI installers).
#   3. Symlink the dotfiles into place.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib/log.sh
source "$SCRIPT_DIR/lib/log.sh"

log_section "Setting up $(whoami)'s machine"
log_info "Dotfiles: $DOTFILES_DIR"

# Steps that fail are collected here instead of aborting the run, so a single
# flaky cask or network installer can't stop the rest (especially the symlinks)
# from being applied. Each entry is reported at the end with how to re-run it.
failed=()

# 1. macOS defaults ----------------------------------------------------------
log_section "Applying macOS defaults"
"$SCRIPT_DIR/defaults/macos.sh" || failed+=("macOS defaults — scripts/defaults/macos.sh")

# 2. Tooling -----------------------------------------------------------------
# Homebrew packages (also runnable on its own via scripts/brew.sh).
"$SCRIPT_DIR/brew.sh" || failed+=("Homebrew packages — scripts/brew.sh")

log_section "Installing tooling"
for installer in "$SCRIPT_DIR"/tooling/*.sh; do
  [[ -e "$installer" ]] || continue
  name="$(basename "$installer")"
  log_step "Running $name"
  bash "$installer" || failed+=("tooling — scripts/tooling/$name")
done

# 3. Symlinks ----------------------------------------------------------------
"$SCRIPT_DIR/symlinks.sh" || failed+=("symlinks — scripts/symlinks.sh")

# Summary --------------------------------------------------------------------
if (( ${#failed[@]} )); then
  log_section "Finished with ${#failed[@]} warning(s)"
  log_info "These steps did not complete cleanly. Re-run them individually:"
  for f in "${failed[@]}"; do
    log_warn "$f"
  done
else
  log_section "All done!"
fi
log_info "Open a new terminal (or run 'source ~/.zshrc') to pick up your shell config."
