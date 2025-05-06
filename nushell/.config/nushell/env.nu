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
# Env vars
#########################################################################
let env_vars = {
    XDG_CONFIG_HOME: ($env.HOME ++ "/.config")
    VIMRUNTIME: '/opt/homebrew/Cellar/neovim/0.11.1/share/nvim/runtime'
    VIM: 'nvim'
    GOROOT: '/usr/local/go'
}
load-env $env_vars

$env.GIT_EDITOR = $env.VIM
$env.BUN_INSTALL = ($env.HOME ++ "/.bun")
$env.DENO_INSTALL = ("/Users/" ++ $env.USER ++ "/.deno")
source ~/.env.local.nu
source ./nix-profile.nu

#########################################################################
# PATH
#########################################################################
$env.path ++= [($env.HOME ++ "/.local/scripts")]
$env.path ++= [($env.BUN_INSTALL ++ "/bin")]
$env.path ++= [
	($env.HOME ++ "/bin")
	/usr/local/bin
	/usr/bin
	/bin
	/usr/sbin
	/sbin
	/usr/local/sbin
	($env.GOROOT ++ "/bin")
	/opt/homebrew/bin
	/opt/homebrew/sbin
	/opt/homebrew/opt/curl/bin
	($env.HOME ++ "/.deno/bin")
]

$env.PATH = ($env.PATH | append ((go env GOPATH | str trim) ++ "/bin"))

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
