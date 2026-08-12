#!/bin/sh
# Shared helpers. Sourced by install.sh, uninstall.sh, shell.sh, and verify.sh.
# Must stay POSIX sh and must never mutate state on its own.

KARL_SHELL_BEGIN='# >>> karl-shell >>>'
KARL_SHELL_END='# <<< karl-shell <<<'
KARL_SHELL_SNAPSHOT="/tmp/karl-shell.bashrc.$(id -u).orig"

log() { echo "[karl-shell] $*"; }
err() { echo "[karl-shell] ERROR: $*" >&2; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

require_system_cmd() {
    if ! has_cmd "$1"; then
        err "expected system tool '$1' not found. Install it via your package manager first."
        exit 1
    fi
}

# Prepend to PATH only if not already present. Safe to call repeatedly.
path_prepend() {
    case ":${PATH-}:" in
        *":$1:"*) ;;
        *) PATH="$1${PATH:+:$PATH}"; export PATH ;;
    esac
}

# Backstop against third-party installers that edit shell config despite our
# opt-out flags. Whatever they append is discarded at the end of install.
snapshot_bashrc() {
    [ -f "$HOME/.bashrc" ] || : > "$HOME/.bashrc"
    cp "$HOME/.bashrc" "$KARL_SHELL_SNAPSHOT"
}

restore_bashrc() {
    [ -f "$KARL_SHELL_SNAPSHOT" ] || return 0
    cp "$KARL_SHELL_SNAPSHOT" "$HOME/.bashrc"
    rm -f "$KARL_SHELL_SNAPSHOT"
}

# Remove the karl-shell sentinel block from a shell rc file, if present.
# Idempotent: removing when absent is a no-op.
remove_footprint() {
    _cf_file="$1"
    [ -f "$_cf_file" ] || return 0
    grep -qF "$KARL_SHELL_BEGIN" "$_cf_file" || return 0
    sed -i "\%^$KARL_SHELL_BEGIN\$%,\%^$KARL_SHELL_END\$%d" "$_cf_file"
}

# Write the sentinel block, replacing any prior copy first.
write_footprint() {
    _cf_file="$1"
    remove_footprint "$_cf_file"
    {
        echo "$KARL_SHELL_BEGIN"
        echo '[ -f ~/.karl-shell/shell.sh ] && . ~/.karl-shell/shell.sh'
        echo "$KARL_SHELL_END"
    } >> "$_cf_file"
}

# Re-exec into a login shell so modules are live in the same terminal.
# Test harnesses set KARL_SHELL_NO_EXEC=1 to stay in control.
reload_shell() {
    [ -n "${KARL_SHELL_NO_EXEC:-}" ] && return 0
    exec bash -l
}

# Iterate modules in sorted order, invoking `$1 <name>` for each.
# Each module is sourced and invoked inside a subshell so modules cannot
# clobber one another's variables or leak state into the driver.
for_each_module() {
    _fem_action="$1"
    _fem_dir="$2"
    for _fem_module in "$_fem_dir"/modules/*.sh; do
        [ -r "$_fem_module" ] || continue
        _fem_name="$(basename "$_fem_module" .sh)"
        (
            . "$_fem_dir/lib/common.sh"
            . "$_fem_module"
            "$_fem_action" "$_fem_name"
        ) || return 1
    done
    return 0
}