#!/usr/bin/env python3
"""Add Cave 4 butterfly behavior to the generated shared game source.

The original C64 keeps butterfly movement in DynMoveButterFly. Butterflies try
left first, otherwise forward, otherwise turn right. They explode into diamond
explosion phases when touching Rockford or when struck by a falling object.
Marker tiles $34-$37 prevent a butterfly from moving twice in one cave scan.
"""

from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()


def replace_once(old: str, new: str, what: str) -> None:
    global text
    if old not in text:
        raise SystemExit(f"butterfly patch marker not found: {what}")
    text = text.replace(old, new, 1)


# Tile constants from the original C64 control field.
replace_once(
    "T_FIREFLY3_      = $0f\n",
    "T_FIREFLY3_      = $0f\n"
    "T_BUTTERFLY0     = $30\n"
    "T_BUTTERFLY1     = $31\n"
    "T_BUTTERFLY2     = $32\n"
    "T_BUTTERFLY3     = $33\n"
    "T_BUTTERFLY0_    = $34\n"
    "T_BUTTERFLY1_    = $35\n"
    "T_BUTTERFLY2_    = $36\n"
    "T_BUTTERFLY3_    = $37\n"
    "T_XPL_DIAMOND0   = $20\n"
    "T_XPL_DIAMOND1   = $21\n"
    "T_XPL_DIAMOND2   = $22\n"
    "T_XPL_DIAMOND3   = $23\n"
    "T_XPL_DIAMOND4   = $24\n",
    "tile constants",
)

# Normalize butterfly marker tiles exactly like TabCaveTileReplace $34-$37 -> $30-$33.
replace_once(
    "    bra @store\n:\n    cmp #T_BOULDER_FIXED_\n",
    "    bra @store\n"
    ":\n"
    "    cmp #T_BUTTERFLY0_\n"
    "    bcc :+\n"
    "    cmp #(T_BUTTERFLY3_ + 1)\n"
    "    bcs :+\n"
    "    sec\n"
    "    sbc #4\n"
    "    bra @store\n"
    ":\n"
    "    cmp #T_BOULDER_FIXED_\n",
    "page butterfly marker normalization",
)
replace_once(
    "    bra @tail_store\n:\n    cmp #T_BOULDER_FIXED_\n",
    "    bra @tail_store\n"
    ":\n"
    "    cmp #T_BUTTERFLY0_\n"
    "    bcc :+\n"
    "    cmp #(T_BUTTERFLY3_ + 1)\n"
    "    bcs :+\n"
    "    sec\n"
    "    sbc #4\n"
    "    bra @tail_store\n"
    ":\n"
    "    cmp #T_BOULDER_FIXED_\n",
    "tail butterfly marker normalization",
)

# Diamond-explosion phases $20-$24 become a fixed diamond after phase 4. Patch
# page and tail halves separately so labels cannot be mixed.
normalize_marker = ".proc game_normalize_markers\n"
if normalize_marker not in text:
    raise SystemExit("butterfly patch marker not found: normalize routine")
prefix, normalize = text.split(normalize_marker, 1)
if "@tail:\n" not in normalize:
    raise SystemExit("butterfly patch marker not found: normalize tail")
page_part, tail_part = normalize.split("@tail:\n", 1)

page_anchor = "    cmp #T_XPL_EMPTY0\n"
page_code = """    cmp #T_XPL_DIAMOND0
    bne :+
    lda #1
    sta game_explosion_changed
    lda #T_XPL_DIAMOND1
    bra @store
:
    cmp #T_XPL_DIAMOND1
    bne :+
    lda #1
    sta game_explosion_changed
    lda #T_XPL_DIAMOND2
    bra @store
:
    cmp #T_XPL_DIAMOND2
    bne :+
    lda #1
    sta game_explosion_changed
    lda #T_XPL_DIAMOND3
    bra @store
:
    cmp #T_XPL_DIAMOND3
    bne :+
    lda #1
    sta game_explosion_changed
    lda #T_XPL_DIAMOND4
    bra @store
:
    cmp #T_XPL_DIAMOND4
    bne :+
    lda #1
    sta game_explosion_changed
    lda #T_DIAMOND_FIXED
    bra @store
:
"""
if page_anchor not in page_part:
    raise SystemExit("butterfly patch marker not found: page diamond explosion")
page_part = page_part.replace(page_anchor, page_code + page_anchor, 1)

tail_anchor = "    cmp #T_XPL_EMPTY0\n"
tail_code = """    cmp #T_XPL_DIAMOND0
    bne :+
    lda #1
    sta game_explosion_changed
    lda #T_XPL_DIAMOND1
    bra @tail_store
:
    cmp #T_XPL_DIAMOND1
    bne :+
    lda #1
    sta game_explosion_changed
    lda #T_XPL_DIAMOND2
    bra @tail_store
:
    cmp #T_XPL_DIAMOND2
    bne :+
    lda #1
    sta game_explosion_changed
    lda #T_XPL_DIAMOND3
    bra @tail_store
:
    cmp #T_XPL_DIAMOND3
    bne :+
    lda #1
    sta game_explosion_changed
    lda #T_XPL_DIAMOND4
    bra @tail_store
:
    cmp #T_XPL_DIAMOND4
    bne :+
    lda #1
    sta game_explosion_changed
    lda #T_DIAMOND_FIXED
    bra @tail_store
:
"""
if tail_anchor not in tail_part:
    raise SystemExit("butterfly patch marker not found: tail diamond explosion")
tail_part = tail_part.replace(tail_anchor, tail_code + tail_anchor, 1)
text = prefix + normalize_marker + page_part + "@tail:\n" + tail_part

butterfly_code = r'''
; Fill a 3x3 diamond explosion centered at game_target_x/game_target_y. Steel is
; preserved. Rockford inside the blast is killed. This is the console version
; of the C64 butterfly explosion path (B1_TileExplDmnd1...).
.proc game_explode_butterfly
    lda #1
    sta game_explosion_changed

    lda game_target_y
    beq @y_start_zero
    dec a
@y_start_zero:
    sta game_point_y

@row:
    lda game_target_x
    beq @x_start_zero
    dec a
@x_start_zero:
    sta game_point_x

@col:
    jsr game_get_point
    cmp #T_STEEL
    beq @next_col
    cmp #T_ROCKFORD
    beq @kill_player
    cmp #T_ROCKFORD_
    bne @write
@kill_player:
    stz game_player_alive
@write:
    lda #T_XPL_DIAMOND0
    jsr game_set_point

@next_col:
    inc game_point_x
    lda game_point_x
    sec
    sbc game_target_x
    cmp #2
    bcc @col

    inc game_point_y
    lda game_point_y
    sec
    sbc game_target_y
    cmp #2
    bcc @row

    jsr game_mark_full_dirty
    rts
.endproc

; C64 TabFliesMoveTargPosLe: 0=left, 1=up, 2=right, 3=down.
.proc game_butterfly_target_left
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

; C64 TabFliesMoveTargPosDo: 0=down, 1=left, 2=up, 3=right.
.proc game_butterfly_target_forward
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

.proc game_butterfly_move
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

; C64 DynMoveButterFly: try left, then forward, else turn right. Marker forms
; $34-$37 ensure a moved butterfly is skipped for the remainder of this scan.
.proc game_butterfly_step
    and #$03
    sta game_fire_dir

    jsr game_firefly_touching_player
    bcc @move
    lda game_phys_x
    sta game_target_x
    lda game_phys_y
    sta game_target_y
    jsr game_explode_butterfly
    rts

@move:
    jsr game_butterfly_target_left
    lda game_target_x
    sta game_point_x
    lda game_target_y
    sta game_point_y
    jsr game_get_point
    bne @try_forward

    lda game_fire_dir
    clc
    adc #1
    and #$03
    clc
    adc #T_BUTTERFLY0_
    jsr game_butterfly_move
    rts

@try_forward:
    jsr game_butterfly_target_forward
    lda game_target_x
    sta game_point_x
    lda game_target_y
    sta game_point_y
    jsr game_get_point
    bne @rotate_right

    lda game_fire_dir
    clc
    adc #T_BUTTERFLY0_
    jsr game_butterfly_move
    rts

@rotate_right:
    lda game_phys_x
    sta game_point_x
    lda game_phys_y
    sta game_point_y
    lda game_fire_dir
    clc
    adc #3
    and #$03
    clc
    adc #T_BUTTERFLY0_
    jsr game_set_point
    jsr game_mark_full_dirty
    rts
.endproc

'''
replace_once(
    ".proc game_physics_step\n",
    butterfly_code + ".proc game_physics_step\n",
    "physics-step anchor",
)

# Dispatch active butterflies only in game_physics_step, after fireflies and
# before boulder/diamond handling.
physics_marker = ".proc game_physics_step\n"
pre, physics = text.split(physics_marker, 1)
fire_dispatch = (
    "    cmp #(T_FIREFLY3 + 1)\n"
    "    bcs :+\n"
    "    jsr game_firefly_step\n"
    "    jmp @next\n"
    ":\n"
    "    cmp #T_BOULDER_FIXED\n"
)
if fire_dispatch not in physics:
    raise SystemExit("butterfly patch marker not found: physics firefly dispatch")
physics = physics.replace(
    fire_dispatch,
    "    cmp #(T_FIREFLY3 + 1)\n"
    "    bcs :+\n"
    "    jsr game_firefly_step\n"
    "    jmp @next\n"
    ":\n"
    "    cmp #T_BUTTERFLY0\n"
    "    bcc :+\n"
    "    cmp #(T_BUTTERFLY3 + 1)\n"
    "    bcs :+\n"
    "    jsr game_butterfly_step\n"
    "    jmp @next\n"
    ":\n"
    "    cmp #T_BOULDER_FIXED\n",
    1,
)
text = pre + physics_marker + physics

# A falling boulder/diamond hitting either active or marker butterfly creates a
# diamond explosion centered on that butterfly, matching DynBoulderChkHitFlies.
fall_marker = ".proc game_physics_falling\n"
if fall_marker not in text:
    raise SystemExit("butterfly patch marker not found: falling routine")
pre, falling = text.split(fall_marker, 1)
fall_anchor = "    cmp #T_EMPTY\n    beq @fall\n"
if fall_anchor not in falling:
    raise SystemExit("butterfly patch marker not found: falling empty check")
falling = falling.replace(
    fall_anchor,
    "    cmp #T_BUTTERFLY0\n"
    "    bcc :+\n"
    "    cmp #(T_BUTTERFLY3_ + 1)\n"
    "    bcs :+\n"
    "    lda game_phys_x\n"
    "    sta game_target_x\n"
    "    lda game_phys_y\n"
    "    inc a\n"
    "    sta game_target_y\n"
    "    jsr game_explode_butterfly\n"
    "    bra @done\n"
    ":\n"
    "    cmp #T_EMPTY\n"
    "    beq @fall\n",
    1,
)
text = pre + fall_marker + falling

# Cave 4 scoring: 5 points per diamond, 20 after the 36 required diamonds.
replace_once(
    "CAVE3_EXTRA_VALUE     = 0\n",
    "CAVE3_EXTRA_VALUE     = 0\n"
    "CAVE4_DIAMOND_VALUE   = 5\n"
    "CAVE4_EXTRA_VALUE     = 20\n",
    "Cave 4 score constants",
)
replace_once(
    "    cmp #3\n    beq @cave3\n\n    lda game_diamonds_got\n",
    "    cmp #3\n"
    "    beq @cave3\n"
    "    cmp #4\n"
    "    beq @cave4\n\n"
    "    lda game_diamonds_got\n",
    "Cave 4 score dispatch",
)
replace_once(
    "@cave3_normal:\n    lda #CAVE3_DIAMOND_VALUE\n\n@score:\n",
    "@cave3_normal:\n"
    "    lda #CAVE3_DIAMOND_VALUE\n"
    "    bra @score\n\n"
    "@cave4:\n"
    "    lda game_diamonds_got\n"
    "    cmp game_diamonds_needed\n"
    "    bcc @cave4_normal\n"
    "    lda #CAVE4_EXTRA_VALUE\n"
    "    bra @score\n"
    "@cave4_normal:\n"
    "    lda #CAVE4_DIAMOND_VALUE\n\n"
    "@score:\n",
    "Cave 4 scoring block",
)

path.write_text(text)
