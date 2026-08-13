#!/bin/sh
# Claude Code CLI: native installer. Creates a launcher symlink at
# ~/.local/bin/claude pointing into ~/.local/share/claude/versions/.
# Verified on 2.1.231: writes nothing to .bashrc/.profile/.zshrc.
#
# The installer owns the launcher symlink and repoints it on auto-update.
# This module must not replace it — a custom launcher makes Claude Code keep
# every installed version on disk forever, since it can't tell which one runs.

_claude_bin_dir="$HOME/.local/bin"
_claude_bin="$_claude_bin_dir/claude"

install_claude() {
    require_system_cmd curl
    curl -fsSL https://claude.ai/install.sh | bash
}

uninstall_claude() {
    rm -f "$_claude_bin"
    rm -rf "$HOME/.local/share/claude"
    rm -rf "$HOME/.local/state/claude"
    rm -rf "$HOME/.claude" "$HOME/.claude.json"
    rm -rf "$HOME/.cache/claude" "$HOME/.cache/claude-cli-nodejs"
    rm -f "$HOME/.local/share/applications/claude-code-url-handler.desktop"
    log "claude removed"
}

# Auto-update churns the versions dir and repoints the symlink, so test the
# launcher's executability rather than any pinned version path.
is_installed_claude() { [ -x "$_claude_bin" ]; }

shell_claude() {
    path_prepend "$_claude_bin_dir"
}