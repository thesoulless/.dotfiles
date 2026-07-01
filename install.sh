#!/usr/bin/env zsh

# Run bootstrap scripts in an explicit order (brew first — it installs `stow`,
# which the stowit() calls below depend on). kubectl.sh needs sudo, so it's
# opt-in: run `./scripts/kubectl.sh` by hand if you want kubectl.
scripts=(brew.sh nix.sh uv.sh tmux.sh nushell-init.sh)
for script in $scripts; do
    echo "running ./scripts/$script"
    ./scripts/$script
done

stowit() {
    echo "stow $1"
    stow -R "$1" || echo "  ⚠ stow $1 had conflicts — remove the pre-existing non-symlink target(s) and re-run"
}

stowit "nushell"
stowit "nvim"
stowit "tmux"
stowit "bin"
stowit "atuin"
stowit "zsh"
stowit "nix"
