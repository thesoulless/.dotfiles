#!/usr/bin/env zsh

for script in $(ls ./scripts)
do
    echo "running ./scripts/$script"
    ./scripts/$script
done

stowit() {
    echo "stow $1"
    stow -D $1
    stow $1
}

stowit "nvim"
stowit "tmux"

