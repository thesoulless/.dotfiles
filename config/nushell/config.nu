# config.nu
#
# Installed by:
# version = "0.103.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.
# use std/util "path add"

####################################################
# Plugins
####################################################
# nushell can't run externals during startup eval, so these init files are
# generated ahead of time: home-manager builds them from the atuin/zoxide in
# the flake closure (see home.nix, xdg.dataFile).
source ~/.local/share/nushell/init/atuin.nu
source ~/.local/share/nushell/init/zoxide.nu

# carapace — external completions for ~1000 CLIs (git, gh, kubectl, terraform…).
# Inline rather than `carapace _carapace nushell`: that generated script's first
# line does `$env.PATH | split row` and assumes PATH is a string — it errors on
# our list PATH and never registers the completer. This closure only shells out
# to carapace at completion time, so it's a no-op at startup.
$env.config.completions.external = {
    enable: true
    completer: {|spans|
        let expanded = (scope aliases | where name == $spans.0 | get -o 0.expansion)
        let spans = (if $expanded != null {
            $spans | skip 1 | prepend ($expanded | split row ' ' | take 1)
        } else {
            $spans
        })
        carapace $spans.0 nushell ...$spans | from json
    }
}

####################################################
# Nu Config
####################################################
$env.config.show_banner = false
$env.config.buffer_editor = "nvim"
$env.config.edit_mode = "vi"
$env.config.cursor_shape.vi_normal = "inherit"
$env.config.cursor_shape.vi_insert = "inherit"
# env_change.PWD is owned by zoxide (sourced above); the devenv autoload hook
# (autoload/devenv-hook.nu) appends to pre_prompt. Never reassign either with
# `= [...]` — that wipes those; always `| append`. So nothing extra is wired here.
# Nix paths and env (NIX_SSL_CERT_FILE etc.) need no setup here: nushell runs
# inside tmux under zsh, which gets them from nix-darwin's /etc/zshenv, and
# env.nu puts the Nix profile dirs first on PATH anyway.

####################################################
# Key Bindings
####################################################
$env.config.keybindings ++= [
	{
		name: hint_or_complete
		modifier: none
		keycode: tab
		mode: [emacs, vi_insert]
		event: {
			until: [
				{ send: HistoryHintComplete }
				{ send: Menu name: completion_menu }
				{ send: MenuNext }
			]
		}
	}
	{
		name: tmux_sessionizer
		modifier: control
		keycode: char_f
		mode: [emacs, vi_normal, vi_insert]
		event: [
			{ edit: InsertString,
				value: "tmux-sessionizer"
			}
			{ send: Enter }
		]
	}
	{
		name: stack_overflow
		modifier: control
		keycode: char_s
		mode: [emacs, vi_normal, vi_insert]
		event: [
			{edit: InsertString, value: "so"}
			{send: Enter}
		]
	}
    # {
    #     name: atuin
    #     modifier: control
    #     keycode: char_r
    #     mode: [emacs, vi_normal, vi_insert]
    #     event: { send: executehostcommand cmd: (_atuin_search_cmd) }
    # }
]

def rgf [pattern: string, path?: path] {
  let dir = ($path | default $env.PWD)
  let sel = (try {
    rg --hidden --no-ignore --line-number --no-heading --no-messages $pattern $dir
    | fzf --delimiter : --preview 'bat --color=always --highlight-line {2} {1}'
    | str trim
  } catch { "" })

  if ($sel | is-not-empty) {
    let parts = ($sel | split row ":")
    ^nvim $"+($parts.1)" $parts.0
  }
}
