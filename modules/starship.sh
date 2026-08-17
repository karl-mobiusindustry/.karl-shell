#!/bin/sh
# starship: cross-shell prompt. Official install.sh drops a prebuilt binary in
# ~/.local/bin; -y skips the confirmation prompt since we're non-interactive.
#
# The README documents shell init as a separate manual step, so the installer
# should not touch rc files — install.sh's snapshot covers us either way.
#
# The prompt init lives in shell_starship, not ~/.bashrc: modules never write
# shell config. Note this must run AFTER anything else that sets PROMPT_COMMAND
# or PS1; starship wraps whatever it finds. Prefix this module (e.g. 90_) if
# ordering ever matters.
#
# Requires a Nerd Font in the terminal for glyphs — same dependency as eza's
# --icons, which is already working here.

_starship_bin_dir="$HOME/.local/bin"
_starship_bin="$_starship_bin_dir/starship"

install_starship() {
    require_system_cmd curl
    curl -sS https://starship.rs/install.sh \
        | sh -s -- -y --bin-dir "$_starship_bin_dir"
}

uninstall_starship() {
    rm -f "$_starship_bin"
    rm -f "$HOME/.config/starship.toml"
    rm -rf "$HOME/.cache/starship"
    log "starship removed"
}

is_installed_starship() { [ -x "$_starship_bin" ]; }

shell_starship() {
    path_prepend "$_starship_bin_dir"
    if [ -n "${BASH_VERSION:-}" ] && [ -x "$_starship_bin" ]; then
        eval "$("$_starship_bin" init bash)"
    fi
}
