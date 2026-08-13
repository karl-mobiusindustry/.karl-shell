#!/bin/sh
set -eu
KARL_SHELL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$KARL_SHELL_DIR/lib/common.sh"

require_system_cmd git
require_system_cmd curl

snapshot_rc_files
log "snapshotted rc files to $KARL_SHELL_SNAPDIR"

do_install() {
    _name="$1"
    if "is_installed_$_name"; then
        log "$_name already installed, skipping"
    else
        log "installing $_name"
        "install_$_name"
        if "is_installed_$_name"; then
            log "$_name installed"
        else
            err "$_name reported success but is_installed_$_name is still false"
            exit 1
        fi
    fi
}

for_each_module do_install "$KARL_SHELL_DIR"

restore_rc_files
write_footprint "$HOME/.bashrc"

log "done — rc files reset to original + karl-shell footprint"
reload_shell