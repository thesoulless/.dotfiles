#!/usr/bin/env bash
# Build and activate the flake: nix-darwin system config, home-manager
# packages and dotfile links. The build runs without sudo first, so errors
# surface before any password prompt and the closure diff shows what the
# switch will change. The first run bootstraps darwin-rebuild via `nix run`.
#
# Flakes only see git-tracked files: `git add` new files before running.
set -eu

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLAKE="$DOTFILES#$(scutil --get LocalHostName)"
cd "$DOTFILES"

# The Determinate installer leaves a comment-only placeholder here; the
# determinateNix module manages this file and nix-darwin refuses to overwrite
# unrecognised /etc files. Move it aside on the first switch only, and only if
# it holds nothing but comments. (Tests the output, not grep's exit status:
# macOS 26's grep is ugrep, whose -q/-v and /dev/null exit codes differ from BSD.)
custom=/etc/nix/nix.custom.conf
if [ -f "$custom" ] && [ ! -L "$custom" ] && [ -z "$(grep -Ev '^[[:space:]]*(#|$)' "$custom")" ]; then
	sudo mv "$custom" "$custom.before-nix-darwin"
fi

if ! command -v darwin-rebuild >/dev/null 2>&1; then
	# Write flake.lock as the user first; otherwise the sudo run below creates
	# it root-owned and every later `nix flake update` fails.
	nix flake lock
	# Branch must match nix-darwin.url in flake.nix.
	exec sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake "$FLAKE"
fi

darwin-rebuild build --flake "$FLAKE"
echo "--- changes vs the running system:"
nix store diff-closures /run/current-system ./result || true
rm -f ./result
sudo darwin-rebuild switch --flake "$FLAKE"
