.import game_cave_state

.export game_build_cave2
.export game_build_cave3

CAVE_COLS = 40

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
cave_ptr:     .res 2
cave_cmd_ptr: .res 2

.segment "BSS"
cave_seed:      .res 1
cave_start:     .res 1
cave_p1:        .res 1
cave_half:      .res 1
cave_carry:     .res 1
cave_rows_left: .res 1
cave_cols_left: .res 1
cave_x:         .res 1
cave_y:         .res 1
cave_len:       .res 1
cave_tile:      .res 1
cave_dir:       .res 1

.segment "RODATA"
; tile, x, y, length, direction (0=east, 1=south)
cave2_commands:
    .byte T_WALL_STONE,  1,  8, 38, 0
    .byte T_WALL_STONE,  1, 15, 38, 0
    .byte T_WALL_STONE,  8,  3, 20, 1
    .byte T_WALL_STONE, 16,  3, 20, 1
    .byte T_WALL_STONE, 24,  3, 20, 1
    .byte T_WALL_STONE, 32,  3, 20, 1
    .byte T_EMPTY,       1,  5, 38, 0
    .byte T_EMPTY,       1, 11, 38, 0
    .byte T_EMPTY,       1, 18, 38, 0
    .byte T_EMPTY,      20,  3, 20, 1
    .byte T_ROCKFORD,   18, 21,  1, 0
    .byte T_EXIT_CLOSED,18, 22,  1, 0
    .byte $ff

; CaveData_03_Var: only birth and exit override the generated field.
cave3_commands:
    .byte T_ROCKFORD,     3,  4, 1, 0
    .byte T_EXIT_CLOSED, 39, 20, 1, 0
    .byte $ff

.segment "CODE"

; Exact 8-bit GetValPseudoRND behaviour used by Boulder Dash I.
.proc cave_rnd
    lda cave_start
    and #$02
    beq @p1_zero
    lda #$80
    bra @p1_store
@p1_zero:
    lda #$00
@p1_store:
    sta cave_p1

    lda cave_seed
    lsr a
    sta cave_half

    lda cave_seed
    and #$01
    beq @seed_even
    lda #$80
    bra @seed_add
@seed_even:
    lda #$00
@seed_add:
    clc
    adc cave_seed
    adc #$13
    sta cave_seed
    bcc @carry_zero
    lda #$01
    bra @carry_store
@carry_zero:
    lda #$00
@carry_store:
    sta cave_carry

    lda cave_start
    clc
    adc cave_p1
    clc
    adc cave_half
    clc
    adc cave_carry
    sta cave_start
    rts
.endproc

.proc cave_add40
    clc
    lda cave_ptr
    adc #40
    sta cave_ptr
    lda cave_ptr+1
    adc #0
    sta cave_ptr+1
    rts
.endproc

.proc cave_inc_ptr
    inc cave_ptr
    bne :+
    inc cave_ptr+1
:
    rts
.endproc

; Uses cave_x/y/tile and may clobber X/Y.
.proc cave_set
    lda #<game_cave_state
    sta cave_ptr
    lda #>game_cave_state
    sta cave_ptr+1
    ldx cave_y
    beq @rows_done
@rows:
    jsr cave_add40
    dex
    bne @rows
@rows_done:
    ldy cave_x
    lda cave_tile
    sta (cave_ptr),y
    rts
.endproc

.proc cave_apply_commands
@next_command:
    ldy #0
    lda (cave_cmd_ptr),y
    cmp #$ff
    beq @done
    sta cave_tile
    iny
    lda (cave_cmd_ptr),y
    sta cave_x
    iny
    lda (cave_cmd_ptr),y
    sta cave_y
    iny
    lda (cave_cmd_ptr),y
    sta cave_len
    iny
    lda (cave_cmd_ptr),y
    sta cave_dir
@draw:
    jsr cave_set
    lda cave_dir
    bne @south
    inc cave_x
    bra @advance
@south:
    inc cave_y
@advance:
    dec cave_len
    bne @draw
    clc
    lda cave_cmd_ptr
    adc #5
    sta cave_cmd_ptr
    lda cave_cmd_ptr+1
    adc #0
    sta cave_cmd_ptr+1
    bra @next_command
@done:
    rts
.endproc

.proc cave_make_frame
    ; Top/bottom steel frame.
    lda #<game_cave_state
    sta cave_ptr
    lda #>game_cave_state
    sta cave_ptr+1
    ldy #0
@top:
    lda #T_WALL_STEEL
    sta (cave_ptr),y
    iny
    cpy #40
    bne @top

    lda #<(game_cave_state + 880)
    sta cave_ptr
    lda #>(game_cave_state + 880)
    sta cave_ptr+1
    ldy #0
@bottom:
    lda #T_WALL_STEEL
    sta (cave_ptr),y
    iny
    cpy #40
    bne @bottom

    ; Left/right steel frame for rows 0..22.
    lda #<game_cave_state
    sta cave_ptr
    lda #>game_cave_state
    sta cave_ptr+1
    lda #23
    sta cave_rows_left
@side_row:
    ldy #0
    lda #T_WALL_STEEL
    sta (cave_ptr),y
    ldy #39
    sta (cave_ptr),y
    jsr cave_add40
    dec cave_rows_left
    bne @side_row
    rts
.endproc

.proc game_build_cave2
    ; Cave 2 difficulty 0: seed $03. The threshold order reproduces the
    ; original Empty/Boulder/Diamond/Firefly probabilities $3c/$32/$09/$02.
    lda #$03
    sta cave_seed
    stz cave_start

    lda #<(game_cave_state + 40)
    sta cave_ptr
    lda #>(game_cave_state + 40)
    sta cave_ptr+1
    lda #22
    sta cave_rows_left
@rnd_row:
    lda #40
    sta cave_cols_left
@rnd_col:
    jsr cave_rnd
    cmp #$02
    bcc @firefly
    cmp #$09
    bcc @diamond
    cmp #$32
    bcc @boulder
    cmp #$3c
    bcc @empty
    lda #T_SOIL
    bra @store_random
@firefly:
    lda #T_FIREFLY0
    bra @store_random
@diamond:
    lda #T_DIAMOND
    bra @store_random
@boulder:
    lda #T_BOULDER
    bra @store_random
@empty:
    lda #T_EMPTY
@store_random:
    ldy #0
    sta (cave_ptr),y
    jsr cave_inc_ptr
    dec cave_cols_left
    bne @rnd_col
    dec cave_rows_left
    bne @rnd_row

    jsr cave_make_frame
    lda #<cave2_commands
    sta cave_cmd_ptr
    lda #>cave2_commands
    sta cave_cmd_ptr+1
    jsr cave_apply_commands
    rts
.endproc

.proc game_build_cave3
    ; Cave 3 difficulty 0: seed $00. Random object thresholds from the C64
    ; header are Brick/Boulder/Diamond/Empty = $64/$32/$09/$00.
    stz cave_seed
    stz cave_start

    lda #<(game_cave_state + 40)
    sta cave_ptr
    lda #>(game_cave_state + 40)
    sta cave_ptr+1
    lda #22
    sta cave_rows_left
@rnd_row:
    lda #40
    sta cave_cols_left
@rnd_col:
    jsr cave_rnd
    cmp #$09
    bcc @diamond
    cmp #$32
    bcc @boulder
    cmp #$64
    bcc @brick
    lda #T_SOIL
    bra @store_random
@diamond:
    lda #T_DIAMOND
    bra @store_random
@boulder:
    lda #T_BOULDER
    bra @store_random
@brick:
    lda #T_WALL_STONE
@store_random:
    ldy #0
    sta (cave_ptr),y
    jsr cave_inc_ptr
    dec cave_cols_left
    bne @rnd_col
    dec cave_rows_left
    bne @rnd_row

    jsr cave_make_frame
    lda #<cave3_commands
    sta cave_cmd_ptr
    lda #>cave3_commands
    sta cave_cmd_ptr+1
    jsr cave_apply_commands
    rts
.endproc
