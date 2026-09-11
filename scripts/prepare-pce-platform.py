#!/usr/bin/env python3
"""Prepare the PCE platform source with native-bank intro transfers."""

from pathlib import Path
import re
import sys

src = Path(sys.argv[1]).read_text(encoding="utf-8")

native_intro = r'''.proc pce_upload_intro
    ; Intro graphics use the same native 32-byte 4bpp tile format as the
    ; known-good gameplay charset. Each full HuCard bank contains 256 tiles.
    lda #$02
    tam #$40
    st0 #VDC_MAWR
    st1 #<PCE_PATTERN_WORD
    st2 #>PCE_PATTERN_WORD
    st0 #VDC_DATA
    tia bd_intro_tiles_pce_part0, VDC_DATA_L, bd_intro_tiles_pce_part0_bytes

    lda #$03
    tam #$40
    st0 #VDC_DATA
    tia bd_intro_tiles_pce_part1, VDC_DATA_L, bd_intro_tiles_pce_part1_bytes

    lda #$04
    tam #$40
    st0 #VDC_DATA
    tia bd_intro_tiles_pce_part2, VDC_DATA_L, bd_intro_tiles_pce_part2_bytes

    lda #$05
    tam #$40
    st0 #VDC_DATA
    tia bd_intro_tiles_pce_part3, VDC_DATA_L, bd_intro_tiles_pce_part3_bytes

    ; BAT is stored in the remainder of bank 5.
    st0 #VDC_MAWR
    st1 #$00
    st2 #$00
    st0 #VDC_DATA
    tia bd_intro_map_pce, VDC_DATA_L, bd_intro_map_pce_bytes
    rts
.endproc

'''

pattern = re.compile(
    r"; Expand X source tiles.*?\.proc pce_upload_game_tiles\n",
    re.DOTALL,
)
match = pattern.search(src)
if not match:
    raise SystemExit("PCE intro upload block not found")
src = src[: match.start()] + native_intro + ".proc pce_upload_game_tiles\n" + src[match.end() :]

old_tail = '''.segment "BANK1_RODATA"
.include "../../build/generated/pce/charset.inc"

.segment "INTRO2_RODATA"
.include "../../build/generated/pce/intro-bank2.inc"

.segment "INTRO3_RODATA"
.include "../../build/generated/pce/intro-bank3.inc"'''
new_tail = '''.segment "BANK1_RODATA"
.include "../../build/generated/pce/charset.inc"

.segment "INTRO2_RODATA"
.include "../../build/generated/pce/intro-bank2.inc"

.segment "INTRO3_RODATA"
.include "../../build/generated/pce/intro-bank3.inc"

.segment "INTRO4_RODATA"
.include "../../build/generated/pce/intro-bank4.inc"

.segment "INTRO5_RODATA"
.include "../../build/generated/pce/intro-bank5.inc"'''
if old_tail not in src:
    raise SystemExit("PCE intro segment tail not found")
src = src.replace(old_tail, new_tail, 1)

Path(sys.argv[2]).write_text(src, encoding="utf-8")
