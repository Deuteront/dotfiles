#!/usr/bin/env bash
set -euo pipefail

# Claude Code — Anthropic's agentic CLI.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/log.sh"

if command -v claude &>/dev/null; then
  log_success "Claude Code is already installed"
  exit 0
fi

log_step "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash
log_success "Claude Code installed"
