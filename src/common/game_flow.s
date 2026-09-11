.include "platform.inc"

.import game_cave_initial
.import game_cave_state
.import game_cave_render
.import game_video_dirty
.import game_video_full_dirty
.import game_pad_current
.import game_pad_previous
.import game_pad_pressed
.import game_player_x
.import game_player_y
.import game_player_alive
.import game_view_x
.import game_view_y
.import game_diamonds_got
.import game_diamonds_needed
.import game_exit_open
.import game_score_lo
.import game_score_hi
.import game_render_cave

.export game_flow_init
.export game_flow_lose_life
.export game_flow_add_time_bonus
.export game_lives
.export game_game_over

CAVE_BYTES = 880
CAVE1_DIAMONDS_NEEDED = 12
CAVE1_PLAYER_X = 3
CAVE1_PLAYER_Y = 4
CAVE1_PLAYER_OFFSET = (CAVE1_PLAYER_Y * 40) + CAVE1_PLAYER_X
INITIAL_LIVES = 3
T_ROCKFORD = $38

.segment "ZEROPAGE"
flow_zp_src: .res 2
flow_zp_dst: .res 2

.segment "BSS"
game_lives:     .res 1
game_game_over: .res 1

.segment "CODE"

.proc game_flow_init
    lda #INITIAL_LIVES
    sta game_lives
    stz game_game_over
    rts
.endproc

.proc game_flow_copy_cave1
    lda #<game_cave_initial
    sta flow_zp_src
    lda #>game_cave_initial
    sta flow_zp_src+1
    lda #<game_cave_state
    sta flow_zp_dst
    lda #>game_cave_state
    sta flow_zp_dst+1

    ldx #3
@page:
    ldy #0
@byte:
    lda (flow_zp_src),y
    sta (flow_zp_dst),y
    iny
    bne @byte
    inc flow_zp_src+1
    inc flow_zp_dst+1
    dex
    bne @page

    ldy #0
@tail:
    lda (flow_zp_src),y
    sta (flow_zp_dst),y
    iny
    cpy #112
    bne @tail
    rts
.endproc

.proc game_flow_place_rockford
    ; The generated Cave 1 still contains the original birth object at (3,4).
    ; game_init replaces it with Rockford; a respawn must do the same or the
    ; cave scan never encounters Rockford and controls appear frozen.
    lda #<(game_cave_state + CAVE1_PLAYER_OFFSET)
    sta flow_zp_dst
    lda #>(game_cave_state + CAVE1_PLAYER_OFFSET)
    sta flow_zp_dst+1
    ldy #0
    lda #T_ROCKFORD
    sta (flow_zp_dst),y
    rts
.endproc

.proc game_flow_reset_attempt
    jsr game_flow_copy_cave1
    jsr game_flow_place_rockford

    stz game_pad_current
    stz game_pad_previous
    stz game_pad_pressed
    stz game_view_x
    stz game_view_y
    stz game_diamonds_got
    stz game_exit_open

    lda #CAVE1_DIAMONDS_NEEDED
    sta game_diamonds_needed
    lda #CAVE1_PLAYER_X
    sta game_player_x
    lda #CAVE1_PLAYER_Y
    sta game_player_y
    lda #1
    sta game_player_alive

    ; Rebuild the shared render buffer before either console uploads the reset
    ; cave. This keeps the logical cave and displayed cave in sync immediately.
    jsr game_render_cave
    lda #1
    sta game_video_dirty
    sta game_video_full_dirty
    rts
.endproc

.proc game_flow_lose_life
    lda game_game_over
    bne @done

    lda game_lives
    beq @game_over
    dec game_lives
    lda game_lives
    beq @game_over

    jsr game_flow_reset_attempt
    rts

@game_over:
    lda #1
    sta game_game_over
    stz game_player_alive
@done:
    rts
.endproc

; A contains the remaining cave seconds. Boulder Dash transfers the remaining
; time into score after the exit is reached. The visual count-down animation
; can be added with the status bar; the score result is already correct here.
.proc game_flow_add_time_bonus
    clc
    adc game_score_lo
    sta game_score_lo
    lda game_score_hi
    adc #0
    sta game_score_hi
    rts
.endproc
