#!/bin/sh
# Sourced from ~/.bashrc on every interactive shell. Keep this fast and
# side-effect-free: no installs, no writes to disk, no persistent config.
KARL_SHELL_DIR="$HOME/.karl-shell"

[ -r "$KARL_SHELL_DIR/lib/common.sh" ] && . "$KARL_SHELL_DIR/lib/common.sh"

for _ks_module in $(LC_ALL=C ls "$KARL_SHELL_DIR"/modules/*.sh 2>/dev/null); do
    [ -r "$_ks_module" ] || continue
    . "$_ks_module"
    _ks_name="$(module_name "$_ks_module")"
    if "is_installed_$_ks_name" 2>/dev/null; then
        "shell_$_ks_name" 2>/dev/null
    fi
done
unset _ks_module _ks_name

# Never leave a nonzero status behind; prompt themes read $?.
: