# LightDM integration

This directory contains the optional LightDM Slick Greeter configuration for
Debian-family X11 systems. The top-level installer deploys the managed files
only when LightDM is selected or already active. Existing administrator
configuration is backed up before replacement.

The configuration expects the packaged `lightdm` and `slick-greeter` tools.
Other display managers continue to use the standard `dwm.desktop` session.
