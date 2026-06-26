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
alias tailscale = /Applications/Tailscale.app/Contents/MacOS/Tailscale
alias tf = terraform

#########################################################################
# PATH
#########################################################################
$env.path ++= [
    /opt/homebrew/bin
    /opt/homebrew/sbin
    /opt/homebrew/opt/curl/bin
    ($env.HOME ++ "/bin")
    /usr/local/bin
    /usr/bin
    /bin
    /usr/sbin
    /sbin
    /usr/local/sbin
    ($env.HOME ++ "/.local/scripts")
    ($env.HOME ++ "/.local/bin")
    ($env.HOME ++ "/.cargo/bin")
    ($env.HOME ++ "/.deno/bin")
    ($env.HOME ++ "/.bun/bin")
    /usr/local/go/bin
    /nix/var/nix/profiles/default/bin
]

$env.PATH = ($env.PATH | append ((go env GOPATH | str trim) ++ "/bin"))

#########################################################################
# Env vars
#########################################################################
let nvim_prefix = (which nvim | get 0?.path? | default "/opt/homebrew" | path expand | path dirname | path dirname)
let env_vars = {
    XDG_CONFIG_HOME: ($env.HOME ++ "/.config")
    VIMRUNTIME: ($nvim_prefix ++ "/share/nvim/runtime")
    VIM: 'nvim'
    GOROOT: '/usr/local/go'
}
load-env $env_vars

$env.GIT_EDITOR = $env.VIM
$env.BUN_INSTALL = ($env.HOME ++ "/.bun")
$env.DENO_INSTALL = ("/Users/" ++ $env.USER ++ "/.deno")
#########################################################################
# fnm (Fast Node Manager)
#########################################################################
$env.FNM_DIR = ($env.HOME ++ "/.local/share/fnm")
$env.FNM_LOGLEVEL = "info"
$env.FNM_NODE_DIST_MIRROR = "https://nodejs.org/dist"
$env.FNM_COREPACK_ENABLED = "false"
$env.FNM_RESOLVE_ENGINES = "true"
$env.FNM_VERSION_FILE_STRATEGY = "local"
$env.FNM_ARCH = "arm64"

# Create a per-session multishell symlink pointing to the default node version
let fnm_multishell_dir = ([$env.HOME ".local/state/fnm_multishells" (random uuid)] | path join)
let fnm_default = ($env.FNM_DIR | path join "aliases/default")
if ($fnm_default | path exists) {
    ln -s ($fnm_default | path expand) $fnm_multishell_dir
    $env.FNM_MULTISHELL_PATH = $fnm_multishell_dir
    $env.PATH = ($env.PATH | prepend ($fnm_multishell_dir | path join "bin"))
}

source ~/.env.local.nu

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
