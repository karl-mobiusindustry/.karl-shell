#!/bin/sh
set -e
KARL_SHELL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$KARL_SHELL_DIR/lib/common.sh"

if [ -n "$1" ]; then
    modules="$KARL_SHELL_DIR/modules/$1.sh"
else
    modules="$KARL_SHELL_DIR"/modules/*.sh
fi

for module in $modules; do
    [ -r "$module" ] || { log "no such module: $module"; exit 1; }
    . "$module"
    "uninstall_$(basename "$module" .sh)"
done

log "done"
