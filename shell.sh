#!/bin/sh
KARL_SHELL_DIR="$HOME/.karl-shell"

for module in "$KARL_SHELL_DIR"/modules/*.sh; do
    [ -r "$module" ] || continue
    . "$module"
    name="$(basename "$module" .sh)"
    "is_installed_$name" 2>/dev/null && "shell_$name"
done