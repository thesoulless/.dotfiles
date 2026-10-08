# home-manager configuration for the primary user (see flake.nix for the plan).
{ config, pkgs, ... }:

let
  # Dotfiles are linked straight into this checkout rather than copied into
  # the store, so an edit is live immediately with no rebuild (what stow did).
  # Trade-off: they are not part of a generation, so rollback doesn't cover them.
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  xdg.configFile = {
    "nvim".source = link "config/nvim";
    "nushell".source = link "config/nushell";
    "atuin/config.toml".source = link "config/atuin/config.toml";
    "tmux/tmux.conf".source = link "tmux/tmux.conf";
    # tmux plugins from nixpkgs (no tpm). tmux/tmux.conf sources this file;
    # `set -g @resurrect-*` / `@continuum-*` options must come before it.
    "tmux/plugins.conf".text = ''
      run-shell ${pkgs.tmuxPlugins.resurrect.rtp}
      run-shell ${pkgs.tmuxPlugins.continuum.rtp}
    '';
  };
  home.file = {
    ".zshrc".source = link "zsh/zshrc";
    ".zsh_profile".source = link "zsh/zsh_profile";
    ".zsh_plugins.txt".source = link "zsh/zsh_plugins.txt";
    ".local/scripts".source = link "bin";
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Hamed Nemati";
      email = "hitech.innovative@gmail.com";
    };
  };

  # Shell init snippets generated at build time from the exact atuin/zoxide in
  # this closure, so they can never go stale on upgrade (replaces
  # scripts/nushell-init.sh). nushell/config.nu sources them from
  # ~/.local/share/nushell/init/. Deliberately not under a vendor/autoload
  # dir: config.nu controls the load order explicitly.
  xdg.dataFile = {
    # ~/.local/share/antidote -> the store copy; .zshrc sources it from there.
    # (The per-user profile only links a fixed set of share/ subdirs, and
    # share/antidote is not one of them.)
    "antidote".source = "${pkgs.antidote}/share/antidote";
    # atuin init wants a writable $HOME for its settings; the hook gives it one.
    "nushell/init/atuin.nu".source =
      pkgs.runCommand "atuin-init.nu" { nativeBuildInputs = [ pkgs.writableTmpDirAsHomeHook ]; } ''
        ${pkgs.atuin}/bin/atuin init nu > $out
      '';
    "nushell/init/zoxide.nu".source = pkgs.runCommand "zoxide-init.nu" { } ''
      ${pkgs.zoxide}/bin/zoxide init nushell > $out
    '';
  };

  # CLI tools wanted on every machine (work-only ones: hosts/work.nix). All
  # verified available for aarch64-darwin in nixpkgs-unstable (2026-10).
  # Library-only formulae (little-cms2, jpeg-xl, aom, harfbuzz, openjpeg, webp,
  # libheif) are gone: ffmpeg/imagemagick bring their own deps under Nix.
  home.packages = with pkgs; [
    antidote
    ast-grep
    atuin
    cachix
    carapace
    coreutils-prefixed   # g-prefixed like Homebrew's, so BSD ls/date/sed stay the default
    devenv
    direnv
    dprint
    fd
    ffmpeg
    fzf
    ghostscript
    glow
    graphviz
    htop
    imagemagick
    jq
    lazygit
    lua-language-server  # lua_ls for nvim (was mason-installed)
    mkcert
    neovim
    nixd                 # Nix LSP; nvim enables it when on PATH
    nixfmt
    nodejs               # LTS; bundles corepack. Per-project versions come from devenv.
    nushell
    p7zip
    pass
    pspg
    ripgrep
    stylua               # Lua formatter conform expects
    tlrc
    tmux
    tokei
    tree-sitter          # was: tree-sitter-cli
    usql                 # was: xo/xo/usql (tap no longer needed)
    yt-dlp
    zoxide
  ];

  # Leave at the value set on first install; see home-manager release notes.
  home.stateVersion = "26.05";
}
