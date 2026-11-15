# Settings capabilities

The Settings frontend is unprivileged. It reads state through service APIs,
D-Bus, event subscriptions or bounded helpers. Session-local preferences remain
user-owned. System changes use trusted installed helpers and explicit
authorization.

| Area | State source | Change path |
| --- | --- | --- |
| Appearance and layout | dwm and theme services | User configuration and per-session layout requests |
| Display and input | XRandR, XInput, XKB and udev | Previewed session changes and authorized Xorg persistence |
| Network, Bluetooth and audio | NetworkManager, BlueZ and audio services | Native service APIs or trusted desktop tools |
| Power and accessibility | UPower, power-profiles-daemon and X11 helpers | Allowlisted session controls |
| System information and health | systemd, procfs and bounded host queries | Read-only snapshots and explicit desktop repairs |
| System updates | PackageKit and APT | Visible, confirmed terminal transaction |
| Accounts and printers | AccountsService and CUPS | Delegated to trusted system tools |

Unsupported hardware and missing services are reported per capability so the
remaining Settings sections continue to work.
