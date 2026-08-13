#!/bin/sh
# just: single static binary, installed to ~/.local/bin by the upstream
# install.sh. Writes nothing to shell config (it only prints a PATH hint).
#
# install.sh queries the GitHub API to resolve the latest release and is
# rate-limited per IP. Set _just_version to a tag (e.g. '1.42.4') to pin and
# skip the API call if you hit limits.

_just_bin_dir="$HOME/.local/bin"
_just_bin="$_just_bin_dir/just"
_just_version=''

install_just() {
    require_system_cmd curl
    if [ -n "$_just_version" ]; then
        curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh \
            | bash -s -- --to "$_just_bin_dir" --tag "$_just_version"
    else
        curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh \
            | bash -s -- --to "$_just_bin_dir"
    fi
}

uninstall_just() {
    rm -f "$_just_bin"
    log "just removed"
}

is_installed_just() { [ -x "$_just_bin" ]; }

shell_just() {
    path_prepend "$_just_bin_dir"
}