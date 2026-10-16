# Re-point SSH_AUTH_SOCK at the socket launchd's ssh-agent currently listens
# on, after an agent restart left this shell with a stale path.
def --env fixsshagent [] {
    let sock = (
        launchctl print $"gui/(id -u)/com.openssh.ssh-agent"
        | parse -r 'SSH_AUTH_SOCK => (?<s>\S+)'
        | get -o s.0
    )
    if $sock == null {
        error make { msg: "com.openssh.ssh-agent has no SSH_AUTH_SOCK in launchd" }
    }
    $env.SSH_AUTH_SOCK = $sock
    # New tmux panes inherit the server's env, not this shell's.
    if "TMUX" in $env { tmux setenv -g SSH_AUTH_SOCK $sock }
    print $"SSH_AUTH_SOCK = ($sock)"
    ssh-add -l
}
