---
title: Install dwm-titus
description: Install the Debian-family dwm-titus X11 desktop from source.
---

# Install dwm-titus

The installer supports Debian-family distributions that use APT. Debian 13 is
the package and runtime baseline. Xorg and an X11 session are required.

```sh
git clone https://github.com/kokul22/dwm-titus.git
cd dwm-titus
./install.sh --dry-run --non-interactive --profile recommended
./install.sh --profile recommended
```

The dry run prints package profiles and installation choices without changing
the system. The installer preserves existing `config.h`, TOML settings and
application preferences.

Profiles:

- `core`: X11 session, required build/runtime packages and terminal support.
- `recommended`: managed Quickshell desktop, Settings and common controls.
- `full`: recommended features plus optional integrations.

Quickshell 0.3.0 or newer is required. On Debian 13, enable the backports suite
if it is not already configured and Quickshell is unavailable.

Select the `dwm` session in your display manager, or start from a TTY with
`startx`.
