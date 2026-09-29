#!/usr/bin/env bash
set -euo pipefail

PROJECT="$HOME/600x-project"
BUILDROOT="$HOME/600x-installer"
CONFIG="$PROJECT/installer/current/buildroot-2026.08.config"
KERNEL_CONFIG="$PROJECT/kernel/current/linux-7.1.13.config"

echo "=== ThinkPad 600X rescue/installer build ==="

for path in "$BUILDROOT" "$CONFIG" "$KERNEL_CONFIG"; do
    if [ ! -e "$path" ]; then
        echo "ERROR: missing: $path" >&2
        exit 1
    fi
done

if [ ! -f "$BUILDROOT/Makefile" ]; then
    echo "ERROR: $BUILDROOT is not a Buildroot tree" >&2
    exit 1
fi

echo "[1/4] Restoring Git-controlled installer config"
cp "$CONFIG" "$BUILDROOT/.config"

echo "[2/4] Normalizing Buildroot config"
make -C "$BUILDROOT" olddefconfig

echo "[3/4] Verifying shared kernel config"
EXPECTED="BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE=\"$KERNEL_CONFIG\""

if ! grep -Fxq "$EXPECTED" "$BUILDROOT/.config"; then
    echo "ERROR: installer Buildroot is not using the shared kernel config" >&2
    echo "Expected:"
    echo "  $EXPECTED"
    exit 1
fi

echo "[4/4] Building rescue/installer"
make -C "$BUILDROOT" -j"$(nproc)"

echo
echo "=== Installer build complete ==="

if [ -d "$BUILDROOT/output/images" ]; then
    ls -lh "$BUILDROOT/output/images/"
elif [ -d "$BUILDROOT/images" ]; then
    ls -lh "$BUILDROOT/images/"
fi
