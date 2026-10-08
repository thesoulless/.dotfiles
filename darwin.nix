# nix-darwin system configuration (see flake.nix for the migration plan).
{ pkgs, inputs, user, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # The account that runs `darwin-rebuild`; user-scoped options such as
  # system.defaults apply to it.
  system.primaryUser = user;
  users.users.${user}.home = "/Users/${user}";

  # Determinate Nix owns the daemon and /etc/nix/nix.conf; this module turns
  # nix-darwin's own nix.* options off (so no nix.settings / nix.gc here).
  # customSettings -> /etc/nix/nix.custom.conf, determinateNixd ->
  # /etc/determinate/config.json. Exit path if we ever drop Determinate:
  # `/nix/nix-installer uninstall`, install NixOS/nix-installer, delete this
  # block and the flake input, and move the settings into nix.settings.
  #
  # Rule: no Determinate-only features anywhere in this flake (wasm builtins,
  # flake schemas, lazy-trees-dependent behaviour, FlakeHub Cache, the native
  # Linux builder). Everything must keep evaluating on upstream Nix so the exit
  # above stays a one-reinstall job.
  determinateNix = {
    enable = true;
    customSettings = {
      # Lets the user-level ~/.config/nix/nix.conf (stow `nix` package) and
      # devenv's per-project caches take effect. nix-command + flakes are
      # already on in Determinate's base nix.conf.
      trusted-users = [ "root" user ];
      # Replaces `cachix use devenv` from the old scripts/nix.sh.
      extra-substituters = [ "https://devenv.cachix.org" ];
      extra-trusted-public-keys = [ "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" ];
    };
    determinateNixd = {
      # Background GC by the daemon (replaces nix.gc / nix.optimise).
      garbageCollector.strategy = "automatic";
      # No crash reports to Sentry.
      telemetry.sentry.endpoint = null;
      # Native Linux builder for building Linux images on this Mac; enable
      # when needed: builder.state = "enabled";
    };
    # Opt out of the remaining usage telemetry (CLI side).
    envVars.DETSYS_IDS_TELEMETRY = "disabled";
  };

  # /etc/zshenv then puts /run/current-system/sw/bin and
  # /etc/profiles/per-user/<user>/bin on PATH for every zsh (login shell).
  # nushell gets the same paths from nushell/.config/nushell/env.nu.
  programs.zsh.enable = true;

  # Apple's Command Line Tools 26.6 bundle a macOS 27 beta SDK next to the real
  # 26.x one, and xcrun picks the newest. Its .tbd stubs declare an arm64e.x1
  # slice that the bundled linker (ld-1267) rejects ("tapi error: malformed
  # file"), which breaks every native link outside Nix: cgo, nvim-treesitter
  # parsers, cargo. Pin the SDK matching the running OS. Drop once a CLT
  # release links against its own newest SDK again. Nix builds are unaffected
  # (nixpkgs ships its own SDK).
  environment.variables.SDKROOT = "/Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk";

  # `sudo darwin-rebuild switch` with Touch ID, also inside tmux (pam_reattach).
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # "command not found" names the nixpkgs package, `nix-locate` searches the
  # prebuilt index, and `, tool args` runs a binary from nixpkgs without
  # installing it. This is how tools get tried before they earn a place in
  # home.nix or hosts/<name>.nix.
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  # Installed into /Library/Fonts/Nix Fonts (was: cask "font-jetbrains-mono").
  fonts.packages = [ pkgs.jetbrains-mono ];

  # No Homebrew: nothing is left in it and GUI apps come from IT's Company
  # Portal. If a cask is ever needed: install Homebrew, then
  #   homebrew = { enable = true; casks = [ "..." ]; onActivation.cleanup = "uninstall"; };

  # macOS settings. Keyboard ones need a logout/login to apply; Dock and
  # Finder are restarted by the switch. Unsetting an option here leaves the
  # value as is (nix-darwin never restores Apple's default), so revert by hand.
  system.defaults = {
    NSGlobalDomain = {
      # Fast key repeat, and holding a key repeats it instead of opening the
      # accent popup (vim: held j/k must scroll).
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
    };
    finder.AppleShowAllExtensions = true;
    dock.show-recents = false;
  };

  # Shown by `darwin-rebuild --list-generations`.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Bump only when nix-darwin's release notes ask for it.
  system.stateVersion = 7;
}
