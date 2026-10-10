#!/usr/bin/env zsh
# Bootstrap a fresh Mac: install Nix, then everything else comes from the flake
# (nix-darwin system config, home-manager packages and dotfile links).
cd "${0:a:h}"

# Identity stays out of the repo: account name and role (= hosts/<role>.nix).
local_nix="$HOME/.config/dotfiles/local.nix"
if [ ! -f "$local_nix" ]; then
    print -n "role for this machine [work]: "; read role; role=${role:-work}
    mkdir -p "${local_nix:h}"
    printf '{ user = "%s"; role = "%s"; }\n' "$USER" "$role" > "$local_nix"
    echo "wrote $local_nix"
fi

./scripts/nix.sh || exit 1
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

./scripts/darwin.sh
