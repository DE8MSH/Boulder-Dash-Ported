#!/usr/bin/env python3
"""Generate SNES/PCE cave palettes from the original C64 cave color bytes.

B1_CaveData.asm stores, per cave:
  $13 -> VIC-II multicolor 1 (D022)
  $14 -> VIC-II multicolor 2 (D023)
  $15 -> Color RAM byte

For multicolor characters, Color RAM bit 3 enables multicolor mode and only
bits 0..2 select the foreground color. Therefore e.g. $09 means MCM + WHITE,
not BROWN. This distinction is the important part of the original C64 logic.

The C64 source contains color indices, not digital RGB values. For the target
hardware we map those exact VIC-II indices through the calibrated Colodore PAL
palette, then quantize to native SNES BGR555 and HuC6260 9-bit GGGRRRBBB.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path

CAVE_RE = re.compile(r"^CaveData_([0-9A-Fa-f]{2})_Fix\s+equ", re.IGNORECASE)
COLOR_RE = re.compile(
    r"dc\.b\s+\$([0-9A-Fa-f]{2})\s*;\s*\$(13|14|15)\s*-\s*"
    r"(back colour 1|back colour 2|fore colour)",
    re.IGNORECASE,
)
SIMPLE_COLOR_RE = re.compile(
    r"^\s*(BLACK|WHITE|RED|CYAN|PURPLE|GREEN|BLUE|YELLOW|ORANGE|BROWN|LT_RED|DK_GREY|GREY|LT_GREEN|LT_BLUE|LT_GREY)\s*=\s*\$([0-9A-Fa-f]{2})\s*$",
    re.IGNORECASE,
)
MCM_RE = re.compile(r"^\s*COLORAM_MCM_On\s*=\s*%([01]{8})", re.IGNORECASE)

# Calibrated PAL VIC-II (Colodore) RGB reference, keyed by the names that are
# defined in the repository's original color.asm.
RGB_BY_NAME = {
    "BLACK": (0x00, 0x00, 0x00),
    "WHITE": (0xFF, 0xFF, 0xFF),
    "RED": (0x81, 0x33, 0x38),
    "CYAN": (0x75, 0xCE, 0xC8),
    "PURPLE": (0x8E, 0x3C, 0x97),
    "GREEN": (0x56, 0xAC, 0x4D),
    "BLUE": (0x2E, 0x2C, 0x9B),
    "YELLOW": (0xED, 0xF1, 0x71),
    "ORANGE": (0x8E, 0x50, 0x29),
    "BROWN": (0x55, 0x38, 0x00),
    "LT_RED": (0xC4, 0x6C, 0x71),
    "DK_GREY": (0x4A, 0x4A, 0x4A),
    "GREY": (0x7B, 0x7B, 0x7B),
    "LT_GREEN": (0xA9, 0xFF, 0x9F),
    "LT_BLUE": (0x70, 0x6D, 0xEB),
    "LT_GREY": (0xB2, 0xB2, 0xB2),
}


def q(value: int, maximum: int) -> int:
    return (value * maximum + 127) // 255


def snes_bgr555(rgb: tuple[int, int, int]) -> int:
    r, g, b = rgb
    return q(r, 31) | (q(g, 31) << 5) | (q(b, 31) << 10)


def pce_grb333(rgb: tuple[int, int, int]) -> int:
    r, g, b = rgb
    return (q(g, 7) << 6) | (q(r, 7) << 3) | q(b, 7)


def read_color_names(path: Path) -> tuple[dict[int, str], int]:
    names: dict[int, str] = {}
    mcm_flag: int | None = None
    for line in path.read_text(encoding="utf-8").splitlines():
        m = SIMPLE_COLOR_RE.match(line)
        if m:
            names[int(m.group(2), 16)] = m.group(1).upper()
        m = MCM_RE.match(line)
        if m:
            mcm_flag = int(m.group(1), 2)
    if len(names) != 16:
        raise SystemExit(f"{path}: expected 16 simple C64 colors, found {len(names)}")
    if mcm_flag != 0x08:
        raise SystemExit(f"{path}: expected COLORAM_MCM_On=$08, got {mcm_flag!r}")
    return names, mcm_flag


def read_caves(path: Path) -> list[tuple[int, int, int, int]]:
    caves: list[tuple[int, int, int, int]] = []
    current: int | None = None
    fields: dict[int, int] = {}

    def finish() -> None:
        nonlocal current, fields
        if current is None:
            return
        if fields:
            missing = [off for off in (0x13, 0x14, 0x15) if off not in fields]
            if missing:
                raise SystemExit(
                    f"{path}: Cave {current:02X} missing color offsets "
                    + ", ".join(f"${x:02X}" for x in missing)
                )
            caves.append((current, fields[0x13], fields[0x14], fields[0x15]))
        current = None
        fields = {}

    for line in path.read_text(encoding="utf-8").splitlines():
        m = CAVE_RE.match(line)
        if m:
            finish()
            current = int(m.group(1), 16)
            continue
        if current is None:
            continue
        m = COLOR_RE.search(line)
        if m:
            fields[int(m.group(2), 16)] = int(m.group(1), 16)
    finish()

    caves.sort(key=lambda c: c[0])
    if not caves:
        raise SystemExit(f"{path}: no cave color headers found")
    return caves


def palette_indices(cave: tuple[int, int, int, int], mcm_flag: int) -> tuple[int, int, int, int]:
    _number, bg1, bg2, fore = cave
    if not (fore & mcm_flag):
        raise SystemExit(f"Cave {_number:02X}: Color RAM ${fore:02X} does not enable multicolor")
    # D021 is BLACK during normal cave play. D022/D023 use all four VIC color
    # bits, while Color RAM uses bit 3 as MCM enable and bits 0..2 as color.
    return (0x00, bg1 & 0x0F, bg2 & 0x0F, fore & 0x07)


def write_table(
    path: Path,
    label: str,
    caves: list[tuple[int, int, int, int]],
    names: dict[int, str],
    mcm_flag: int,
    convert,
    width: int,
) -> None:
    lines = [
        "; Generated from original B1_CaveData.asm + color.asm -- do not edit.",
        "; Per cave: D021 black, D022 color1, D023 color2, Color-RAM foreground.",
        "; Color-RAM bit 3 is the C64 multicolor-enable flag, not a color bit.",
        "",
        f"{label}:",
    ]
    for number, bg1, bg2, fore in caves:
        indices = palette_indices((number, bg1, bg2, fore), mcm_flag)
        words = [convert(RGB_BY_NAME[names[index]]) for index in indices]
        names_text = "/".join(names[index] for index in indices)
        lines.append(
            f"    ; Cave {number:02X}: C64 $00/${bg1:02X}/${bg2:02X}/${fore:02X} -> {names_text}"
        )
        lines.append("    .word " + ", ".join(f"${word:0{width}X}" for word in words))
    lines += [
        f"{label}_caves = {len(caves)}",
        f"{label}_stride = 8",
        "",
    ]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("caves", type=Path)
    ap.add_argument("colors", type=Path)
    ap.add_argument("snes_out", type=Path)
    ap.add_argument("pce_out", type=Path)
    args = ap.parse_args()

    names, mcm_flag = read_color_names(args.colors)
    caves = read_caves(args.caves)
    for index, name in names.items():
        if name not in RGB_BY_NAME:
            raise SystemExit(f"missing RGB reference for C64 ${index:02X} {name}")

    write_table(args.snes_out, "bd_cave_palettes_snes", caves, names, mcm_flag, snes_bgr555, 4)
    write_table(args.pce_out, "bd_cave_palettes_pce", caves, names, mcm_flag, pce_grb333, 3)

    print(f"generated {len(caves)} source-derived C64 cave palettes")
    for number, bg1, bg2, fore in caves[:3]:
        idx = palette_indices((number, bg1, bg2, fore), mcm_flag)
        print(
            f"cave {number:02X}: "
            + ", ".join(f"${i:02X} {names[i]}" for i in idx)
            + f" (ColorRAM raw ${fore:02X})"
        )
    print(f"SNES: {args.snes_out}")
    print(f"PCE : {args.pce_out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
