.import game_cave_state

.export game_build_cave2

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
cave2_ptr:     .res 2
cave2_cmd_ptr: .res 2

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
cave2_dir:       .res 1

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

.segment "CODE"

; Exact 8-bit GetValPseudoRND behaviour used by Boulder Dash I.
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
    bcc @carry_zero
    lda #$01
    bra @carry_store
@carry_zero:
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

.proc cave2_add40
    clc
    lda cave2_ptr
    adc #40
    sta cave2_ptr
    lda cave2_ptr+1
    adc #0
    sta cave2_ptr+1
    rts
.endproc

.proc cave2_inc_ptr
    inc cave2_ptr
    bne :+
    inc cave2_ptr+1
:
    rts
.endproc

; Uses cave2_x/y/tile and may clobber X/Y.
.proc cave2_set
    lda #<game_cave_state
    sta cave2_ptr
    lda #>game_cave_state
    sta cave2_ptr+1
    ldx cave2_y
    beq @rows_done
@rows:
    jsr cave2_add40
    dex
    bne @rows
@rows_done:
    ldy cave2_x
    lda cave2_tile
    sta (cave2_ptr),y
    rts
.endproc

.proc cave2_apply_commands
    lda #<cave2_commands
    sta cave2_cmd_ptr
    lda #>cave2_commands
    sta cave2_cmd_ptr+1
@next_command:
    ldy #0
    lda (cave2_cmd_ptr),y
    cmp #$ff
    beq @done
    sta cave2_tile
    iny
    lda (cave2_cmd_ptr),y
    sta cave2_x
    iny
    lda (cave2_cmd_ptr),y
    sta cave2_y
    iny
    lda (cave2_cmd_ptr),y
    sta cave2_len
    iny
    lda (cave2_cmd_ptr),y
    sta cave2_dir
@draw:
    jsr cave2_set
    lda cave2_dir
    bne @south
    inc cave2_x
    bra @advance
@south:
    inc cave2_y
@advance:
    dec cave2_len
    bne @draw
    clc
    lda cave2_cmd_ptr
    adc #5
    sta cave2_cmd_ptr
    lda cave2_cmd_ptr+1
    adc #0
    sta cave2_cmd_ptr+1
    bra @next_command
@done:
    rts
.endproc

.proc game_build_cave2
    ; Difficulty 0 header: seed $03. Random object thresholds reproduce
    ; Empty/Boulder/Diamond/Firefly at $3c/$32/$09/$02.
    lda #$03
    sta cave2_seed
    stz cave2_start

    lda #<(game_cave_state + 40)
    sta cave2_ptr
    lda #>(game_cave_state + 40)
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
    sta (cave2_ptr),y
    jsr cave2_inc_ptr
    dec cave2_cols_left
    bne @rnd_col
    dec cave2_rows_left
    bne @rnd_row

    ; Top/bottom steel frame.
    lda #<game_cave_state
    sta cave2_ptr
    lda #>game_cave_state
    sta cave2_ptr+1
    ldy #0
@top:
    lda #T_WALL_STEEL
    sta (cave2_ptr),y
    iny
    cpy #40
    bne @top

    lda #<(game_cave_state + 880)
    sta cave2_ptr
    lda #>(game_cave_state + 880)
    sta cave2_ptr+1
    ldy #0
@bottom:
    lda #T_WALL_STEEL
    sta (cave2_ptr),y
    iny
    cpy #40
    bne @bottom

    ; Left/right steel frame for rows 0..22.
    lda #<game_cave_state
    sta cave2_ptr
    lda #>game_cave_state
    sta cave2_ptr+1
    lda #23
    sta cave2_rows_left
@side_row:
    ldy #0
    lda #T_WALL_STEEL
    sta (cave2_ptr),y
    ldy #39
    sta (cave2_ptr),y
    jsr cave2_add40
    dec cave2_rows_left
    bne @side_row

    ; Apply CaveData_02_Var after the steel frame, like the C64 code.
    jsr cave2_apply_commands
    rts
.endproc
