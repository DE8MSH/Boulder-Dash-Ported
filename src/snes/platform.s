.setcpu "65816"
.a8
.i8

.include "../common/platform.inc"

.import game_cave_render
.import game_progress_tick
.import game_current_cave

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
MDMAEN   = $420B
HVBJOY   = $4212
JOY1H    = $4219
DMAP0    = $4300
BBAD0    = $4301
A1T0L    = $4302
A1T0H    = $4303
A1B0     = $4304
DAS0L    = $4305
DAS0H    = $4306

CAVE_RENDER_BYTES = 32 * 28 * 2

; VIC-II PAL reference colors (Pepto palette) quantized to SNES BGR555.
; $08 orange  #6F4F25 -> $114D
; $09 brown   #433900 -> $00E8
; $0A lt red  #9A6759 -> $2DB3
; $0B dk gray #444444 -> $2108
; $04 purple  #6F3D86 -> $40ED
C64_ORANGE_SN   = $114d
C64_BROWN_SN    = $00e8
C64_LIGHTRED_SN = $2db3
C64_DARKGRAY_SN = $2108
C64_PURPLE_SN   = $40ed

.segment "BSS"
pad_result:        .res 1
snes_palette_cave: .res 1

.segment "CODE"

.proc snes_upload_cave
    lda #$80
    sta VMAIN
    stz VMADDL
    lda #$10
    sta VMADDH

    lda #$01
    sta DMAP0
    lda #$18
    sta BBAD0
    lda #<game_cave_render
    sta A1T0L
    lda #>game_cave_render
    sta A1T0H
    stz A1B0
    lda #<CAVE_RENDER_BYTES
    sta DAS0L
    lda #>CAVE_RENDER_BYTES
    sta DAS0H
    lda #$01
    sta MDMAEN
    rts
.endproc

.proc snes_write_color
    ; A=low byte, X=high byte of one BGR555 color.
    sta CGDATA
    txa
    sta CGDATA
    rts
.endproc

.proc snes_load_cave_palette
    lda game_current_cave
    cmp snes_palette_cave
    beq @done
    sta snes_palette_cave

    stz CGADD
    ; VIC-II cave background D021 is black.
    stz CGDATA
    stz CGDATA

    lda game_current_cave
    cmp #2
    beq @cave2
    cmp #3
    beq @cave3

    ; Cave 1 header: D022=$08, D023=$0b, Color RAM=$09.
    lda #<C64_ORANGE_SN
    ldx #>C64_ORANGE_SN
    jsr snes_write_color
    lda #<C64_DARKGRAY_SN
    ldx #>C64_DARKGRAY_SN
    jsr snes_write_color
    lda #<C64_BROWN_SN
    ldx #>C64_BROWN_SN
    jsr snes_write_color
    rts

@cave2:
    ; Cave 2 header: D022=$0a, D023=$04, Color RAM=$09.
    lda #<C64_LIGHTRED_SN
    ldx #>C64_LIGHTRED_SN
    jsr snes_write_color
    lda #<C64_PURPLE_SN
    ldx #>C64_PURPLE_SN
    jsr snes_write_color
    lda #<C64_BROWN_SN
    ldx #>C64_BROWN_SN
    jsr snes_write_color
    rts

@cave3:
    ; Cave 3 header: D022=$09, D023=$08, Color RAM=$09.
    lda #<C64_BROWN_SN
    ldx #>C64_BROWN_SN
    jsr snes_write_color
    lda #<C64_ORANGE_SN
    ldx #>C64_ORANGE_SN
    jsr snes_write_color
    lda #<C64_BROWN_SN
    ldx #>C64_BROWN_SN
    jsr snes_write_color
@done:
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

    lda #$ff
    sta snes_palette_cave
    jsr snes_load_cave_palette

    lda #$01
    sta TM

    ; Automatic joypad sampling only. No benchmark NMI.
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
    ; game_tick enters here in VBlank, so palette changes and VRAM DMA are
    ; applied together without visible tearing when advancing caves.
    jsr snes_load_cave_palette
    jsr snes_upload_cave
    rts
.endproc

.proc platform_video_end
    rts
.endproc

.proc platform_audio_tick
    jsr game_progress_tick
    ; Deferred milestone: SPC700/DSP music and SFX backend.
    rts
.endproc

.segment "RODATA"
.include "../../build/generated/snes/charset.inc"
