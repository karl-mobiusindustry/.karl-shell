#!/bin/sh
log() { echo "[karl-shell] $*"; }
has_cmd() { command -v "$1" >/dev/null 2>&1; }
require_system_cmd() {
    if ! has_cmd "$1"; then
        log "ERROR: expected system tool '$1' not found. Install it via apt first."
        exit 1
    fi
}
