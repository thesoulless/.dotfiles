# Work laptop only. Shared config lives in darwin.nix / home.nix; a personal
# machine gets its own hosts/<name>.nix and an entry in flake.nix.
{ pkgs, user, ... }:

{
  home-manager.users.${user} = {
    home.packages = with pkgs; [
      gnupg
      insomnia
      kubectl
      opentofu
      pinentry_mac # gpg passphrase prompts via a native dialog
    ];
    home.file.".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
      default-cache-ttl 600
      max-cache-ttl 7200
    '';
  };
}
