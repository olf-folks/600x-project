#!/bin/sh
set -eu

PROJECT="$HOME/600x-project"
KERNEL="$HOME/600x-installer/build/linux-7.1.13"
TOOLCHAIN="$HOME/buildroot-2026.08/output/host/bin"

export ARCH=i386
export CROSS_COMPILE="$TOOLCHAIN/i686-buildroot-linux-gnu-"

cp "$PROJECT/kernel/current/linux-7.1.13.config" \
   "$KERNEL/.config"

cd "$KERNEL"

make olddefconfig

grep -q '^CONFIG_X86_32=y' .config
grep -q '^CONFIG_MPENTIUMIII=y' .config

if grep -q '^CONFIG_X86_64=y' .config; then
    echo "ERROR: configuration became x86_64"
    exit 1
fi

echo "Building 600X i386/Pentium III kernel..."

make -j"$(nproc)" bzImage
make -j"$(nproc)" modules
