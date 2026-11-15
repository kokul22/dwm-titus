---
title: Troubleshooting
description: Diagnose common dwm-titus installation and session issues.
---

# Troubleshooting

## The panel or launcher is missing

Check `quickshell --version` and confirm version 0.3.0 or newer is installed.
Review the current session log and run `dwm-diagnostics`. On Debian 13, enable
backports if Quickshell is not available from the configured APT sources.

## A package is missing

Refresh APT metadata with `sudo apt-get update`, then rerun the installer dry
run. Optional packages unavailable from enabled repositories are reported and
skipped.

## The keyring does not unlock at login

Install `gnome-keyring` and `libpam-gnome-keyring`. Automatic unlock also
requires the display manager PAM stack to load the keyring module and the
account and keyring passwords to match. Autologin and `startx` do not provide
a password to that PAM path.

## The X11 session does not start

Select `dwm` in the display manager, or test from a TTY with `startx`. Check
`~/.xsession-errors`, the display-manager journal and `dwm-diagnostics`.

## Session configuration

User settings are under `${XDG_CONFIG_HOME:-$HOME/.config}/dwm-titus/`.
Existing `config.h`, TOML settings and `.xinitrc` are preserved by installation.
