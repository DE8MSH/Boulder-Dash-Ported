.setcpu "HUC6280"

.include "../common/platform.inc"

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

    ; Canonical PCE VDC setup uses the HuC6280's dedicated ST0/ST1/ST2 path.
    ; Display/IRQs off and VRAM auto-increment fixed at +1 word.
    st0 #VDC_CR
    st1 #$00
    st2 #$00

    ; 256x224 timing.
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

    ; 32x32 BAT and zero scroll.
    st0 #VDC_MWR
    st1 #$00
    st2 #$00

    st0 #VDC_BXR
    st1 #$00
    st2 #$00

    st0 #VDC_BYR
    st1 #$00
    st2 #$00

    ; Upload the converted Boulder Dash C64 characters to VRAM word $0400.
    ; TIA alternates destination writes between VDC data low/high ports.
    st0 #VDC_MAWR
    st1 #<PCE_PATTERN_WORD
    st2 #>PCE_PATTERN_WORD
    st0 #VDC_DATA
    tia bd_charset_pce, VDC_DATA_L, bd_charset_pce_bytes

    ; Clear all 1024 BAT cells with Chr_00 using the proven ST1/ST2 path.
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

    ; Render the shared 32x22 Cave 1 preview as ready-made 16-bit BAT words.
    ; This deliberately uses TIA, matching the PCE path already confirmed in
    ; Mednafen. Do not regress this to ordinary STA/STZ writes at $0002/$0003.
    st0 #VDC_MAWR
    st1 #$00
    st2 #$00
    st0 #VDC_DATA
    tia pce_cave_bat, VDC_DATA_L, pce_cave_bat_bytes

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

    ; Background on + VBlank source; VRAM increment stays +1.
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
.include "cave_preview_bat.inc"
.include "../../build/generated/pce/charset.inc"
