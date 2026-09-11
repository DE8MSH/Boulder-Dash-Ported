.setcpu "65816"
.a8
.i8

.include "../common/platform.inc"

.import game_cave_render

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

CAVE_RENDER_BYTES = 32 * 28 * 2

.segment "BSS"
pad_result: .res 1

.segment "CODE"

.proc snes_upload_cave
    ; BG1 tilemap starts at VRAM word $1000. The shared render buffer already
    ; contains complete little-endian tilemap words using pattern base $40.
    stz VMADDL
    lda #$10
    sta VMADDH

    rep #$10
    .i16
    ldx #$0000
@copy:
    lda game_cave_render,x
    sta VMDATAL
    inx
    lda game_cave_render,x
    sta VMDATAH
    inx
    cpx #CAVE_RENDER_BYTES
    bne @copy
    sep #$10
    .i8
    rts
.endproc

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

    ; Upload graphics beginning at SNES tile $40 so SNES and PCE can consume
    ; the same shared render words without translation.
    stz VMADDL
    lda #$04
    sta VMADDH

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

    ; Clear complete 32x32 BG1 tilemap.
    stz VMADDL
    lda #$10
    sta VMADDH
    ldx #1024
@clear_map:
    stz VMDATAL
    stz VMDATAH
    dex
    bne @clear_map
    sep #$10
    .i8

    jsr snes_upload_cave

    ; Temporary Cave 1 palette. Exact C64 palette calibration is deferred.
    stz CGADD
    stz CGDATA
    stz CGDATA
    lda #$51
    sta CGDATA
    lda #$15
    sta CGDATA
    lda #$4a
    sta CGDATA
    lda #$29
    sta CGDATA
    lda #$4d
    sta CGDATA
    lda #$01
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
    ; A full 32x28 CPU tilemap upload is longer than one normal VBlank. Until
    ; dirty-row/DMA uploads are implemented, force blank for the single frame
    ; in which gameplay actually changed. This avoids split-screen tearing.
    lda #$80
    sta INIDISP
    jsr snes_upload_cave
    lda #$0f
    sta INIDISP
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
.include "../../build/generated/snes/charset.inc"