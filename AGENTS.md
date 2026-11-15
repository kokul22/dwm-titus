# Repository instructions

## Scope

This repository is a Debian-family X11 desktop built around a maintained dwm
fork and a managed Quickshell shell. Debian 13 is the package and runtime
baseline. Read `SPEC.md` before product, platform, installer, dependency or
packaging changes. Keep Debian package capabilities in the shared dependency
map and reject non-Debian identities before package or system changes.

## Priorities

1. Preserve dwm stability and existing workflows.
2. Keep the C window-manager core small, understandable and dependency-light.
3. Keep desktop policy in helpers and Quickshell services.
4. Preserve X11 session startup and XDG configuration contracts.
5. Keep installation and settings changes safe, repeatable and reversible.
6. Make focused, independently reviewable changes.

## Configuration

- Preserve `config.def.h` as the default template and never overwrite an
  existing `config.h`.
- Preserve existing dwm TOML settings, `.xinitrc` and application preferences.
- Runtime TOML files live under `${XDG_CONFIG_HOME:-$HOME/.config}/dwm-titus/`.
- The managed Quickshell tree under `${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/`
  is refreshed from tracked `config/quickshell/` during install and update.
- Keep Quickshell state integrations event-driven when a service signal,
  subscription, watch, IPC stream or API exists.

## Safety

- Keep Settings unprivileged. Privileged helpers must be root-owned,
  non-writable, allowlisted and argument-validated.
- Keep authorization explicit for system changes. Do not elevate repository or
  user-writable helper copies.
- Do not silently change bootloader, display-manager, firewall, SELinux or
  security settings.
- Preserve unrelated worktree changes and inspect `git status --short` before
  edits. Do not publish, merge, release or deploy without authorization.
- Never expose credentials, tokens, private keys or secret contents.
- Do not commit generated binaries, objects, archives or local configuration.

## Engineering

- Use Bash only when Bash features are needed; otherwise use POSIX `sh`.
- Quote expansions, use `command -v`, and prefer machine interfaces over
  human-oriented output.
- Use `pkg-config` for X11/library discovery where available.
- Respect compiler/linker overrides, `PREFIX`, `DESTDIR`, XDG paths and the
  invoking user's home directory.
- Keep optional desktop components optional and avoid blocking dwm's event loop.
- Use ASCII punctuation in source and new documentation.

## Validation

Use the managed test workspace:

```sh
scripts/run-tests make clean all
scripts/run-tests
```

Run ShellCheck and shfmt for changed shell scripts when available. For QML,
run `qmllint` with explicit Qt and Quickshell import roots and validate the
managed shell in a real or nested X11 session. Installer changes require
package resolution, a clean build, staged `DESTDIR` install, installed path
checks and syntax checks on Debian 13. State precisely what could not be tested.
