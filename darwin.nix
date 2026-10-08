# nix-darwin system configuration (see flake.nix for the migration plan).
{ pkgs, inputs, user, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Owner of the Homebrew install and of user-scoped options such as
  # system.defaults. Also the account that runs `darwin-rebuild`.
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

  # `sudo darwin-rebuild switch` with Touch ID. (Inside tmux this needs
  # pam_reattach, which nix-darwin does not ship; later.)
  security.pam.services.sudo_local.touchIdAuth = true;

  # Installed into /Library/Fonts/Nix Fonts (was: cask "font-jetbrains-mono").
  fonts.packages = [ pkgs.jetbrains-mono ];

  # Homebrew is not installed by this module (scripts/brew.sh does that); it
  # only drives `brew bundle` with the list below on every switch.
  homebrew = {
    enable = true;
    # Still Homebrew because the shell configs reference /opt/homebrew paths
    # (tmux default-shell, antidote.zsh, ~/.fzf.zsh). Migration step 2.
    brews = [ "antidote" "fzf" "nushell" ];
    # "uninstall" later, once everything Homebrew-installed is declared here
    # (avoid "zap" if masApps ever get added: it also removes App Store apps).
    onActivation.cleanup = "none";
  };

  # Shown by `darwin-rebuild --list-generations`.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Bump only when nix-darwin's release notes ask for it.
  system.stateVersion = 7;
}
