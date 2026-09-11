#!/usr/bin/env python3
"""Convert Boulder Dash C64 character graphics to console 4bpp tiles.

Two source layouts are supported:

* ``chr``: ``Chr_XX`` labels followed by eight .byte rows.
* ``gfx``: the in-game graphics store in B1_GfxS.asm. Each tile's first .byte
  line contains a ``Gfx_XX`` comment and is followed by seven more byte rows.

The output keeps the original character index. Missing indices are emitted as
blank tiles so a C64 character number such as $44, $46 or $60 can be used
unchanged by the console tile maps.

Boulder Dash uses VIC-II multicolor character graphics for the cave. Each C64
source byte therefore contains four 2-bit pixels. A multicolor pixel is twice
as wide as a hires pixel, so each 2-bit value is expanded to two identical
console pixels. Palette indices 0..3 preserve the VIC multicolor roles:
background, multicolor 1, multicolor 2, per-character foreground.

SNES and HuC6270/PCE output is 4bpp, 32 bytes per 8x8 tile. Only planes 0 and
1 are needed because converted pixels are palette indices 0..3.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path

CHR_LABEL_RE = re.compile(r"^\s*Chr_([0-9A-Fa-f]{2})\b")
GFX_MARK_RE = re.compile(r"\bGfx_([0-9A-Fa-f]{2})\b", re.IGNORECASE)
BYTE_RE = re.compile(r"\.byte\s+\$([0-9A-Fa-f]{2})", re.IGNORECASE)


def _validate_unique(chars: list[tuple[int, list[int]]]) -> None:
    seen: set[int] = set()
    for index, rows in chars:
        if index in seen:
            raise ValueError(f"duplicate character index ${index:02x}")
        if len(rows) != 8:
            raise ValueError(f"character ${index:02x} has {len(rows)} rows; expected 8")
        seen.add(index)


def read_chr_characters(path: Path) -> list[tuple[int, list[int]]]:
    chars: list[tuple[int, list[int]]] = []
    current_index: int | None = None
    rows: list[int] = []

    def finish() -> None:
        nonlocal current_index, rows
        if current_index is None:
            return
        if len(rows) != 8:
            raise ValueError(
                f"Chr_{current_index:02x} has {len(rows)} rows; expected exactly 8"
            )
        chars.append((current_index, rows.copy()))
        current_index = None
        rows = []

    for line_no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        label = CHR_LABEL_RE.match(line)
        if label:
            if current_index is not None:
                finish()
            current_index = int(label.group(1), 16)

        if current_index is not None:
            value = BYTE_RE.search(line)
            if value:
                rows.append(int(value.group(1), 16))
                if len(rows) == 8:
                    finish()
                elif len(rows) > 8:
                    raise ValueError(
                        f"Chr_{current_index:02x} has more than 8 rows near line {line_no}"
                    )

    if current_index is not None:
        finish()
    if not chars:
        raise ValueError("no Chr_XX definitions found")
    _validate_unique(chars)
    return chars


def read_gfx_characters(path: Path) -> list[tuple[int, list[int]]]:
    """Read indexed Gfx_XX tiles from B1_GfxS.asm comments."""
    chars: list[tuple[int, list[int]]] = []
    current_index: int | None = None
    rows: list[int] = []

    for line_no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        byte_match = BYTE_RE.search(line)
        gfx_match = GFX_MARK_RE.search(line)

        if gfx_match:
            if current_index is not None and len(rows) != 8:
                raise ValueError(
                    f"Gfx_{current_index:02x} has {len(rows)} rows before line {line_no}"
                )
            current_index = int(gfx_match.group(1), 16)
            rows = []

        if current_index is not None and byte_match:
            rows.append(int(byte_match.group(1), 16))
            if len(rows) == 8:
                chars.append((current_index, rows.copy()))
                current_index = None
                rows = []
            elif len(rows) > 8:
                raise ValueError(f"Gfx tile has more than 8 rows near line {line_no}")

    if current_index is not None:
        raise ValueError(f"Gfx_{current_index:02x} ended with only {len(rows)} rows")
    if not chars:
        raise ValueError("no Gfx_XX definitions found")
    _validate_unique(chars)
    return chars


def materialize_indexed(chars: list[tuple[int, list[int]]], count: int) -> list[tuple[int, list[int]]]:
    if count <= 0:
        raise ValueError("tile count must be greater than zero")
    by_index = {index: rows for index, rows in chars}
    blank = [0x00] * 8
    return [(index, by_index.get(index, blank)) for index in range(count)]


def expand_multicolor_row(row: int) -> list[int]:
    """Expand four C64 2-bit multicolor pixels to eight console pixels."""
    pixels: list[int] = []
    for shift in (6, 4, 2, 0):
        value = (row >> shift) & 0x03
        pixels.extend((value, value))
    return pixels


def encode_4bpp(rows: list[int]) -> bytes:
    """Encode C64 multicolor rows as SNES/PCE-compatible 4bpp tile bytes."""
    plane01 = bytearray()
    plane23 = bytearray()

    for row in rows:
        plane0 = 0
        plane1 = 0
        for pixel_index, value in enumerate(expand_multicolor_row(row)):
            bit = 7 - pixel_index
            if value & 0x01:
                plane0 |= 1 << bit
            if value & 0x02:
                plane1 |= 1 << bit
        plane01.extend((plane0, plane1))
        plane23.extend((0x00, 0x00))

    out = bytes(plane01 + plane23)
    assert len(out) == 32
    return out


def emit_ca65(path: Path, label: str, chars: list[tuple[int, list[int]]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "; Generated by scripts/convert-charset.py -- do not edit.",
        f"; {len(chars)} indexed C64 multicolor characters, 32 bytes per 4bpp tile.",
        "",
        f"{label}:",
    ]

    for index, rows in chars:
        data = encode_4bpp(rows)
        lines.append(f"    ; character ${index:02X}")
        for offset in range(0, 32, 16):
            chunk = data[offset : offset + 16]
            lines.append("    .byte " + ", ".join(f"${b:02X}" for b in chunk))

    lines += [
        f"{label}_end:",
        f"{label}_count = {len(chars)}",
        f"{label}_bytes = {len(chars) * 32}",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument(
        "--source-format",
        choices=("chr", "gfx"),
        default="chr",
        help="input layout: Chr_XX labels or B1_GfxS Gfx_XX comments",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=64,
        help="number of indexed output tile slots (default: 64)",
    )
    parser.add_argument("--snes-out", type=Path, required=True)
    parser.add_argument("--pce-out", type=Path, required=True)
    args = parser.parse_args()

    if args.limit <= 0:
        raise SystemExit("--limit must be greater than zero")

    if args.source_format == "gfx":
        parsed = read_gfx_characters(args.source)
    else:
        parsed = read_chr_characters(args.source)

    chars = materialize_indexed(parsed, args.limit)
    emit_ca65(args.snes_out, "bd_charset_snes", chars)
    emit_ca65(args.pce_out, "bd_charset_pce", chars)

    present = sum(1 for index, _rows in parsed if index < args.limit)
    print(f"converted {present} source characters into {len(chars)} indexed slots")
    print(f"SNES: {args.snes_out}")
    print(f"PCE : {args.pce_out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
