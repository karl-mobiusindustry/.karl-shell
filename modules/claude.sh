#!/bin/sh
# Claude Code CLI: native installer. Creates a launcher symlink at
# ~/.local/bin/claude pointing into ~/.local/share/claude/versions/.
# Verified on 2.1.228: writes nothing to .bashrc/.profile/.zshrc.
#
# The installer owns the launcher symlink and repoints it on auto-update.
# This module must not replace it — a custom launcher makes Claude Code keep
# every installed version on disk forever, since it can't tell which one runs.
#
# ~/.claude and ~/.claude.json are created by the installer (verified: deleted
# both, ran a full install/uninstall cycle, both returned), so uninstall removes
# them.

_claude_bin_dir="$HOME/.local/bin"
_claude_bin="$_claude_bin_dir/claude"
_claude_share="$HOME/.local/share/claude"
_claude_state="$HOME/.local/state/claude"
_claude_config="$HOME/.claude"
_claude_config_json="$HOME/.claude.json"

install_claude() {
    require_system_cmd curl
    curl -fsSL https://claude.ai/install.sh | bash
}

uninstall_claude() {
    rm -f "$_claude_bin"
    rm -rf "$_claude_share"
    rm -rf "$_claude_state"
    rm -rf "$_claude_config"
    rm -f "$_claude_config_json"
    log "claude removed"
}

# Auto-update churns the versions dir and repoints the symlink, so test the
# launcher's executability rather than any pinned version path.
is_installed_claude() { [ -x "$_claude_bin" ]; }

shell_claude() {
    path_prepend "$_claude_bin_dir"
}