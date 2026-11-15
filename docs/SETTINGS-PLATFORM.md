# Settings platform contract

Settings is an unprivileged Quickshell frontend for Debian-family X11 sessions.
Debian 13 is the package and runtime baseline. Capabilities are discovered at
runtime so missing optional services do not break unrelated settings.

| Capability | Interface | Behavior when unavailable |
| --- | --- | --- |
| Display | XRandR and bounded Xorg helper | Readable session state remains available; persistent changes require explicit authorization. |
| Input and accessibility | XInput, XKB, XKBSet and udev | Unsupported controls are hidden or explained. |
| Network and Bluetooth | NetworkManager and BlueZ service APIs | Other Settings sections remain available. |
| Audio and power | PipeWire/PulseAudio, ALSA, UPower and power-profiles-daemon | Missing providers are reported without stopping the shell. |
| System updates | PackageKit D-Bus API and visible APT terminal | Discovery remains read-only; updates require explicit action. |
| Regional settings | systemd timedated and locale services | Changes use preview, generation checks and recovery behavior. |
| Accounts and printers | AccountsService, CUPS and trusted system tools | Settings reports missing tools and does not elevate repository copies. |

Privileged operations run only through installed root-owned helpers with
allowlisted actions and validated arguments. Authorization denial preserves
readable state. Unsupported capabilities are isolated from the rest of Settings.
