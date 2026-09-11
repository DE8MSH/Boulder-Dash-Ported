.setcpu "6502"

.import game_cave_state

.export game_build_cave2

CAVE_COLS  = 40
CAVE_ROWS  = 23
CAVE_BYTES = 920

T_EMPTY       = $00
T_SOIL        = $01
T_WALL_STONE  = $02
T_EXIT_CLOSED = $04
T_WALL_STEEL  = $07
T_FIREFLY0    = $08
T_BOULDER     = $10
T_DIAMOND     = $14
T_ROCKFORD    = $38

.segment "ZEROPAGE"
cave2_ptr: .res 2

.segment "BSS"
cave2_seed:      .res 1
cave2_start:     .res 1
cave2_p1:        .res 1
cave2_half:      .res 1
cave2_carry:     .res 1
cave2_rows_left: .res 1
cave2_cols_left: .res 1
cave2_x:         .res 1
cave2_y:         .res 1
cave2_len:       .res 1
cave2_tile:      .res 1

.segment "CODE"

; Exact 8-bit GetValPseudoRND sequence used by Boulder Dash I.
.proc cave2_rnd
    lda cave2_start
    and #$02
    beq @p1_zero
    lda #$80
    bra @p1_store
@p1_zero:
    lda #$00
@p1_store:
    sta cave2_p1

    lda cave2_seed
    lsr a
    sta cave2_half

    lda cave2_seed
    and #$01
    beq @seed_even
    lda #$80
    bra @seed_add
@seed_even:
    lda #$00
@seed_add:
    clc
    adc cave2_seed
    adc #$13
    sta cave2_seed
    bcc @no_carry
    lda #$01
    bra @carry_store
@no_carry:
    lda #$00
@carry_store:
    sta cave2_carry

    lda cave2_start
    clc
    adc cave2_p1
    clc
    adc cave2_half
    clc
    adc cave2_carry
    sta cave2_start
    rts
.endproc

.proc cave2_inc_ptr
    inc cave2_ptr
    bne :+
    inc cave2_ptr+1
:
    rts
.endproc

; A=tile, X=x, Y=y.
.proc cave2_set_xy
    sta cave2_tile
    stx cave2_x
    sty cave2_y

    lda #<game_cave_state
    sta cave2_ptr
    lda #>game_cave_state
    sta cave2_ptr+1

    ldx cave2_y
    beq @rows_done
@row_add:
    clc
    lda cave2_ptr
    adc #CAVE_COLS
    sta cave2_ptr
    lda cave2_ptr+1
    adc #$00
    sta cave2_ptr+1
    dex
    bne @row_add
@rows_done:
    ldy cave2_x
    lda cave2_tile
    sta (cave2_ptr),y
    rts
.endproc

.proc cave2_hline
@loop:
    lda cave2_tile
    ldx cave2_x
    ldy cave2_y
    jsr cave2_set_xy
    inc cave2_x
    dec cave2_len
    bne @loop
    rts
.endproc

.proc cave2_vline
@loop:
    lda cave2_tile
    ldx cave2_x
    ldy cave2_y
    jsr cave2_set_xy
    inc cave2_y
    dec cave2_len
    bne @loop
    rts
.endproc

.proc game_build_cave2
    ; Cave 2 difficulty 0 header: seed $03 and the original random objects
    ; Empty/Boulder/Diamond/Firefly with probabilities $3c/$32/$09/$02.
    lda #$03
    sta cave2_seed
    stz cave2_start

    lda #<(game_cave_state + CAVE_COLS)
    sta cave2_ptr
    lda #>(game_cave_state + CAVE_COLS)
    sta cave2_ptr+1
    lda #22
    sta cave2_rows_left
@rnd_row:
    lda #40
    sta cave2_cols_left
@rnd_col:
    jsr cave2_rnd
    cmp #$02
    bcc @firefly
    cmp #$09
    bcc @diamond
    cmp #$32
    bcc @boulder
    cmp #$3c
    bcc @empty
    lda #T_SOIL
    bra @store_rnd
@firefly:
    lda #T_FIREFLY0
    bra @store_rnd
@diamond:
    lda #T_DIAMOND
    bra @store_rnd
@boulder:
    lda #T_BOULDER
    bra @store_rnd
@empty:
    lda #T_EMPTY
@store_rnd:
    ldy #0
    sta (cave2_ptr),y
    jsr cave2_inc_ptr
    dec cave2_cols_left
    bne @rnd_col
    dec cave2_rows_left
    bne @rnd_row

    ; Steel top and bottom rows.
    ldx #0
@frame_cols:
    lda #T_WALL_STEEL
    ldy #0
    jsr cave2_set_xy
    lda #T_WALL_STEEL
    ldy #22
    jsr cave2_set_xy
    inx
    cpx #40
    bne @frame_cols

    ; Steel left and right columns.
    ldy #0
@frame_rows:
    lda #T_WALL_STEEL
    ldx #0
    jsr cave2_set_xy
    lda #T_WALL_STEEL
    ldx #39
    jsr cave2_set_xy
    iny
    cpy #23
    bne @frame_rows

    ; CaveData_02_Var from the original C64 source.
    lda #T_WALL_STONE
    sta cave2_tile
    lda #1
    sta cave2_x
    lda #8
    sta cave2_y
    lda #38
    sta cave2_len
    jsr cave2_hline

    lda #T_WALL_STONE
    sta cave2_tile
    lda #1
    sta cave2_x
    lda #15
    sta cave2_y
    lda #38
    sta cave2_len
    jsr cave2_hline

    lda #T_WALL_STONE
    sta cave2_tile
    lda #8
    sta cave2_x
    lda #3
    sta cave2_y
    lda #20
    sta cave2_len
    jsr cave2_vline

    lda #T_WALL_STONE
    sta cave2_tile
    lda #16
    sta cave2_x
    lda #3
    sta cave2_y
    lda #20
    sta cave2_len
    jsr cave2_vline

    lda #T_WALL_STONE
    sta cave2_tile
    lda #24
    sta cave2_x
    lda #3
    sta cave2_y
    lda #20
    sta cave2_len
    jsr cave2_vline

    lda #T_WALL_STONE
    sta cave2_tile
    lda #32
    sta cave2_x
    lda #3
    sta cave2_y
    lda #20
    sta cave2_len
    jsr cave2_vline

    lda #T_EMPTY
    sta cave2_tile
    lda #1
    sta cave2_x
    lda #5
    sta cave2_y
    lda #38
    sta cave2_len
    jsr cave2_hline

    lda #T_EMPTY
    sta cave2_tile
    lda #1
    sta cave2_x
    lda #11
    sta cave2_y
    lda #38
    sta cave2_len
    jsr cave2_hline

    lda #T_EMPTY
    sta cave2_tile
    lda #1
    sta cave2_x
    lda #18
    sta cave2_y
    lda #38
    sta cave2_len
    jsr cave2_hline

    lda #T_EMPTY
    sta cave2_tile
    lda #20
    sta cave2_x
    lda #3
    sta cave2_y
    lda #20
    sta cave2_len
    jsr cave2_vline

    ; The port starts Rockford immediately instead of replaying the birth
    ; animation, matching the existing Cave 1 startup convention.
    lda #T_ROCKFORD
    ldx #18
    ldy #21
    jsr cave2_set_xy

    lda #T_EXIT_CLOSED
    ldx #18
    ldy #22
    jsr cave2_set_xy
    rts
.endproc
