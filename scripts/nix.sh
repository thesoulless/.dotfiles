curl -L https://nixos.org/nix/install -o nix.sh
sh nix.sh
rm nix.sh

nix-env -iA cachix -f https://cachix.org/api/v1/install
cachix use devenv

nix-env -if https://install.devenv.sh/latest
