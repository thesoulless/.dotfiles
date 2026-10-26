local shell = "com.superlogical.terminal.shell"

rex.action{
  name  = "sessionizer",
  title = "Project Sessionizer",
  run   = function(ctx, args)
    local cmd = { os.getenv("HOME") .. "/.local/scripts/tmux-sessionizer" }
    -- The picker switches the app that asked, not whichever app is local.
    if ctx.client_id then
      cmd = { "env", "REX_CLIENT=" .. ctx.client_id, cmd[1] }
    end
    local _, err = rex.session.new_layer{
      bounds = { 0.25, 0.15, 0.5, 0.6 },
      focus  = true,
      layout = rex.layout.block{
        flavor  = shell,
        -- zsh, not the default shell: its /etc/zshenv puts the Nix
        -- profiles (fzf, jq) on PATH whatever the default shell is.
        options = { shell = "/bin/zsh", command = cmd },
      },
    }
    if err ~= nil then error(err, 0) end
  end,
}

rex.bind("ctrl+f", "sessionizer")
