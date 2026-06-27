#!/usr/bin/env bash
set -euo pipefail

# Remote bootstrap for a brand-new Mac. This is the only thing you run by hand:
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Deuteront/dotfiles/main/bootstrap.sh)"
#
# It installs the prerequisites that aren't on a clean macOS install
# (Xcode CLT, Homebrew, git, yq), clones the dotfiles repo, and then hands
# off to scripts/setup.sh to do the actual configuration.

DOTFILES_REPO="https://github.com/Deuteront/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# Minimal banner helper — bootstrap runs via `curl | bash` before the repo
# (and its lib/log.sh) exists, so it can't rely on the shared helpers.
say() { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }

say "Hello $(whoami)! Setting up your Mac."
echo "    You may be asked for your password along the way."

# Ask for the administrator password upfront and keep the sudo session alive
# for the duration of the bootstrap so later steps don't re-prompt.
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Xcode Command Line Tools — provides git and the compilers Homebrew needs.
if ! xcode-select -p &>/dev/null; then
  say "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "    Finish the installation in the dialog, then press any key to continue."
  read -n 1 -s
else
  say "Xcode Command Line Tools already installed."
fi

# Homebrew — the package manager everything else is installed through.
if ! command -v brew &>/dev/null; then
  say "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Put brew on PATH for the rest of this script.
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  say "Homebrew already installed."
fi

# git is needed to clone the repo; yq is needed by the symlink step.
say "Installing git and yq..."
brew install git yq

say "Creating ~/projects..."
mkdir -p "$HOME/projects"

# Clone (or update) the dotfiles repo.
if [[ -d "$DOTFILES_DIR/.git" ]]; then
  say "Dotfiles already cloned — pulling latest into $DOTFILES_DIR..."
  git -C "$DOTFILES_DIR" pull --ff-only
else
  say "Cloning dotfiles into $DOTFILES_DIR..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Hand off to the main setup orchestrator.
say "Handing off to setup.sh..."
bash "$DOTFILES_DIR/scripts/setup.sh"

say "Bootstrap complete. Welcome aboard!"
