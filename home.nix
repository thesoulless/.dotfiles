# home-manager configuration for the primary user (shared by every host; see README.md).
{ config, lib, pkgs, ... }:

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
    "ghostty".source = link "config/ghostty";
    "rex".source = link "config/rex";
    "direnv/direnv.toml".source = link "config/direnv/direnv.toml";
    # git's default global-excludes path, so no core.excludesfile needed.
    "git/ignore".source = link "config/git/ignore";
    # Personal commit-message lint; repos opt in via `commit-msg-lint --install`.
    "git/hooks/commit-msg-lint".source = link "bin/commit-msg-lint";
    "tmux/tmux.conf".source = link "tmux/tmux.conf";
    # tmux plugins from nixpkgs (no tpm). tmux/tmux.conf sources this file;
    # `set -g @resurrect-*` / `@continuum-*` options must come before it.
    "tmux/plugins.conf".text = ''
      run-shell ${pkgs.tmuxPlugins.resurrect.rtp}
      run-shell ${pkgs.tmuxPlugins.continuum.rtp}
    '';
  };
  # Keyboard layout: Apple's ABC with the ISO quirk fixed. On the built-in
  # keyboard the key under Esc gives `/~ and the key next to left shift
  # gives §/±; other keyboards are unchanged. Generated from a Ukelele export
  # of ABC with
  #   keylayout-isofix "ABC copy.keylayout" ABCISO "ABC ISO" config/keyboard-layouts
  # Add "ABC ISO" under System Settings > Keyboard > Input Sources after a
  # logout. (hidutil cannot remap these two keys on the built-in keyboard;
  # modifiers like caps lock it can.)
  # Copied, not linked: macOS ignores symlinked bundles in Keyboard Layouts.
  home.activation.keyboardLayouts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dest="$HOME/Library/Keyboard Layouts/ABCISO.bundle"
    src=${./config/keyboard-layouts/ABCISO.bundle}
    if ! diff -rq "$src" "$dest" >/dev/null 2>&1; then
      run rm -rf "$dest"
      run cp -R "$src" "$dest"
      run chmod -R u+w "$dest"
    fi
  '';

  home.file = {
    ".zshrc".source = link "zsh/zshrc";
    ".zsh_profile".source = link "zsh/zsh_profile";
    ".zsh_plugins.txt".source = link "zsh/zsh_plugins.txt";
    ".local/scripts".source = link "bin";
    # nushell's config dir on macOS when XDG_CONFIG_HOME isn't set yet, as
    # for a nu that Rex starts directly with launchd's environment.
    "Library/Application Support/nushell".source = link "config/nushell";
    ".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
      default-cache-ttl 600
      max-cache-ttl 7200
    '';
  };

  programs.git = {
    enable = true;
    # Identity by directory. Order matters: git takes the last matching value,
    # so the machine-wide default (untracked ~/.gitconfig.local, e.g. the work
    # identity on the work laptop) comes first and the personal directories
    # override it. Outside any rule git refuses to commit (useConfigOnly)
    # rather than guessing.
    includes =
      let
        personal = {
          user.name = "Hamed Nemati";
          user.email = "hitech.innovative@gmail.com";
        };
      in
      [
        { path = "~/.gitconfig.local"; }
        { condition = "gitdir:~/.dotfiles/"; contents = personal; }
        { condition = "gitdir:~/go/src/github.com/thesoulless/"; contents = personal; }
        { condition = "gitdir:~/go/src/github.com/hamednz/"; contents = personal; }
      ];
    settings = {
      user.useConfigOnly = true;
      init.defaultBranch = "main";
      # `git push` on a new branch sets upstream itself; pulls rebase.
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase = {
        autoStash = true;
        updateRefs = true; # rebasing a stack moves the branches on it too
      };
      fetch.prune = true;
      # Remember how conflicts were resolved and replay that next time.
      rerere.enabled = true;
      merge.conflictStyle = "zdiff3";
      diff.algorithm = "histogram";
      branch.sort = "-committerdate";
      commit.verbose = true; # show the diff in the commit message editor
      help.autocorrect = "prompt";
      column.ui = "auto";
    };
  };

  # GitHub CLI; its credential helper lets git push over https after `gh auth login`.
  programs.gh = {
    enable = true;
    settings.aliases.co = "pr checkout";
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

  # CLI tools wanted on every machine (work-only ones: hosts/work.nix).
  # Occasional tools are not listed: `, tool` (comma) runs them from nixpkgs
  # on demand; per-project ones (formatters, mkcert, toolchains) come from
  # each project's devenv.
  home.packages = with pkgs; [
    (callPackage ./pkgs/agentaps-bin.nix { })
    antidote
    atuin
    bat
    carapace
    claude-code          # CLI; `claude auth login` is what the ACP adapter authenticates with
    claude-agent-acp     # provides `claude-agent-acp`: Claude Code over ACP, for Agentaps
    daisydisk
    devenv
    direnv
    fd
    ffmpeg
    fzf
    ghostty-bin          # vendor-signed Ghostty.app, lands in ~/Applications/Home Manager Apps
    glow
    gnupg
    htop
    iina
    imagemagick
    jq
    lazygit
    lua-language-server  # lua_ls for nvim (was mason-installed)
    neovim
    nixd                 # Nix LSP; nvim enables it when on PATH
    nixfmt
    nodejs               # LTS; bundles corepack. Per-project versions come from devenv.
    nushell
    pass
    pinentry_mac         # gpg passphrase prompts via a native dialog
    pspg
    ripgrep
    rsync                # macOS ships openrsync (rsync 2.6.9 compatible): no --info=progress2
    stylua               # Lua formatter conform expects
    tmux
    tree-sitter          # was: tree-sitter-cli
    usql                 # was: xo/xo/usql (tap no longer needed)
    yt-dlp
    zoxide
  ];

  # Leave at the value set on first install; see home-manager release notes.
  home.stateVersion = "26.05";
}
