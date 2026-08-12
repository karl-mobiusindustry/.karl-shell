#!/bin/sh
# nvm: cloned to ~/.nvm. Env vars go on the right side of the pipe, where the
# interpreter actually is — a prefix on `curl` never reaches `bash`.

_nvm_version='v0.40.6'
_nvm_dir="$HOME/.nvm"

install_nvm() {
    require_system_cmd curl
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$_nvm_version/install.sh" \
        | PROFILE=/dev/null NVM_DIR="$_nvm_dir" bash
}

uninstall_nvm() {
    # nvm unload unsets NVM_DIR, so hold the path in a local first.
    _nvm_target="$_nvm_dir"
    NVM_DIR="$_nvm_target"; export NVM_DIR
    if [ -s "$_nvm_target/nvm.sh" ]; then
        # shellcheck disable=SC1090
        . "$_nvm_target/nvm.sh" >/dev/null 2>&1 || true
        command -v nvm >/dev/null 2>&1 && { nvm unload || true; }
    fi
    rm -rf "$_nvm_target"
    log "nvm removed"
}

is_installed_nvm() { [ -s "$_nvm_dir/nvm.sh" ]; }

shell_nvm() {
    NVM_DIR="$_nvm_dir"; export NVM_DIR
    # shellcheck disable=SC1090
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    # shellcheck disable=SC1090
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}