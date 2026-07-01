#!/usr/bin/env bash
# Generate the nushell integration files that config.nu sources. nushell cannot
# run external commands during startup config evaluation, so these are produced
# ahead of time here. Only creates missing files — delete a file and re-run to
# refresh after a tool upgrade.
# (carapace is wired inline in config.nu, so it needs no generated file.)
set -eu

gen() { # gen <target-file> <command...>
	local target="$1"
	shift
	if [ ! -f "$target" ]; then
		mkdir -p "$(dirname "$target")"
		"$@" >"$target"
		echo "generated $target"
	fi
}

if command -v atuin >/dev/null 2>&1; then
	gen "$HOME/.local/share/atuin/init.nu" atuin init nu
fi
if command -v zoxide >/dev/null 2>&1; then
	gen "$HOME/.zoxide.nu" zoxide init nushell
fi
