# Changelog

## Unreleased

- Rotate Feh wallpapers every 30 minutes using images under `~/Pictures/`.
- Replace the Quickshell panel's Chris Titus logo with the Debian logo.
- Set Debian-family APT systems as the sole platform target, with Debian 13 as
  the package and runtime baseline.
- Replace legacy package detection and update execution with Debian package
  management while retaining the dwm and Quickshell desktop workflows.
- Remove distribution image construction, binary package packaging, and legacy release artifacts.
- Simplify the repository around the existing-system installer and Debian
  validation path.
