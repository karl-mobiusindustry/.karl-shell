#!/bin/sh
install_uv() {
    has_cmd uv && { log "uv already installed"; return; }
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

uninstall_uv() {
    uv cache clean || true
    rm -rf "$(uv python dir)" || true
    rm -rf "$(uv tool dir)" || true
    rm -f ~/.local/bin/uv ~/.local/bin/uvx || true
    log "uv removed"
}

is_installed_uv() { has_cmd uv; }

shell_uv() {
    export PATH="$HOME/.local/bin:$PATH"
}