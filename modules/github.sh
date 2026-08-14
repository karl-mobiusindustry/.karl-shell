#!/bin/sh
# GitHub CLI: precompiled release tarball extracted to ~/.local.
# Every "official" install path in the docs needs sudo (apt/dnf/zypper repos)
# or Homebrew, so we take the release binary directly.
#
# Layout inside the tarball is gh_<ver>_linux_<arch>/{bin/gh,share/man/...}.
# We extract only bin/gh to keep the footprint to a single file.
#
# The GitHub API resolves "latest"; it's rate-limited per IP. Set _gh_version
# to a tag like '2.97.0' to pin and skip the API call.

_gh_bin_dir="$HOME/.local/bin"
_gh_bin="$_gh_bin_dir/gh"
_gh_version=''

install_github() {
    require_system_cmd curl
    require_system_cmd tar

    _gh_arch="$(uname -m)"
    case "$_gh_arch" in
        x86_64)  _gh_arch=amd64 ;;
        aarch64|arm64) _gh_arch=arm64 ;;
        armv6l)  _gh_arch=armv6 ;;
        i386|i686) _gh_arch=386 ;;
        *) err "gh: unsupported architecture $_gh_arch"; exit 1 ;;
    esac

    _gh_ver="$_gh_version"
    if [ -z "$_gh_ver" ]; then
        _gh_ver="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest \
            | grep '"tag_name"' | head -n1 | cut -d'"' -f4)"
        _gh_ver="${_gh_ver#v}"
    fi
    [ -n "$_gh_ver" ] || { err "gh: could not resolve latest version"; exit 1; }

    _gh_tarball="gh_${_gh_ver}_linux_${_gh_arch}.tar.gz"
    _gh_url="https://github.com/cli/cli/releases/download/v${_gh_ver}/${_gh_tarball}"

    _gh_tmp="$(mktemp -d)"
    if curl -fsSL "$_gh_url" -o "$_gh_tmp/$_gh_tarball"; then
        tar -xzf "$_gh_tmp/$_gh_tarball" -C "$_gh_tmp"
        mkdir -p "$_gh_bin_dir"
        cp "$_gh_tmp/gh_${_gh_ver}_linux_${_gh_arch}/bin/gh" "$_gh_bin"
        chmod +x "$_gh_bin"
        rm -rf "$_gh_tmp"
    else
        rm -rf "$_gh_tmp"
        err "gh: download failed for $_gh_url"
        exit 1
    fi
}

uninstall_github() {
    rm -f "$_gh_bin"
    # Config and auth token (from `gh auth login`), device id, HTTP cache.
    rm -rf "$HOME/.config/gh"
    rm -rf "$HOME/.local/state/gh"
    rm -rf "$HOME/.cache/gh"
    log "github removed"
}

is_installed_github() { [ -x "$_gh_bin" ]; }

shell_github() {
    path_prepend "$_gh_bin_dir"
}