#!/usr/bin/env bash
set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
    echo "error: this setup script expects a Debian/Ubuntu/Linux Mint system" >&2
    exit 1
fi

. /etc/os-release

echo "Detected: ${PRETTY_NAME:-unknown Linux}"
echo "Installing local build dependencies for SNES + PC Engine ports..."

sudo apt-get update
sudo apt-get install -y \
    build-essential \
    make \
    cc65 \
    git \
    python3

echo
printf 'ca65: '
ca65 --version 2>&1 | head -n 1
printf 'ld65: '
ld65 --version 2>&1 | head -n 1

echo
echo "Toolchain ready. Build both ports with:"
echo "  make"
