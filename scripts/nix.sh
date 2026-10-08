#!/usr/bin/env bash
# Install Determinate Nix (multi-user, launchd daemon). Everything else
# Nix-related (packages, nix.custom.conf, the devenv cache, GC) is declared in
# flake.nix / darwin.nix / home.nix and applied by scripts/darwin.sh.
#
# Why Determinate rather than the nixos.org installer: its daemon is a signed
# binary that survives macOS major upgrades (the upstream installer's
# /bin/sh-wrapped launchd jobs got disabled by Background Task Management on
# macOS 26), it has a real uninstaller (/nix/nix-installer uninstall) and
# in-place upgrades (sudo determinate-nixd upgrade), and a first-party
# nix-darwin module. Cost: a vendor fork with a closed daemon; telemetry is
# opted out in darwin.nix.
set -eu

if command -v nix >/dev/null 2>&1; then
	echo "nix already installed: $(nix --version)"
	exit 0
fi

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
