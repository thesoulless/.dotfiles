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
source ~/.local/share/atuin/init.nu
source ~/.zoxide.nu


####################################################
# Nu Config
####################################################
$env.config.buffer_editor = "nvim"
$env.config.edit_mode = "vi"
$env.config.cursor_shape.vi_normal = "inherit"
$env.config.cursor_shape.vi_insert = "inherit"

$env.config.hooks.env_change.PWD = [(source nu-hooks/direnv/config.nu)]
$env.config.hooks.pre_prompt = (
    $env.config.hooks.pre_prompt | append (source nu-hooks/direnv/config.nu)
)

$env.config = $env.config | upsert hooks {
    pre_prompt: ($env.config.hooks.pre_prompt | default [] | append {||
        job spawn { atuin history start ... }
    })
    pre_execution: ($env.config.hooks.pre_execution | default [] | append {||
        job spawn { atuin history end ... }
    })
}

####################################################
# Key Bindings
####################################################
$env.config.keybindings ++= [
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
