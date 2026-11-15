# dwm-titus

A complete, keyboard-driven X11 desktop built around a maintained dwm fork and
an event-driven Quickshell shell. The project targets Debian and Debian-derived
distributions that use APT. Debian 13 is the package and runtime baseline.

## What it includes

- Tiling, floating, monocle and per-tag window layouts, multi-monitor support,
  EWMH integration, window swallowing, fullscreen modes and live TOML reloads.
- Quickshell panel, searchable launcher, Control Center, Settings, notifications,
  system tray, Update Center and System Health.
- Guided display and input setup, screenshots, audio and power controls,
  accessibility settings, themes, default-application setup and diagnostics.
- Display-manager login and `startx` session startup.
- Safe, repeatable source updates and APT-backed dependency installation.

The project supports X11/Xorg. Wayland compositor support is outside scope.

## Install

On Debian 13 or a compatible Debian-derived distribution, clone the repository
and review the package plan first:

```sh
git clone https://github.com/kokul22/dwm-titus.git
cd dwm-titus
./install.sh --dry-run --non-interactive --profile recommended
./install.sh --profile recommended
```

The installer supports `core`, `recommended`, and `full` profiles. It uses APT,
shows its package plan, preserves user configuration, and installs the `dwm`
X11 session. Quickshell 0.3.0 or newer must be available from the enabled APT
repositories. Debian 13 publishes it in backports; enable the appropriate
backports suite before installing the recommended profile if needed.

Start a session by selecting `dwm` in the display manager, or from a TTY with:

```sh
startx
```

## First login

Super is the Windows key on most keyboards.

| Action | Keybind |
| --- | --- |
| Open the application launcher | Super + R |
| Open terminal | Super + X |
| Open Control Center | Super + F1 |
| Show keybindings | Super + / |
| Close the focused window | Super + Q |
| Switch workspace | Super + 1-9 |
| Open power menu | Super + Ctrl + Q |

## Configuration

User settings live under `${XDG_CONFIG_HOME:-$HOME/.config}/dwm-titus/`:

- `hotkeys.toml`
- `themes.toml`
- `window-rules.toml`

Changes reload without restarting dwm. Existing files are user-owned and are
preserved during installation and updates. `config.h` is also user-owned. The
managed Quickshell tree at `${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/` is
updated from the project on install and source update.

## Development

Build with `make`. For the managed validation workspace, run:

```sh
scripts/run-tests make clean all
scripts/run-tests
```

The platform contract and package map are in [SPEC.md](SPEC.md). Contributor
workflow is in [CONTRIBUTING.md](CONTRIBUTING.md).
