---
title: Updates
description: Update the desktop, Debian packages and user applications.
---

# Updates

The panel Update Center discovers system package, dwm-titus source, Flatpak and
mise updates. System package state is read through PackageKit. A confirmed
system update opens a terminal and runs APT so package progress, authorization
and transaction confirmation remain visible.

Desktop source updates build the selected revision before installing it, update
the managed Quickshell and data trees, preserve user-owned dwm TOML files, and
verify installed files. The updater reports when a session restart is needed.

Flatpak and mise updates remain optional providers. Their absence does not
prevent system or desktop updates.
