#!/usr/bin/env python3
"""Put a tiny 4x7 benchmark font into unused indexed charset slots $02-$0d."""

from pathlib import Path
import sys

GLYPHS = {
    "0": ("0110","1001","1001","1001","1001","1001","0110","0000"),
    "1": ("0010","0110","0010","0010","0010","0010","0111","0000"),
    "2": ("0110","1001","0001","0010","0100","1000","1111","0000"),
    "3": ("1110","0001","0001","0110","0001","0001","1110","0000"),
    "4": ("0001","0011","0101","1001","1111","0001","0001","0000"),
    "5": ("1111","1000","1000","1110","0001","0001","1110","0000"),
    "6": ("0111","1000","1000","1110","1001","1001","0110","0000"),
    "7": ("1111","0001","0010","0010","0100","0100","0100","0000"),
    "8": ("0110","1001","1001","0110","1001","1001","0110","0000"),
    "9": ("0110","1001","1001","0111","0001","0001","1110","0000"),
    "M": ("1001","1111","1111","1001","1001","1001","1001","0000"),
    "S": ("0111","1000","1000","0110","0001","0001","1110","0000"),
}


def encode(rows):
    plane01 = bytearray()
    plane23 = bytearray()
    for row in rows:
        pixels = []
        for bit in row:
            value = 1 if bit == "1" else 0
            pixels.extend((value, value))
        p0 = 0
        for i, value in enumerate(pixels):
            if value:
                p0 |= 1 << (7 - i)
        plane01.extend((p0, 0))
        plane23.extend((0, 0))
    return bytes(plane01 + plane23)


def patch(path: Path):
    lines = path.read_text(encoding="utf-8").splitlines()
    for slot, ch in zip(range(0x02, 0x0e), "0123456789MS"):
        marker = f"    ; character ${slot:02X}"
        try:
            i = lines.index(marker)
        except ValueError as exc:
            raise SystemExit(f"{path}: missing {marker}") from exc
        data = encode(GLYPHS[ch])
        lines[i + 1] = "    .byte " + ", ".join(f"${b:02X}" for b in data[:16])
        lines[i + 2] = "    .byte " + ", ".join(f"${b:02X}" for b in data[16:])
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    if len(sys.argv) < 2:
        raise SystemExit("usage: inject-benchmark-font.py charset.inc [...]")
    for arg in sys.argv[1:]:
        path = Path(arg)
        patch(path)
        print(f"injected benchmark font into {path}")


if __name__ == "__main__":
    main()
