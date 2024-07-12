#!/usr/bin/env bash
# selected='cc \n' + `cat ~/.tmux-cht-languages ~/.tmux-cht-command | fzf`
all=`cat ~/.tmux-cht-languages ~/.tmux-cht-command`
all+=("chat")
selected="$(printf "%s\n" "${all[@]}" | fzf)"
if [[ -z $selected ]]; then
    exit 0
fi

read -p "Enter Query: " query

if grep -qs "$selected" ~/.tmux-cht-languages; then
    query=`echo $query | tr ' ' '+'`
    tmux neww bash -c "echo \"curl cht.sh/$selected/$query/\" & curl cht.sh/$selected/$query & while [ : ]; do sleep 1; done"
elif grep -qs "$selected" ~/.tmux-cht-command; then
    tmux neww bash -c "curl -s cht.sh/$selected~$query | less"
else
    tmux neww bash -c "chatgpt $query | less"
fi
