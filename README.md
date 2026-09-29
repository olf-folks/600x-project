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
│   └── ath9k-htc-fullspeed.patch
├── scripts/
│   └── build-kernel.sh
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
    Installed/root filesystem Buildroot working tree

~/600x-installer
    Rescue/installer Buildroot working tree
```

If either Buildroot working tree is damaged, it should eventually be possible to recreate it from this repository.

## Shared kernel

Both the installed rootfs and rescue/installer use the same kernel configuration:

```text
~/600x-project/kernel/current/linux-7.1.13.config
```

Current target:

```text
Kernel:      Linux 7.1.13
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

`CONFIG_IKCONFIG_PROC=y` provides:

```text
/proc/config.gz
```

on the running system.

### Kernel build

Use the controlled build script instead of invoking `make` manually:

```bash
~/600x-project/scripts/build-kernel.sh
```

The script forces:

```text
ARCH=i386
```

and uses the Buildroot i686 cross-toolchain so the kernel cannot silently become x86_64.

The current kernel working tree is:

```text
~/600x-installer/build/linux-7.1.13
```

The resulting kernel is:

```text
~/600x-installer/build/linux-7.1.13/arch/x86/boot/bzImage
```

## Buildroot split

There are two separate Buildroot configurations.

### Installed root filesystem

Working tree:

```text
~/buildroot-2026.08
```

Purpose:

- Main installed operating system
- SysV init
- networking
- Python
- X.Org
- ALSA userspace tools
- storage/debugging utilities
- persistent `/home` and `/opt`

### Rescue / installer

Working tree:

```text
~/600x-installer
```

Purpose:

- Minimal bootable rescue environment
- Installs the prepared root filesystem to disk
- Installs the shared kernel and modules
- Preserves `/home` and `/opt`

Both Buildroot configs should reference the shared kernel config:

```text
/home/superuser/600x-project/kernel/current/linux-7.1.13.config
```

## Filesystem policy

The base Buildroot system owns:

```text
/bin
/sbin
/lib
/usr
```

Custom and persistent software belongs under:

```text
/opt
```

User data and scripts may live under:

```text
/home
/opt
```

The installer should preserve:

```text
/home
/opt
```

during reinstall.

## Desktop / audio plan

The rootfs includes the X.Org stack with:

```text
Modular X.Org
xinit
xterm
xf86-input-libinput
xf86-video-neomagic
xf86-video-vesa
xf86-video-fbdev
```

The 600X GPU is:

```text
NeoMagic NM2360 / MagicMedia 256ZX
```

Audio is:

```text
Cirrus Logic CS4614/22/24/30 SoundFusion
```

with the kernel driver:

```text
CONFIG_SND_CS46XX=y
```

JWM is intentionally **not** part of Buildroot. It will be built natively on the 600X and installed under `/opt`.

`cmus` will also be built natively on the 600X and installed under `/opt`.

## Network / development workflow

The 600X can use NFS to edit files stored on the build server while builds run remotely.

Typical workflow:

```text
600X
  edits source over NFS
      ↓
Ubuntu build server
  performs heavy compilation
      ↓
600X
  uses resulting binaries
```

The Ubuntu build VM Tailscale address is:

```text
100.79.138.14
```

The 600X Tailscale address is:

```text
100.124.199.35
```

## Optical drive

The 600X contains a:

```text
MATSHITA UJDA740 DVD/CDRW
```

It can burn CD-R/CD-RW media.

The rootfs includes `cdrkit` / `wodim`, allowing the 600X to burn its own installer ISO.

## Change-control rules

1. **Git configs are authoritative.**
2. Live `.config` files inside build trees are working copies only.
3. Do not overwrite a known-good config with a file named `WORKING`, `.old`, or similar without comparing it first.
4. Kernel changes should be committed separately and descriptively.
5. Generated build output does not belong in Git.
6. The rootfs and installer Buildroot configs are separate and must remain separately tracked.
7. Application projects such as `600cheat` are separate from the OS repository.

## Current kernel history

Important commits include:

```text
Enable kernel config export and CS46xx audio
Enable TUN and use stable kernel version string
Set Linux 7.1.13 known-good baseline
Add build artifact ignore rules
Import existing 600X config snapshots
```

Historical kernel and Buildroot configurations are retained under `snapshots/` for recovery and comparison.

## Current priorities

- Commit the current installed-rootfs Buildroot config
- Commit the current rescue/installer Buildroot config
- Add reproducible Buildroot build scripts
- Audit account-management tools (`shadow`, `passwd`, `useradd`)
- Verify `resize2fs`, timezone data, and time synchronization
- Rebuild the rootfs and installer from Git-controlled configs
- Install the new shared kernel into both images
- Build `cmus` natively under `/opt`
- Build JWM natively under `/opt`

## Philosophy

The repository contains the **recipe and history**.

The working trees contain the **temporary build state**.

If a working tree disappears, rebuild it.

If the Git repository disappears, that is a problem.
