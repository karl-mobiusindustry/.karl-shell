#!/bin/sh
# starship: cross-shell prompt. Official install.sh drops a prebuilt binary in
# ~/.local/bin; -y skips the confirmation prompt since we're non-interactive.
# Verified: the installer only prints shell-init instructions, it does not
# write to rc files.
#
# The prompt init lives in shell_starship, not ~/.bashrc: modules never write
# shell config. Must run AFTER anything else touching PROMPT_COMMAND — starship
# wraps what it finds, so atuin and direnv hooks survive. Alphabetical order
# already gives us that; prefix this module if it ever stops holding.
#
# ~/.config/starship.toml is written by install and removed by uninstall: it is
# the module's config, not user state. is_installed checks BOTH artifacts so a
# missing config is repaired by a plain install.sh run without re-downloading.
#
# python_binary routes version detection through uv. Starship resolves plain
# `python`/`python3` from PATH and cannot see uv or shell aliases, so in a uv
# project it otherwise reports /usr/bin/python3 instead of the project's
# interpreter. Starship's own docs flag this as potentially dangerous: uv will
# run whatever binary sits at .venv/bin/python, without interaction, on every
# prompt render in that directory.

_starship_bin_dir="$HOME/.local/bin"
_starship_bin="$_starship_bin_dir/starship"
_starship_config="$HOME/.config/starship.toml"

install_starship() {
    require_system_cmd curl

    if [ ! -x "$_starship_bin" ]; then
        curl -sS https://starship.rs/install.sh \
            | sh -s -- -y --bin-dir "$_starship_bin_dir"
    fi

    mkdir -p "$(dirname "$_starship_config")"
    cat > "$_starship_config" << 'STARSHIP_TOML'
[python]
python_binary = [['uv', 'run', '--no-python-downloads', '--no-project', 'python']]
STARSHIP_TOML
}

uninstall_starship() {
    rm -f "$_starship_bin"
    rm -f "$_starship_config"
    rm -rf "$HOME/.cache/starship"
    log "starship removed"
}

is_installed_starship() {
    [ -x "$_starship_bin" ] && [ -f "$_starship_config" ]
}

shell_starship() {
    path_prepend "$_starship_bin_dir"
    if [ -n "${BASH_VERSION:-}" ] && [ -x "$_starship_bin" ]; then
        eval "$("$_starship_bin" init bash)"
    fi
}