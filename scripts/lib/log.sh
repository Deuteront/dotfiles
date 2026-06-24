#!/usr/bin/env bash
# Shared pretty-printing helpers used across the dotfiles scripts.
#
# Source this file to get consistent, colorized progress output:
#
#   source "$(dirname "${BASH_SOURCE[0]}")/lib/log.sh"
#
#   log_section "Installing tooling"
#   log_step    "Installing fnm"
#   log_success "fnm installed"
#   log_warn    "Skipping, already present"
#   log_error   "Something went wrong"

# Only emit color codes when writing to an interactive terminal.
if [[ -t 1 ]]; then
  _C_BOLD=$'\033[1m'
  _C_DIM=$'\033[2m'
  _C_RESET=$'\033[0m'
  _C_RED=$'\033[31m'
  _C_GREEN=$'\033[32m'
  _C_YELLOW=$'\033[33m'
  _C_BLUE=$'\033[34m'
  _C_CYAN=$'\033[36m'
else
  _C_BOLD="" _C_DIM="" _C_RESET="" _C_RED="" _C_GREEN="" _C_YELLOW="" _C_BLUE="" _C_CYAN=""
fi

# A bold, spaced banner that announces a new phase of work.
log_section() {
  printf '\n%s==>%s %s%s%s\n' "$_C_BOLD$_C_BLUE" "$_C_RESET" "$_C_BOLD" "$*" "$_C_RESET"
}

# A single action being taken inside a section.
log_step() {
  printf '%s  •%s %s\n' "$_C_CYAN" "$_C_RESET" "$*"
}

# Secondary, indented detail (paths, hints, counts).
log_info() {
  printf '%s    %s%s\n' "$_C_DIM" "$*" "$_C_RESET"
}

# A successfully completed action.
log_success() {
  printf '%s  ✓%s %s\n' "$_C_GREEN" "$_C_RESET" "$*"
}

# A non-fatal warning (skipped, backed up, already present).
log_warn() {
  printf '%s  !%s %s\n' "$_C_YELLOW" "$_C_RESET" "$*"
}

# A fatal error — goes to stderr.
log_error() {
  printf '%s  ✗ %s%s\n' "$_C_RED" "$*" "$_C_RESET" >&2
}
