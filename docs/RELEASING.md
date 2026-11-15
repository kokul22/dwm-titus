# Releasing

Releases target Debian-family APT systems, with Debian 13 as the reference
platform. The project does not provide a distribution image or binary package;
users install from source with `install.sh`.

Before a release:

1. Run `scripts/run-tests make clean all` and `scripts/run-tests`.
2. Resolve the full recommended package profile from a clean Debian 13 system
   with its intended repositories enabled.
3. Verify staged installation paths with `DESTDIR` and run shell/QML checks.
4. Exercise display-manager and `startx` sessions where available.
5. Record the tested Debian release, architecture, repository configuration,
   Quickshell version and any untested hardware or runtime path.
6. Update `CHANGELOG.md` and publish source artifacts only after validation.
