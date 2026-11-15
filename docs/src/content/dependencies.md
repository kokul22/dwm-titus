---
title: Desktop dependencies
description: Debian package capabilities and dwm-titus install profiles.
---

# Desktop dependencies

The installer uses the shared package map in `scripts/dwm-packages.sh` and APT
to resolve packages. Package names can differ across Debian derivatives; the
installer checks the enabled repositories and reports unavailable optional
components.

| Profile | Main capabilities |
| --- | --- |
| Core | C compiler, make, X11 development libraries, Xorg, D-Bus session, clipboard and input utilities, keyring, media defaults and terminal candidate. |
| Recommended | Quickshell, Thunar, Picom, audio, brightness, notifications, Bluetooth, network controls, Flatpak portal, themes and fonts. |
| Full | Recommended profile plus optional theme and desktop integrations. |

Quickshell 0.3.0 or newer is required. Debian 13 publishes Quickshell in
backports. Enable that suite when needed before running the recommended profile.

The native build uses Xlib, Xft, Fontconfig, Xinerama, Xrender, Imlib2,
Xlib-XCB, XCB/RES and freetype headers. Debian packages are resolved from the
APT repositories enabled on the target system.
