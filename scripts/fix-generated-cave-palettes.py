#!/usr/bin/env python3
"""Replace generated hardcoded cave palettes with source-derived tables."""

from pathlib import Path
import re
import sys

if len(sys.argv) != 3 or sys.argv[1] not in {"snes", "pce"}:
    raise SystemExit("usage: fix-generated-cave-palettes.py snes|pce FILE")

platform = sys.argv[1]
path = Path(sys.argv[2])
text = path.read_text(encoding="utf-8")

if platform == "snes":
    routine = r'''.proc snes_load_cave_palette
    lda game_current_cave
    cmp snes_palette_cave
    beq @done
    sta snes_palette_cave

    ; 8 bytes per cave: four native SNES BGR555 words generated directly
    ; from the original C64 cave header/color-RAM semantics.
    dec a
    asl a
    asl a
    asl a
    tax

    stz CGADD
    ldy #$04
@copy:
    lda bd_cave_palettes_snes,x
    sta CGDATA
    inx
    lda bd_cave_palettes_snes,x
    sta CGDATA
    inx
    dey
    bne @copy
@done:
    rts
.endproc'''
    pattern = re.compile(r"\.proc snes_load_cave_palette\n.*?\.endproc", re.DOTALL)
    text, count = pattern.subn(routine, text, count=1)
    if count != 1:
        raise SystemExit("SNES cave palette routine not found")

    marker = '.include "../../build/generated/snes/diamond-anim.inc"\n'
    insert = marker + '.include "../../build/generated/snes/cave-palettes.inc"\n'
    if marker not in text:
        raise SystemExit("SNES RODATA include marker not found")
    text = text.replace(marker, insert, 1)

else:
    routine = r'''.proc pce_load_cave_palette
    lda game_current_cave
    cmp pce_palette_cave
    beq @done
    sta pce_palette_cave

    ; The generated palette table lives with gameplay data in physical bank 1.
    ; Force MPR6 back to that bank before reading it.
    lda #$01
    tam #$40

    lda game_current_cave
    dec a
    asl a
    asl a
    asl a
    tax

    stz VCE_ADDR_L
    stz VCE_ADDR_H
    ldy #$04
@copy:
    lda bd_cave_palettes_pce,x
    sta VCE_DATA_L
    inx
    lda bd_cave_palettes_pce,x
    sta VCE_DATA_H
    inx
    dey
    bne @copy
@done:
    rts
.endproc'''
    pattern = re.compile(r"\.proc pce_load_cave_palette\n.*?\.endproc", re.DOTALL)
    text, count = pattern.subn(routine, text, count=1)
    if count != 1:
        raise SystemExit("PCE cave palette routine not found")

    marker = '.include "../../build/generated/pce/diamond-anim.inc"\n'
    insert = marker + '.include "../../build/generated/pce/cave-palettes.inc"\n'
    if marker not in text:
        raise SystemExit("PCE BANK1_RODATA include marker not found")
    text = text.replace(marker, insert, 1)

path.write_text(text, encoding="utf-8")
