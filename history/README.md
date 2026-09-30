# ThinkPad 600X Historical Build Files

These files are archived snapshots from earlier stages of the ThinkPad 600X
Linux project.

They are retained to document how the current system evolved and are not
intended to be used as the current build configuration.

## Kernel history

Earlier builds were based on Linux 6.1.156 and evolved through several
experimental configurations before the current Linux 7.1.13 configuration.

Notable changes over time included:

- early RTL8712U USB Wi-Fi support
- transition toward Atheros ath5k / ath9k_htc support
- NeoMagic framebuffer support
- CS46xx sound support
- installer and filesystem support additions
- CONFIG_DEVMEM enabled for working NeoMagic Xorg support

The canonical current kernel configuration is:

    kernel/current/linux-7.1.13.config

## Buildroot history

The archived Buildroot configurations document earlier rootfs generations.

The current project eventually split into two distinct Buildroot systems:

1. the installed system/rootfs payload
2. the minimal installer ISO which carries and installs that payload

Historical files in this directory should therefore not be compared directly
to the installer configuration without accounting for that split.

### ath9k-htc-fullspeed.patch

`history/kernel/ath9k-htc-fullspeed.patch` is a custom Linux kernel patch
created during the ThinkPad 600X Wi-Fi work.

The stock `ath9k_htc` driver expects the USB register/control OUT endpoint to
be an interrupt endpoint. Some Atheros HTC USB devices operating at USB
full-speed expose that endpoint as a bulk OUT endpoint instead.

The patch teaches `ath9k_htc` to handle that full-speed endpoint layout by:

- detecting USB full-speed devices
- locating the expected endpoints manually
- accepting a bulk OUT endpoint for register/control traffic
- using bulk URBs for register writes on those devices
- using a bulk transfer for the device reboot command when required

High-speed devices continue to use the normal `ath9k_htc` endpoint handling.

This patch was part of the effort to make Atheros USB Wi-Fi usable on the
ThinkPad 600X and is preserved here because it represents an actual kernel
driver modification developed for the project, not just a configuration
change.
