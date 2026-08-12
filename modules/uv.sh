#!/bin/sh
# uv: installed to ~/.local/bin. Env vars go on the right side of the pipe —
# that's the process that reads them. PATH is our job, in shell_uv.

_uv_bin_dir="$HOME/.local/bin"
_uv_bin="$_uv_bin_dir/uv"

install_uv() {
    require_system_cmd curl
    curl -LsSf https://astral.sh/uv/install.sh \
        | INSTALLER_NO_MODIFY_PATH=1 UV_INSTALL_DIR="$_uv_bin_dir" sh
}

uninstall_uv() {
    if [ -x "$_uv_bin" ]; then
        "$_uv_bin" cache clean --cache-dir "$HOME/.cache/uv" || true
        _uv_py="$("$_uv_bin" python dir 2>/dev/null || true)"
        _uv_tool="$("$_uv_bin" tool dir 2>/dev/null || true)"
        [ -n "$_uv_py" ]   && [ -d "$_uv_py" ]   && rm -rf "$_uv_py"
        [ -n "$_uv_tool" ] && [ -d "$_uv_tool" ] && rm -rf "$_uv_tool"
    fi
    rm -rf "$HOME/.local/share/uv" "$HOME/.cache/uv"
    # Only what this module created. ~/.local/bin/env may belong to rustup etc.
    rm -f "$_uv_bin" "$_uv_bin_dir/uvx"
    log "uv removed"
}

is_installed_uv() { [ -x "$_uv_bin" ]; }

shell_uv() {
    path_prepend "$_uv_bin_dir"
}