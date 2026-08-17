#!/bin/sh
# btop: resource monitor. Statically-linked musl binary from GitHub releases.
# The documented install runs `make install` into /usr/local with sudo; we do
# the same layout under ~/.local instead, which needs no privileges.
#
# The binary resolves system themes at ../share/btop/themes RELATIVE to itself,
# so the themes must go to ~/.local/share/btop/themes for the bundled 41 themes
# to be selectable. Binary alone would leave only the Default and TTY builtins.
#
# Note the README is out of date: assets are .tar.gz (not .tbz) and use the full
# target triple. Skipping `make setcap` (needs sudo) means no CPU wattage or
# Intel GPU stats.
#
# Config: ~/.config/btop  |  Log: ~/.local/state/btop.log (a file, not a dir)

_btop_bin_dir="$HOME/.local/bin"
_btop_bin="$_btop_bin_dir/btop"
_btop_share_dir="$HOME/.local/share/btop"

install_btop() {
    require_system_cmd curl
    require_system_cmd tar

    _btop_arch="$(uname -m)"
    case "$_btop_arch" in
        x86_64)  _btop_target=x86_64-unknown-linux-musl ;;
        aarch64) _btop_target=aarch64-unknown-linux-musl ;;
        armv7l)  _btop_target=armv7-unknown-linux-musleabi ;;
        i686)    _btop_target=i686-unknown-linux-musl ;;
        riscv64) _btop_target=riscv64-unknown-linux-musl ;;
        *) err "btop: unsupported architecture $_btop_arch"; exit 1 ;;
    esac

    _btop_url="https://github.com/aristocratos/btop/releases/latest/download/btop-${_btop_target}.tar.gz"

    _btop_tmp="$(mktemp -d)"
    if curl -fsSL "$_btop_url" -o "$_btop_tmp/btop.tar.gz"; then
        tar -xzf "$_btop_tmp/btop.tar.gz" -C "$_btop_tmp"
        mkdir -p "$_btop_bin_dir" "$_btop_share_dir/themes"
        cp "$_btop_tmp/btop/bin/btop" "$_btop_bin"
        chmod +x "$_btop_bin"
        cp "$_btop_tmp/btop/themes/"*.theme "$_btop_share_dir/themes/"
        rm -rf "$_btop_tmp"
    else
        rm -rf "$_btop_tmp"
        err "btop: download failed for $_btop_url"
        exit 1
    fi
}

uninstall_btop() {
    rm -f "$_btop_bin"
    rm -rf "$_btop_share_dir"
    rm -rf "$HOME/.config/btop"
    rm -f "$HOME/.local/state/btop.log"
    log "btop removed"
}

is_installed_btop() { [ -x "$_btop_bin" ]; }

shell_btop() {
    path_prepend "$_btop_bin_dir"
}
