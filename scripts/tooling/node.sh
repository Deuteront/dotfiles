#!/usr/bin/env bash
set -euo pipefail

# fnm — Fast Node Manager. Switches Node versions automatically per directory
# (wired up in .zshrc via `fnm env --use-on-cd`).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

if command -v fnm &>/dev/null; then
  log_success "fnm is already installed"
  exit 0
fi

log_step "Installing fnm (Fast Node Manager)..."
curl -fsSL https://fnm.vercel.app/install | bash
log_success "fnm installed"
