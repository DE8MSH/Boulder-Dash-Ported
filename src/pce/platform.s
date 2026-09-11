.setcpu "HUC6280"

.include "../common/platform.inc"

.import game_cave_view

VDC_STATUS  = $0000
VDC_DATA_L  = $0002
VDC_DATA_H  = $0003
VCE_CTRL    = $0400
VCE_ADDR_L  = $0402
VCE_ADDR_H  = $0403
VCE_DATA_L  = $0404
VCE_DATA_H  = $0405
JOYPAD      = $1000

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

PCE_PATTERN_WORD = $0400
PCE_PATTERN_TILE = $0040

.segment "BSS"
pad_result:      .res 1
pce_raw_dpad:    .res 1
pce_raw_buttons: .res 1

.segment "CODE"

.proc platform_init
    sei
    csh

    stz VCE_CTRL

    st0 #VDC_CR
    st1 #$00
    st2 #$00

    st0 #VDC_HSR
    st1 #$02
    st2 #$02

    st0 #VDC_HDR
    st1 #$1f
    st2 #$04

    st0 #VDC_VSR
    st1 #$07
    st2 #$0d

    st0 #VDC_VDR
    st1 #$df
    st2 #$00

    st0 #VDC_VCR
    st1 #$03
    st2 #$00

    st0 #VDC_MWR
    st1 #$00
    st2 #$00

    st0 #VDC_BXR
    st1 #$00
    st2 #$00

    st0 #VDC_BYR
    st1 #$00
    st2 #$00

    ; Upload converted Boulder Dash characters at tile index $40.
    st0 #VDC_MAWR
    st1 #<PCE_PATTERN_WORD
    st2 #>PCE_PATTERN_WORD
    st0 #VDC_DATA
    tia bd_charset_pce, VDC_DATA_L, bd_charset_pce_bytes

    ; Fill all 1024 BAT entries with Chr_00 first.
    st0 #VDC_MAWR
    st1 #$00
    st2 #$00
    st0 #VDC_DATA

    ldy #$04
@bat_page:
    ldx #$00
@bat_blank:
    st1 #<PCE_PATTERN_TILE
    st2 #>PCE_PATTERN_TILE
    inx
    bne @bat_blank
    dey
    bne @bat_page

    ; Render the shared 32x22 Cave 1 viewport. HuC6280 X is 8-bit, so the
    ; 704-byte map is emitted in three indexed chunks. PCE patterns begin at
    ; tile $40, therefore each portable tile ID receives that fixed offset.
    st0 #VDC_MAWR
    st1 #$00
    st2 #$00
    st0 #VDC_DATA

    ldx #$00
@cave_page0:
    lda game_cave_view,x
    clc
    adc #<PCE_PATTERN_TILE
    sta VDC_DATA_L
    stz VDC_DATA_H
    inx
    bne @cave_page0

    ldx #$00
@cave_page1:
    lda game_cave_view+$0100,x
    clc
    adc #<PCE_PATTERN_TILE
    sta VDC_DATA_L
    stz VDC_DATA_H
    inx
    bne @cave_page1

    ldx #$00
@cave_page2:
    lda game_cave_view+$0200,x
    clc
    adc #<PCE_PATTERN_TILE
    sta VDC_DATA_L
    stz VDC_DATA_H
    inx
    cpx #$c0            ; 192 bytes: 704 - 512
    bne @cave_page2

    ; BG palette 0: dark blue background and white set pixels.
    stz VCE_ADDR_L
    stz VCE_ADDR_H
    lda #$03
    sta VCE_DATA_L
    stz VCE_DATA_H
    lda #$ff
    sta VCE_DATA_L
    lda #$01
    sta VCE_DATA_H

    ; Backdrop/border blue.
    stz VCE_ADDR_L
    lda #$01
    sta VCE_ADDR_H
    lda #$03
    sta VCE_DATA_L
    stz VCE_DATA_H

    st0 #VDC_CR
    st1 #$88
    st2 #$00

    lda #$03
    sta JOYPAD
    lda #$01
    sta JOYPAD
    rts
.endproc

.proc platform_wait_frame
@wait_vblank:
    lda VDC_STATUS
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

.segment "RODATA"
.include "../../build/generated/pce/charset.inc"
