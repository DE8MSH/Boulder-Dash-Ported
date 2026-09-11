.include "platform.inc"

.import game_cave_state
.import game_player_x
.import game_player_y
.import game_player_alive
.import game_exit_open
.import game_game_over

.export game_autoplay_step

; The original C64 demo is a compressed direction/duration stream. In
; particular, direction nibble $f means no direction: deliberate waits are
; part of the successful route. This player does not replay that route. It
; applies the same style to the live cave: survive first, wait for unstable
; physics when needed, collect every diamond, then enter the exit.

T_EMPTY          = $00
T_SOIL           = $01
T_EXIT_OPEN      = $05
T_FIREFLY0       = $08
T_FIREFLY3_      = $0f
T_BOULDER_FIXED  = $10
T_BOULDER_FIXED_ = $11
T_BOULDER_FALL   = $12
T_BOULDER_FALL_  = $13
T_DIAMOND_FIXED  = $14
T_DIAMOND_FIXED_ = $15
T_DIAMOND_FALL   = $16
T_DIAMOND_FALL_  = $17
T_XPL_DIAMOND0   = $20
T_XPL_DIAMOND4   = $24
T_BUTTERFLY0     = $30
T_BUTTERFLY3_    = $37

AI_GOAL_NONE     = $00
AI_GOAL_DIAMOND  = $01
AI_GOAL_EXIT     = $02
AI_GOAL_RELEASE  = $03
AI_GOAL_EXPLORE  = $04
AI_GOAL_WAIT     = $05

.segment "ZEROPAGE"
ai_ptr: .res 2

.segment "BSS"
ai_scan_x:       .res 1
ai_scan_y:       .res 1
ai_match_lo:     .res 1
ai_match_end:    .res 1
ai_best_dist:    .res 1
ai_goal_found:   .res 1
ai_goal_kind:    .res 1
ai_target_x:     .res 1
ai_target_y:     .res 1
ai_bfly_x:       .res 1
ai_bfly_y:       .res 1
ai_candidate_x:  .res 1
ai_candidate_y:  .res 1
ai_probe_x:      .res 1
ai_probe_y:      .res 1
ai_test_dir:     .res 1
ai_test_tile:    .res 1
ai_dir_x:        .res 1
ai_dir_y:        .res 1
ai_abs_x:        .res 1
ai_abs_y:        .res 1
ai_last_dir:     .res 1
ai_detour_dir:   .res 1
ai_goal_prev_x:  .res 1
ai_goal_prev_y:  .res 1
ai_goal_valid:   .res 1
ai_wall_flip:    .res 1

.segment "CODE"

.proc ai_add40
    clc
    lda ai_ptr
    adc #40
    sta ai_ptr
    lda ai_ptr+1
    adc #0
    sta ai_ptr+1
    rts
.endproc

.proc ai_get_probe
    lda #<game_cave_state
    sta ai_ptr
    lda #>game_cave_state
    sta ai_ptr+1
    ldx ai_probe_y
    beq @row_done
@row:
    jsr ai_add40
    dex
    bne @row
@row_done:
    ldy ai_probe_x
    lda (ai_ptr),y
    rts
.endproc

.proc ai_tile_is_enemy
    cmp #T_FIREFLY0
    bcc @butterfly
    cmp #(T_FIREFLY3_ + 1)
    bcc @yes
@butterfly:
    cmp #T_BUTTERFLY0
    bcc @no
    cmp #(T_BUTTERFLY3_ + 1)
    bcc @yes
@no:
    clc
    rts
@yes:
    sec
    rts
.endproc

.proc ai_tile_is_falling
    cmp #T_BOULDER_FALL
    beq @yes
    cmp #T_BOULDER_FALL_
    beq @yes
    cmp #T_DIAMOND_FALL
    beq @yes
    cmp #T_DIAMOND_FALL_
    beq @yes
    clc
    rts
@yes:
    sec
    rts
.endproc

.proc ai_enemy_near_candidate
    lda ai_candidate_x
    dec a
    sta ai_probe_x
    lda ai_candidate_y
    sta ai_probe_y
    jsr ai_get_probe
    jsr ai_tile_is_enemy
    bcc :+
    sec
    rts
:
    lda ai_candidate_x
    inc a
    sta ai_probe_x
    lda ai_candidate_y
    sta ai_probe_y
    jsr ai_get_probe
    jsr ai_tile_is_enemy
    bcc :+
    sec
    rts
:
    lda ai_candidate_y
    beq @skip_up
    lda ai_candidate_x
    sta ai_probe_x
    lda ai_candidate_y
    dec a
    sta ai_probe_y
    jsr ai_get_probe
    jsr ai_tile_is_enemy
    bcc @skip_up
    sec
    rts
@skip_up:
    lda ai_candidate_y
    cmp #22
    bcs @no
    lda ai_candidate_x
    sta ai_probe_x
    lda ai_candidate_y
    inc a
    sta ai_probe_y
    jsr ai_get_probe
    jsr ai_tile_is_enemy
    bcc @no
    sec
    rts
@no:
    clc
    rts
.endproc

.proc ai_is_safe_dir
    lda game_player_x
    sta ai_candidate_x
    lda game_player_y
    sta ai_candidate_y

    lda ai_test_dir
    cmp #PAD_LEFT
    bne @right
    lda ai_candidate_x
    cmp #1
    beq @no
    dec ai_candidate_x
    jmp @tile
@right:
    cmp #PAD_RIGHT
    bne @up
    lda ai_candidate_x
    cmp #38
    beq @no
    inc ai_candidate_x
    jmp @tile
@up:
    cmp #PAD_UP
    bne @down
    lda ai_candidate_y
    cmp #1
    beq @no
    dec ai_candidate_y
    jmp @tile
@down:
    cmp #PAD_DOWN
    bne @no
    lda ai_candidate_y
    cmp #22
    beq @no
    inc ai_candidate_y

@tile:
    lda ai_candidate_x
    sta ai_probe_x
    lda ai_candidate_y
    sta ai_probe_y
    jsr ai_get_probe
    sta ai_test_tile

    cmp #T_EMPTY
    beq @hazards
    cmp #T_SOIL
    beq @hazards
    cmp #T_EXIT_OPEN
    beq @hazards
    cmp #T_DIAMOND_FIXED
    beq @hazards
    cmp #T_DIAMOND_FIXED_
    beq @hazards
    cmp #T_BOULDER_FIXED
    beq @push
    cmp #T_BOULDER_FIXED_
    bne @no

@push:
    lda ai_test_dir
    cmp #PAD_LEFT
    beq @push_left
    cmp #PAD_RIGHT
    bne @no
    lda ai_candidate_x
    cmp #38
    beq @no
    inc a
    sta ai_probe_x
    lda ai_candidate_y
    sta ai_probe_y
    jsr ai_get_probe
    cmp #T_EMPTY
    bne @no
    jmp @hazards
@push_left:
    lda ai_candidate_x
    cmp #1
    beq @no
    dec a
    sta ai_probe_x
    lda ai_candidate_y
    sta ai_probe_y
    jsr ai_get_probe
    cmp #T_EMPTY
    bne @no

@hazards:
    lda ai_candidate_y
    beq @enemy
    lda ai_candidate_x
    sta ai_probe_x
    lda ai_candidate_y
    dec a
    sta ai_probe_y
    jsr ai_get_probe
    jsr ai_tile_is_falling
    bcc @enemy
    jmp @no

@enemy:
    jsr ai_enemy_near_candidate
    bcc @yes
@no:
    clc
    rts
@yes:
    sec
    rts
.endproc

.proc ai_try_dir
    sta ai_test_dir
    jsr ai_is_safe_dir
    bcc @no
    lda ai_test_dir
    sta ai_last_dir
    sec
    rts
@no:
    lda #0
    clc
    rts
.endproc

.proc ai_current_danger
    lda game_player_x
    sta ai_candidate_x
    lda game_player_y
    sta ai_candidate_y
    jsr ai_enemy_near_candidate
    bcc :+
    sec
    rts
:
    lda game_player_y
    beq @no
    lda game_player_x
    sta ai_probe_x
    lda game_player_y
    dec a
    sta ai_probe_y
    jsr ai_get_probe
    cmp #T_BOULDER_FIXED
    beq @yes
    cmp #T_BOULDER_FIXED_
    beq @yes
    jsr ai_tile_is_falling
    bcc @no
@yes:
    sec
    rts
@no:
    clc
    rts
.endproc

.proc ai_choose_escape
    lda #PAD_LEFT
    jsr ai_try_dir
    bcc :+
    rts
:
    lda #PAD_RIGHT
    jsr ai_try_dir
    bcc :+
    rts
:
    lda #PAD_DOWN
    jsr ai_try_dir
    bcc :+
    rts
:
    lda #PAD_UP
    jsr ai_try_dir
    bcc :+
    rts
:
    lda #0
    rts
.endproc

.proc ai_find_range
    lda #$ff
    sta ai_best_dist
    stz ai_goal_found
    lda #<(game_cave_state + 40)
    sta ai_ptr
    lda #>(game_cave_state + 40)
    sta ai_ptr+1
    lda #1
    sta ai_scan_y
@row:
    lda #1
    sta ai_scan_x
@col:
    ldy ai_scan_x
    lda (ai_ptr),y
    cmp ai_match_lo
    bcc @next
    cmp ai_match_end
    bcs @next

    lda ai_scan_x
    sec
    sbc game_player_x
    bcs :+
    eor #$ff
    clc
    adc #1
:
    sta ai_abs_x
    lda ai_scan_y
    sec
    sbc game_player_y
    bcs :+
    eor #$ff
    clc
    adc #1
:
    clc
    adc ai_abs_x
    cmp ai_best_dist
    bcs @next
    sta ai_best_dist
    lda ai_scan_x
    sta ai_target_x
    lda ai_scan_y
    sta ai_target_y
    lda #1
    sta ai_goal_found

@next:
    inc ai_scan_x
    lda ai_scan_x
    cmp #39
    bne @col
    inc ai_scan_y
    lda ai_scan_y
    cmp #23
    beq @done
    jsr ai_add40
    jmp @row
@done:
    rts
.endproc

.proc ai_find_butterfly_support
    lda #T_BUTTERFLY0
    sta ai_match_lo
    lda #(T_BUTTERFLY3_ + 1)
    sta ai_match_end
    jsr ai_find_range
    lda ai_goal_found
    bne :+
    clc
    rts
:
    lda ai_target_x
    sta ai_bfly_x
    lda ai_target_y
    sta ai_bfly_y
    cmp #3
    bcs :+
    jmp @approach
:
    sec
    sbc #2
    sta ai_scan_y
@search_up:
    lda ai_bfly_x
    sta ai_probe_x
    lda ai_scan_y
    sta ai_probe_y
    jsr ai_get_probe
    cmp #T_BOULDER_FIXED
    beq @check_support
    cmp #T_BOULDER_FIXED_
    beq @check_support
    jmp @next_up

@check_support:
    lda ai_bfly_x
    sta ai_probe_x
    lda ai_scan_y
    inc a
    sta ai_probe_y
    jsr ai_get_probe
    cmp #T_EMPTY
    beq @support
    cmp #T_SOIL
    bne @next_up
@support:
    lda ai_bfly_x
    sta ai_target_x
    lda ai_scan_y
    inc a
    sta ai_target_y
    lda #AI_GOAL_RELEASE
    sta ai_goal_kind
    sec
    rts

@next_up:
    lda ai_scan_y
    cmp #1
    beq @approach
    dec ai_scan_y
    jmp @search_up

@approach:
    lda ai_bfly_x
    sta ai_target_x
    lda ai_bfly_y
    cmp #4
    bcc :+
    sec
    sbc #3
    sta ai_target_y
    lda #AI_GOAL_EXPLORE
    sta ai_goal_kind
    sec
    rts
:
    lda #1
    sta ai_target_y
    lda #AI_GOAL_EXPLORE
    sta ai_goal_kind
    sec
    rts
.endproc

.proc ai_find_goal
    stz ai_goal_kind

    ; Collect every fixed diamond before considering the exit.
    lda #T_DIAMOND_FIXED
    sta ai_match_lo
    lda #(T_DIAMOND_FIXED_ + 1)
    sta ai_match_end
    jsr ai_find_range
    lda ai_goal_found
    beq :+
    lda #AI_GOAL_DIAMOND
    sta ai_goal_kind
    rts
:
    ; Demo-inspired wait: do not run to the exit while a diamond is still
    ; falling or a butterfly diamond explosion is still resolving.
    lda #T_DIAMOND_FALL
    sta ai_match_lo
    lda #(T_DIAMOND_FALL_ + 1)
    sta ai_match_end
    jsr ai_find_range
    lda ai_goal_found
    beq :+
    lda #AI_GOAL_WAIT
    sta ai_goal_kind
    rts
:
    lda #T_XPL_DIAMOND0
    sta ai_match_lo
    lda #(T_XPL_DIAMOND4 + 1)
    sta ai_match_end
    jsr ai_find_range
    lda ai_goal_found
    beq :+
    lda #AI_GOAL_WAIT
    sta ai_goal_kind
    rts
:
    lda game_exit_open
    beq @make_diamonds
    lda #T_EXIT_OPEN
    sta ai_match_lo
    lda #(T_EXIT_OPEN + 1)
    sta ai_match_end
    jsr ai_find_range
    lda ai_goal_found
    beq @make_diamonds
    lda #AI_GOAL_EXIT
    sta ai_goal_kind
    rts

@make_diamonds:
    jsr ai_find_butterfly_support
    bcc @explore
    rts

@explore:
    lda #T_SOIL
    sta ai_match_lo
    lda #(T_SOIL + 1)
    sta ai_match_end
    jsr ai_find_range
    lda ai_goal_found
    beq @wait
    lda #AI_GOAL_EXPLORE
    sta ai_goal_kind
    rts
@wait:
    lda #AI_GOAL_WAIT
    sta ai_goal_kind
    rts
.endproc

.proc ai_update_goal_memory
    lda ai_goal_valid
    beq @new
    lda ai_target_x
    cmp ai_goal_prev_x
    bne @new
    lda ai_target_y
    cmp ai_goal_prev_y
    bne @new
    rts
@new:
    lda ai_target_x
    sta ai_goal_prev_x
    lda ai_target_y
    sta ai_goal_prev_y
    lda #1
    sta ai_goal_valid
    stz ai_detour_dir
    rts
.endproc

.proc ai_prepare_dirs
    stz ai_dir_x
    stz ai_dir_y
    stz ai_abs_x
    stz ai_abs_y

    lda ai_target_x
    cmp game_player_x
    beq @y
    bcc @x_left
    lda #PAD_RIGHT
    sta ai_dir_x
    lda ai_target_x
    sec
    sbc game_player_x
    sta ai_abs_x
    jmp @y
@x_left:
    lda #PAD_LEFT
    sta ai_dir_x
    lda game_player_x
    sec
    sbc ai_target_x
    sta ai_abs_x

@y:
    lda ai_target_y
    cmp game_player_y
    beq @done
    bcc @y_up
    lda #PAD_DOWN
    sta ai_dir_y
    lda ai_target_y
    sec
    sbc game_player_y
    sta ai_abs_y
    rts
@y_up:
    lda #PAD_UP
    sta ai_dir_y
    lda game_player_y
    sec
    sbc ai_target_y
    sta ai_abs_y
@done:
    rts
.endproc

.proc ai_choose_toward
    jsr ai_prepare_dirs
    lda ai_abs_x
    cmp ai_abs_y
    bcc @vertical_primary

@horizontal_primary:
    lda ai_dir_x
    beq @horizontal_secondary
    jsr ai_try_dir
    bcc :+
    stz ai_detour_dir
    rts
:
    lda ai_detour_dir
    beq @horizontal_secondary
    jsr ai_try_dir
    bcc @horizontal_secondary
    rts
@horizontal_secondary:
    lda ai_dir_y
    beq @horizontal_detour
    jsr ai_try_dir
    bcc @horizontal_detour
    sta ai_detour_dir
    rts
@horizontal_detour:
    lda ai_wall_flip
    and #1
    bne @h_down_first
    lda #PAD_UP
    jsr ai_try_dir
    bcc :+
    sta ai_detour_dir
    rts
:
    lda #PAD_DOWN
    jsr ai_try_dir
    bcc @fallback
    sta ai_detour_dir
    inc ai_wall_flip
    rts
@h_down_first:
    lda #PAD_DOWN
    jsr ai_try_dir
    bcc :+
    sta ai_detour_dir
    rts
:
    lda #PAD_UP
    jsr ai_try_dir
    bcc @fallback
    sta ai_detour_dir
    inc ai_wall_flip
    rts

@vertical_primary:
    lda ai_dir_y
    beq @vertical_secondary
    jsr ai_try_dir
    bcc :+
    stz ai_detour_dir
    rts
:
    lda ai_detour_dir
    beq @vertical_secondary
    jsr ai_try_dir
    bcc @vertical_secondary
    rts
@vertical_secondary:
    lda ai_dir_x
    beq @vertical_detour
    jsr ai_try_dir
    bcc @vertical_detour
    sta ai_detour_dir
    rts
@vertical_detour:
    lda ai_wall_flip
    and #1
    bne @v_right_first
    lda #PAD_LEFT
    jsr ai_try_dir
    bcc :+
    sta ai_detour_dir
    rts
:
    lda #PAD_RIGHT
    jsr ai_try_dir
    bcc @fallback
    sta ai_detour_dir
    inc ai_wall_flip
    rts
@v_right_first:
    lda #PAD_RIGHT
    jsr ai_try_dir
    bcc :+
    sta ai_detour_dir
    rts
:
    lda #PAD_LEFT
    jsr ai_try_dir
    bcc @fallback
    sta ai_detour_dir
    inc ai_wall_flip
    rts

@fallback:
    lda ai_last_dir
    beq :+
    jsr ai_try_dir
    bcc :+
    rts
:
    jsr ai_choose_escape
    rts
.endproc

.proc game_autoplay_step
    lda game_game_over
    beq :+
    lda #PAD_START
    rts
:
    lda game_player_alive
    bne :+
    lda #0
    rts
:
    jsr ai_current_danger
    bcc @goal
    jsr ai_choose_escape
    rts

@goal:
    jsr ai_find_goal
    lda ai_goal_kind
    cmp #AI_GOAL_WAIT
    bne :+
    lda #0
    rts
:
    cmp #AI_GOAL_NONE
    bne :+
    lda #0
    rts
:
    jsr ai_update_goal_memory
    jsr ai_choose_toward
    rts
.endproc
