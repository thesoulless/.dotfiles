#!/usr/bin/env bash
# Build and activate the flake: nix-darwin system config, home-manager
# packages and the Homebrew bundle. Needs sudo (system activation runs as root).
# The first run bootstraps darwin-rebuild via `nix run`; afterwards it is on PATH.
#
# Flakes only see git-tracked files: `git add` new *.nix files before running.
set -eu

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLAKE="$DOTFILES#$(scutil --get LocalHostName)"

# The Determinate installer leaves a comment-only placeholder here; the
# determinateNix module manages this file and nix-darwin refuses to overwrite
# unrecognised /etc files. Move it aside on the first switch only, and only if
# it holds nothing but comments. (Tests the output, not grep's exit status:
# macOS 26's grep is ugrep, whose -q/-v and /dev/null exit codes differ from BSD.)
custom=/etc/nix/nix.custom.conf
if [ -f "$custom" ] && [ ! -L "$custom" ] && [ -z "$(grep -Ev '^[[:space:]]*(#|$)' "$custom")" ]; then
	sudo mv "$custom" "$custom.before-nix-darwin"
fi

if command -v darwin-rebuild >/dev/null 2>&1; then
	sudo darwin-rebuild switch --flake "$FLAKE"
else
	# Branch must match nix-darwin.url in flake.nix.
	sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake "$FLAKE"
fi
