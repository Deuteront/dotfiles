#!/usr/bin/env bash
set -euo pipefail

# Set up an SSH key for GitHub. This is interactive (it signs you in to GitHub),
# so it lives outside the unattended setup flow — run it once on a new machine:
#
#   ~/dotfiles/scripts/ssh.sh
#
# It generates an ed25519 key (only if one doesn't already exist), wires it into
# the macOS Keychain, registers it on GitHub via the gh CLI, and verifies the
# connection. Safe to run again — existing pieces are detected and left alone.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/log.sh
source "$SCRIPT_DIR/lib/log.sh"

KEY="$HOME/.ssh/id_ed25519"
SSH_CONFIG="$HOME/.ssh/config"

log_section "Setting up a GitHub SSH key"

# 1. Generate the key --------------------------------------------------------
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [[ -f "$KEY" ]]; then
  log_success "SSH key already exists: $KEY"
else
  comment="$(git config --global user.email 2>/dev/null || true)"
  [[ -z "$comment" ]] && comment="$(whoami)@$(hostname)"
  log_step "Generating an ed25519 key for $comment"
  log_info "You'll be asked for a passphrase — press Enter twice to skip it."
  ssh-keygen -t ed25519 -C "$comment" -f "$KEY"
  log_success "Key generated: $KEY"
fi

# 2. Wire it into the agent + macOS Keychain ---------------------------------
if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
  log_step "Adding a github.com block to $SSH_CONFIG"
  cat >> "$SSH_CONFIG" <<EOF

Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile $KEY
EOF
  chmod 600 "$SSH_CONFIG"
else
  log_success "$SSH_CONFIG already has a github.com block"
fi

log_step "Loading the key into the ssh-agent + Keychain"
ssh-add --apple-use-keychain "$KEY" 2>/dev/null || ssh-add "$KEY"

# 3. Register the public key on GitHub via gh --------------------------------
if ! command -v gh &>/dev/null; then
  log_error "The gh CLI is not installed — run scripts/brew.sh first."
  log_info "Then add the key manually: https://github.com/settings/ssh/new"
  log_info "Public key:"
  cat "$KEY.pub"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  log_step "Signing in to GitHub (gh auth login)"
  gh auth login
fi

title="$(scutil --get ComputerName 2>/dev/null || hostname)"
log_step "Registering the key on GitHub as \"$title\""
if gh ssh-key add "$KEY.pub" --title "$title" 2>/tmp/gh-ssh-key.err; then
  log_success "Key registered on GitHub"
else
  if grep -qi "already" /tmp/gh-ssh-key.err; then
    log_success "Key is already registered on GitHub"
  else
    log_warn "Could not register the key automatically:"
    log_info "$(cat /tmp/gh-ssh-key.err)"
    log_info "If it's a permissions error, run: gh auth refresh -h github.com -s admin:public_key"
    log_info "...then re-run this script, or add it manually: https://github.com/settings/ssh/new"
  fi
fi
rm -f /tmp/gh-ssh-key.err

# 4. Verify ------------------------------------------------------------------
log_step "Verifying the connection to GitHub"
# `ssh -T git@github.com` exits 1 even on success, so check the message instead.
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  log_success "GitHub SSH is working"
else
  log_warn "Could not confirm the GitHub SSH connection — try: ssh -T git@github.com"
fi
