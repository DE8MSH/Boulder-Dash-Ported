#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

make check
make clean
make snes-rom
make pce-rom

test -s build/snes/boulder-dash.sfc
test -s build/pce/boulder-dash.pce

echo
echo "Local dual-port build completed successfully:"
ls -lh build/snes/boulder-dash.sfc build/pce/boulder-dash.pce
