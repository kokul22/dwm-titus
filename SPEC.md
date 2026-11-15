# dwm-titus Project Specification

## 1. Product

dwm-titus is a complete Debian-family X11 desktop. It combines a maintained
suckless dwm fork, runtime-configurable hotkeys, themes and window rules, a
managed Quickshell panel and Settings layer, and supporting desktop services.

Debian 13 is the package and runtime baseline. The installer accepts Debian and
Debian-derived operating-system identities that expose APT. A derived system is
supported only when its enabled repositories provide the required package
capabilities. Xorg is required. Wayland-native support is outside scope.

## 2. Core behavior

### Window manager

The session provides tiling, floating and monocle layouts; nine workspaces;
per-tag layout state; Xinerama multi-monitor support; EWMH desktop integration;
window swallowing; size factors; true and fake fullscreen; `_NET_WM_ICON`; and
optional floating titlebars. Runtime TOML rules control window assignment and
behavior. Existing keybindings, window rules, monitor behavior and autostart
remain compatible unless a change explicitly updates that contract.

The searchable window overview opens with Super+Tab. It tracks X11 client events
only while open and captures bounded thumbnails outside dwm's event loop. When
capture is unavailable it falls back to icons and titles.

### Configuration

Runtime files live under `${XDG_CONFIG_HOME:-$HOME/.config}/dwm-titus/`:
`hotkeys.toml`, `themes.toml`, and `window-rules.toml`. Changes hot reload when
valid; invalid files report an actionable error and retain the last valid state.
Compile-time defaults stay in `config.def.h`. An existing `config.h` is never
overwritten. Quickshell is managed by dwm-titus and refreshed from the tracked
`config/quickshell/` tree during installation and source updates.

### Quickshell and session

The managed Quickshell provides an X11 panel, application launcher, Control
Center, Settings, notifications, system tray, Update Center and System Health.
The launcher indexes XDG desktop entries, supports keyboard and mouse use, and
releases its application model while closed. State integrations use events,
subscriptions, IPC or service APIs when available. Shell surfaces follow the
active theme and remain low overhead while idle.

The session supports display-manager login and `startx`. Missing optional
components such as Picom, wallpaper tools or a preferred terminal must not stop
dwm from starting.

### Settings and system operations

Settings stays unprivileged. Read-only state comes from service APIs or bounded
helpers. User-session changes, privileged system operations, delegated desktop
tools and unsupported capabilities are distinguished. Privileged helpers are
root-owned, non-writable, allowlisted and argument-validated. Risky operations
provide confirmation and recovery behavior appropriate to their impact.

System package discovery and updates use Debian's PackageKit/APT stack. APT
transactions remain visible and require the package manager's normal
confirmation. Dependency repair installs only validated package names from the
shared Debian package map.

## 3. Installation contract

`install.sh` reads `/etc/os-release` and accepts Debian-family identities only.
It rejects unsupported systems before package installation or system changes.
The package map in `scripts/dwm-packages.sh` is the single source for package
capabilities. The installer:

1. Shows required and optional packages before changes.
2. Installs only missing required packages unless the selected profile requests
   a broader desktop setup.
3. Preserves an existing `config.h`, TOML settings, `.xinitrc`, and application
   preferences; seeds only missing user files.
4. Builds with the system compiler and detected X11 flags.
5. Installs the binary, man page, session file, helpers and default config.
6. Supports repeat execution without duplicate services or lost user choices.
7. Prints skipped optional features and actionable next steps.

Profiles are `core`, `recommended`, and `full`. Core includes the X11 session,
build/runtime requirements and a terminal candidate. Recommended adds the
managed Quickshell desktop and common controls. Full adds optional integrations.
Quickshell 0.3.0 or newer is required for the managed shell.

## 4. Build and dependency contract

The build uses C99, `make`, and `pkg-config` where available. It honors `CC`,
`CFLAGS`, `CPPFLAGS`, `LDFLAGS`, `PREFIX`, `DESTDIR`, XDG paths and the invoking
user's home directory. Staged installation works without root. No fixed
`/usr/lib`, `/usr/lib64` or `/usr/X11R6` paths are assumed.

Native build capabilities include Xlib, Xft, Fontconfig, Xinerama, Xrender,
Imlib2, Xlib-XCB, XCB/RES, freetype headers and standard Linux/POSIX interfaces.
Debian package names are maintained in the shared capability map and checked
against the active APT repositories.

## 5. Safety and compatibility

- Keep the C window-manager core small and avoid blocking work in its event loop.
- Keep desktop policy in helpers and Quickshell services rather than the C loop.
- Never replace user-owned configuration without consent or a backup.
- Keep network downloads optional and failure-tolerant unless explicitly
  required; verify pinned downloads before installation.
- Keep privilege escalation to package operations and system file installation.
- Do not silently change bootloader, display-manager, firewall, SELinux or
  security settings.
- Use ASCII punctuation in source and new documentation.
- Do not commit generated binaries, objects, archives or local configuration.

## 6. Validation

Use the managed test workspace for repository gates:

```sh
scripts/run-tests make clean all
scripts/run-tests
```

For shell changes, run ShellCheck and shfmt when available. For Quickshell QML,
run `qmllint` with explicit Qt and Quickshell module roots. Validate the managed
shell in a real or nested X11 session before claiming runtime behavior works.
Installer changes require package resolution, clean build, staged installation
with `DESTDIR`, installed path checks and script syntax checks on Debian 13.
Record any missing package repository, desktop session or hardware coverage.
