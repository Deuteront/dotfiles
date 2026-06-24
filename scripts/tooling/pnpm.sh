#!/usr/bin/env bash
set -euo pipefail

# pnpm — fast, disk-efficient package manager.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

if command -v pnpm &>/dev/null; then
  log_success "pnpm is already installed"
  exit 0
fi

log_step "Installing pnpm..."
curl -fsSL https://get.pnpm.io/install.sh | sh -
log_success "pnpm installed"
