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
