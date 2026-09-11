#!/usr/bin/env python3
"""Finalize generated platform video code.

C64 character animation is frame/IRQ driven, not cave-dirty driven. Move the
console diamond tick out of platform_video_begin into the unconditional
platform_video_tick hook. On PCE, use the same HuC6280 TIA path as the
known-good gameplay charset upload instead of byte-at-a-time VDC writes.
"""

from pathlib import Path
import re
import sys

if len(sys.argv) != 3 or sys.argv[1] not in {"snes", "pce"}:
    raise SystemExit("usage: fix-generated-platform-video.py snes|pce FILE")

platform = sys.argv[1]
path = Path(sys.argv[2])
text = path.read_text()

if platform == "snes":
    old = ".proc platform_video_begin\n    jsr snes_load_cave_palette\n    jsr snes_tick_diamond_animation\n"
    new = (
        ".proc platform_video_tick\n"
        "    jsr snes_tick_diamond_animation\n"
        "    rts\n"
        ".endproc\n\n"
        ".proc platform_video_begin\n"
        "    jsr snes_load_cave_palette\n"
    )
    if old not in text:
        raise SystemExit("SNES generated video-begin animation marker not found")
    text = text.replace(old, new, 1)

else:
    old = ".proc platform_video_begin\n    jsr pce_load_cave_palette\n    jsr pce_tick_diamond_animation\n"
    new = (
        ".proc platform_video_tick\n"
        "    jsr pce_tick_diamond_animation\n"
        "    rts\n"
        ".endproc\n\n"
        ".proc platform_video_begin\n"
        "    jsr pce_load_cave_palette\n"
    )
    if old not in text:
        raise SystemExit("PCE generated video-begin animation marker not found")
    text = text.replace(old, new, 1)

    # TIA is already used successfully for the normal PCE charset. Use it for
    # the four diamond characters too: two adjacent top tiles at $0880 and two
    # adjacent bottom tiles at $0980. Each pair is 64 bytes / 32 VRAM words.
    routine = r'''.proc pce_upload_diamond_frame
    lda #$01
    tam #$40

    st0 #VDC_MAWR
    st1 #<DIAMOND_TOP_WORD
    st2 #>DIAMOND_TOP_WORD
    st0 #VDC_DATA

    lda pce_diamond_phase
    cmp #$00
    bne :+
    tia bd_diamond_anim_pce_frame0, VDC_DATA_L, $40
    jmp @bottom_setup
:
    cmp #$01
    bne :+
    tia bd_diamond_anim_pce_frame1, VDC_DATA_L, $40
    jmp @bottom_setup
:
    cmp #$02
    bne :+
    tia bd_diamond_anim_pce_frame2, VDC_DATA_L, $40
    jmp @bottom_setup
:
    cmp #$03
    bne :+
    tia bd_diamond_anim_pce_frame3, VDC_DATA_L, $40
    jmp @bottom_setup
:
    cmp #$04
    bne :+
    tia bd_diamond_anim_pce_frame4, VDC_DATA_L, $40
    jmp @bottom_setup
:
    cmp #$05
    bne :+
    tia bd_diamond_anim_pce_frame5, VDC_DATA_L, $40
    jmp @bottom_setup
:
    cmp #$06
    bne :+
    tia bd_diamond_anim_pce_frame6, VDC_DATA_L, $40
    jmp @bottom_setup
:
    tia bd_diamond_anim_pce_frame7, VDC_DATA_L, $40

@bottom_setup:
    st0 #VDC_MAWR
    st1 #<DIAMOND_BOTTOM_WORD
    st2 #>DIAMOND_BOTTOM_WORD
    st0 #VDC_DATA

    lda pce_diamond_phase
    cmp #$00
    bne :+
    tia bd_diamond_anim_pce_frame0+$40, VDC_DATA_L, $40
    rts
:
    cmp #$01
    bne :+
    tia bd_diamond_anim_pce_frame1+$40, VDC_DATA_L, $40
    rts
:
    cmp #$02
    bne :+
    tia bd_diamond_anim_pce_frame2+$40, VDC_DATA_L, $40
    rts
:
    cmp #$03
    bne :+
    tia bd_diamond_anim_pce_frame3+$40, VDC_DATA_L, $40
    rts
:
    cmp #$04
    bne :+
    tia bd_diamond_anim_pce_frame4+$40, VDC_DATA_L, $40
    rts
:
    cmp #$05
    bne :+
    tia bd_diamond_anim_pce_frame5+$40, VDC_DATA_L, $40
    rts
:
    cmp #$06
    bne :+
    tia bd_diamond_anim_pce_frame6+$40, VDC_DATA_L, $40
    rts
:
    tia bd_diamond_anim_pce_frame7+$40, VDC_DATA_L, $40
    rts
.endproc

.proc pce_tick_diamond_animation'''

    pattern = re.compile(
        r"\.proc pce_upload_diamond_frame\n.*?\.endproc\n\n\.proc pce_tick_diamond_animation",
        re.DOTALL,
    )
    text, count = pattern.subn(routine, text, count=1)
    if count != 1:
        raise SystemExit("PCE generated diamond upload routine not found")

path.write_text(text)
