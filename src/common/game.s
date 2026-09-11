.include "platform.inc"

.import game_cave_initial

.export game_init
.export game_tick
.export game_pad_current
.export game_pad_previous
.export game_pad_pressed
.export game_video_dirty
.export game_video_full_dirty
.export game_cave_state
.export game_cave_render
.export game_player_x
.export game_player_y
.export game_player_alive
.export game_view_x
.export game_view_y
.export game_diamonds_got
.export game_diamonds_needed
.export game_score_lo
.export game_score_hi
.export game_exit_open

CAVE_COLS = 40
CAVE_ROWS = 22
CAVE_BYTES = 880
VIEW_OBJ_W = 16
VIEW_OBJ_H = 14
VIEW_MAX_X = CAVE_COLS - VIEW_OBJ_W
VIEW_MAX_Y = CAVE_ROWS - VIEW_OBJ_H
RENDER_CHAR_W = 32
RENDER_CHAR_H = 28
RENDER_BYTES = RENDER_CHAR_W * RENDER_CHAR_H * 2
PATTERN_BASE = $40
PHYSICS_DIV = 6

; Cave 1, difficulty 0 values from the original cave header.
CAVE1_DIAMONDS_NEEDED = 12
CAVE1_DIAMOND_VALUE   = 10
CAVE1_EXTRA_VALUE     = 15

T_EMPTY          = $00
T_SOIL           = $01
T_BRICK          = $02
T_EXIT_CLOSED    = $04
T_EXIT_OPEN      = $05
T_STEEL          = $07
T_BOULDER_FIXED  = $10
T_BOULDER_FIXED_ = $11
T_BOULDER_FALL   = $12
T_BOULDER_FALL_  = $13
T_DIAMOND_FIXED  = $14
T_DIAMOND_FIXED_ = $15
T_DIAMOND_FALL   = $16
T_DIAMOND_FALL_  = $17
T_XPL_EMPTY0     = $1b
T_XPL_EMPTY1     = $1c
T_XPL_EMPTY2     = $1d
T_XPL_EMPTY3     = $1e
T_XPL_EMPTY4     = $1f
T_ROCKFORD       = $38

.segment "ZEROPAGE"
game_zp_src:  .res 2
game_zp_dst:  .res 2
game_zp_dst2: .res 2

.segment "BSS"
game_pad_current:      .res 1
game_pad_previous:     .res 1
game_pad_pressed:      .res 1
game_video_dirty:      .res 1
game_video_full_dirty: .res 1

game_player_x:     .res 1
game_player_y:     .res 1
game_player_alive: .res 1
game_target_x:     .res 1
game_target_y:     .res 1
game_point_x:      .res 1
game_point_y:      .res 1
game_view_x:       .res 1
game_view_y:       .res 1

game_render_row:  .res 1
game_render_col:  .res 1
game_render_base: .res 1

game_phys_counter:      .res 1
game_phys_x:            .res 1
game_phys_y:            .res 1
game_phys_fix_tile:     .res 1
game_phys_fall_tile:    .res 1
game_phys_new_tile:     .res 1
game_explosion_changed: .res 1

game_diamonds_got:    .res 1
game_diamonds_needed: .res 1
game_score_lo:        .res 1
game_score_hi:        .res 1
game_exit_open:       .res 1
game_random:          .res 1

game_cave_state:  .res CAVE_BYTES
game_cave_render: .res RENDER_BYTES

.segment "RODATA"
game_tile_char_map:
    .byte $60,$46,$4e,$22,$2e,$62,$2e,$4a
    .byte $64,$64,$64,$64,$64,$64,$64,$64
    .byte $44,$44,$44,$44,$48,$48,$48,$48
    .byte $00,$00,$00,$66,$68,$6a,$68,$66
    .byte $24,$26,$28,$2a,$2c,$62,$66,$68
    .byte $6a,$00,$00,$00,$00,$00,$00,$00
    .byte $20,$20,$20,$20,$20,$20,$20,$20
    .byte $4c,$4c,$40,$40,$00,$00,$00,$00

.segment "CODE"

.proc game_copy_initial_cave
    lda #<game_cave_initial
    sta game_zp_src
    lda #>game_cave_initial
    sta game_zp_src+1
    lda #<game_cave_state
    sta game_zp_dst
    lda #>game_cave_state
    sta game_zp_dst+1

    ldx #3
@page:
    ldy #0
@page_byte:
    lda (game_zp_src),y
    sta (game_zp_dst),y
    iny
    bne @page_byte
    inc game_zp_src+1
    inc game_zp_dst+1
    dex
    bne @page

    ldy #0
@tail:
    lda (game_zp_src),y
    sta (game_zp_dst),y
    iny
    cpy #112
    bne @tail
    rts
.endproc

.proc game_get_point_ptr
    lda #<game_cave_state
    sta game_zp_src
    lda #>game_cave_state
    sta game_zp_src+1

    ldx game_point_y
    beq @rows_done
@add_row:
    clc
    lda game_zp_src
    adc #CAVE_COLS
    sta game_zp_src
    lda game_zp_src+1
    adc #0
    sta game_zp_src+1
    dex
    bne @add_row

@rows_done:
    clc
    lda game_zp_src
    adc game_point_x
    sta game_zp_src
    lda game_zp_src+1
    adc #0
    sta game_zp_src+1
    rts
.endproc

.proc game_get_point
    jsr game_get_point_ptr
    ldy #0
    lda (game_zp_src),y
    rts
.endproc

.proc game_set_point
    sta game_phys_new_tile
    jsr game_get_point_ptr
    ldy #0
    lda game_phys_new_tile
    sta (game_zp_src),y
    rts
.endproc

.proc game_update_view
    lda game_player_x
    cmp #8
    bcc @x_zero
    sec
    sbc #8
    cmp #(VIEW_MAX_X + 1)
    bcc @x_store
    lda #VIEW_MAX_X
@x_store:
    sta game_view_x
    bra @y_part
@x_zero:
    stz game_view_x

@y_part:
    lda game_player_y
    cmp #7
    bcc @y_zero
    sec
    sbc #7
    cmp #(VIEW_MAX_Y + 1)
    bcc @y_store
    lda #VIEW_MAX_Y
@y_store:
    sta game_view_y
    rts
@y_zero:
    stz game_view_y
    rts
.endproc

.proc game_render_cave
    lda game_view_x
    sta game_point_x
    lda game_view_y
    sta game_point_y
    jsr game_get_point_ptr

    lda #<game_cave_render
    sta game_zp_dst
    lda #>game_cave_render
    sta game_zp_dst+1
    lda #<(game_cave_render + 64)
    sta game_zp_dst2
    lda #>(game_cave_render + 64)
    sta game_zp_dst2+1

    stz game_render_row
@row:
    stz game_render_col
@col:
    ldy game_render_col
    lda (game_zp_src),y
    tax
    lda game_tile_char_map,x
    clc
    adc #PATTERN_BASE
    sta game_render_base

    lda game_render_col
    asl a
    asl a
    tay

    lda game_render_base
    sta (game_zp_dst),y
    iny
    lda #0
    sta (game_zp_dst),y
    iny
    lda game_render_base
    clc
    adc #1
    sta (game_zp_dst),y
    iny
    lda #0
    sta (game_zp_dst),y

    lda game_render_col
    asl a
    asl a
    tay
    lda game_render_base
    clc
    adc #$10
    sta (game_zp_dst2),y
    iny
    lda #0
    sta (game_zp_dst2),y
    iny
    lda game_render_base
    clc
    adc #$11
    sta (game_zp_dst2),y
    iny
    lda #0
    sta (game_zp_dst2),y

    inc game_render_col
    lda game_render_col
    cmp #VIEW_OBJ_W
    bne @col

    clc
    lda game_zp_src
    adc #CAVE_COLS
    sta game_zp_src
    lda game_zp_src+1
    adc #0
    sta game_zp_src+1

    clc
    lda game_zp_dst
    adc #128
    sta game_zp_dst
    lda game_zp_dst+1
    adc #0
    sta game_zp_dst+1

    clc
    lda game_zp_dst2
    adc #128
    sta game_zp_dst2
    lda game_zp_dst2+1
    adc #0
    sta game_zp_dst2+1

    inc game_render_row
    lda game_render_row
    cmp #VIEW_OBJ_H
    beq @done
    jmp @row
@done:
    rts
.endproc

.proc game_mark_full_dirty
    lda #1
    sta game_video_dirty
    sta game_video_full_dirty
    rts
.endproc

; Small deterministic replacement for the C64 CIA timer entropy used by
; GetValRND. The original push rule only depends on the low two bits.
.proc game_next_random
    lda game_random
    asl a
    bcc :+
    eor #$1d
:
    eor game_phys_counter
    adc #$17
    sta game_random
    rts
.endproc

.proc game_add_score
    clc
    adc game_score_lo
    sta game_score_lo
    lda game_score_hi
    adc #0
    sta game_score_hi
    rts
.endproc

.proc game_open_exit
    lda game_exit_open
    bne @done
    lda #1
    sta game_exit_open

    lda #<game_cave_state
    sta game_zp_src
    lda #>game_cave_state
    sta game_zp_src+1
    ldx #3
@page:
    ldy #0
@scan:
    lda (game_zp_src),y
    cmp #T_EXIT_CLOSED
    bne :+
    lda #T_EXIT_OPEN
    sta (game_zp_src),y
:
    iny
    bne @scan
    inc game_zp_src+1
    dex
    bne @page

    ldy #0
@tail:
    lda (game_zp_src),y
    cmp #T_EXIT_CLOSED
    bne :+
    lda #T_EXIT_OPEN
    sta (game_zp_src),y
:
    iny
    cpy #112
    bne @tail
    jsr game_mark_full_dirty
@done:
    rts
.endproc

.proc game_collect_diamond
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

.proc game_physics_normalize
    stz game_explosion_changed
    lda #<game_cave_state
    sta game_zp_src
    lda #>game_cave_state
    sta game_zp_src+1
    ldx #3
@page:
    ldy #0
@byte:
    lda (game_zp_src),y
    cmp #T_BOULDER_FIXED_
    bne :+
    lda #T_BOULDER_FIXED
    bra @store
:
    cmp #T_BOULDER_FALL_
    bne :+
    lda #T_BOULDER_FALL
    bra @store
:
    cmp #T_DIAMOND_FIXED_
    bne :+
    lda #T_DIAMOND_FIXED
    bra @store
:
    cmp #T_DIAMOND_FALL_
    bne :+
    lda #T_DIAMOND_FALL
    bra @store
:
    cmp #T_XPL_EMPTY0
    bne :+
    lda #T_XPL_EMPTY1
    bra @expl_store
:
    cmp #T_XPL_EMPTY1
    bne :+
    lda #T_XPL_EMPTY2
    bra @expl_store
:
    cmp #T_XPL_EMPTY2
    bne :+
    lda #T_XPL_EMPTY3
    bra @expl_store
:
    cmp #T_XPL_EMPTY3
    bne :+
    lda #T_XPL_EMPTY4
    bra @expl_store
:
    cmp #T_XPL_EMPTY4
    bne @next
    lda #T_EMPTY
@expl_store:
    inc game_explosion_changed
@store:
    sta (game_zp_src),y
@next:
    iny
    bne @byte
    inc game_zp_src+1
    dex
    bne @page

    ldy #0
@tail:
    lda (game_zp_src),y
    cmp #T_BOULDER_FIXED_
    bne :+
    lda #T_BOULDER_FIXED
    bra @tail_store
:
    cmp #T_BOULDER_FALL_
    bne :+
    lda #T_BOULDER_FALL
    bra @tail_store
:
    cmp #T_DIAMOND_FIXED_
    bne :+
    lda #T_DIAMOND_FIXED
    bra @tail_store
:
    cmp #T_DIAMOND_FALL_
    bne :+
    lda #T_DIAMOND_FALL
    bra @tail_store
:
    cmp #T_XPL_EMPTY0
    bne :+
    lda #T_XPL_EMPTY1
    bra @tail_expl_store
:
    cmp #T_XPL_EMPTY1
    bne :+
    lda #T_XPL_EMPTY2
    bra @tail_expl_store
:
    cmp #T_XPL_EMPTY2
    bne :+
    lda #T_XPL_EMPTY3
    bra @tail_expl_store
:
    cmp #T_XPL_EMPTY3
    bne :+
    lda #T_XPL_EMPTY4
    bra @tail_expl_store
:
    cmp #T_XPL_EMPTY4
    bne @tail_next
    lda #T_EMPTY
@tail_expl_store:
    inc game_explosion_changed
@tail_store:
    sta (game_zp_src),y
@tail_next:
    iny
    cpy #112
    bne @tail

    lda game_explosion_changed
    beq @done
    jsr game_mark_full_dirty
@done:
    rts
.endproc

.proc game_physics_is_rounded
    cmp #T_BOULDER_FIXED
    beq @yes
    cmp #T_DIAMOND_FIXED
    beq @yes
    cmp #T_BRICK
    beq @yes
    clc
    rts
@yes:
    sec
    rts
.endproc

.proc game_physics_move_to_target
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
    lda game_phys_fall_tile
    jsr game_set_point
    jsr game_mark_full_dirty
    rts
.endproc

.proc game_explosion_write
    sta game_phys_new_tile
    jsr game_get_point
    cmp #T_STEEL
    beq @done
    lda game_phys_new_tile
    jsr game_set_point
@done:
    rts
.endproc

.proc game_explode_drop
    stz game_player_alive

    lda game_phys_x
    dec a
    sta game_point_x
    lda game_phys_y
    sta game_point_y
    lda #T_XPL_EMPTY1
    jsr game_explosion_write

    lda game_phys_x
    sta game_point_x
    lda game_phys_y
    sta game_point_y
    lda #T_XPL_EMPTY1
    jsr game_explosion_write

    lda game_phys_x
    inc a
    sta game_point_x
    lda game_phys_y
    sta game_point_y
    lda #T_XPL_EMPTY0
    jsr game_explosion_write

    lda game_phys_y
    inc a
    sta game_point_y
    lda game_phys_x
    dec a
    sta game_point_x
    lda #T_XPL_EMPTY0
    jsr game_explosion_write
    lda game_phys_x
    sta game_point_x
    lda #T_XPL_EMPTY0
    jsr game_explosion_write
    lda game_phys_x
    inc a
    sta game_point_x
    lda #T_XPL_EMPTY0
    jsr game_explosion_write

    lda game_phys_y
    clc
    adc #2
    sta game_point_y
    lda game_phys_x
    dec a
    sta game_point_x
    lda #T_XPL_EMPTY0
    jsr game_explosion_write
    lda game_phys_x
    sta game_point_x
    lda #T_XPL_EMPTY0
    jsr game_explosion_write
    lda game_phys_x
    inc a
    sta game_point_x
    lda #T_XPL_EMPTY0
    jsr game_explosion_write

    jsr game_mark_full_dirty
    rts
.endproc

.proc game_physics_try_roll
    lda game_phys_x
    cmp #1
    beq @right
    dec a
    sta game_point_x
    lda game_phys_y
    sta game_point_y
    jsr game_get_point
    bne @right

    lda game_phys_x
    dec a
    sta game_point_x
    lda game_phys_y
    inc a
    sta game_point_y
    jsr game_get_point
    bne @right

    lda game_phys_x
    dec a
    sta game_target_x
    lda game_phys_y
    inc a
    sta game_target_y
    jsr game_physics_move_to_target
    sec
    rts

@right:
    lda game_phys_x
    cmp #38
    beq @no
    inc a
    sta game_point_x
    lda game_phys_y
    sta game_point_y
    jsr game_get_point
    bne @no

    lda game_phys_x
    inc a
    sta game_point_x
    lda game_phys_y
    inc a
    sta game_point_y
    jsr game_get_point
    bne @no

    lda game_phys_x
    inc a
    sta game_target_x
    lda game_phys_y
    inc a
    sta game_target_y
    jsr game_physics_move_to_target
    sec
    rts
@no:
    clc
    rts
.endproc

.proc game_physics_fixed
    lda game_phys_x
    sta game_point_x
    lda game_phys_y
    inc a
    sta game_point_y
    jsr game_get_point
    beq @fall
    jsr game_physics_is_rounded
    bcc @done
    jsr game_physics_try_roll
    rts
@fall:
    lda game_phys_x
    sta game_target_x
    lda game_phys_y
    inc a
    sta game_target_y
    jsr game_physics_move_to_target
@done:
    rts
.endproc

.proc game_physics_falling
    lda game_phys_x
    sta game_point_x
    lda game_phys_y
    inc a
    sta game_point_y
    jsr game_get_point
    cmp #T_ROCKFORD
    bne :+
    jsr game_explode_drop
    bra @done
:
    cmp #T_EMPTY
    beq @fall
    jsr game_physics_is_rounded
    bcc @rest
    jsr game_physics_try_roll
    bcs @done
@rest:
    lda game_phys_x
    sta game_point_x
    lda game_phys_y
    sta game_point_y
    lda game_phys_fix_tile
    jsr game_set_point
    jsr game_mark_full_dirty
    bra @done
@fall:
    lda game_phys_x
    sta game_target_x
    lda game_phys_y
    inc a
    sta game_target_y
    jsr game_physics_move_to_target
@done:
    rts
.endproc

.proc game_physics_step
    inc game_phys_counter
    lda game_phys_counter
    cmp #PHYSICS_DIV
    bcc @done
    stz game_phys_counter
    jsr game_physics_normalize

    lda #1
    sta game_phys_y
@row:
    lda #1
    sta game_phys_x
@col:
    lda game_phys_x
    sta game_point_x
    lda game_phys_y
    sta game_point_y
    jsr game_get_point

    cmp #T_BOULDER_FIXED
    bne @bfall
    lda #T_BOULDER_FIXED
    sta game_phys_fix_tile
    lda #T_BOULDER_FALL_
    sta game_phys_fall_tile
    jsr game_physics_fixed
    bra @next

@bfall:
    cmp #T_BOULDER_FALL
    bne @dfix
    lda #T_BOULDER_FIXED_
    sta game_phys_fix_tile
    lda #T_BOULDER_FALL_
    sta game_phys_fall_tile
    jsr game_physics_falling
    bra @next

@dfix:
    cmp #T_DIAMOND_FIXED
    bne @dfall
    lda #T_DIAMOND_FIXED
    sta game_phys_fix_tile
    lda #T_DIAMOND_FALL_
    sta game_phys_fall_tile
    jsr game_physics_fixed
    bra @next

@dfall:
    cmp #T_DIAMOND_FALL
    bne @next
    lda #T_DIAMOND_FIXED_
    sta game_phys_fix_tile
    lda #T_DIAMOND_FALL_
    sta game_phys_fall_tile
    jsr game_physics_falling

@next:
    inc game_phys_x
    lda game_phys_x
    cmp #39
    bne @col
    inc game_phys_y
    lda game_phys_y
    cmp #21
    bne @row
@done:
    rts
.endproc

.proc game_try_push_boulder
    lda game_target_x
    cmp game_player_x
    bne :+
    jmp @no
:
    lda game_target_y
    cmp game_player_y
    beq :+
    jmp @no
:
    lda game_target_x
    cmp game_player_x
    bcc @left
    lda game_target_x
    cmp #38
    bne :+
    jmp @no
:
    inc a
    sta game_point_x
    lda game_target_y
    sta game_point_y
    jsr game_get_point
    beq :+
    jmp @no
:
    bra @chance
@left:
    lda game_target_x
    cmp #1
    bne :+
    jmp @no
:
    dec a
    sta game_point_x
    lda game_target_y
    sta game_point_y
    jsr game_get_point
    beq :+
    jmp @no
:
@chance:
    jsr game_next_random
    and #$03
    beq :+
    jmp @no
:
    lda #T_BOULDER_FIXED_
    jsr game_set_point
    lda game_player_x
    sta game_point_x
    lda game_player_y
    sta game_point_y
    lda #T_EMPTY
    jsr game_set_point
    lda game_target_x
    sta game_point_x
    lda game_target_y
    sta game_point_y
    lda #T_ROCKFORD
    jsr game_set_point
    lda game_target_x
    sta game_player_x
    lda game_target_y
    sta game_player_y
    jsr game_update_view
    jsr game_mark_full_dirty
    sec
    rts
@no:
    clc
    rts
.endproc

.proc game_try_move
    lda game_target_x
    sta game_point_x
    lda game_target_y
    sta game_point_y
    jsr game_get_point
    cmp #T_EMPTY
    beq @allowed
    cmp #T_SOIL
    beq @allowed
    cmp #T_DIAMOND_FIXED
    beq @diamond
    cmp #T_EXIT_OPEN
    beq @allowed
    cmp #T_BOULDER_FIXED
    bne @blocked
    jsr game_try_push_boulder
    rts
@diamond:
    jsr game_collect_diamond
@allowed:
    lda game_player_x
    sta game_point_x
    lda game_player_y
    sta game_point_y
    lda #T_EMPTY
    jsr game_set_point
    lda game_target_x
    sta game_point_x
    lda game_target_y
    sta game_point_y
    lda #T_ROCKFORD
    jsr game_set_point
    lda game_target_x
    sta game_player_x
    lda game_target_y
    sta game_player_y
    jsr game_update_view
    lda #1
    sta game_video_dirty
@blocked:
    rts
.endproc

.proc game_handle_player
    lda game_player_alive
    bne :+
    rts
:
    lda game_pad_pressed
    and #PAD_LEFT
    beq @right
    lda game_player_x
    cmp #1
    beq @done
    sec
    sbc #1
    sta game_target_x
    lda game_player_y
    sta game_target_y
    jmp game_try_move
@right:
    lda game_pad_pressed
    and #PAD_RIGHT
    beq @up
    lda game_player_x
    cmp #38
    beq @done
    clc
    adc #1
    sta game_target_x
    lda game_player_y
    sta game_target_y
    jmp game_try_move
@up:
    lda game_pad_pressed
    and #PAD_UP
    beq @down
    lda game_player_y
    cmp #1
    beq @done
    sec
    sbc #1
    sta game_target_y
    lda game_player_x
    sta game_target_x
    jmp game_try_move
@down:
    lda game_pad_pressed
    and #PAD_DOWN
    beq @done
    lda game_player_y
    cmp #20
    beq @done
    clc
    adc #1
    sta game_target_y
    lda game_player_x
    sta game_target_x
    jmp game_try_move
@done:
    rts
.endproc

.proc game_init
    lda #$00
    sta game_pad_current
    sta game_pad_previous
    sta game_pad_pressed
    sta game_video_dirty
    sta game_video_full_dirty
    sta game_view_x
    sta game_view_y
    sta game_phys_counter
    sta game_explosion_changed
    sta game_diamonds_got
    sta game_score_lo
    sta game_score_hi
    sta game_exit_open
    lda #1
    sta game_player_alive
    lda #CAVE1_DIAMONDS_NEEDED
    sta game_diamonds_needed
    lda #$5a
    sta game_random
    jsr game_copy_initial_cave
    lda #3
    sta game_player_x
    sta game_point_x
    lda #4
    sta game_player_y
    sta game_point_y
    jsr game_get_point_ptr
    ldy #0
    lda #T_ROCKFORD
    sta (game_zp_src),y
    jsr game_update_view
    jsr game_render_cave
    jsr platform_init
    rts
.endproc

.proc game_tick
    stz game_video_full_dirty

    ; First sample handles input that was already present at the start of the
    ; frame. Edge detection still guarantees one logical move per press.
    lda game_pad_current
    sta game_pad_previous
    jsr platform_read_pad
    sta game_pad_current
    lda game_pad_previous
    eor #$ff
    and game_pad_current
    sta game_pad_pressed
    jsr game_handle_player

    ; Physics is the longest CPU section. A quick press can happen while the
    ; cave scan is running, so sample once more immediately afterwards instead
    ; of waiting until the next complete frame.
    jsr game_physics_step
    lda game_pad_current
    sta game_pad_previous
    jsr platform_read_pad
    sta game_pad_current
    lda game_pad_previous
    eor #$ff
    and game_pad_current
    sta game_pad_pressed
    jsr game_handle_player

    lda game_video_dirty
    beq @render_ready
    jsr game_render_cave

@render_ready:
    jsr platform_wait_frame

    lda game_video_dirty
    beq @no_video_change
    jsr platform_video_begin
    jsr platform_video_end
    stz game_video_dirty

@no_video_change:
    jsr platform_audio_tick
    rts
.endproc
