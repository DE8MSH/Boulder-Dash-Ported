.setcpu "HUC6280"

.include "../common/platform.inc"

VDC_REG    = $0000
VDC_DATA_L = $0002
VDC_DATA_H = $0003
VCE_CTRL   = $0400
VCE_ADDR_L = $0402
VCE_ADDR_H = $0403
VCE_DATA_L = $0404
VCE_DATA_H = $0405
JOYPAD     = $1000

VDC_MAWR = $00
VDC_DATA = $02
VDC_CR   = $05
VDC_BXR  = $07
VDC_BYR  = $08
VDC_MWR  = $09
VDC_HSR  = $0A
VDC_HDR  = $0B
VDC_VSR  = $0C
VDC_VDR  = $0D
VDC_VCR  = $0E

; BAT occupies words $0000-$03ff in 32x32 mode. A 4bpp BG tile is 32 bytes
; (16 VDC words), so tile index $40 starts exactly at VDC word $0400.
PCE_DIAG_WORD = $0400
PCE_DIAG_TILE = $0040

.segment "BSS"
pad_result:      .res 1
pce_raw_dpad:    .res 1
pce_raw_buttons: .res 1

.segment "CODE"

.proc vdc_write_xy
    sta VDC_REG
    stx VDC_DATA_L
    sty VDC_DATA_H
    rts
.endproc

.proc platform_init
    sei
    csh

    stz VCE_CTRL        ; 5 MHz dot clock

    ; Disable display/IRQs and force MAWR increment +1 before any VRAM access.
    lda #VDC_CR
    ldx #$00
    ldy #$00
    jsr vdc_write_xy

    ; 256x224 timing.
    lda #VDC_HSR
    ldx #$02
    ldy #$02
    jsr vdc_write_xy

    lda #VDC_HDR
    ldx #$1f
    ldy #$04
    jsr vdc_write_xy

    lda #VDC_VSR
    ldx #$07
    ldy #$0d
    jsr vdc_write_xy

    lda #VDC_VDR
    ldx #$df
    ldy #$00
    jsr vdc_write_xy

    lda #VDC_VCR
    ldx #$03
    ldy #$00
    jsr vdc_write_xy

    lda #VDC_MWR
    ldx #$00            ; 32x32 BAT
    ldy #$00
    jsr vdc_write_xy

    lda #VDC_BXR
    ldx #$00
    ldy #$00
    jsr vdc_write_xy

    lda #VDC_BYR
    ldx #$00
    ldy #$00
    jsr vdc_write_xy

    ; One known solid tile, written directly through the VDC data port.
    ; First 8 words contain planes 0/1, next 8 words planes 2/3.
    lda #VDC_MAWR
    ldx #<PCE_DIAG_WORD
    ldy #>PCE_DIAG_WORD
    jsr vdc_write_xy

    lda #VDC_DATA
    sta VDC_REG

    ldx #$08
@diag01:
    lda #$ff            ; plane 0 = all set -> palette index 1
    sta VDC_DATA_L
    stz VDC_DATA_H      ; plane 1 = clear
    dex
    bne @diag01

    ldx #$08
@diag23:
    stz VDC_DATA_L
    stz VDC_DATA_H
    dex
    bne @diag23

    ; Fill ALL 1024 BAT cells with tile $40. If BG output works, the complete
    ; active display must become palette color 1 (white).
    lda #VDC_MAWR
    ldx #$00
    ldy #$00
    jsr vdc_write_xy

    lda #VDC_DATA
    sta VDC_REG

    ldy #$04
@bat_page:
    ldx #$00
@bat_word:
    lda #<PCE_DIAG_TILE
    sta VDC_DATA_L
    lda #>PCE_DIAG_TILE
    sta VDC_DATA_H
    inx
    bne @bat_word
    dey
    bne @bat_page

    ; Background palette 0: color 0 blue, color 1 white.
    stz VCE_ADDR_L
    stz VCE_ADDR_H
    lda #$03
    sta VCE_DATA_L
    stz VCE_DATA_H
    lda #$ff
    sta VCE_DATA_L
    lda #$01
    sta VCE_DATA_H

    ; Border/backdrop remains blue so active BG area is easy to distinguish.
    stz VCE_ADDR_L
    lda #$01
    sta VCE_ADDR_H
    lda #$03
    sta VCE_DATA_L
    stz VCE_DATA_H

    ; BG on + VBlank interrupt/status source; IW remains +1.
    lda #VDC_CR
    ldx #$88
    ldy #$00
    jsr vdc_write_xy

    lda #$03
    sta JOYPAD
    lda #$01
    sta JOYPAD
    rts
.endproc

.proc platform_wait_frame
@wait_vblank:
    lda VDC_REG
    and #$20
    beq @wait_vblank
    rts
.endproc

.proc platform_read_pad
    lda #$01
    sta JOYPAD
    nop
    nop
    lda JOYPAD
    and #$0f
    eor #$0f
    sta pce_raw_dpad

    stz JOYPAD
    nop
    nop
    lda JOYPAD
    and #$0f
    eor #$0f
    sta pce_raw_buttons

    stz pad_result

    lda pce_raw_dpad
    and #%00001000
    beq :+
    lda pad_result
    ora #PAD_LEFT
    sta pad_result
:
    lda pce_raw_dpad
    and #%00000100
    beq :+
    lda pad_result
    ora #PAD_RIGHT
    sta pad_result
:
    lda pce_raw_dpad
    and #%00000001
    beq :+
    lda pad_result
    ora #PAD_UP
    sta pad_result
:
    lda pce_raw_dpad
    and #%00000010
    beq :+
    lda pad_result
    ora #PAD_DOWN
    sta pad_result
:
    lda pce_raw_buttons
    and #%00000001
    beq :+
    lda pad_result
    ora #PAD_FIRE
    sta pad_result
:
    lda pce_raw_buttons
    and #%00001000
    beq :+
    lda pad_result
    ora #PAD_START
    sta pad_result
:
    lda pce_raw_buttons
    and #%00000100
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
    ; Deferred milestone: HuC6280 PSG music and SFX backend.
    rts
.endproc
