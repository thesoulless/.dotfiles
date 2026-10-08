# home-manager configuration for the primary user (see flake.nix for the plan).
{ pkgs, ... }:

{
  # CLI tools that used to be `brew "..."` lines in the Brewfile. All verified
  # available for aarch64-darwin in nixpkgs-unstable (2026-10).
  # Library-only formulae (little-cms2, jpeg-xl, aom, harfbuzz, openjpeg, webp,
  # libheif) are gone: ffmpeg/imagemagick bring their own deps under Nix.
  home.packages = with pkgs; [
    act
    ast-grep
    atuin
    cachix
    caddy
    carapace
    coreutils-prefixed   # g-prefixed like Homebrew's, so BSD ls/date/sed stay the default
    devenv
    direnv
    dprint
    e2fsprogs
    fd
    ffmpeg
    fnm
    ghostscript
    git                  # nixpkgs' git ships git-credential-osxkeychain on darwin
    glow
    graphviz
    htop
    imagemagick
    jq
    kubectl              # was: kubernetes-cli
    lazygit
    mkcert
    neovim
    nodejs               # LTS global fallback (was: node); bundles corepack, so no separate package
    opentofu
    p7zip
    pass
    pspg
    ripgrep
    stow
    tlrc
    tmux
    tokei
    tree-sitter          # was: tree-sitter-cli
    ttygif
    usql                 # was: xo/xo/usql (tap no longer needed)
    watchman
    web-ext
    yt-dlp
    zoxide
  ];

  # Leave at the value set on first install; see home-manager release notes.
  home.stateVersion = "26.05";
}
