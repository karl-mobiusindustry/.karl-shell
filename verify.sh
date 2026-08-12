#!/bin/sh
# Round-trip check: install -> all modules present -> uninstall -> all gone,
# and ~/.bashrc byte-identical to where it started. Run before adding modules.
set -eu
KARL_SHELL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$KARL_SHELL_DIR/lib/common.sh"

SNAP="$(mktemp)"
trap 'rm -f "$SNAP"' EXIT
cp "$HOME/.bashrc" "$SNAP"

assert_state() {
    _want="$1"
    for _m in "$KARL_SHELL_DIR"/modules/*.sh; do
        _n="$(basename "$_m" .sh)"
        if ( . "$KARL_SHELL_DIR/lib/common.sh"; . "$_m"; "is_installed_$_n" ); then
            _got=installed
        else
            _got=absent
        fi
        if [ "$_got" != "$_want" ]; then
            err "FAIL: $_n is $_got, expected $_want"
            exit 1
        fi
        log "ok: $_n is $_got"
    done
}

log '=== install ==='
KARL_SHELL_NO_EXEC=1 "$KARL_SHELL_DIR/install.sh"
assert_state installed

log '=== install again (idempotency) ==='
KARL_SHELL_NO_EXEC=1 "$KARL_SHELL_DIR/install.sh"
assert_state installed

log '=== uninstall ==='
KARL_SHELL_NO_EXEC=1 "$KARL_SHELL_DIR/uninstall.sh"
assert_state absent

log '=== uninstall again (idempotency) ==='
KARL_SHELL_NO_EXEC=1 "$KARL_SHELL_DIR/uninstall.sh"
assert_state absent

if diff -q "$SNAP" "$HOME/.bashrc" >/dev/null; then
    log 'ok: ~/.bashrc byte-identical to pre-install state'
else
    err 'FAIL: ~/.bashrc differs from pre-install state'
    diff "$SNAP" "$HOME/.bashrc" || true
    exit 1
fi

log 'ALL CHECKS PASSED'