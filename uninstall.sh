#!/bin/sh
set -eu
KARL_SHELL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$KARL_SHELL_DIR/lib/common.sh"

do_uninstall() {
    _name="$1"
    if "is_installed_$_name"; then
        log "uninstalling $_name"
        "uninstall_$_name"
        if "is_installed_$_name"; then
            err "$_name still reports installed after uninstall_$_name"
            exit 1
        fi
    else
        log "$_name not installed, skipping"
    fi
}

for_each_module do_uninstall "$KARL_SHELL_DIR"

remove_footprint "$HOME/.bashrc"
log ".bashrc footprint removed"

log "done"
reload_shell