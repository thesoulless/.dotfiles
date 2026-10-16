# Work laptop only. Shared config lives in darwin.nix / home.nix; a personal
# machine gets its own hosts/<role>.nix and an entry in flake.nix.
{ pkgs, user, ... }:

{
  home-manager.users.${user} = { config, pkgs, ... }: {
    home.packages = with pkgs; [
      gnupg
      # gcloud with the GKE auth plugin that ~/.kube/config relies on.
      (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]))
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

  # Caps lock -> escape on every keyboard, via a login agent (nix-darwin's
  # system.keyboard.* only runs hidutil during activation, which a reboot
  # loses; its Karabiner module is broken since Karabiner 15, nix-darwin#1041).
  # The ISO §/` swap is NOT done here: the built-in keyboard ignores hidutil
  # for those keys, so it lives in the keyboard layout instead (see
  # keylayout-isofix). Keyboards connected later, like a Bluetooth one
  # reconnecting, inherit the mapping.
  launchd.user.agents.keyboard-remap = {
    serviceConfig = {
      ProgramArguments = [
        "/usr/bin/hidutil" "property" "--set"
        ''{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}''
      ];
      RunAtLoad = true;
    };
  };
}
