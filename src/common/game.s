.include "platform.inc"

.import game_cave_initial

.export game_init
.export game_tick
.export game_pad_current
.export game_pad_previous
.export game_pad_pressed
.export game_video_dirty
.export game_cave_state
.export game_cave_render
.export game_player_x
.export game_player_y
.export game_view_x
.export game_view_y

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

.segment "ZEROPAGE"
game_zp_src:  .res 2
game_zp_dst:  .res 2
game_zp_dst2: .res 2

.segment "BSS"
game_pad_current:  .res 1
game_pad_previous: .res 1
game_pad_pressed:  .res 1
game_video_dirty:  .res 1

game_player_x: .res 1
game_player_y: .res 1
game_target_x: .res 1
game_target_y: .res 1
game_point_x:  .res 1
game_point_y:  .res 1
game_view_x:   .res 1
game_view_y:   .res 1

game_render_row:  .res 1
game_render_col:  .res 1
game_render_base: .res 1

game_cave_state:  .res CAVE_BYTES
; Shared 16-bit tilemap words. Both console backends upload their graphics at
; tile index $40, so the same words can be copied directly to SNES BG1 or the
; HuC6270 BAT.
game_cave_render: .res RENDER_BYTES

.segment "RODATA"
; Original Boulder Dash I TabCaveTileCharNo mapping.
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

    ; 880 bytes = 3 complete pages + 112 bytes.
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

; Build game_zp_src = &game_cave_state[game_point_y][game_point_x].
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

.proc game_update_view
    ; Keep Rockford roughly centred while clamping to the 40x22 cave bounds.
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

; Expand the current 16x14 logical viewport to the original 2x2 C64 character
; layout. Each output cell is a 16-bit tilemap word using shared pattern base
; $40, which matches both platform VRAM layouts.
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

.proc game_try_move
    ; Only empty, soil and diamonds are passable in this first gameplay slice.
    lda game_target_x
    sta game_point_x
    lda game_target_y
    sta game_point_y
    jsr game_get_point_ptr
    ldy #0
    lda (game_zp_src),y
    cmp #$00
    beq @allowed
    cmp #$01
    beq @allowed
    cmp #$14
    bne @blocked

@allowed:
    lda game_player_x
    sta game_point_x
    lda game_player_y
    sta game_point_y
    jsr game_get_point_ptr
    ldy #0
    lda #$00
    sta (game_zp_src),y

    lda game_target_x
    sta game_point_x
    lda game_target_y
    sta game_point_y
    jsr game_get_point_ptr
    ldy #0
    lda #$38
    sta (game_zp_src),y

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
    sta game_view_x
    sta game_view_y

    jsr game_copy_initial_cave

    ; Cave 1 birth point. For this first interactive slice we replace the birth
    ; animation tile with the normal Rockford logical tile immediately.
    lda #3
    sta game_player_x
    sta game_point_x
    lda #4
    sta game_player_y
    sta game_point_y
    jsr game_get_point_ptr
    ldy #0
    lda #$38
    sta (game_zp_src),y

    jsr game_update_view
    jsr game_render_cave
    jsr platform_init
    rts
.endproc

.proc game_tick
    ; Read the pad state left by the previous video frame first. This gives the
    ; common core the visible-display period to update gameplay and rebuild a
    ; dirty render buffer before waiting for the next VBlank upload window.
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
    ; Synchronize only after gameplay/render preparation. Platform video
    ; uploads that follow can therefore run immediately inside VBlank.
    jsr platform_wait_frame

    lda game_video_dirty
    beq @no_video_change
    jsr platform_video_begin
    jsr platform_video_end
    stz game_video_dirty

@no_video_change:
    ; Audio remains a required but deferred backend.
    jsr platform_audio_tick
    rts
.endproc
