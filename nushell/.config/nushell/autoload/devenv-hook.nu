# devenv hook for nushell
#
# Loaded automatically (no config.nu edit needed) when devenv is installed via
# Nix, which ships this under $nu.vendor-autoload-dirs. If you're running a
# devenv build that didn't install it there, add it to your own autoload dir:
#   mkdir ($nu.default-config-dir | path join autoload)
#   devenv hook nu | save --force ($nu.default-config-dir | path join autoload/devenv-hook.nu)

# The project dir we last auto-activated. Lets you `exit` a devenv shell back to
# the parent shell without it immediately re-spawning; cleared once you cd
# elsewhere. `devenv hook-should-activate` is cheap (static binary), so apart
# from this guard the hook runs it every prompt — no result caching, so
# `devenv allow`/`revoke` take effect on the next prompt without a re-`cd`.
$env._DEVENV_HOOK_ACTIVATED = ""
# Last directory reported as untrusted, so the "not allowed" hint is shown once
# per entry rather than on every prompt.
$env._DEVENV_HOOK_UNTRUSTED = ""

# `_DEVENV_HOOK_DIR` marks the one shell process the hook itself spawned;
# it gates the cd-out `exit` so externally-set `DEVENV_ROOT` (e.g. via
# direnv) does not close the user's terminal. Capture it into a plain
# variable, then remove it from `$env` so it cannot leak into further
# descendants (a new tmux/zellij pane, a manually started nested
# shell, ...) started from this shell later on — those would otherwise
# inherit it, wrongly conclude they too are hook-spawned, and `exit` on
# cd-out with nothing around to catch them.
let _devenv_hook_dir = ("_DEVENV_HOOK_DIR" in $env)
hide-env -i _DEVENV_HOOK_DIR

# devenv decides a directory is a project by walking up for a `devenv.nix`
# (a lone `devenv.yaml` is not one). Mirrored here so the hook can answer
# "nothing to activate" from a few stats instead of a 50-400 ms devenv spawn.
def _devenv_project_dir [] {
    mut dir = $env.PWD
    loop {
        if ([$dir devenv.nix] | path join | path exists) {
            return $dir
        }
        let parent = ($dir | path dirname)
        if $parent == $dir {
            return null
        }
        $dir = $parent
    }
}

def --env _devenv_hook [] {
    if ("DEVENV_ROOT" in $env) {
        if $_devenv_hook_dir {
            if not ($env.PWD == $env.DEVENV_ROOT or ($env.PWD | str starts-with ($env.DEVENV_ROOT + "/"))) {
                $env.PWD | save --force ($env.DEVENV_ROOT + "/.devenv/exit-dir")
                # `exit` throws ShellError::Exit, which is only handled at the
                # REPL top level; from inside a hook nushell reports
                # "Exit doesn't catch internally" and the shell survives.
                # Signal ourselves instead so the process really terminates.
                ^kill $nu.pid
            }
        }
        return
    }

    # Just exited the devenv shell for this dir — don't re-spawn until you leave.
    if ($env._DEVENV_HOOK_ACTIVATED == $env.PWD) {
        return
    }
    $env._DEVENV_HOOK_ACTIVATED = ""

    if (_devenv_project_dir) == null {
        $env._DEVENV_HOOK_UNTRUSTED = ""
        return
    }

    let result = (^devenv hook-should-activate | complete)
    let retrying = ($env._DEVENV_HOOK_UNTRUSTED == $env.PWD)
    if not $retrying and ($result.stderr | str trim) != "" {
        print -e $result.stderr
    }

    if $result.exit_code == 0 {
        let dir = ($result.stdout | str trim)
        if $dir != "" {
            $env._DEVENV_HOOK_UNTRUSTED = ""
            # Mark activated before launching so exiting the shell doesn't re-launch.
            $env._DEVENV_HOOK_ACTIVATED = $env.PWD
            # `try`: a hook-spawned shell that leaves the project terminates
            # itself with a signal, so `devenv shell` exits 128+SIGTERM. Without
            # `try` nushell aborts the hook on that non-zero exit and never
            # follows the user to `exit-dir` below.
            try {
                with-env { _DEVENV_HOOK_DIR: $dir, _DEVENV_CALLER: "hook", _DEVENV_SHELL_HINT: "nu" } { do { cd $dir; ^devenv shell } }
            }
            let exit_dir_file = ($dir + "/.devenv/exit-dir")
            if ($exit_dir_file | path exists) {
                let target_dir = (open $exit_dir_file | str trim)
                rm -f $exit_dir_file
                if ($target_dir | path exists) {
                    cd $target_dir
                    # We followed the user out, so the "don't re-spawn" guard
                    # above no longer applies: it only exists for exiting the
                    # shell and staying put. Leaving it set to the project dir
                    # would silently skip activation the next time the user
                    # cd's back in.
                    $env._DEVENV_HOOK_ACTIVATED = ""
                }
            }
        } else {
            $env._DEVENV_HOOK_UNTRUSTED = ""
        }
    } else {
        $env._DEVENV_HOOK_UNTRUSTED = $env.PWD
    }
}

# Run on every prompt: inside a project each prompt re-checks, so `devenv
# allow`/`revoke` take effect without a re-`cd`; outside one the walk above
# short-circuits before anything is spawned.
$env.config = ($env.config | upsert hooks.pre_prompt (
    ($env.config | get -o hooks.pre_prompt | default []) | append {|| _devenv_hook }
))
