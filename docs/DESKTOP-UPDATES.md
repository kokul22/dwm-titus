# Desktop updates

The Update Center tracks Debian system packages, the dwm-titus source tree,
Flatpak applications and mise tools. System-package discovery uses the
PackageKit API. A user-confirmed update runs APT in a visible terminal so the
package plan, authorization and confirmation are clear.

Desktop source updates verify the selected source revision, build it before
installation, update the managed Quickshell and data trees, preserve user-owned
TOML settings, and verify installed files. Session activation is reported
separately from installed files.

Dependency repair uses the installed, root-owned helper and the shared Debian
package map. It validates package names, installs only missing required
packages, and handles optional packages separately.

Recovery rechecks system state and never claims rollback for package-manager
transactions. Review APT output if an operation is interrupted.
