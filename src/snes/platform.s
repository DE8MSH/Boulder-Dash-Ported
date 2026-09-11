.setcpu "65816"
.a8
.i8

.include "../common/platform.inc"

; SNES CPU / PPU registers used by the port bootstrap.
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
    xce                 ; enter native 65C816 mode

    ; Keep the porting core deliberately 6502-like: 8-bit A/X/Y and DP=$0000.
    rep #$20
    .a16
    lda #$0000
    tcd
    sep #$20
    .a8

    ; Force blank while touching PPU/VRAM state.
    lda #$8f
    sta INIDISP

    ; Mode 1, 8x8 BG tiles. BG1 tiles start at VRAM word $0000 and the
    ; 32x32 BG1 tilemap starts at VRAM word $1000 (8 KiB byte offset).
    lda #$01
    sta BGMODE
    lda #$10
    sta BG1SC
    stz BG12NBA
    stz TS
    stz SETINI

    ; Zero BG1 scroll. Each scroll register must be written twice.
    stz BG1HOFS
    stz BG1HOFS
    stz BG1VOFS
    stz BG1VOFS

    ; Sequential VRAM word access, increment after writing VMDATAH.
    lda #$80
    sta VMAIN
    stz VMADDL
    stz VMADDH

    ; Upload the generated 4bpp Boulder Dash character set to VRAM $0000.
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

    ; Clear all 32x32 BG1 tilemap entries at VRAM word $1000.
    stz VMADDL
    lda #$10
    sta VMADDH
    ldx #1024
@clear_map:
    stz VMDATAL
    stz VMDATAH
    dex
    bne @clear_map

    ; Put the converted characters 0..63 in the first two rows. A tilemap
    ; entry is a 16-bit word; palette 0, normal priority/flip, tile index X.
    stz VMADDL
    lda #$10
    sta VMADDH
    ldx #$0000
@write_test_map:
    txa
    sta VMDATAL
    stz VMDATAH
    inx
    cpx #bd_charset_snes_count
    bne @write_test_map

    sep #$10
    .i8

    ; Palette 0: dark-blue backdrop and white foreground pixels.
    stz CGADD
    lda #$00            ; color 0 = BGR555 $3000
    sta CGDATA
    lda #$30
    sta CGDATA
    lda #$ff            ; color 1 = BGR555 $7fff
    sta CGDATA
    lda #$7f
    sta CGDATA

    ; Enable BG1 on the main screen.
    lda #$01
    sta TM

    ; Auto joypad read on, NMI/IRQ still off for this polling bootstrap.
    lda #%00000001
    sta NMITIMEN

    ; Leave forced blank only during VBlank.
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
.include "../../build/generated/snes/charset.inc"
