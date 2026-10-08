# dotfiles

macOS environment managed by Nix: [Determinate Nix](https://determinate.systems),
[nix-darwin](https://github.com/nix-darwin/nix-darwin) and
[home-manager](https://github.com/nix-community/home-manager), from one flake.
The migration history and remaining ideas are in the header of `flake.nix`.

## Fresh machine

```sh
git clone https://github.com/thesoulless/.dotfiles ~/.dotfiles
cd ~/.dotfiles
# add the machine to the `hosts` table in flake.nix (key: `scutil --get LocalHostName`)
# and create hosts/<name>.nix, then:
./install.sh
```

`install.sh` installs Nix and runs `scripts/darwin.sh`, which builds the system
(no sudo), prints what changes, then `sudo darwin-rebuild switch`. Everything
else (packages, fonts, nix settings, dotfile links) comes from the flake.
Optional, untracked per-machine files: `~/.zshrc.local`, `~/.env.local.nu`,
and `~/.gitconfig.local` for that machine's default git identity (personal
directories are matched by rules in `home.nix`; elsewhere git refuses to
commit until an identity applies):

```ini
[user]
	name = Hamed Nemati
	email = <work address>
```

GUI apps: Ghostty comes from nixpkgs and appears in `~/Applications/Home
Manager Apps`. Tailscale is installed from tailscale.com, because its network
extension has to come from the signed vendor package.

## Day to day

| Task | Command |
|---|---|
| Apply a config change | `./scripts/darwin.sh` |
| Update all inputs | `nix flake update && ./scripts/darwin.sh`, then commit `flake.lock` |
| Roll back | `sudo darwin-rebuild --rollback` |
| Try a tool without installing it | `, tool args` (comma) |
| Which package ships a binary? | `nix-locate --minimal --at-root /bin/<name>` |

CI builds every host on a macOS runner for each push and PR, and every two
weeks a workflow opens a `flake.lock` update PR; merge it and run
`scripts/darwin.sh`. Nothing is merged or applied automatically.

Dotfiles are linked straight into this checkout (`home.nix`), so editing them
is live without a rebuild. Nix changes need a switch; new files must be
`git add`ed before Nix can see them.

## Layout

| Path | Purpose |
|---|---|
| `flake.nix` | inputs, the `hosts` table, wiring |
| `darwin.nix` | system: Nix daemon settings, fonts, Touch ID, nix-index |
| `home.nix` | user: packages, git identity, dotfile links, generated snippets |
| `hosts/<name>.nix` | what only that machine gets (e.g. work tooling) |
| `config/<app>/` | `~/.config/<app>` (nvim, nushell, atuin) |
| `tmux/` | `~/.config/tmux` (plugins come from nixpkgs) |
| `zsh/` | `~/.zshrc`, `~/.zsh_profile`, `~/.zsh_plugins.txt` (antidote) |
| `bin/` | `~/.local/scripts` (tmux-sessionizer and friends) |
| `scripts/` | bootstrap scripts |
