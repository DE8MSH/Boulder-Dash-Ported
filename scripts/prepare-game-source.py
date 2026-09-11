#!/usr/bin/env python3
"""Prepare the shared console game source without demo/benchmark injection."""

from pathlib import Path
import sys

src = Path(sys.argv[1]).read_text()

# The C64 control field has rows 0..22. Row 22 is used by Cave 2's exit.
src = src.replace("CAVE_ROWS = 22\nCAVE_BYTES = 880", "CAVE_ROWS = 23\nCAVE_BYTES = 920", 1)
src = src.replace("cpy #112", "cpy #152")

# Cave scan processes rows 1..21 and leaves row 22 as the lower border/exit
# row. ca65 cannot reach @row with a relative branch after the full dispatch.
old = "    cmp #21\n    bne @row\n    rts\n.endproc\n"
new = "    cmp #22\n    beq :+\n    jmp @row\n:\n    rts\n.endproc\n"
if old not in src:
    raise SystemExit("cave scan tail not found")
src = src.replace(old, new, 1)

# game_set_point uses game_phys_new_tile internally. Preserve the moving tile
# while clearing its previous cell so boulders and diamonds do not vanish.
old = """.proc game_physics_move_to_target
    lda game_phys_x
    sta game_point_x
    lda game_phys_y
    sta game_point_y
    lda #T_EMPTY
    jsr game_set_point

    lda game_target_x
    sta game_point_x
    lda game_target_y
    sta game_point_y
    lda game_phys_new_tile
    jsr game_set_point
"""
new = """.proc game_physics_move_to_target
    lda game_phys_new_tile
    pha
    lda game_phys_x
    sta game_point_x
    lda game_phys_y
    sta game_point_y
    lda #T_EMPTY
    jsr game_set_point

    lda game_target_x
    sta game_point_x
    lda game_target_y
    sta game_point_y
    pla
    jsr game_set_point
"""
if old not in src:
    raise SystemExit("moving tile preservation block not found")
src = src.replace(old, new, 1)

# Cave 2 uses 20 points per required diamond and 50 afterwards.
src = src.replace(
    ".import game_progress_init\n",
    ".import game_progress_init\n.import game_current_cave\n",
    1,
)
src = src.replace(
    "CAVE1_EXTRA_VALUE     = 15\n",
    "CAVE1_EXTRA_VALUE     = 15\nCAVE2_DIAMOND_VALUE   = 20\nCAVE2_EXTRA_VALUE     = 50\n",
    1,
)
old = """.proc game_collect_diamond
    lda game_diamonds_got
    cmp game_diamonds_needed
    bcc @normal
    lda #CAVE1_EXTRA_VALUE
    bra @score
@normal:
    lda #CAVE1_DIAMOND_VALUE
@score:
    jsr game_add_score
    inc game_diamonds_got
    lda game_diamonds_got
    cmp game_diamonds_needed
    bne @done
    jsr game_open_exit
@done:
    rts
.endproc
"""
new = """.proc game_collect_diamond
    lda game_current_cave
    cmp #2
    beq @cave2

    lda game_diamonds_got
    cmp game_diamonds_needed
    bcc @cave1_normal
    lda #CAVE1_EXTRA_VALUE
    bra @score
@cave1_normal:
    lda #CAVE1_DIAMOND_VALUE
    bra @score

@cave2:
    lda game_diamonds_got
    cmp game_diamonds_needed
    bcc @cave2_normal
    lda #CAVE2_EXTRA_VALUE
    bra @score
@cave2_normal:
    lda #CAVE2_DIAMOND_VALUE

@score:
    jsr game_add_score
    inc game_diamonds_got
    lda game_diamonds_got
    cmp game_diamonds_needed
    bne @done
    jsr game_open_exit
@done:
    rts
.endproc
"""
if old not in src:
    raise SystemExit("diamond scoring block not found")
src = src.replace(old, new, 1)

Path(sys.argv[2]).write_text(src)
