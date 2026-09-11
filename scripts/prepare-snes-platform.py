#!/usr/bin/env python3
"""Prepare SNES platform source with C64 intro and cave tile animations."""

from pathlib import Path
import sys

src_path = Path(sys.argv[1])
out_path = Path(sys.argv[2])
src = src_path.read_text(encoding="utf-8")

src = src.replace(
    "CAVE_RENDER_BYTES = 32 * 28 * 2\n",
    "CAVE_RENDER_BYTES = 32 * 28 * 2\n"
    "DIAMOND_TOP_WORD = $0880\n"
    "DIAMOND_BOTTOM_WORD = $0980\n"
    "INTRO_MAP_WORD = $3800\n"
    "INTRO_MAP_BYTES = $0800\n",
    1,
)

src = src.replace(
    '.segment "BSS"\n',
    '.segment "ZEROPAGE"\n'
    'snes_zp_anim_src: .res 2\n\n'
    '.segment "BSS"\n',
    1,
)

src = src.replace(
    "snes_palette_cave: .res 1\n",
    "snes_palette_cave:  .res 1\n"
    "snes_diamond_phase: .res 1\n"
    "snes_intro_phase:   .res 1\n"
    "snes_intro_counter: .res 1\n",
    1,
)

animation_code = r'''
; Eight maps generated from the original C64 title charset. The C64 routine
; rotates character $00 and rebuilds $09/$0A every fourth PAL IRQ.
snes_intro_map_lo:
    .byte <bd_intro_map_snes_0,<bd_intro_map_snes_1,<bd_intro_map_snes_2,<bd_intro_map_snes_3
    .byte <bd_intro_map_snes_4,<bd_intro_map_snes_5,<bd_intro_map_snes_6,<bd_intro_map_snes_7
snes_intro_map_hi:
    .byte >bd_intro_map_snes_0,>bd_intro_map_snes_1,>bd_intro_map_snes_2,>bd_intro_map_snes_3
    .byte >bd_intro_map_snes_4,>bd_intro_map_snes_5,>bd_intro_map_snes_6,>bd_intro_map_snes_7
snes_intro_map_bank:
    .byte ^bd_intro_map_snes_0,^bd_intro_map_snes_1,^bd_intro_map_snes_2,^bd_intro_map_snes_3
    .byte ^bd_intro_map_snes_4,^bd_intro_map_snes_5,^bd_intro_map_snes_6,^bd_intro_map_snes_7

.proc snes_upload_intro_map_frame
    lda #$80
    sta VMAIN
    lda #<INTRO_MAP_WORD
    sta VMADDL
    lda #>INTRO_MAP_WORD
    sta VMADDH

    lda #$01
    sta DMAP0
    lda #$18
    sta BBAD0
    ldx snes_intro_phase
    lda snes_intro_map_lo,x
    sta A1T0L
    lda snes_intro_map_hi,x
    sta A1T0H
    lda snes_intro_map_bank,x
    sta A1B0
    lda #<INTRO_MAP_BYTES
    sta DAS0L
    lda #>INTRO_MAP_BYTES
    sta DAS0H
    lda #$01
    sta MDMAEN
    rts
.endproc

.proc snes_tick_intro_animation
    inc snes_intro_counter
    lda snes_intro_counter
    cmp #$04
    bcc @done
    stz snes_intro_counter
    inc snes_intro_phase
    lda snes_intro_phase
    and #$07
    sta snes_intro_phase
    jsr snes_upload_intro_map_frame
@done:
    rts
.endproc

.proc snes_upload_diamond_frame
    ; C64 logical diamond stays unchanged. Only its four graphics characters
    ; $48/$49/$58/$59 are replaced, matching IRQ_AnimateTiles.
    ldx snes_diamond_phase
    lda bd_diamond_anim_snes_ptr_lo,x
    sta snes_zp_anim_src
    lda bd_diamond_anim_snes_ptr_hi,x
    sta snes_zp_anim_src+1

    lda #$80
    sta VMAIN

    lda #<DIAMOND_TOP_WORD
    sta VMADDL
    lda #>DIAMOND_TOP_WORD
    sta VMADDH
    ldy #$00
@top:
    lda (snes_zp_anim_src),y
    sta VMDATAL
    iny
    lda (snes_zp_anim_src),y
    sta VMDATAH
    iny
    cpy #$40
    bne @top

    lda #<DIAMOND_BOTTOM_WORD
    sta VMADDL
    lda #>DIAMOND_BOTTOM_WORD
    sta VMADDH
@bottom:
    lda (snes_zp_anim_src),y
    sta VMDATAL
    iny
    lda (snes_zp_anim_src),y
    sta VMDATAH
    iny
    cpy #$80
    bne @bottom
    rts
.endproc

.proc snes_tick_diamond_animation
    ; The SNES image is PAL/Europe, matching the C64's 50 Hz animation IRQ.
    inc snes_diamond_phase
    lda snes_diamond_phase
    and #$07
    sta snes_diamond_phase
    jsr snes_upload_diamond_frame
    rts
.endproc

'''

marker = ".proc platform_init\n"
if marker not in src:
    raise SystemExit("SNES platform_init marker not found")
src = src.replace(marker, animation_code + marker, 1)

old = "    jsr snes_upload_intro\n    jsr snes_load_intro_palette\n"
new = (
    "    stz snes_intro_phase\n"
    "    stz snes_intro_counter\n"
    "    jsr snes_upload_intro\n"
    "    jsr snes_load_intro_palette\n"
)
if old not in src:
    raise SystemExit("SNES intro-init marker not found")
src = src.replace(old, new, 1)

old = "@intro_wait:\n    jsr platform_wait_frame\n    jsr platform_read_pad\n"
new = (
    "@intro_wait:\n"
    "    jsr platform_wait_frame\n"
    "    jsr snes_tick_intro_animation\n"
    "    jsr platform_read_pad\n"
)
if old not in src:
    raise SystemExit("SNES intro-wait marker not found")
src = src.replace(old, new, 1)

old = "    jsr snes_upload_game_tiles\n    jsr snes_upload_cave\n"
new = (
    "    jsr snes_upload_game_tiles\n"
    "    stz snes_diamond_phase\n"
    "    jsr snes_upload_diamond_frame\n"
    "    jsr snes_upload_cave\n"
)
if old not in src:
    raise SystemExit("SNES game-graphics init marker not found")
src = src.replace(old, new, 1)

old = ".proc platform_video_begin\n    jsr snes_load_cave_palette\n"
new = (
    ".proc platform_video_begin\n"
    "    jsr snes_load_cave_palette\n"
    "    jsr snes_tick_diamond_animation\n"
)
if old not in src:
    raise SystemExit("SNES video-begin marker not found")
src = src.replace(old, new, 1)

old = '.segment "RODATA"\n.include "../../build/generated/snes/charset.inc"\n'
new = (
    '.segment "RODATA"\n'
    '.include "../../build/generated/snes/charset.inc"\n'
    '.include "../../build/generated/snes/diamond-anim.inc"\n'
)
if old not in src:
    raise SystemExit("SNES RODATA marker not found")
src = src.replace(old, new, 1)

out_path.parent.mkdir(parents=True, exist_ok=True)
out_path.write_text(src, encoding="utf-8")
