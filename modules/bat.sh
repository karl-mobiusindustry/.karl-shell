#!/bin/sh
# bat: cat clone with syntax highlighting. Prebuilt musl binary from GitHub
# releases (statically linked; the apt package installs as `batcat` and needs
# sudo, so we take the release tarball).
#
# Tarball layout: bat-v<ver>-<target>/{bat,bat.1,autocomplete/}. We extract
# only the binary.
#
# GitHub API resolves "latest" and is rate-limited per IP. Set _bat_version to
# a tag like '0.25.0' to pin and skip the API call.

_bat_bin_dir="$HOME/.local/bin"
_bat_bin="$_bat_bin_dir/bat"
_bat_version=''

install_bat() {
    require_system_cmd curl
    require_system_cmd tar

    _bat_arch="$(uname -m)"
    case "$_bat_arch" in
        x86_64)        _bat_target=x86_64-unknown-linux-musl ;;
        aarch64|arm64) _bat_target=aarch64-unknown-linux-musl ;;
        *) err "bat: unsupported architecture $_bat_arch"; exit 1 ;;
    esac

    _bat_ver="$_bat_version"
    if [ -z "$_bat_ver" ]; then
        _bat_ver="$(curl -fsSL https://api.github.com/repos/sharkdp/bat/releases/latest \
            | grep '"tag_name"' | head -n1 | cut -d'"' -f4)"
        _bat_ver="${_bat_ver#v}"
    fi
    [ -n "$_bat_ver" ] || { err "bat: could not resolve latest version"; exit 1; }

    _bat_dir="bat-v${_bat_ver}-${_bat_target}"
    _bat_url="https://github.com/sharkdp/bat/releases/download/v${_bat_ver}/${_bat_dir}.tar.gz"

    _bat_tmp="$(mktemp -d)"
    if curl -fsSL "$_bat_url" -o "$_bat_tmp/bat.tar.gz"; then
        tar -xzf "$_bat_tmp/bat.tar.gz" -C "$_bat_tmp"
        mkdir -p "$_bat_bin_dir"
        cp "$_bat_tmp/$_bat_dir/bat" "$_bat_bin"
        chmod +x "$_bat_bin"
        rm -rf "$_bat_tmp"
    else
        rm -rf "$_bat_tmp"
        err "bat: download failed for $_bat_url"
        exit 1
    fi
}

uninstall_bat() {
    rm -f "$_bat_bin"
    # Config dir and the syntax/theme binary cache built by `bat cache --build`.
    rm -rf "$HOME/.config/bat"
    rm -rf "$HOME/.cache/bat"
    log "bat removed"
}

is_installed_bat() { [ -x "$_bat_bin" ]; }

shell_bat() {
    path_prepend "$_bat_bin_dir"
    BAT_STYLE="plain"; export BAT_STYLE
    BAT_PAGING="never"; export BAT_PAGING
    alias cat='bat'
}