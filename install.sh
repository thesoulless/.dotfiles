#!/usr/bin/env zsh
# Bootstrap a fresh Mac: install Nix, then everything else comes from the flake
# (nix-darwin system config, home-manager packages and dotfile links).
cd "${0:a:h}"

./scripts/nix.sh || exit 1
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

./scripts/darwin.sh
