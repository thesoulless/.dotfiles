#!/usr/bin/env bash
# Install Nix (official installer) and the tools that live in the user's nix
# profile. `nix-env` is intentionally not used: profiles created by `nix profile`
# are incompatible with it ("profile is incompatible with 'nix-env'").
set -eu

if ! command -v nix >/dev/null 2>&1; then
	curl -L https://nixos.org/nix/install -o /tmp/nix-install.sh
	sh /tmp/nix-install.sh
	rm -f /tmp/nix-install.sh
	# shellcheck disable=SC1091
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# `nix profile add` (nix >= 2.29) replaced `nix profile install`; support both.
profile_add() {
	nix profile add "$1" 2>/dev/null || nix profile install "$1"
}

profile_add nixpkgs#cachix
cachix use devenv
profile_add nixpkgs#devenv
# Upgrade later with: nix profile upgrade devenv
