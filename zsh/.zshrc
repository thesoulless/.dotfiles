# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh

zmodload zsh/complist
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
setopt MENU_COMPLETE

# Load zsh-vi-mode synchronously so subsequent plugins' keybindings (atuin, autosuggestions) aren't clobbered.
ZVM_INIT_MODE=sourcing

antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt

# Hand-rolled prompt: dir + git branch/dirty + arrow that turns red on non-zero exit.
git_prompt_info() {
  local branch
  branch=$(command git symbolic-ref --short HEAD 2>/dev/null) \
    || branch=$(command git rev-parse --short HEAD 2>/dev/null) \
    || return
  local dirty=""
  [[ -n $(command git status --porcelain --ignore-submodules 2>/dev/null) ]] && dirty=" ✗"
  print -n " %F{blue}git:(%F{red}${branch}%F{blue})%f%F{yellow}${dirty}%f"
}
setopt PROMPT_SUBST
PROMPT='%(?.%F{green}.%F{red})➜%f %F{cyan}%~%f$(git_prompt_info) '

# Hide ohmyzsh's theme-internal functions from tab completion.
zstyle ':completion:*' ignored-patterns 'VCS_INFO_*' '*_prompt_info'

# Tab widget: accept the shadow suggestion when present; otherwise insert a literal tab.
# (Bound below, after ~/.fzf.zsh, so fzf-completion doesn't steal ^I.)
_tab_accept_suggestion() {
  if [[ -n "$POSTDISPLAY" ]]; then
    zle autosuggest-accept
  else
    zle expand-or-complete
  fi
}
zle -N _tab_accept_suggestion

export XDG_CONFIG_HOME="$HOME/.config"

eval "$(devenv hook zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(fnm env --use-on-cd --shell zsh)"


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

# Bind tab AFTER fzf, since ~/.fzf.zsh binds ^I to fzf-completion and would otherwise win.
bindkey -M viins '^I' _tab_accept_suggestion
bindkey -M emacs '^I' _tab_accept_suggestion

# Ctrl-G: dismiss the autosuggestion shadow without accepting it.
bindkey -M viins '^G' autosuggest-clear
bindkey -M emacs '^G' autosuggest-clear

# Inside the completion menu: hjkl + Enter to accept, Esc to cancel.
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect '^M' .accept-line
bindkey -M menuselect '^[' send-break

# conda is intentionally NOT initialized at startup (it slowed every shell and
# uv is the day-to-day Python tool). To use it on demand in a session, run:
#   eval "$(/Users/hamed/miniconda3/bin/conda shell.zsh hook)"

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

. "$HOME/.cargo/env"
