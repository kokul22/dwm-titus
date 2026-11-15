# Roadmap

## Debian desktop port

Make the existing dwm-titus desktop fully installable, updateable and testable
on Debian-family APT systems, with Debian 13 as the reference platform.

Exit criteria:

- The installer, package repair, desktop update and system-management paths use
  Debian package services and reject non-Debian identities before changes.
- Existing dwm, Quickshell, Settings, launcher, session, configuration and
  accessibility workflows continue to work.
- Debian package resolution, clean build, staged installation and focused
  desktop checks pass on the host; gaps are recorded precisely.
- The legacy image builder and distribution-specific packaging are removed.
