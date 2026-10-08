# Work laptop only. Shared config lives in darwin.nix / home.nix; a personal
# machine gets its own hosts/<name>.nix and an entry in flake.nix.
{ pkgs, user, ... }:

{
  home-manager.users.${user}.home.packages = with pkgs; [
    kubectl
    opentofu
  ];

  # Work laptop has an ISO keyboard (the personal one is US, where ` and ~
  # are already in the right place, so this must not apply there).
  # ISO keyboard: swap the §/± key (HID 0x64, top left) with the `/~ key
  # (HID 0x35, next to left shift) so ` and ~ sit where the thumb expects them.
  # nix-darwin's system.keyboard.userKeyMapping only runs hidutil during
  # activation, which a reboot loses, so a login agent applies it instead.
  launchd.user.agents.keyboard-swap = {
    serviceConfig = {
      ProgramArguments = [
        "/usr/bin/hidutil" "property" "--set"
        ''{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000064,"HIDKeyboardModifierMappingDst":0x700000035},{"HIDKeyboardModifierMappingSrc":0x700000035,"HIDKeyboardModifierMappingDst":0x700000064}]}''
      ];
      RunAtLoad = true;
    };
  };
}
