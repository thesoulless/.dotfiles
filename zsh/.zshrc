source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh

autoload -Uz compinit
compinit

# Load the theme.
export ZSH_THEME="robbyrussell"

antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt

export XDG_CONFIG_HOME="$HOME/.config"

eval "$(direnv hook zsh)"


# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

source ~/.zsh_profile

if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
else
    print "404: ~/.zshrc.local not found."
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/hamed/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/hamed/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/hamed/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/hamed/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/hamed/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/hamed/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/hamed/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/hamed/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

db() {
    export USQL_PAGER='pspg';
    usql $@;
}

if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  export TERM=xterm-256color
fi

# bun completions
[ -s "/Users/hamed/.bun/_bun" ] && source "/Users/hamed/.bun/_bun"
# zprof

. "$HOME/.local/bin/env"
. "/Users/hamed/.deno/env"
