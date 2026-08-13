#!/bin/sh
# direnv: single binary. The upstream installer picks the first writable dir
# in $PATH when bin_path is unset — nondeterministic, and it would leave
# uninstall with no known path — so bin_path is always set explicitly.
# It goes on the right side of the pipe, where bash can actually read it.
#
# The shell hook lives here, not in ~/.bashrc: modules never write shell config.
#
# Installer queries the GitHub API (rate-limited per IP). Set _direnv_version to
# a tag like 'v2.37.1' to pin, or export DIRENV_GITHUB_API_TOKEN to authenticate.

_direnv_bin_dir="$HOME/.local/bin"
_direnv_bin="$_direnv_bin_dir/direnv"
_direnv_data="$HOME/.local/share/direnv"
_direnv_version=''

install_direnv() {
    require_system_cmd curl
    mkdir -p "$_direnv_bin_dir"
    curl -sfL https://direnv.net/install.sh \
        | bin_path="$_direnv_bin_dir" version="$_direnv_version" bash
}

uninstall_direnv() {
    rm -f "$_direnv_bin"
    rm -rf "$_direnv_data"
    log "direnv removed"
}

is_installed_direnv() { [ -x "$_direnv_bin" ]; }

shell_direnv() {
    path_prepend "$_direnv_bin_dir"
    # direnv hook output is bash-specific; shell.sh is POSIX but sourced by bash.
    if [ -n "${BASH_VERSION:-}" ] && [ -x "$_direnv_bin" ]; then
        eval "$("$_direnv_bin" hook bash)"
    fi
}