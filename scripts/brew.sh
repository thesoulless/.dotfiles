#!/usr/bin/env bash
# Install Homebrew itself if missing. Packages are NOT installed here anymore:
# nix-darwin's `homebrew` module (darwin.nix) generates the Brewfile and runs
# `brew bundle` on every `darwin-rebuild switch`.
set -eu

if ! command -v brew >/dev/null 2>&1 && [ ! -x /opt/homebrew/bin/brew ]; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
