#!/usr/bin/env bash
# Build and activate the flake: nix-darwin system config, home-manager
# packages and dotfile links. The build runs without sudo first, so errors
# surface before any password prompt and the closure diff shows what the
# switch will change. The first run bootstraps darwin-rebuild via `nix run`.
#
# Identity comes from ~/.config/dotfiles/local.nix (see install.sh), read with
# --impure so neither the account name nor the machine appears in the repo.
# Flakes only see git-tracked files: `git add` new files before running.
set -eu

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL="${DOTFILES_LOCAL:-$HOME/.config/dotfiles/local.nix}"
[ -f "$LOCAL" ] || { echo "darwin.sh: $LOCAL missing; run ./install.sh once" >&2; exit 1; }
role=$(sed -nE 's/.*role *= *"([^"]+)".*/\1/p' "$LOCAL" | head -1)
[ -n "$role" ] || { echo "darwin.sh: no role = \"...\" in $LOCAL" >&2; exit 1; }
FLAKE="$DOTFILES#$role"
cd "$DOTFILES"
export DOTFILES_LOCAL="$LOCAL"

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
	# Branch must match nix-darwin.url in flake.nix. `env` carries the
	# variable past sudo's environment reset.
	exec sudo env DOTFILES_LOCAL="$LOCAL" nix run nix-darwin/master#darwin-rebuild -- switch --impure --flake "$FLAKE"
fi

darwin-rebuild build --impure --flake "$FLAKE"
echo "--- changes vs the running system:"
nix store diff-closures /run/current-system ./result || true
rm -f ./result
sudo env DOTFILES_LOCAL="$LOCAL" darwin-rebuild switch --impure --flake "$FLAKE"
