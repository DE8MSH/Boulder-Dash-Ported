.setcpu "HUC6280"

.include "../common/platform.inc"

; HuC6280 I/O mapping assumes the hardware page is mapped at $0000-$1fff.
VDC_REG   = $0000
VDC_DATA_L= $0002
VDC_DATA_H= $0003
VCE_CTRL  = $0400
VCE_ADDR_L= $0402
VCE_ADDR_H= $0403
VCE_DATA_L= $0404
VCE_DATA_H= $0405
JOYPAD    = $1000

; VDC register numbers.
VDC_CR    = $05
VDC_MWR   = $09
VDC_HSR   = $0A
VDC_HDR   = $0B
VDC_VSR   = $0C
VDC_VDR   = $0D
VDC_VCR   = $0E

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
    csh                 ; high-speed HuC6280 mode

    ; Standard 256-ish pixel timing bootstrap. Keep BG/sprites disabled for the
    ; first visible test; palette entry 0 therefore becomes the backdrop.
    stz VCE_CTRL        ; RGB mode, 5 MHz dot clock

    lda #VDC_HSR
    ldx #$02
    ldy #$02
    jsr vdc_write_xy    ; HSR = $0202

    lda #VDC_HDR
    ldx #$1f
    ldy #$04
    jsr vdc_write_xy    ; HDR = $041f

    lda #VDC_VSR
    ldx #$02
    ldy #$0f
    jsr vdc_write_xy    ; VSR = $0f02

    lda #VDC_VDR
    ldx #$ef
    ldy #$00
    jsr vdc_write_xy    ; 240 visible lines

    lda #VDC_VCR
    ldx #$0c
    ldy #$00
    jsr vdc_write_xy

    lda #VDC_MWR
    ldx #$00            ; 32x32 BAT for the upcoming tile renderer
    ldy #$00
    jsr vdc_write_xy

    ; Enable VBlank event generation, but leave BG and sprites off for now.
    ; CPU IRQs remain masked; platform_wait_frame polls the VDC status flag.
    lda #VDC_CR
    ldx #$08
    ldy #$00
    jsr vdc_write_xy

    ; VCE palette entry 0 = dark blue (9-bit GRB: $0003).
    stz VCE_ADDR_L
    stz VCE_ADDR_H
    lda #$03
    sta VCE_DATA_L
    stz VCE_DATA_H

    ; Reset controller/multitap scan state, then leave SEL high.
    lda #$03            ; CLR=1, SEL=1
    sta JOYPAD
    lda #$01            ; CLR=0, SEL=1
    sta JOYPAD
    rts
.endproc

.proc platform_wait_frame
    ; Reading VDC_REG returns/acknowledges status. Wait until the VBlank event
    ; flag appears; this gives the common game loop one tick per video frame.
@wait_vblank:
    lda VDC_REG
    and #$20
    beq @wait_vblank
    rts
.endproc

.proc platform_read_pad
    ; Standard two-button PCE pad, active low:
    ; SEL=1: d3..d0 = Left, Right, Down, Up
    ; SEL=0: d3..d0 = Run, Select, II, I
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
    and #%00000001      ; I = Boulder Dash fire/action
    beq :+
    lda pad_result
    ora #PAD_FIRE
    sta pad_result
:
    lda pce_raw_buttons
    and #%00001000      ; Run
    beq :+
    lda pad_result
    ora #PAD_START
    sta pad_result
:
    lda pce_raw_buttons
    and #%00000100      ; Select
    beq :+
    lda pad_result
    ora #PAD_SELECT
    sta pad_result
:
    lda pad_result
    rts
.endproc

.proc platform_video_begin
    ; BAT/pattern updates arrive with the converted Boulder Dash characters.
    rts
.endproc

.proc platform_video_end
    rts
.endproc

.proc platform_audio_tick
    ; Deferred milestone: HuC6280 PSG music and SFX backend.
    ; Keep the ABI entry point so audio cannot disappear from the plan.
    rts
.endproc
