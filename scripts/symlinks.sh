#!/usr/bin/env bash
set -euo pipefail

# Create the symlinks declared in configuration/symlinks.yaml.
#
# The manifest is a list of source/target pairs:
#
#   - source: configuration/shell/.zshrc   # path inside this repo
#     target: ~/.zshrc                      # where it should live in $HOME
#
# Existing files at the target are backed up (never silently destroyed),
# and links that already point at the right place are left untouched, so
# this script is safe to run repeatedly.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib/log.sh
source "$SCRIPT_DIR/lib/log.sh"

MANIFEST="$DOTFILES_DIR/configuration/symlinks.yaml"

if ! command -v yq &>/dev/null; then
  log_error "yq is required to read the symlink manifest but was not found."
  log_info "Install it with: brew install yq"
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  log_error "Symlink manifest not found: $MANIFEST"
  exit 1
fi

log_section "Linking dotfiles"
log_info "Manifest: $MANIFEST"

linked=0
unchanged=0
skipped=0
backed_up=0

count="$(yq '. | length' "$MANIFEST")"

for ((i = 0; i < count; i++)); do
  source="$(yq ".[$i].source" "$MANIFEST")"
  target="$(yq ".[$i].target" "$MANIFEST")"

  if [[ -z "$source" || "$source" == "null" || -z "$target" || "$target" == "null" ]]; then
    log_warn "Entry $i is missing a source or target, skipping."
    skipped=$((skipped + 1))
    continue
  fi

  src="$DOTFILES_DIR/$source"
  # Expand a leading ~ in the target into $HOME.
  dest="${target/#\~/$HOME}"

  if [[ ! -e "$src" ]]; then
    log_warn "Source does not exist, skipping: $source"
    skipped=$((skipped + 1))
    continue
  fi

  # Already linked to the right place — nothing to do.
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    log_success "Already linked: $target"
    unchanged=$((unchanged + 1))
    continue
  fi

  mkdir -p "$(dirname "$dest")"

  # Preserve whatever is currently at the target before replacing it.
  if [[ -e "$dest" || -L "$dest" ]]; then
    backup="$dest.backup.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    log_warn "Backed up existing $target -> $backup"
    backed_up=$((backed_up + 1))
  fi

  ln -s "$src" "$dest"
  log_success "Linked $target -> $source"
  linked=$((linked + 1))
done

log_section "Dotfiles linked"
log_info "linked: $linked   unchanged: $unchanged   backed up: $backed_up   skipped: $skipped"
