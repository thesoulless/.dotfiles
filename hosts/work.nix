# Work laptop only. Shared config lives in darwin.nix / home.nix; a personal
# machine gets its own hosts/<role>.nix and an entry in flake.nix.
{ pkgs, user, ... }:

let
  # Apple's `container` (Linux VMs per container); pkgs/container-bin.nix.
  containerBin = pkgs.callPackage ../pkgs/container-bin.nix { };
in
{
  home-manager.users.${user} = { config, pkgs, ... }: {
    home.packages = with pkgs; [
      containerBin
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

  # GitHub Actions runner for the work org: one Linux arm64 VM run by Apple's
  # `container`, built and registered once with hosts/work/ci-runner/create.sh.
  # `container system start` bootstraps its launchd services for the current
  # login only, and containers have no restart policy, so this agent brings
  # both back after a reboot. The laptop has to stay logged in and awake
  # (sudo pmset -a disablesleep 1). Runner output: `container logs ci-runner`.
  launchd.user.agents.ci-runner = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.writeShellScript "ci-runner-start" ''
          set -eu
          container=${containerBin}/bin/container
          if ! "$container" system status >/dev/null 2>&1; then
            "$container" system start --enable-kernel-install
          fi
          state=$("$container" inspect ci-runner 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[0].status.state' || true)
          case "$state" in
            running) ;;
            "" | null) echo "ci-runner: not created yet; run hosts/work/ci-runner/create.sh" ;;
            *) "$container" start ci-runner ;;
          esac
        ''}"
      ];
      RunAtLoad = true;
      StandardOutPath = "/Users/${user}/Library/Logs/ci-runner.log";
      StandardErrorPath = "/Users/${user}/Library/Logs/ci-runner.log";
    };
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
