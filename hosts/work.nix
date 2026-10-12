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

  # Key remapping with hidutil (nix-darwin's Karabiner module has been broken
  # since Karabiner 15, nix-darwin#1041). A login agent, because
  # system.keyboard.* only runs hidutil during activation, which a reboot
  # loses. Two steps: caps lock -> escape on every keyboard present at login,
  # then the built-in ISO keyboard additionally gets the §/± key (HID 0x64,
  # top left) swapped with `/~ (HID 0x35, next to left shift). A matched
  # --set replaces the whole mapping for that device, so it repeats caps lock.
  # Keyboards that connect later miss the first step; for those, System
  # Settings > Keyboard > Keyboard Shortcuts > Modifier Keys is the robust
  # per-keyboard fallback.
  launchd.user.agents.keyboard-remap = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh" "-c"
        ''
          /usr/bin/hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}' &&
          /usr/bin/hidutil property --matching '{"Product":"Apple Internal Keyboard / Trackpad"}' --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029},{"HIDKeyboardModifierMappingSrc":0x700000064,"HIDKeyboardModifierMappingDst":0x700000035},{"HIDKeyboardModifierMappingSrc":0x700000035,"HIDKeyboardModifierMappingDst":0x700000064}]}'
        ''
      ];
      RunAtLoad = true;
    };
  };
}
