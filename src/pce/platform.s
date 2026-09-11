.setcpu "HUC6280"

.include "../common/platform.inc"

; HuC6280 I/O mapping assumes the hardware page is mapped at $0000-$1fff.
VDC_REG    = $0000
VDC_DATA_L = $0002
VDC_DATA_H = $0003
VCE_CTRL   = $0400
VCE_ADDR_L = $0402
VCE_ADDR_H = $0403
VCE_DATA_L = $0404
VCE_DATA_H = $0405
JOYPAD     = $1000

; VDC register numbers.
VDC_MAWR = $00
VDC_DATA = $02
VDC_CR   = $05
VDC_MWR  = $09
VDC_HSR  = $0A
VDC_HDR  = $0B
VDC_VSR  = $0C
VDC_VDR  = $0D
VDC_VCR  = $0E

; 32x32 BAT occupies VRAM words $0000-$03ff. Pattern data starts at $0400,
; which corresponds to BAT character index $0040 because each 8x8 4bpp tile
; consumes 16 VRAM words.
PCE_PATTERN_WORD = $0400
PCE_PATTERN_TILE = $0040

.segment "BSS"
pad_result:      .res 1
pce_raw_dpad:    .res 1
pce_raw_buttons: .res 1

.segment "CODE"

; Write A=register number, X=low byte, Y=high byte to the VDC.
.proc vdc_write_xy
    sta VDC_REG
    stx VDC_DATA_L
    sty VDC_DATA_H
    rts
.endproc

.proc platform_init
    sei
    csh

    ; RGB mode, 5 MHz dot clock.
    stz VCE_CTRL

    ; 256-ish pixel / 240-line bootstrap timing.
    lda #VDC_HSR
    ldx #$02
    ldy #$02
    jsr vdc_write_xy

    lda #VDC_HDR
    ldx #$1f
    ldy #$04
    jsr vdc_write_xy

    lda #VDC_VSR
    ldx #$02
    ldy #$0f
    jsr vdc_write_xy

    lda #VDC_VDR
    ldx #$ef
    ldy #$00
    jsr vdc_write_xy

    lda #VDC_VCR
    ldx #$0c
    ldy #$00
    jsr vdc_write_xy

    lda #VDC_MWR
    ldx #$00            ; 32x32 BAT
    ldy #$00
    jsr vdc_write_xy

    ; Upload generated 4bpp tiles to VRAM word $0400 first. Chr_00 is a
    ; guaranteed blank character and becomes tile $40.
    lda #VDC_MAWR
    ldx #<PCE_PATTERN_WORD
    ldy #>PCE_PATTERN_WORD
    jsr vdc_write_xy
    lda #VDC_DATA
    sta VDC_REG
    tia bd_charset_pce, VDC_DATA_L, bd_charset_pce_bytes

    ; Fill the complete 32x32 BAT with tile $40 (Chr_00), not tile 0.
    ; Tile 0 would point back into the BAT itself because the BAT occupies
    ; VRAM $0000-$03ff; using the dedicated blank tile avoids self-reference.
    lda #VDC_MAWR
    ldx #$00
    ldy #$00
    jsr vdc_write_xy
    lda #VDC_DATA
    sta VDC_REG
    ldy #$04            ; 4 * 256 words = 1024 BAT entries
@clear_page:
    ldx #$00
@clear_word:
    lda #<PCE_PATTERN_TILE
    sta VDC_DATA_L
    lda #>PCE_PATTERN_TILE
    sta VDC_DATA_H
    inx
    bne @clear_word
    dey
    bne @clear_page

    ; First two BAT rows show converted Chr_00..Chr_3f.
    lda #VDC_MAWR
    ldx #$00
    ldy #$00
    jsr vdc_write_xy
    lda #VDC_DATA
    sta VDC_REG
    ldx #$00
@write_test_map:
    txa
    clc
    adc #<PCE_PATTERN_TILE
    sta VDC_DATA_L
    lda #>PCE_PATTERN_TILE
    adc #$00
    sta VDC_DATA_H
    inx
    cpx #bd_charset_pce_count
    bne @write_test_map

    ; BG palette 0: dark blue background, white foreground for C64 set pixels.
    stz VCE_ADDR_L
    stz VCE_ADDR_H
    lda #$03            ; palette $000 color 0 = dark blue
    sta VCE_DATA_L
    stz VCE_DATA_H
    lda #$ff            ; palette $000 color 1 = white ($01ff)
    sta VCE_DATA_L
    lda #$01
    sta VCE_DATA_H

    ; The PCE's backdrop when no opaque BG pixel is present comes from color 0
    ; of the first sprite palette (VCE entry $100). Initialize that too so an
    ; empty/transparent area is deterministic rather than power-on white.
    stz VCE_ADDR_L
    lda #$01
    sta VCE_ADDR_H
    lda #$03
    sta VCE_DATA_L
    stz VCE_DATA_H

    ; Enable VBlank event and background display; sprites remain off.
    lda #VDC_CR
    ldx #$88            ; BG enable + VBlank event
    ldy #$00
    jsr vdc_write_xy

    ; Reset controller/multitap scan state, then leave SEL high.
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

.segment "RODATA"
.include "../../build/generated/pce/charset.inc"
