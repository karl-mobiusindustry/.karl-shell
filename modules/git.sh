#!/bin/sh
# git: system-provided. This module owns only the three global config keys
# it sets; --unset is their exact inverse. No bookkeeping files.

_git_name='Karl Velazquez'
_git_email='karl@mobiusindustry.com'

install_git() {
    require_system_cmd git
    git config --global user.name "$_git_name"
    git config --global user.email "$_git_email"
    git config --global color.ui auto
}

uninstall_git() {
    git config --global --unset user.name  || true
    git config --global --unset user.email || true
    git config --global --unset color.ui   || true
    # --unset leaves an empty file behind; skel has no .gitconfig.
    [ -f "$HOME/.gitconfig" ] && [ ! -s "$HOME/.gitconfig" ] && rm -f "$HOME/.gitconfig"
    log "git config reverted"
}

# Tests this module's own footprint, not merely whether git exists on PATH.
is_installed_git() {
    has_cmd git || return 1
    [ "$(git config --global --get user.email 2>/dev/null || true)" = "$_git_email" ]
}

shell_git() {
    alias gl='git log --oneline --graph --all --decorate'
}