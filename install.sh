#!/usr/bin/env zsh
# Bootstrap a fresh Mac. Order matters:
#   nix.sh    – Nix itself (sudo, interactive)
#   darwin.sh – `darwin-rebuild switch`: nix-darwin + home-manager packages (incl.
#               stow), all from flake.nix
#   stow      – link the configs
#   tmux.sh   – clone tpm (tmux plugins)
cd "${0:a:h}"

./scripts/nix.sh || exit 1
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

./scripts/darwin.sh || exit 1
# What darwin-rebuild just installed (this shell predates /etc/zshrc changes).
export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

stowit() {
    echo "stow $1"
    stow -R "$1" || echo "  ⚠ stow $1 had conflicts — remove the pre-existing non-symlink target(s) and re-run"
}
stowit "nushell"
stowit "nvim"
stowit "tmux"
stowit "bin"
stowit "atuin"
stowit "zsh"

./scripts/tmux.sh
