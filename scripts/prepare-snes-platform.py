#!/usr/bin/env python3
"""Prepare SNES platform source with original C64 diamond animation upload."""

from pathlib import Path
import sys

src_path = Path(sys.argv[1])
out_path = Path(sys.argv[2])
src = src_path.read_text(encoding="utf-8")

src = src.replace(
    "CAVE_RENDER_BYTES = 32 * 28 * 2\n",
    "CAVE_RENDER_BYTES = 32 * 28 * 2\n"
    "DIAMOND_TOP_WORD = $0880\n"
    "DIAMOND_BOTTOM_WORD = $0980\n",
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
    "snes_palette_cave:    .res 1\n"
    "snes_diamond_phase:   .res 1\n"
    "snes_diamond_cadence: .res 1\n",
    1,
)

animation_code = r'''
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
    ; Original PAL C64 updates on the 50 Hz video IRQ. The console loop is
    ; roughly 60 Hz, so skip one update out of six to preserve that cadence.
    inc snes_diamond_cadence
    lda snes_diamond_cadence
    cmp #$06
    bne @advance
    stz snes_diamond_cadence
    rts
@advance:
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

old = "    jsr snes_upload_game_tiles\n    jsr snes_upload_cave\n"
new = (
    "    jsr snes_upload_game_tiles\n"
    "    stz snes_diamond_phase\n"
    "    stz snes_diamond_cadence\n"
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
