#!/bin/sh
# Rust toolchain via rustup. Installs to ~/.cargo and ~/.rustup.
#
# -y is required: the script is piped, so it has no tty to prompt on and
# aborts without it. --no-modify-path keeps rustup out of shell config;
# PATH is our job, in shell_cargo. Env vars go on the right side of the
# pipe, where sh actually reads them.
#
# Name this 01_cargo.sh (or any NN_ prefix) if a later module needs to
# `cargo install` something — the prefix is stripped from the function names.

_cargo_home="$HOME/.cargo"
_cargo_bin_dir="$_cargo_home/bin"
_rustup_home="$HOME/.rustup"

install_cargo() {
    require_system_cmd curl
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | CARGO_HOME="$_cargo_home" RUSTUP_HOME="$_rustup_home" \
          sh -s -- -y --no-modify-path
}

uninstall_cargo() {
    if [ -x "$_cargo_bin_dir/rustup" ]; then
        CARGO_HOME="$_cargo_home" RUSTUP_HOME="$_rustup_home" \
            "$_cargo_bin_dir/rustup" self uninstall -y || true
    fi
    rm -rf "$_cargo_home" "$_rustup_home"
    log "cargo removed"
}

is_installed_cargo() { [ -x "$_cargo_bin_dir/cargo" ]; }

shell_cargo() {
    path_prepend "$_cargo_bin_dir"
}