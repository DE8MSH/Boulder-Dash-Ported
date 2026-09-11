#!/usr/bin/env python3
"""Generate the console title screen directly from the original C64 data.

B1_Title_therza.asm replaces only the requested prefix of the 40x25 C64
screen matrix and inherits the rest from B1_Title.asm. B1_ChrS.asm supplies
the original title charset.

The C64 title background animation is reproduced from BoulderDashI.asm:
character $0B is copied to character $00, character $00 is rotated upward,
and characters $09/$0A are rebuilt as $06/$07 OR $00. Eight animation
phases are rendered. The 320x200 C64 picture is horizontally sampled to the
256x200 console playfield, then tiles are deduplicated across all phases.
The consoles keep the resulting graphics resident in VRAM and animate the
intro by replacing only the 32x32 tile map/BAT every fourth PAL C64 frame.
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
FILL_RE = re.compile(r"^\s*;\s*@fill-title\s+\$([0-9A-Fa-f]{2})\s*$", re.IGNORECASE)

SRC_W = 320
SRC_H = 200
DST_W = 256
MAP_W = 32
MAP_H = 32
SCREEN_Y = 1
PATTERN_BASE = 0x40
PCE_BANK_BYTES = 0x2000
PCE_TILE_BANKS = 4
INTRO_PHASES = 8
MAP_BYTES = MAP_W * MAP_H * 2


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
    fill: int | None = None
    for line in path.read_text(encoding="utf-8").splitlines():
        m = BYTE_RE.search(line)
        if m:
            values.append(int(m.group(1), 16))
        im = INHERIT_RE.match(line)
        if im:
            inherit = (path.parent / im.group(1), int(im.group(2), 10))
        fm = FILL_RE.match(line)
        if fm:
            fill = int(fm.group(1), 16)

    if fill is not None:
        if values or inherit is not None:
            raise SystemExit(f"{path}: @fill-title cannot be combined with explicit bytes/inheritance")
        return [fill] * 1000

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
    for needed in (0x00, 0x06, 0x07, 0x09, 0x0A, 0x0B):
        if needed not in chars:
            raise SystemExit(f"{path}: missing Chr_{needed:02x} required by C64 intro animation")
    return chars


def animated_charset(chars: dict[int, list[int]], phase: int) -> dict[int, list[int]]:
    """Reproduce IRQ_OptsAnimCharSteel + IRQ_OptsAnimChar for one phase."""
    out = {index: rows.copy() for index, rows in chars.items()}

    # InitVicGameStatus copies C64 character $0B ($2058) over character $00.
    seed = chars[0x0B]
    phase &= 7
    moving = seed[phase:] + seed[:phase]
    out[0x00] = moving
    out[0x09] = [chars[0x06][i] | moving[i] for i in range(8)]
    out[0x0A] = [chars[0x07][i] | moving[i] for i in range(8)]
    return out


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


def image_tiles(image: list[list[int]]) -> list[tuple[int, ...]]:
    result: list[tuple[int, ...]] = []
    for ty in range(25):
        for tx in range(32):
            flat: list[int] = []
            for y in range(8):
                flat.extend(image[ty * 8 + y][tx * 8 : tx * 8 + 8])
            result.append(tuple(flat))
    return result


def deduplicate_phases(images: list[list[list[int]]]) -> tuple[list[tuple[int, ...]], list[list[int]]]:
    blank = tuple([0] * 64)
    tiles: list[tuple[int, ...]] = [blank]
    tile_ids: dict[tuple[int, ...], int] = {blank: 0}
    phase_maps: list[list[int]] = []

    for image in images:
        ids: list[int] = []
        for tile in image_tiles(image):
            tile_id = tile_ids.get(tile)
            if tile_id is None:
                tile_id = len(tiles)
                tile_ids[tile] = tile_id
                tiles.append(tile)
            ids.append(tile_id)
        phase_maps.append(ids)

    if PATTERN_BASE + len(tiles) - 1 > 0x3FF:
        raise SystemExit(
            f"intro needs {len(tiles)} deduplicated tiles; SNES BG1 limit with base ${PATTERN_BASE:02X} is 960"
        )
    if len(tiles) * 32 > PCE_TILE_BANKS * PCE_BANK_BYTES:
        raise SystemExit(f"intro tile data ({len(tiles) * 32} bytes) exceeds four PCE tile banks")
    return tiles, phase_maps


def encode_4bpp(tile: tuple[int, ...]) -> bytes:
    plane01 = bytearray()
    plane23 = bytearray()
    for y in range(8):
        p0 = 0
        p1 = 0
        for x in range(8):
            value = tile[y * 8 + x]
            bit = 7 - x
            if value & 1:
                p0 |= 1 << bit
            if value & 2:
                p1 |= 1 << bit
        plane01.extend((p0, p1))
        plane23.extend((0, 0))
    return bytes(plane01 + plane23)


def make_map(tile_ids: list[int]) -> bytes:
    if len(tile_ids) != 32 * 25:
        raise ValueError("one intro phase must contain 32x25 visible tiles")
    words: list[int] = []
    for row in range(MAP_H):
        for col in range(MAP_W):
            if SCREEN_Y <= row < SCREEN_Y + 25:
                n = (row - SCREEN_Y) * 32 + col
                tile = PATTERN_BASE + tile_ids[n]
            else:
                tile = PATTERN_BASE
            words.append(tile)
    out = bytearray()
    for word in words:
        out.extend((word & 0xFF, (word >> 8) & 0xFF))
    assert len(out) == MAP_BYTES
    return bytes(out)


def emit_bytes(lines: list[str], data: bytes) -> None:
    for offset in range(0, len(data), 16):
        chunk = data[offset : offset + 16]
        lines.append("    .byte " + ", ".join(f"${b:02x}" for b in chunk))


def write_snes(path: Path, tiles: list[tuple[int, ...]], maps: list[bytes]) -> None:
    tile_data = b"".join(encode_4bpp(tile) for tile in tiles)
    lines = [
        "; generated by scripts/generate-intro.py",
        '.segment "INTRO_TILES"',
        "bd_intro_tiles_snes:",
    ]
    emit_bytes(lines, tile_data)
    lines += [
        "bd_intro_tiles_snes_end:",
        f"bd_intro_tiles_snes_bytes = {len(tile_data)}",
        f"bd_intro_tiles_snes_count = {len(tiles)}",
        "",
        '.segment "INTRO_MAPS"',
    ]
    for phase, tilemap in enumerate(maps):
        lines.append(f"bd_intro_map_snes_{phase}:")
        emit_bytes(lines, tilemap)
        lines.append("")
    lines += [
        "bd_intro_map_snes = bd_intro_map_snes_0",
        f"bd_intro_map_snes_bytes = {MAP_BYTES}",
        "",
    ]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")


def write_pce(tile_paths: list[Path], map_paths: list[Path], tiles: list[tuple[int, ...]], maps: list[bytes]) -> None:
    if len(tile_paths) != 4 or len(map_paths) != 2:
        raise ValueError("PCE intro layout requires four tile banks and two map banks")

    native = b"".join(encode_4bpp(tile) for tile in tiles)
    native = native.ljust(PCE_TILE_BANKS * PCE_BANK_BYTES, b"\x00")

    for i, path in enumerate(tile_paths):
        chunk = native[i * PCE_BANK_BYTES : (i + 1) * PCE_BANK_BYTES]
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
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("\n".join(lines), encoding="utf-8")

    for bank_index, path in enumerate(map_paths):
        first_phase = bank_index * 4
        lines = ["; generated by scripts/generate-intro.py"]
        for local in range(4):
            phase = first_phase + local
            lines.append(f"bd_intro_map_pce_{phase}:")
            emit_bytes(lines, maps[phase])
            lines.append("")
        if bank_index == 0:
            lines.append(f"bd_intro_map_pce_bytes = {MAP_BYTES}")
            lines.append("")
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
    ap.add_argument("pce_bank6_out", type=Path)
    ap.add_argument("pce_bank7_out", type=Path)
    args = ap.parse_args()

    screen = read_title(args.title)
    chars = read_charset(args.charset)
    images = [
        scale_horizontal(render_source(screen, animated_charset(chars, phase)))
        for phase in range(INTRO_PHASES)
    ]
    tiles, phase_tile_ids = deduplicate_phases(images)
    maps = [make_map(ids) for ids in phase_tile_ids]

    write_snes(args.snes_out, tiles, maps)
    write_pce(
        [args.pce_bank2_out, args.pce_bank3_out, args.pce_bank4_out, args.pce_bank5_out],
        [args.pce_bank6_out, args.pce_bank7_out],
        tiles,
        maps,
    )

    print(f"generated animated intro from {args.title}: {len(tiles)} unique tiles, {INTRO_PHASES} phases")
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
                args.pce_bank6_out,
                args.pce_bank7_out,
            ]
        )
    )


if __name__ == "__main__":
    main()
