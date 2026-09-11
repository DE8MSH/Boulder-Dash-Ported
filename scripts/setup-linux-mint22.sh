#!/usr/bin/env bash
set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
    echo "error: this setup script expects a Debian/Ubuntu/Linux Mint system" >&2
    exit 1
fi

. /etc/os-release

echo "Detected: ${PRETTY_NAME:-unknown Linux}"
echo "Installing local build + emulator dependencies for SNES + PC Engine ports..."

sudo apt-get update
sudo apt-get install -y \
    build-essential \
    make \
    cc65 \
    git \
    python3 \
    mednafen

echo
printf 'ca65: '
ca65 --version 2>&1 | sed -n '1p'
printf 'ld65: '
ld65 --version 2>&1 | sed -n '1p'
printf 'mednafen: '
mednafen -help 2>&1 | sed -n '1p' || true

echo
echo "Toolchain ready."
echo "Build both ports: make"
echo "Verify both ROMs: make verify"
echo "Run SNES: make run-snes"
echo "Run PC Engine: make run-pce"
echo "Run both: make run-both"
