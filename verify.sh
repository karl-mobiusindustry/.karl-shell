#!/bin/sh
# Round-trip check: install -> all modules present -> uninstall -> all gone,
# rc files byte-identical to their footprint-free state, and no stray files
# left anywhere under $HOME.
set -eu
KARL_SHELL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$KARL_SHELL_DIR/lib/common.sh"

remove_footprint "$HOME/.bashrc"

SNAPDIR="$(mktemp -d)"
HOMELIST="$SNAPDIR/home.before"
trap 'rm -rf "$SNAPDIR"' EXIT

for f in $KARL_SHELL_RC_FILES; do
    [ -f "$f" ] && cp "$f" "$SNAPDIR/$(basename "$f")"
done

inventory() {
    find "$HOME" \
        -path "$HOME/.karl-shell" -prune -o \
        -path "$HOME/.vscode-server" -prune -o \
        -path "$HOME/.bash_history" -prune -o \
        -path "$HOME/.lesshst" -prune -o \
        -path "$HOME/projects" -prune -o \
        -print 2>/dev/null | sort
}
inventory > "$HOMELIST"

assert_state() {
    _want="$1"
    for _m in $(LC_ALL=C ls "$KARL_SHELL_DIR"/modules/*.sh 2>/dev/null); do
        _n="$(module_name "$_m")"
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

log '=== module order ==='
for _m in $(LC_ALL=C ls "$KARL_SHELL_DIR"/modules/*.sh 2>/dev/null); do
    log "  $(basename "$_m")  ->  $(module_name "$_m")"
done

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

_fail=0

for f in $KARL_SHELL_RC_FILES; do
    _b="$(basename "$f")"
    if [ -f "$SNAPDIR/$_b" ]; then
        if diff -q "$SNAPDIR/$_b" "$f" >/dev/null 2>&1; then
            log "ok: ~/$_b byte-identical to pre-install state"
        else
            err "FAIL: ~/$_b differs from pre-install state"
            diff "$SNAPDIR/$_b" "$f" || true
            _fail=1
        fi
    fi
done

log '=== stray files left in $HOME ==='
if inventory | diff "$HOMELIST" - > "$SNAPDIR/home.diff"; then
    log 'ok: no stray files'
else
    err 'FAIL: $HOME differs after uninstall'
    cat "$SNAPDIR/home.diff"
    _fail=1
fi

[ "$_fail" -eq 0 ] || exit 1
log 'ALL CHECKS PASSED'