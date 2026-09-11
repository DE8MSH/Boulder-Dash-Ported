#!/usr/bin/env python3
"""Cheap structural checks for locally built SNES and PC Engine ROMs.

No emulator and no network access are required. This intentionally runs on the
Python 3 shipped with Linux Mint 22.

The verifier accepts bank-sized growth so the ports can expand without undoing
the console-native layouts: 32 KiB LoROM banks on SNES and 8 KiB HuCard banks
on PC Engine. The current linker files still emit one bank until banked
segments are actually introduced.
"""
from pathlib import Path
import struct
import sys

ROOT = Path(__file__).resolve().parents[1]
SNES = ROOT / "build/snes/boulder-dash.sfc"
PCE = ROOT / "build/pce/boulder-dash.pce"


def fail(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)


def read_rom(path: Path) -> bytes:
    try:
        return path.read_bytes()
    except FileNotFoundError:
        fail(f"missing {path.relative_to(ROOT)}; run make first")


def check_snes() -> None:
    rom = read_rom(SNES)
    if len(rom) < 0x8000 or len(rom) % 0x8000:
        fail(f"SNES ROM is {len(rom)} bytes; expected a whole number of 32 KiB LoROM banks")

    title = rom[0x7FC0:0x7FD5]
    if title != b"BOULDER DASH PORT    ":
        fail(f"unexpected SNES title/header bytes: {title!r}")

    if rom[0x7FD5] != 0x20:
        fail("SNES mapper byte is not slow LoROM ($20)")

    reset, = struct.unpack_from("<H", rom, 0x7FFC)
    if not 0x8000 <= reset < 0xFFC0:
        fail(f"SNES reset vector ${reset:04X} is outside fixed bank-0 ROM code")

    print(f"ok: SNES {len(rom) // 1024} KiB LoROM ({len(rom) // 0x8000} bank(s)), reset=${reset:04X}")


def check_pce() -> None:
    rom = read_rom(PCE)
    if len(rom) < 0x2000 or len(rom) % 0x2000:
        fail(f"PC Engine ROM is {len(rom)} bytes; expected a whole number of 8 KiB HuCard banks")

    # The fixed vector bank is kept as the final 8 KiB bank when the image is
    # expanded. The CPU still sees its reset vector at $FFFE.
    reset, = struct.unpack_from("<H", rom, len(rom) - 2)
    if not 0xE000 <= reset < 0xFFF6:
        fail(f"PCE reset vector ${reset:04X} is outside the fixed $E000-$FFF5 bank")

    print(f"ok: PC Engine {len(rom) // 1024} KiB HuCard ({len(rom) // 0x2000} bank(s)), reset=${reset:04X}")


def main() -> None:
    check_snes()
    check_pce()
    print("ok: both ROM images passed local structural checks")


if __name__ == "__main__":
    main()
