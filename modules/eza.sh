#!/bin/sh
# eza: modern ls replacement. Prebuilt binary from GitHub releases — the
# documented Debian path needs sudo for an apt repo, and the "manual" path
# installs to /usr/local/bin, so we take the tarball into ~/.local/bin.
#
# Unlike bat/gh, this tarball extracts the binary directly with no wrapping
# directory. Uses the /releases/latest/download/ redirect, so no GitHub API
# call and no rate limit. Set _eza_version to pin a tag like 'v0.20.0'.

_eza_bin_dir="$HOME/.local/bin"
_eza_bin="$_eza_bin_dir/eza"
_eza_version=''

install_eza() {
    require_system_cmd curl
    require_system_cmd tar

    _eza_arch="$(uname -m)"
    case "$_eza_arch" in
        x86_64)        _eza_target=x86_64-unknown-linux-gnu ;;
        aarch64|arm64) _eza_target=aarch64-unknown-linux-gnu ;;
        *) err "eza: unsupported architecture $_eza_arch"; exit 1 ;;
    esac

    if [ -n "$_eza_version" ]; then
        _eza_url="https://github.com/eza-community/eza/releases/download/${_eza_version}/eza_${_eza_target}.tar.gz"
    else
        _eza_url="https://github.com/eza-community/eza/releases/latest/download/eza_${_eza_target}.tar.gz"
    fi

    _eza_tmp="$(mktemp -d)"
    if curl -fsSL "$_eza_url" -o "$_eza_tmp/eza.tar.gz"; then
        tar -xzf "$_eza_tmp/eza.tar.gz" -C "$_eza_tmp"
        mkdir -p "$_eza_bin_dir"
        cp "$_eza_tmp/eza" "$_eza_bin"
        chmod +x "$_eza_bin"
        rm -rf "$_eza_tmp"
    else
        rm -rf "$_eza_tmp"
        err "eza: download failed for $_eza_url"
        exit 1
    fi
}

uninstall_eza() {
    rm -f "$_eza_bin"
    rm -rf "$HOME/.config/eza"
    log "eza removed"
}

is_installed_eza() { [ -x "$_eza_bin" ]; }

shell_eza() {
    path_prepend "$_eza_bin_dir"

    # Shared flag sets. Kept in locals rather than module-level vars so the
    # module's top level stays at the four contract functions.
    _eza_common="--icons --group-directories-first"
    _eza_short="$_eza_common -1"
    _eza_long="$_eza_common -l --git --header"
    # Default: dotfiles, but no .git/ and nothing .gitignore'd.
    _eza_def="-a --git-ignore -I '.git'"
    # a-variants: everything. Flat forms get -aa (. and ..); tree forms can't —
    # eza rejects --tree with -aa, since it can't recurse into . or ..
    _eza_all="-aa"
    _eza_all_tree="-a"

    alias l="eza $_eza_short $_eza_def"
    alias la="eza $_eza_short $_eza_all"
    alias ll="eza $_eza_long $_eza_def"
    alias lla="eza $_eza_long $_eza_all"

    for _eza_lvl in 1 2 3 4 5 6 7 8 9; do
        alias "lt$_eza_lvl"="eza $_eza_short --tree --level=$_eza_lvl $_eza_def"
        alias "lta$_eza_lvl"="eza $_eza_short --tree --level=$_eza_lvl $_eza_all_tree"
        alias "llt$_eza_lvl"="eza $_eza_long --tree --level=$_eza_lvl $_eza_def"
        alias "llta$_eza_lvl"="eza $_eza_long --tree --level=$_eza_lvl $_eza_all_tree"
    done

    alias lt=lt1
    alias lta=lta1
    alias llt=llt1
    alias llta=llta1

    unset _eza_common _eza_short _eza_long _eza_def _eza_all _eza_all_tree _eza_lvl
}
