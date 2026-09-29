#!/usr/bin/env bash
set -euo pipefail

PROJECT="$HOME/600x-project"
BUILDROOT="$HOME/buildroot-2026.08"
CONFIG="$PROJECT/rootfs/current/buildroot-2026.08.config"
KERNEL_CONFIG="$PROJECT/kernel/current/linux-7.1.13.config"

echo "=== ThinkPad 600X rootfs build ==="

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

echo "[1/4] Restoring Git-controlled Buildroot config"
cp "$CONFIG" "$BUILDROOT/.config"

echo "[2/4] Normalizing Buildroot config"
make -C "$BUILDROOT" olddefconfig

echo "[3/4] Verifying shared kernel config"
EXPECTED="BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE=\"$KERNEL_CONFIG\""

if ! grep -Fxq "$EXPECTED" "$BUILDROOT/.config"; then
    echo "ERROR: rootfs Buildroot is not using the shared kernel config" >&2
    echo "Expected:"
    echo "  $EXPECTED"
    exit 1
fi

echo "[4/4] Building root filesystem"
make -C "$BUILDROOT" -j"$(nproc)"

echo
echo "=== Rootfs build complete ==="
echo "Images:"
ls -lh "$BUILDROOT/output/images/" 2>/dev/null || true
