source ~/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Load the theme.
antigen theme robbyrussell

antigen bundle zsh-users/zsh-autosuggestions

# Tell Antigen that you're done.
antigen apply

source ~/.zsh_profile

if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
else
    print "404: ~/.zshrc.local not found."
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
