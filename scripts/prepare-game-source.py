#!/usr/bin/env python3
"""Prepare the shared console game source without demo/benchmark injection."""

from pathlib import Path
import sys

src = Path(sys.argv[1]).read_text()

# The C64 control field has rows 0..22. Row 22 is used by Cave 2's exit.
src = src.replace("CAVE_ROWS = 22\nCAVE_BYTES = 880", "CAVE_ROWS = 23\nCAVE_BYTES = 920", 1)
src = src.replace("cpy #112", "cpy #152")

# Cave starts need to center the shared view immediately, not only after the
# first player movement.
src = src.replace(
    ".export game_render_cave\n",
    ".export game_render_cave\n.export game_update_view\n",
    1,
)

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

# Firefly constants and one temporary direction byte.
src = src.replace(
    "T_STEEL          = $07\n",
    "T_STEEL          = $07\n"
    "T_FIREFLY0       = $08\n"
    "T_FIREFLY1       = $09\n"
    "T_FIREFLY2       = $0a\n"
    "T_FIREFLY3       = $0b\n"
    "T_FIREFLY0_      = $0c\n"
    "T_FIREFLY1_      = $0d\n"
    "T_FIREFLY2_      = $0e\n"
    "T_FIREFLY3_      = $0f\n",
    1,
)
src = src.replace(
    "game_explosion_changed: .res 1\n",
    "game_explosion_changed: .res 1\ngame_fire_dir:          .res 1\n",
    1,
)

# Normalize firefly marker tiles after one cave scan, exactly like the C64
# replacement table maps $0c..$0f back to $08..$0b.
src = src.replace(
    "@scan:\n    lda (game_zp_src),y\n    cmp #T_BOULDER_FIXED_\n",
    "@scan:\n"
    "    lda (game_zp_src),y\n"
    "    cmp #T_FIREFLY0_\n"
    "    bcc :+\n"
    "    cmp #(T_FIREFLY3_ + 1)\n"
    "    bcs :+\n"
    "    sec\n"
    "    sbc #4\n"
    "    bra @store\n"
    ":\n"
    "    cmp #T_BOULDER_FIXED_\n",
    1,
)
src = src.replace(
    "@tail:\n    lda (game_zp_src),y\n    cmp #T_BOULDER_FIXED_\n",
    "@tail:\n"
    "    lda (game_zp_src),y\n"
    "    cmp #T_FIREFLY0_\n"
    "    bcc :+\n"
    "    cmp #(T_FIREFLY3_ + 1)\n"
    "    bcs :+\n"
    "    sec\n"
    "    sbc #4\n"
    "    bra @tail_store\n"
    ":\n"
    "    cmp #T_BOULDER_FIXED_\n",
    1,
)

firefly_code = r'''
; C64 firefly rule: explode when Rockford is orthogonally adjacent. Otherwise
; try the direction from TabFliesMoveTargPosDo, then TabFliesMoveTargPosLe;
; if both are blocked rotate in place. Marker tiles prevent a second move in
; the same top-to-bottom cave scan.
.proc game_firefly_touching_player
    lda game_phys_x
    sta game_point_x
    lda game_phys_y
    dec a
    sta game_point_y
    jsr game_get_point
    cmp #T_ROCKFORD
    beq @yes

    lda game_phys_x
    sta game_point_x
    lda game_phys_y
    inc a
    sta game_point_y
    jsr game_get_point
    cmp #T_ROCKFORD
    beq @yes

    lda game_phys_x
    dec a
    sta game_point_x
    lda game_phys_y
    sta game_point_y
    jsr game_get_point
    cmp #T_ROCKFORD
    beq @yes

    lda game_phys_x
    inc a
    sta game_point_x
    lda game_phys_y
    sta game_point_y
    jsr game_get_point
    cmp #T_ROCKFORD
    beq @yes
    clc
    rts
@yes:
    sec
    rts
.endproc

.proc game_firefly_target_do
    lda game_phys_x
    sta game_target_x
    lda game_phys_y
    sta game_target_y
    lda game_fire_dir
    beq @down
    cmp #1
    beq @left
    cmp #2
    beq @up
    inc game_target_x
    rts
@down:
    inc game_target_y
    rts
@left:
    dec game_target_x
    rts
@up:
    dec game_target_y
    rts
.endproc

.proc game_firefly_target_left
    lda game_phys_x
    sta game_target_x
    lda game_phys_y
    sta game_target_y
    lda game_fire_dir
    beq @left
    cmp #1
    beq @up
    cmp #2
    beq @right
    inc game_target_y
    rts
@left:
    dec game_target_x
    rts
@up:
    dec game_target_y
    rts
@right:
    inc game_target_x
    rts
.endproc

; A = firefly marker tile to place at target.
.proc game_firefly_move
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
    jsr game_mark_full_dirty
    rts
.endproc

.proc game_firefly_step
    and #$03
    sta game_fire_dir

    jsr game_firefly_touching_player
    bcc @move
    jsr game_explode_drop
    rts

@move:
    jsr game_firefly_target_do
    lda game_target_x
    sta game_point_x
    lda game_target_y
    sta game_point_y
    jsr game_get_point
    beq :+
    jmp @try_left
:
    lda game_fire_dir
    clc
    adc #3
    and #$03
    clc
    adc #T_FIREFLY0_
    jsr game_firefly_move
    rts

@try_left:
    jsr game_firefly_target_left
    lda game_target_x
    sta game_point_x
    lda game_target_y
    sta game_point_y
    jsr game_get_point
    beq :+
    jmp @rotate
:
    lda game_fire_dir
    clc
    adc #T_FIREFLY0_
    jsr game_firefly_move
    rts

@rotate:
    lda game_phys_x
    sta game_point_x
    lda game_phys_y
    sta game_point_y
    lda game_fire_dir
    clc
    adc #1
    and #$03
    clc
    adc #T_FIREFLY0_
    jsr game_set_point
    jsr game_mark_full_dirty
    rts
.endproc

'''
anchor = ".proc game_physics_step\n"
if anchor not in src:
    raise SystemExit("physics step anchor not found")
src = src.replace(anchor, firefly_code + anchor, 1)

# Dispatch active fireflies before boulder/diamond handling.
src = src.replace(
    "    jsr game_get_point\n    cmp #T_BOULDER_FIXED\n",
    "    jsr game_get_point\n"
    "    cmp #T_FIREFLY0\n"
    "    bcc :+\n"
    "    cmp #(T_FIREFLY3 + 1)\n"
    "    bcs :+\n"
    "    jsr game_firefly_step\n"
    "    jmp @next\n"
    ":\n"
    "    cmp #T_BOULDER_FIXED\n",
    1,
)

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
