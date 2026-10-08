# Work laptop only. Shared config lives in darwin.nix / home.nix; a personal
# machine gets its own hosts/<name>.nix and an entry in flake.nix.
{ pkgs, user, ... }:

{
  home-manager.users.${user}.home.packages = with pkgs; [
    kubectl
    opentofu
  ];
}
