#!/bin/sh
install_git() {
    require_system_cmd git
}

uninstall_git() {
    :
}

is_installed_git() { has_cmd git; }

shell_git() {
    git config --global user.name "Karl Velazquez"
    git config --global user.email "karl@mobiusindustry.com"
    git config --global color.ui auto
    alias gl='git log --oneline --graph --all --decorate'
}