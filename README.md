# dotfiles

mfklauberg's dotfiles.

## Setup a new Mac

Open Terminal and run:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mfklauberg/dotfiles/main/bootstrap.sh)"
```

This installs the prerequisites (Xcode Command Line Tools, Homebrew, git, yq),
clones this repo to `~/dotfiles`, and runs the full setup: macOS defaults,
Homebrew packages, tooling, and dotfile symlinks.

## Re-running things

Everything is safe to run again at any time.

Run the full setup:

```sh
~/dotfiles/scripts/setup.sh
```

Install just the Homebrew packages (handy after adding an entry to the
[`Brewfile`](configuration/homebrew/Brewfile)):

```sh
~/dotfiles/scripts/brew.sh
```
