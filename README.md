# ThinkPad 600X Linux Project

Custom Linux environment for an IBM ThinkPad 600X built around Linux 7.1.13 and Buildroot 2026.08.

This repository is the **source of truth** for the 600X operating system, shared kernel configuration, rescue/installer configuration, build scripts, patches, and project history.

## Project layout

```text
600x-project/
├── kernel/
│   ├── current/
│   │   └── linux-7.1.13.config
│   └── snapshots/
├── rootfs/
│   └── current/
├── installer/
│   ├── current/
│   └── grub-builtin.cfg
├── patches/
│   ├── ath9k-htc-fullspeed.patch
│   └── 600x-installer-payload.patch
├── scripts/
│   ├── build-kernel.sh
│   ├── build-rootfs.sh
│   └── build-installer.sh
├── docs/
├── archive/
└── buildroot/
    └── snapshots/
```

## Working trees

The Git repository is authoritative. The Buildroot trees are disposable working directories.

```text
~/600x-project
    Git-controlled source of truth

~/buildroot-2026.08
    Installed/root filesystem Buildroot working tree and shared Buildroot source tree

~/600x-installer
    Rescue/installer Buildroot working tree
```

If either working tree is damaged, it should eventually be possible to recreate it from this repository.

## Shared kernel

Both the installed rootfs and rescue/installer use the same kernel configuration:

```text
~/600x-project/kernel/current/linux-7.1.13.config
```

Current target:

```text
Kernel:       Linux 7.1.13
Architecture: 32-bit x86
CPU target:   Pentium III
```

Important enabled features include:

```text
CONFIG_X86_32=y
CONFIG_MPENTIUMIII=y
CONFIG_TUN=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_FB_NEOMAGIC=y
CONFIG_SND_CS46XX=y
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
```

`CONFIG_IKCONFIG_PROC=y` provides `/proc/config.gz` on the running system.

### Kernel build

Use:

```bash
~/600x-project/scripts/build-kernel.sh
```

The script forces `ARCH=i386` and uses the Buildroot i686 cross-toolchain so the kernel cannot silently become x86_64.

## Buildroot split

There are two separate Buildroot configurations.

### Installed root filesystem

Working tree:

```text
~/buildroot-2026.08
```

Build with:

```bash
~/600x-project/scripts/build-rootfs.sh
```

The generated installed-system payload is:

```text
~/buildroot-2026.08/output/images/rootfs.tar
```

The current rootfs includes X.Org, xinit, xterm, libinput, NeoMagic, VESA, fbdev, ALSA utilities, cdrkit/wodim, Python, networking and debugging/storage tools.

### Rescue / installer

Working tree:

```text
~/600x-installer
```

Build with:

```bash
~/600x-project/scripts/build-installer.sh
```

The installer uses Buildroot's ISO9660 target with GRUB2 and an initramfs.

Both Buildroot configs reference:

```text
/home/superuser/600x-project/kernel/current/linux-7.1.13.config
```

## Installer ISO payload

The installer ISO contains both the rescue environment and the full installed-system payload:

```text
installer ISO
├── rescue/initramfs environment
└── payload/rootfs-v7.tar
```

The rescue installer at:

```text
/usr/sbin/600x-install
```

expects:

```text
/payload/rootfs-v7.tar
```

on the CD.

The installed-system payload is produced by the rootfs build as:

```text
~/buildroot-2026.08/output/images/rootfs.tar
```

A custom Buildroot ISO hook copies that tarball into the temporary ISO tree immediately before `xorriso` creates the image:

```text
rootfs.tar
    -> ISO staging/payload/rootfs-v7.tar
    -> xorriso builds rootfs.iso9660
    -> temporary payload directory is removed
```

This Buildroot customization is preserved in Git as:

```text
patches/600x-installer-payload.patch
```

It patches:

```text
fs/iso9660/iso9660.mk
```

and installs:

```text
ROOTFS_ISO9660_PRE_GEN_HOOKS
ROOTFS_ISO9660_POST_GEN_HOOKS
```

The pre-generation hook creates `payload/` and copies in the current rootfs. The post-generation hook removes the temporary staging payload after the ISO is complete.

This cleanup is intentional: the payload remains inside the finished ISO but does not remain in Buildroot's temporary staging directory.

### Complete installer build

Normal sequence:

```bash
cd ~/600x-project
./scripts/build-kernel.sh
./scripts/build-rootfs.sh
./scripts/build-installer.sh
```

The rootfs should be built before the installer ISO so the newest installed system is embedded.

If Buildroot considers an existing ISO current even though the external rootfs changed, force only the ISO to regenerate:

```bash
rm -f ~/600x-installer/images/rootfs.iso9660
~/600x-project/scripts/build-installer.sh
```

Result:

```text
~/600x-installer/images/rootfs.iso9660
```

## X.Org / graphics

The installed rootfs has been verified to contain:

```text
/usr/bin/Xorg
/usr/bin/startx
/usr/bin/xterm
/usr/lib/xorg/modules/drivers/neomagic_drv.so
/usr/lib/xorg/modules/input/libinput_drv.so
```

The ThinkPad 600X GPU is:

```text
NeoMagic NM2360 / MagicMedia 256ZX
```

JWM and cmus are intentionally planned as native `/opt` installs rather than Buildroot packages.

## Audio

The ThinkPad 600X audio device is:

```text
Cirrus Logic CS4614/22/24/30 SoundFusion
```

Kernel support:

```text
CONFIG_SND_CS46XX=y
```

## Filesystem policy

Buildroot owns:

```text
/bin
/sbin
/lib
/usr
```

Custom/persistent software belongs under `/opt`. User data and scripts may live under `/home` or `/opt`.

The installer should preserve:

```text
/home
/opt
```

during reinstall.

## Optical drive

The 600X contains a MATSHITA UJDA740 DVD/CDRW and can burn its own installer media with `wodim`.

## Change-control rules

1. **Git configs are authoritative.**
2. Live `.config` files are working copies only.
3. Generated build output does not belong in Git.
4. Rootfs and installer Buildroot configs remain separately tracked.
5. Application projects such as `600cheat` stay outside this OS repository.
6. Local Buildroot source modifications must be preserved as patches under `patches/`.
7. Build the rootfs before building the installer ISO.
8. Prefer the controlled scripts over manual build commands.

## Current build interface

```bash
~/600x-project/scripts/build-kernel.sh
~/600x-project/scripts/build-rootfs.sh
~/600x-project/scripts/build-installer.sh
```

## Current priorities

- Verify the new installer ISO contains the fresh X.Org rootfs payload
- Test the installer ISO on the ThinkPad 600X
- Audit account-management tools
- Verify resize2fs, timezone data and time synchronization
- Test CS46xx audio
- Start X manually with `startx`
- Build cmus under `/opt`
- Build JWM under `/opt`

## Philosophy

The repository contains the **recipe and history**.

The working trees contain the **temporary build state**.

If a working tree disappears, rebuild it.

If the Git repository disappears, that is a problem.
