#!/bin/sh
set -e
KARL_SHELL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$KARL_SHELL_DIR/lib/common.sh"

require_system_cmd git
require_system_cmd curl

BASHRC_ORIG="/tmp/karl-shell.bashrc.orig"

cp "$HOME/.bashrc" "$BASHRC_ORIG"
log "snapshotted .bashrc to $BASHRC_ORIG"

for module in "$KARL_SHELL_DIR"/modules/*.sh; do
    . "$module"
    "install_$(basename "$module" .sh)"
done

cp "$BASHRC_ORIG" "$HOME/.bashrc"
{
    echo ''
    echo '[ -f ~/.karl-shell/shell.sh ] && . ~/.karl-shell/shell.sh'
} >> "$HOME/.bashrc"

log "done — .bashrc reset to original + karl-shell footprint"
exec bash -l
