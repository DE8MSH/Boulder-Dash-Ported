#!/usr/bin/env python3
"""Prepare the PCE platform source with native intro and C64 tile animation."""

from pathlib import Path
import re
import sys

src = Path(sys.argv[1]).read_text(encoding="utf-8")

src = src.replace(
    "CAVE_RENDER_BYTES = 32 * 28 * 2\n",
    "CAVE_RENDER_BYTES = 32 * 28 * 2\n"
    "DIAMOND_TOP_WORD = $0880\n"
    "DIAMOND_BOTTOM_WORD = $0980\n",
    1,
)

src = src.replace(
    "pce_palette_cave:.res 1\n",
    "pce_palette_cave:    .res 1\n"
    "pce_diamond_phase:   .res 1\n"
    "pce_diamond_cadence: .res 1\n",
    1,
)

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

animation_code = r'''
.proc pce_upload_diamond_frame
    ; Bank 1 contains both the normal gameplay charset and these generated
    ; animation frames. Keep it mapped in MPR6 at $C000-$DFFF.
    lda #$01
    tam #$40

    ldx pce_diamond_phase
    lda bd_diamond_anim_pce_ptr_lo,x
    sta pce_zp_src
    lda bd_diamond_anim_pce_ptr_hi,x
    sta pce_zp_src+1

    st0 #VDC_MAWR
    st1 #<DIAMOND_TOP_WORD
    st2 #>DIAMOND_TOP_WORD
    st0 #VDC_DATA
    ldy #$00
@top:
    lda (pce_zp_src),y
    sta VDC_DATA_L
    iny
    lda (pce_zp_src),y
    sta VDC_DATA_L+1
    iny
    cpy #$40
    bne @top

    st0 #VDC_MAWR
    st1 #<DIAMOND_BOTTOM_WORD
    st2 #>DIAMOND_BOTTOM_WORD
    st0 #VDC_DATA
@bottom:
    lda (pce_zp_src),y
    sta VDC_DATA_L
    iny
    lda (pce_zp_src),y
    sta VDC_DATA_L+1
    iny
    cpy #$80
    bne @bottom
    rts
.endproc

.proc pce_tick_diamond_animation
    ; Original PAL C64 animation runs on the 50 Hz IRQ. The PCE timer loop is
    ; about 60 Hz, so omit one animation step every six console frames.
    inc pce_diamond_cadence
    lda pce_diamond_cadence
    cmp #$06
    bne @advance
    stz pce_diamond_cadence
    rts
@advance:
    inc pce_diamond_phase
    lda pce_diamond_phase
    and #$07
    sta pce_diamond_phase
    jsr pce_upload_diamond_frame
    rts
.endproc

'''

marker = ".proc platform_init\n"
if marker not in src:
    raise SystemExit("PCE platform_init marker not found")
src = src.replace(marker, animation_code + marker, 1)

old = "    jsr pce_upload_game_tiles\n    jsr pce_upload_cave\n"
new = (
    "    jsr pce_upload_game_tiles\n"
    "    stz pce_diamond_phase\n"
    "    stz pce_diamond_cadence\n"
    "    jsr pce_upload_diamond_frame\n"
    "    jsr pce_upload_cave\n"
)
if old not in src:
    raise SystemExit("PCE game-graphics init marker not found")
src = src.replace(old, new, 1)

old = ".proc platform_video_begin\n    jsr pce_load_cave_palette\n"
new = (
    ".proc platform_video_begin\n"
    "    jsr pce_load_cave_palette\n"
    "    jsr pce_tick_diamond_animation\n"
)
if old not in src:
    raise SystemExit("PCE video-begin marker not found")
src = src.replace(old, new, 1)

old_tail = '''.segment "BANK1_RODATA"
.include "../../build/generated/pce/charset.inc"

.segment "INTRO2_RODATA"
.include "../../build/generated/pce/intro-bank2.inc"

.segment "INTRO3_RODATA"
.include "../../build/generated/pce/intro-bank3.inc"'''
new_tail = '''.segment "BANK1_RODATA"
.include "../../build/generated/pce/charset.inc"
.include "../../build/generated/pce/diamond-anim.inc"

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
