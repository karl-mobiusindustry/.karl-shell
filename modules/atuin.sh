#!/bin/sh
# atuin: shell history in SQLite with fuzzy Ctrl-R search.
#
# The installer has --non-interactive but NO flag to skip rc-file writes, so
# it appends to ~/.bashrc and ~/.profile regardless — install.sh's snapshot
# discards both. It also CREATES ~/.zshrc and ~/.config/fish/conf.d from
# nothing on a box with neither shell; those are removed here.
#
# It writes Claude Code hooks into ~/.claude/settings.json and `atuin hook`
# offers install but no uninstall, so we strip them ourselves. If the file
# holds nothing but atuin's hooks we delete it (atuin created it); if the user
# has since added their own settings we leave it alone rather than clobber it.

_atuin_dir="$HOME/.atuin"
_atuin_bin_dir="$_atuin_dir/bin"
_atuin_bin="$_atuin_bin_dir/atuin"
_atuin_claude_settings="$HOME/.claude/settings.json"

install_atuin() {
    require_system_cmd curl
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh \
        | sh -s -- --non-interactive
}

uninstall_atuin() {
    rm -rf "$_atuin_dir"
    rm -rf "$HOME/.local/share/atuin"
    rm -rf "$HOME/.config/atuin"

    # Shell rc files atuin creates from nothing on this box.
    rm -f "$HOME/.zshrc"
    rm -f "$HOME/.config/fish/conf.d/atuin.env.fish"
    rmdir "$HOME/.config/fish/conf.d" "$HOME/.config/fish" 2>/dev/null || true

    # Claude Code hooks: delete the file only if atuin's hooks are all it holds.
    if [ -f "$_atuin_claude_settings" ]; then
        if grep -q 'atuin hook claude-code' "$_atuin_claude_settings" \
           && ! grep -qv 'atuin hook claude-code\|hooks\|PostToolUse\|PostToolUseFailure\|PreToolUse\|matcher\|command\|Bash\|[{}\[\],"]*$' \
                "$_atuin_claude_settings"; then
            rm -f "$_atuin_claude_settings"
        else
            log "atuin: left $_atuin_claude_settings in place (has non-atuin content)"
        fi
    fi

    log "atuin removed"
}

is_installed_atuin() { [ -x "$_atuin_bin" ]; }

shell_atuin() {
    path_prepend "$_atuin_bin_dir"
    # init needs atuin on PATH; call by absolute path so ordering can't bite.
    if [ -n "${BASH_VERSION:-}" ] && [ -x "$_atuin_bin" ]; then
        eval "$("$_atuin_bin" init bash)"
    fi
}
