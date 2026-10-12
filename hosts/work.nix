# Work laptop only. Shared config lives in darwin.nix / home.nix; a personal
# machine gets its own hosts/<name>.nix and an entry in flake.nix.
{ pkgs, user, ... }:

{
  home-manager.users.${user} = {
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

  # Work laptop has an ISO keyboard (the personal one is US, where ` and ~
  # are already in the right place, so this must not apply there).
  # ISO keyboard: swap the §/± key (HID 0x64, top left) with the `/~ key
  # (HID 0x35, next to left shift) so ` and ~ sit where the thumb expects them.
  # nix-darwin's system.keyboard.userKeyMapping only runs hidutil during
  # activation, which a reboot loses, so a login agent applies it instead.
  launchd.user.agents.keyboard-swap = {
    serviceConfig = {
      ProgramArguments = [
        # Only the built-in keyboard: external (US) keyboards keep their own
        # layout. `hidutil list` shows the product names.
        "/usr/bin/hidutil" "property" "--matching" ''{"Product":"Apple Internal Keyboard / Trackpad"}'' "--set"
        ''{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000064,"HIDKeyboardModifierMappingDst":0x700000035},{"HIDKeyboardModifierMappingSrc":0x700000035,"HIDKeyboardModifierMappingDst":0x700000064}]}''
      ];
      RunAtLoad = true;
    };
  };
}
