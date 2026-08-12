# .karl-shell

Per-user dev environment bootstrap. No sudo, no writes outside `$HOME`,
fully reversible.

## Usage

```sh
git clone <repo> ~/.karl-shell
~/.karl-shell/install.sh
exec bash -l          # or open a new terminal

~/.karl-shell/uninstall.sh
~/.karl-shell/verify.sh   # round-trip test
```

## Layout

```
install.sh      drives install_* across modules, writes the .bashrc footprint
uninstall.sh    drives uninstall_* across modules, removes the footprint
shell.sh        sourced by .bashrc; drives shell_* for installed modules
verify.sh       install/uninstall round-trip assertions
lib/common.sh   shared helpers (log, has_cmd, path_prepend, footprint I/O)
modules/*.sh    one file per tool
```

`install.sh` and `uninstall.sh` write exactly one sentinel block to `~/.bashrc`:

```
# >>> karl-shell >>>
[ -f ~/.karl-shell/shell.sh ] && . ~/.karl-shell/shell.sh
# <<< karl-shell <
```

Both operations strip any existing block before acting, so repeated runs are
byte-idempotent.

## Module contract

A module `modules/<name>.sh` defines exactly four functions and nothing else
at top level. Module-local variables are prefixed `_<name>_`.

| Function | Contract |
|---|---|
| `install_<name>` | Installs under `$HOME` only. Calls `require_system_cmd` for each of its own system deps. |
| `uninstall_<name>` | Fully reverts `install_<name>`. Afterwards `is_installed_<name>` must be false. |
| `is_installed_<name>` | Tests this module's own footprint, not merely whether a binary is on PATH. |
| `shell_<name>` | Per-shell setup only. Idempotent under repeated sourcing. |

Rules:

1. **Isolation.** A module assumes no other module exists. If it needs
   `~/.local/bin` on PATH, it calls `path_prepend` itself.
2. **No shell-config writes.** Modules never touch `~/.bashrc`, `~/.profile`,
   `~/.zshrc`. Pass the upstream installer's opt-out
   (`PROFILE=/dev/null`, `INSTALLER_NO_MODIFY_PATH=1`) instead.
3. **`shell_*` mutates nothing persistent.** No `git config --global`, no file
   writes, no network. Persistent config belongs in `install_*` and must be
   undone in `uninstall_*`.
4. **No sudo, no `/usr/local`.** Everything lands under `$HOME`.
5. **Fail loudly.** Don't blanket-`|| true` a `rm`; only guard commands that
   are genuinely allowed to fail.

Modules are sourced and invoked in subshells, so they cannot leak variables
into each other or into the driver scripts.

Run `verify.sh` after adding a module.