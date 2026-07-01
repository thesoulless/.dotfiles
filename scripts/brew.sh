#!/usr/bin/env bash
# Install Homebrew if missing, then sync all packages from the repo Brewfile.
# The Brewfile (repo root) is the single source of truth — edit it, not this script.
set -eu

if ! command -v brew >/dev/null 2>&1; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zprofile"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# Brewfile lives at the repo root, one level up from scripts/.
BREWFILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/Brewfile"
brew bundle install --file="$BREWFILE"

# Install fzf key bindings & fuzzy completion without touching shell rc files
# (we wire fzf ourselves in .zshrc / nushell config).
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc || true
