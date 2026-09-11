#!/usr/bin/env python3
"""Generate console intro assets directly from the C64 title data.

The title source supplies the 40x25 screen codes and B1_ChrS.asm supplies the
matching C64 multicolor character set. A variant file may replace an initial
prefix and inherit the unchanged tail from another title file with:

    ; @inherit-title-tail B1_Title.asm 40

The C64 picture is reconstructed at 320x200 and horizontally sampled to the
consoles' 256-pixel playfield. No artwork is redrawn by hand.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path

BYTE_RE = re.compile(r"\.byte\s+\$([0-9A-Fa-f]{2})", re.IGNORECASE)
CHR_RE = re.compile(r"^\s*Chr_([0-9A-Fa-f]{2})\b")
INHERIT_RE = re.compile(
    r"^\s*;\s*@inherit-title-tail\s+(\S+)\s+(\d+)\s*$", re.IGNORECASE
)

SRC_W = 320
SRC_H = 200
DST_W = 256
MAP_W = 32
MAP_H = 32
SCREEN_Y = 1
PATTERN_BASE = 0x40
PCE_BANK_BYTES = 0x2000


def read_raw_title(path: Path) -> list[int]:
    values: list[int] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        m = BYTE_RE.search(line)
        if m:
            values.append(int(m.group(1), 16))
    return values


def read_title(path: Path) -> list[int]:
    values: list[int] = []
    inherit: tuple[Path, int] | None = None
    for line in path.read_text(encoding="utf-8").splitlines():
        m = BYTE_RE.search(line)
        if m:
            values.append(int(m.group(1), 16))
        im = INHERIT_RE.match(line)
        if im:
            inherit = (path.parent / im.group(1), int(im.group(2), 10))

    if inherit is not None:
        base_path, skip = inherit
        base = read_raw_title(base_path)
        if len(base) < 1000:
            raise SystemExit(f"{base_path}: only {len(base)} title bytes; need 1000")
        if len(values) != skip:
            raise SystemExit(
                f"{path}: variant has {len(values)} explicit bytes; expected {skip} before inherited tail"
            )
        values.extend(base[skip:1000])

    if len(values) < 1000:
        raise SystemExit(f"{path}: only {len(values)} title bytes; need 1000")
    return values[:1000]


def read_charset(path: Path) -> dict[int, list[int]]:
    chars: dict[int, list[int]] = {}
    current: int | None = None
    rows: list[int] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        label = CHR_RE.match(line)
        if label:
            if current is not None and len(rows) != 8:
                raise SystemExit(f"Chr_{current:02x} has {len(rows)} rows")
            current = int(label.group(1), 16)
            rows = []
        if current is not None:
            m = BYTE_RE.search(line)
            if m:
                rows.append(int(m.group(1), 16))
                if len(rows) == 8:
                    chars[current] = rows.copy()
                    current = None
                    rows = []
    if not chars:
        raise SystemExit(f"{path}: no Chr_XX characters found")
    return chars


def char_row_pixels(value: int) -> list[int]:
    out: list[int] = []
    for shift in (6, 4, 2, 0):
        c = (value >> shift) & 3
        out.extend((c, c))
    return out


def render_source(screen: list[int], chars: dict[int, list[int]]) -> list[list[int]]:
    image = [[0] * SRC_W for _ in range(SRC_H)]
    for cy in range(25):
        for cx in range(40):
            code = screen[cy * 40 + cx]
            rows = chars.get(code)
            if rows is None:
                raise SystemExit(f"title uses missing Chr_{code:02x}")
            for py, row in enumerate(rows):
                pixels = char_row_pixels(row)
                image[cy * 8 + py][cx * 8 : cx * 8 + 8] = pixels
    return image


def scale_horizontal(src: list[list[int]]) -> list[list[int]]:
    return [[row[(x * 5) // 4] for x in range(DST_W)] for row in src]


def make_tiles(image: list[list[int]]) -> list[list[list[int]]]:
    blank = [[0] * 8 for _ in range(8)]
    tiles: list[list[list[int]]] = [blank]
    for ty in range(25):
        for tx in range(32):
            tile = [image[ty * 8 + y][tx * 8 : tx * 8 + 8] for y in range(8)]
            tiles.append(tile)
    assert len(tiles) == 801
    return tiles


def encode_planes01(tile: list[list[int]]) -> bytes:
    out = bytearray()
    for row in tile:
        p0 = 0
        p1 = 0
        for x, value in enumerate(row):
            bit = 7 - x
            if value & 1:
                p0 |= 1 << bit
            if value & 2:
                p1 |= 1 << bit
        out.extend((p0, p1))
    return bytes(out)


def encode_4bpp(tile: list[list[int]]) -> bytes:
    return encode_planes01(tile) + bytes(16)


def make_map() -> bytes:
    words: list[int] = []
    for row in range(MAP_H):
        for col in range(MAP_W):
            if SCREEN_Y <= row < SCREEN_Y + 25:
                n = (row - SCREEN_Y) * 32 + col
                tile = PATTERN_BASE + 1 + n
            else:
                tile = PATTERN_BASE
            words.append(tile)
    out = bytearray()
    for word in words:
        out.extend((word & 0xFF, (word >> 8) & 0xFF))
    return bytes(out)


def emit_bytes(lines: list[str], data: bytes) -> None:
    for offset in range(0, len(data), 16):
        chunk = data[offset : offset + 16]
        lines.append("    .byte " + ", ".join(f"${b:02x}" for b in chunk))


def write_snes(path: Path, tiles: list[list[list[int]]], tilemap: bytes) -> None:
    tile_data = b"".join(encode_4bpp(tile) for tile in tiles)
    lines = [
        "; generated by scripts/generate-intro.py",
        "bd_intro_tiles_snes:",
    ]
    emit_bytes(lines, tile_data)
    lines += [
        "bd_intro_tiles_snes_end:",
        f"bd_intro_tiles_snes_bytes = {len(tile_data)}",
        "",
        "bd_intro_map_snes:",
    ]
    emit_bytes(lines, tilemap)
    lines += [
        "bd_intro_map_snes_end:",
        f"bd_intro_map_snes_bytes = {len(tilemap)}",
        "",
    ]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")


def write_pce(paths: list[Path], tiles: list[list[list[int]]], tilemap: bytes) -> None:
    native = b"".join(encode_4bpp(tile) for tile in tiles)
    chunks = [
        native[0x0000:0x2000],
        native[0x2000:0x4000],
        native[0x4000:0x6000],
        native[0x6000:],
    ]
    if any(len(chunk) != PCE_BANK_BYTES for chunk in chunks[:3]):
        raise SystemExit("first three PCE intro banks must each contain 8 KiB")
    if len(chunks[3]) + len(tilemap) > PCE_BANK_BYTES:
        raise SystemExit("final PCE intro bank does not fit tiles plus BAT")

    for i, (path, chunk) in enumerate(zip(paths, chunks)):
        lines = [
            "; generated by scripts/generate-intro.py",
            f"bd_intro_tiles_pce_part{i}:",
        ]
        emit_bytes(lines, chunk)
        lines += [
            f"bd_intro_tiles_pce_part{i}_end:",
            f"bd_intro_tiles_pce_part{i}_bytes = {len(chunk)}",
            "",
        ]
        if i == 3:
            lines.append("bd_intro_map_pce:")
            emit_bytes(lines, tilemap)
            lines += [
                "bd_intro_map_pce_end:",
                f"bd_intro_map_pce_bytes = {len(tilemap)}",
                "",
            ]
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("title", type=Path)
    ap.add_argument("charset", type=Path)
    ap.add_argument("snes_out", type=Path)
    ap.add_argument("pce_bank2_out", type=Path)
    ap.add_argument("pce_bank3_out", type=Path)
    ap.add_argument("pce_bank4_out", type=Path)
    ap.add_argument("pce_bank5_out", type=Path)
    args = ap.parse_args()

    screen = read_title(args.title)
    chars = read_charset(args.charset)
    source = render_source(screen, chars)
    scaled = scale_horizontal(source)
    tiles = make_tiles(scaled)
    tilemap = make_map()
    write_snes(args.snes_out, tiles, tilemap)
    write_pce(
        [args.pce_bank2_out, args.pce_bank3_out, args.pce_bank4_out, args.pce_bank5_out],
        tiles,
        tilemap,
    )
    print(f"generated intro from {args.title}")
    print(f"SNES: {args.snes_out}")
    print(
        "PCE : "
        + ", ".join(
            str(p)
            for p in [
                args.pce_bank2_out,
                args.pce_bank3_out,
                args.pce_bank4_out,
                args.pce_bank5_out,
            ]
        )
    )


if __name__ == "__main__":
    main()
