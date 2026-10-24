{
  # Declarative macOS environment: Determinate Nix + nix-darwin (system) +
  # home-manager as a nix-darwin module (user packages, dotfile links).
  # README.md has the bootstrap, daily commands and layout; git history has
  # the migration from the Brewfile/stow setup.
  #
  # Principles: everything that has a nixpkgs package comes from here; tools
  # are tried first with `, tool` (comma) and only then added to home.nix, or
  # to hosts/<role>.nix when only machines of one role need them; toolchains
  # arrive per project via devenv; configs are linked into this checkout so
  # edits are live without a rebuild; no Homebrew unless a cask is ever needed;
  # the untracked ~/.config/dotfiles/local.nix (account name, role),
  # ~/.gitconfig.local, ~/.zshrc.local and ~/.env.local.nu hold what must not
  # be in a public repo.
  #
  # Apply: ./scripts/darwin.sh   (build, show the closure diff, then switch)
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
    # Prebuilt nix-locate database (weekly) for command-not-found and comma.
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, determinate, nix-index-database, ... }:
    let
      # Who and where stay out of the repo: ~/.config/dotfiles/local.nix holds
      # `{ user = "<account name>"; role = "work"; }` and scripts/darwin.sh
      # passes its path in DOTFILES_LOCAL with --impure. Without it (CI) every
      # role still evaluates, for a placeholder user.
      local =
        let p = builtins.getEnv "DOTFILES_LOCAL";
        in if p == "" then { user = "nobody"; } else import p;
      user = local.user;

      # Configurations are keyed by role, not hostname; a machine picks its
      # role in local.nix, so a second machine of the same role needs no change.
      roles = {
        work = [ ./hosts/work.nix ];
        personal = [ ];
      };

      mkRole = role: modules:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs user; };
          modules = [
            determinate.darwinModules.default
            nix-index-database.darwinModules.nix-index
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
      darwinConfigurations = builtins.mapAttrs mkRole roles;
    };
}
