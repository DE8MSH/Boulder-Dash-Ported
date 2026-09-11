#!/usr/bin/env python3
"""Prepare the PCE platform source with native C64 intro/game animations."""

from pathlib import Path
import re
import sys

src = Path(sys.argv[1]).read_text(encoding="utf-8")

src = src.replace(
    "CAVE_RENDER_BYTES = 32 * 28 * 2\n",
    "CAVE_RENDER_BYTES = 32 * 28 * 2\n"
    "DIAMOND_TOP_WORD = $0880\n"
    "DIAMOND_BOTTOM_WORD = $0980\n"
    "INTRO_MAP_BYTES = $0800\n",
    1,
)

src = src.replace(
    "pce_palette_cave:.res 1\n",
    "pce_palette_cave:    .res 1\n"
    "pce_diamond_phase:   .res 1\n"
    "pce_diamond_cadence: .res 1\n"
    "pce_intro_phase:     .res 1\n"
    "pce_intro_accum:     .res 1\n",
    1,
)

native_intro = r'''.proc pce_upload_intro_map_frame
    ; Maps 0-3 occupy physical HuCard bank 6, maps 4-7 bank 7.
    lda pce_intro_phase
    cmp #$04
    bcc @bank6
    lda #$07
    bra @map_bank
@bank6:
    lda #$06
@map_bank:
    tam #$40

    st0 #VDC_MAWR
    st1 #$00
    st2 #$00
    st0 #VDC_DATA

    lda pce_intro_phase
    cmp #$00
    bne :+
    tia bd_intro_map_pce_0, VDC_DATA_L, INTRO_MAP_BYTES
    rts
:
    cmp #$01
    bne :+
    tia bd_intro_map_pce_1, VDC_DATA_L, INTRO_MAP_BYTES
    rts
:
    cmp #$02
    bne :+
    tia bd_intro_map_pce_2, VDC_DATA_L, INTRO_MAP_BYTES
    rts
:
    cmp #$03
    bne :+
    tia bd_intro_map_pce_3, VDC_DATA_L, INTRO_MAP_BYTES
    rts
:
    cmp #$04
    bne :+
    tia bd_intro_map_pce_4, VDC_DATA_L, INTRO_MAP_BYTES
    rts
:
    cmp #$05
    bne :+
    tia bd_intro_map_pce_5, VDC_DATA_L, INTRO_MAP_BYTES
    rts
:
    cmp #$06
    bne :+
    tia bd_intro_map_pce_6, VDC_DATA_L, INTRO_MAP_BYTES
    rts
:
    tia bd_intro_map_pce_7, VDC_DATA_L, INTRO_MAP_BYTES
    rts
.endproc

.proc pce_tick_intro_animation
    ; C64 changes the moving title characters every 4 PAL frames = 12.5 Hz.
    ; The PCE timer loop is about 60 Hz, so 5/24 gives the same average rate.
    lda pce_intro_accum
    clc
    adc #$05
    cmp #$18
    bcc @store
    sbc #$18
    sta pce_intro_accum
    inc pce_intro_phase
    lda pce_intro_phase
    and #$07
    sta pce_intro_phase
    jsr pce_upload_intro_map_frame
    rts
@store:
    sta pce_intro_accum
    rts
.endproc

.proc pce_upload_intro
    ; Static title graphics occupy physical HuCard banks 2-5 and remain in
    ; VRAM. Animation only changes the BAT, matching the C64 charset motion.
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

    stz pce_intro_phase
    stz pce_intro_accum
    jsr pce_upload_intro_map_frame
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
    ; Bank 1 contains both the normal gameplay charset and generated original
    ; C64 diamond phases. Keep it mapped in MPR6 at $C000-$DFFF.
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
    ; Preserve the PAL C64's 50 Hz graphics update rate on the ~60 Hz PCE loop.
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

old = "@intro_wait:\n    jsr platform_wait_frame\n    jsr platform_read_pad\n"
new = (
    "@intro_wait:\n"
    "    jsr platform_wait_frame\n"
    "    jsr pce_tick_intro_animation\n"
    "    jsr platform_read_pad\n"
)
if old not in src:
    raise SystemExit("PCE intro-wait marker not found")
src = src.replace(old, new, 1)

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
.include "../../build/generated/pce/intro-bank5.inc"

.segment "INTRO6_RODATA"
.include "../../build/generated/pce/intro-bank6.inc"

.segment "INTRO7_RODATA"
.include "../../build/generated/pce/intro-bank7.inc"'''
if old_tail not in src:
    raise SystemExit("PCE intro segment tail not found")
src = src.replace(old_tail, new_tail, 1)

Path(sys.argv[2]).write_text(src, encoding="utf-8")
