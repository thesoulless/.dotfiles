#!/usr/bin/env bash
# tmux plugin manager; plugins themselves are installed from inside tmux (prefix+I).
set -eu
[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
