#!/usr/bin/env python3
"""Structural checks for locally built SNES and PC Engine ROMs."""
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
    if len(rom) != 0x10000:
        fail(f"SNES ROM is {len(rom)} bytes; expected 65536 with intro LoROM bank")

    title = rom[0x7FC0:0x7FD5]
    if title != b"BOULDER DASH PORT    ":
        fail(f"unexpected SNES title/header bytes: {title!r}")
    if rom[0x7FD5] != 0x20:
        fail("SNES mapper byte is not slow LoROM ($20)")
    if rom[0x7FD7] != 0x06:
        fail(f"SNES ROM-size header is ${rom[0x7FD7]:02X}; expected $06 for 64 KiB")

    reset, = struct.unpack_from("<H", rom, 0x7FFC)
    if not 0x8000 <= reset < 0xFFC0:
        fail(f"SNES reset vector ${reset:04X} is outside fixed bank-0 ROM code")
    if all(b == 0xFF for b in rom[0x8000:0x10000]):
        fail("SNES intro LoROM bank 1 is completely empty")

    print(f"ok: SNES 64 KiB LoROM (2 banks), reset=${reset:04X}")


def check_pce() -> None:
    rom = read_rom(PCE)
    if len(rom) != 0xC000:
        fail(f"PC Engine ROM is {len(rom)} bytes; expected 49152 with 6 HuCard banks")

    reset, = struct.unpack_from("<H", rom, 0x1FFE)
    if not 0xE000 <= reset < 0xFFF6:
        fail(f"PCE reset vector ${reset:04X} is outside fixed MPR7 bank-0 code")

    for bank in (1, 2, 3, 4, 5):
        start = bank * 0x2000
        end = start + 0x2000
        if all(b == 0xFF for b in rom[start:end]):
            fail(f"PCE HuCard bank {bank} is completely empty")

    print(f"ok: PC Engine 48 KiB HuCard (6 banks), reset=${reset:04X}")


def main() -> None:
    check_snes()
    check_pce()
    print("ok: both ROM images passed local structural checks")


if __name__ == "__main__":
    main()
