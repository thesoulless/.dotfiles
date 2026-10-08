{
  # Declarative macOS environment: Determinate Nix + nix-darwin (system,
  # Homebrew bundle, fonts) + home-manager as a nix-darwin module (user
  # packages; later shell integration and dotfiles).
  #
  # Migration from the Brewfile/stow setup, one committed step at a time:
  #   1. (done) CLI packages -> home.nix; nix settings, devenv cache, fonts,
  #      Touch ID sudo -> darwin.nix. The Brewfile's `go install` tools are
  #      dropped (see step 3). stow still links all configs.
  #   2. (this) Shell plumbing: nushell/antidote/fzf from Nix and Homebrew
  #      removed entirely; home-manager generates the atuin/zoxide nushell
  #      snippets at build time (replaces scripts/nushell-init.sh); zsh uses
  #      `fzf --zsh` and a linked antidote (replaces ~/.fzf.zsh); tmux starts
  #      `nu` via zsh's PATH instead of a hardcoded path; programs.git carries
  #      the identity; fnm dropped in favour of nix nodejs + devenv; nixd,
  #      nixfmt, stylua, lua-language-server from Nix instead of mason.
  #   3. Toolchains: Go and its tools (gopls, golangci-lint, staticcheck, ...)
  #      from nixpkgs or per-project devenv; uv/bun/deno/rustup/fnm stay
  #      imperative until each project is covered by devenv.
  #   4. Dotfiles: home-manager owns configs; nvim and nushell via
  #      mkOutOfStoreSymlink so they stay editable in place; retire stow.
  #   Later, when the base is stable: system.defaults, nix-index-database;
  #   Homebrew (via nix-darwin's module) only if a cask is ever needed.
  #
  # Per-machine differences live in hosts/<name>.nix (work vs personal laptop);
  # darwin.nix and home.nix are shared. Binaries that exist in no nixpkgs
  # package go in ~/.local/bin by hand (last resort, appended to PATH).
  #
  # Apply: ./scripts/darwin.sh   (= sudo darwin-rebuild switch --flake ~/.dotfiles)
  # Update inputs: nix flake update && ./scripts/darwin.sh
  # Rollback: sudo darwin-rebuild --rollback
  description = "hamed's macOS environment";

  inputs = {
    # Rolling, like Homebrew was. nixpkgs-unstable (not nixos-unstable) is the
    # branch whose gating jobs include aarch64-darwin builds. For a slower base
    # pin nixpkgs-26.05-darwin / nix-darwin-26.05 / home-manager release-26.05.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Determinate Nix's nix-darwin module (daemon, /etc/nix/nix.conf, GC).
    # Deliberately not following our nixpkgs: it ships a prebuilt Nix.
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, determinate, ... }:
    let
      # One entry per machine, keyed by `scutil --get LocalHostName` (what
      # `darwin-rebuild --flake ~/.dotfiles` looks up).
      hosts = {
        "WORK-MAC" = {
          user = "me";
          modules = [ ./hosts/work.nix ];
        };
      };

      mkHost = host: { user, modules }:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs user; };
          modules = [
            determinate.darwinModules.default
            ./darwin.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              # Install into /etc/profiles/per-user/<user> instead of ~/.nix-profile,
              # so the user profile stays free for ad-hoc `nix profile add`.
              home-manager.useUserPackages = true;
              # If home-manager ever wants to write a file that already exists
              # (e.g. a stow symlink), keep a copy instead of aborting.
              home-manager.backupFileExtension = "hm-backup";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.${user} = import ./home.nix;
            }
          ] ++ modules;
        };
    in
    {
      darwinConfigurations = builtins.mapAttrs mkHost hosts;
    };
}
