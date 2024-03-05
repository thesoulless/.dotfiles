if [[ $(command -v brew) == "" ]]; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/hamed/.zprofile
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install tmux
brew install lima
brew install fzf
brew install stow
brew install neovim
brew install node
brew install direnv
brew install pyenv
brew install pyenv-virtualenv
brew install ripgrep

# To install useful key bindings and fuzzy completion:
$(brew --prefix)/opt/fzf/install
brew install tlrc

brew install jq
brew install terraform
brew install antidote
brew install glow
brew install pspg
brew install xo/xo/usql
