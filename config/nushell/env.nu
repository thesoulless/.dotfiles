# env.nu
#
# Installed by:
# version = "0.103.0"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

#########################################################################
# Aliases
#########################################################################
alias vim = nvim
alias vi = nvim
alias g = git
alias gw = g worktree
alias gwa = gw add
alias tf = tofu
# Tailscale is installed from tailscale.com (its network extension must come
# from the signed vendor package); the CLI lives inside the app bundle.
alias tailscale = /Applications/Tailscale.app/Contents/MacOS/Tailscale

#########################################################################
# PATH
#########################################################################
# `path add` (std) prepends in priority order, expands `~`, and de-dupes.
# Replaces the old `$env.path ++= [...]`, which *appended* — leaving Homebrew
# at lower precedence than the inherited system paths.
use std/util "path add"
let priority_paths = [
    # home-manager (nix-darwin module) and nix-darwin system packages; zsh gets
    # these from nix-darwin's /etc/zshrc, nushell has to add them itself.
    $"/etc/profiles/per-user/($env.USER)/bin"
    "/run/current-system/sw/bin"
    "~/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
    "/usr/local/sbin"
    "~/.local/scripts"
    "/nix/var/nix/profiles/default/bin"
]
path add ...$priority_paths
# Last resort for hand-installed binaries that have no nixpkgs package;
# machine-specific packaged tools belong in hosts/<name>.nix instead.
$env.PATH = ($env.PATH | append ($env.HOME | path join ".local/bin"))
# Rex terminals get REX_BIN_DIR but not always on PATH; its `rex` must come
# first so it matches the running server.
if ($env.REX_BIN_DIR? | is-not-empty) { path add $env.REX_BIN_DIR }

#########################################################################
# Env vars
#########################################################################
let env_vars = {
    XDG_CONFIG_HOME: ($env.HOME ++ "/.config")
}
load-env $env_vars

$env.GIT_EDITOR = "nvim"
# Machine-local, untracked overrides (secrets, work-only env). Optional:
# `source` needs a parse-time constant, and `source null` is a no-op.
const local_env = ("~/.env.local.nu" | path expand)
const local_env_or_null = if ($local_env | path exists) { $local_env } else { null }
source $local_env_or_null

#########################################################################
# Sources
#########################################################################
# Check if the Nix daemon script exists and source it
# if ("/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" | path exists) {
#    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
#}

#########################################################################
# Plugins
########################################################################
