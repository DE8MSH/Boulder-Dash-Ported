.setcpu "65816"
.a8
.i8

.include "../common/platform.inc"

.import game_cave_view

INIDISP  = $2100
BGMODE   = $2105
BG1SC    = $2107
BG12NBA  = $210B
BG1HOFS  = $210D
BG1VOFS  = $210E
VMAIN    = $2115
VMADDL   = $2116
VMADDH   = $2117
VMDATAL  = $2118
VMDATAH  = $2119
CGADD    = $2121
CGDATA   = $2122
TM       = $212C
TS       = $212D
SETINI   = $2133
NMITIMEN = $4200
HVBJOY   = $4212
JOY1H    = $4219

.segment "BSS"
pad_result: .res 1

.segment "CODE"

.proc platform_init
    sei
    clc
    xce

    rep #$20
    .a16
    lda #$0000
    tcd
    sep #$20
    .a8

    lda #$8f
    sta INIDISP

    lda #$01
    sta BGMODE
    lda #$10
    sta BG1SC
    stz BG12NBA
    stz TS
    stz SETINI

    stz BG1HOFS
    stz BG1HOFS
    stz BG1VOFS
    stz BG1VOFS

    lda #$80
    sta VMAIN
    stz VMADDL
    stz VMADDH

    rep #$10
    .i16
    ldx #$0000
@upload_tiles:
    lda bd_charset_snes,x
    sta VMDATAL
    inx
    lda bd_charset_snes,x
    sta VMDATAH
    inx
    cpx #bd_charset_snes_bytes
    bne @upload_tiles

    ; Clear the complete 32x32 BG1 tilemap first.
    stz VMADDL
    lda #$10
    sta VMADDH
    ldx #1024
@clear_map:
    stz VMDATAL
    stz VMDATAH
    dex
    bne @clear_map

    ; Cave memory stores Boulder Dash object/tile IDs. The original C64 does
    ; not use those IDs as character numbers directly; TabCaveTileCharNo maps
    ; each object to the character cell that represents it. Apply the same
    ; mapping here before writing the SNES tilemap.
    stz VMADDL
    lda #$10
    sta VMADDH
    ldx #$0000
@write_cave:
    lda game_cave_view,x
    tay
    lda bd1_tile_char_map,y
    sta VMDATAL
    stz VMDATAH
    inx
    cpx #704
    bne @write_cave

    sep #$10
    .i8

    stz CGADD
    lda #$00
    sta CGDATA
    lda #$30
    sta CGDATA
    lda #$ff
    sta CGDATA
    lda #$7f
    sta CGDATA

    lda #$01
    sta TM

    lda #%00000001
    sta NMITIMEN

@wait_vblank:
    lda HVBJOY
    bpl @wait_vblank
    lda #$0f
    sta INIDISP
    rts
.endproc

.proc platform_wait_frame
@leave_vblank:
    lda HVBJOY
    bmi @leave_vblank
@enter_vblank:
    lda HVBJOY
    bpl @enter_vblank
@wait_autojoy:
    lda HVBJOY
    and #$01
    bne @wait_autojoy
    rts
.endproc

.proc platform_read_pad
    stz pad_result

    lda JOY1H
    and #%00000010
    beq :+
    lda pad_result
    ora #PAD_LEFT
    sta pad_result
:
    lda JOY1H
    and #%00000001
    beq :+
    lda pad_result
    ora #PAD_RIGHT
    sta pad_result
:
    lda JOY1H
    and #%00001000
    beq :+
    lda pad_result
    ora #PAD_UP
    sta pad_result
:
    lda JOY1H
    and #%00000100
    beq :+
    lda pad_result
    ora #PAD_DOWN
    sta pad_result
:
    lda JOY1H
    and #%10000000
    beq :+
    lda pad_result
    ora #PAD_FIRE
    sta pad_result
:
    lda JOY1H
    and #%00010000
    beq :+
    lda pad_result
    ora #PAD_START
    sta pad_result
:
    lda JOY1H
    and #%00100000
    beq :+
    lda pad_result
    ora #PAD_SELECT
    sta pad_result
:
    lda pad_result
    rts
.endproc

.proc platform_video_begin
    rts
.endproc

.proc platform_video_end
    rts
.endproc

.proc platform_audio_tick
    ; Deferred milestone: SPC700/DSP music and SFX backend.
    rts
.endproc

.segment "RODATA"

; Original Boulder Dash I TabCaveTileCharNo table.
bd1_tile_char_map:
    .byte $60,$46,$4e,$22,$2e,$62,$2e,$4a
    .byte $64,$64,$64,$64,$64,$64,$64,$64
    .byte $44,$44,$44,$44,$48,$48,$48,$48
    .byte $00,$00,$00,$66,$68,$6a,$68,$66
    .byte $24,$26,$28,$2a,$2c,$62,$66,$68
    .byte $6a,$00,$00,$00,$00,$00,$00,$00
    .byte $20,$20,$20,$20,$20,$20,$20,$20
    .byte $4c,$4c,$40,$40,$00,$00,$00,$00

.include "../../build/generated/snes/charset.inc"
