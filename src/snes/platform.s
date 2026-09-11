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
C64_WHITE_SN    = $7fff
C64_BLUE_SN     = $3ca6
C64_LTBLUE_SN   = $596d
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

.proc snes_upload_game_tiles
    lda #$80
    sta VMAIN
    stz VMADDL
    lda #$04
    sta VMADDH

    rep #$10
    .i16
    ldx #$0000
@tiles:
    lda bd_charset_snes,x
    sta VMDATAL
    inx
    lda bd_charset_snes,x
    sta VMDATAH
    inx
    cpx #bd_charset_snes_bytes
    bne @tiles

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
    rts
.endproc

.proc snes_upload_intro
    lda #$38
    sta BG1SC
    lda #$80
    sta VMAIN

    ; Original C64 title image tiles live in LoROM bank 1.
    stz VMADDL
    lda #$04
    sta VMADDH
    lda #$01
    sta DMAP0
    lda #$18
    sta BBAD0
    lda #<bd_intro_tiles_snes
    sta A1T0L
    lda #>bd_intro_tiles_snes
    sta A1T0H
    lda #^bd_intro_tiles_snes
    sta A1B0
    lda #<bd_intro_tiles_snes_bytes
    sta DAS0L
    lda #>bd_intro_tiles_snes_bytes
    sta DAS0H
    lda #$01
    sta MDMAEN

    ; 32x32 title map, with the 40x25 C64 picture resampled to 32x25.
    stz VMADDL
    lda #$38
    sta VMADDH
    lda #<bd_intro_map_snes
    sta A1T0L
    lda #>bd_intro_map_snes
    sta A1T0H
    lda #^bd_intro_map_snes
    sta A1B0
    lda #<bd_intro_map_snes_bytes
    sta DAS0L
    lda #>bd_intro_map_snes_bytes
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

.proc snes_load_intro_palette
    ; Original C64 start screen: black, blue, light blue, white multicolor.
    stz CGADD
    stz CGDATA
    stz CGDATA
    lda #<C64_BLUE_SN
    ldx #>C64_BLUE_SN
    jsr snes_write_color
    lda #<C64_LTBLUE_SN
    ldx #>C64_LTBLUE_SN
    jsr snes_write_color
    lda #<C64_WHITE_SN
    ldx #>C64_WHITE_SN
    jsr snes_write_color
    rts
.endproc

.proc snes_load_cave_palette
    lda game_current_cave
    cmp snes_palette_cave
    beq @done
    sta snes_palette_cave

    stz CGADD
    stz CGDATA
    stz CGDATA

    lda game_current_cave
    cmp #2
    beq @cave2
    cmp #3
    beq @cave3

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
    stz BG12NBA
    stz TS
    stz SETINI

    stz BG1HOFS
    stz BG1HOFS
    stz BG1VOFS
    stz BG1VOFS

    ; Enable automatic joypad sampling before showing the C64 title screen.
    lda #%00000001
    sta NMITIMEN

    jsr snes_upload_intro
    jsr snes_load_intro_palette
    lda #$01
    sta TM

@intro_vblank:
    lda HVBJOY
    bpl @intro_vblank
    lda #$0f
    sta INIDISP

@intro_wait:
    jsr platform_wait_frame
    jsr platform_read_pad
    and #(PAD_FIRE | PAD_START)
    beq @intro_wait

    ; Replace the title assets with the normal cave assets while forced blank.
    lda #$8f
    sta INIDISP
    lda #$10
    sta BG1SC
    jsr snes_upload_game_tiles
    jsr snes_upload_cave
    lda #$ff
    sta snes_palette_cave
    jsr snes_load_cave_palette

@game_vblank:
    lda HVBJOY
    bpl @game_vblank
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

.segment "INTRO_RODATA"
.include "../../build/generated/snes/intro.inc"
