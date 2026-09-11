.setcpu "HUC6280"

.include "../common/platform.inc"

.import game_cave_render

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
CAVE_RENDER_BYTES = 32 * 28 * 2

.segment "BSS"
pad_result:      .res 1
pce_raw_dpad:    .res 1
pce_raw_buttons: .res 1

.segment "CODE"

.proc pce_upload_cave
    st0 #VDC_MAWR
    st1 #$00
    st2 #$00
    st0 #VDC_DATA
    tia game_cave_render, VDC_DATA_L, CAVE_RENDER_BYTES
    rts
.endproc

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

    st0 #VDC_MAWR
    st1 #<PCE_PATTERN_WORD
    st2 #>PCE_PATTERN_WORD
    st0 #VDC_DATA
    tia bd_charset_pce, VDC_DATA_L, bd_charset_pce_bytes

    ; Clear complete 32x32 BAT with tile $40 before copying visible viewport.
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

    jsr pce_upload_cave

    ; Temporary Cave 1 palette. Exact C64 palette calibration is deferred.
    stz VCE_ADDR_L
    stz VCE_ADDR_H
    stz VCE_DATA_L
    stz VCE_DATA_H
    lda #$e9
    sta VCE_DATA_L
    stz VCE_DATA_H
    lda #$db
    sta VCE_DATA_L
    stz VCE_DATA_H
    lda #$a0
    sta VCE_DATA_L
    stz VCE_DATA_H

    ; Backdrop/border black.
    stz VCE_ADDR_L
    lda #$01
    sta VCE_ADDR_H
    stz VCE_DATA_L
    stz VCE_DATA_H

    st0 #VDC_CR
    st1 #$88
    st2 #$00

    ; Reset the controller/multitap scan chain once at startup.
    lda #$01            ; SEL=1, CLR=0
    sta JOYPAD
    lda #$03            ; SEL=1, CLR=1
    sta JOYPAD
    lda #$01            ; SEL=1, CLR=0
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
    ; HuC6280 controller protocol: pulse CLR once per complete scan, keep SEL
    ; high for the direction nibble, then drive SEL low for I/II/Select/Run.
    ; The return lines are active-low.
    lda #$01            ; SEL=1, CLR=0
    sta JOYPAD
    lda #$03            ; SEL=1, CLR=1 -> reset to pad 1
    sta JOYPAD
    lda #$01            ; SEL=1, CLR=0 -> directions
    sta JOYPAD

    ; Give the pad enough settling time after changing CLR/SEL.
    pha
    pla
    nop

    lda JOYPAD
    and #$0f
    eor #$0f
    sta pce_raw_dpad

    lda #$00            ; SEL=0, CLR=0 -> buttons
    sta JOYPAD
    pha
    pla
    nop

    lda JOYPAD
    and #$0f
    eor #$0f
    sta pce_raw_buttons

    stz pad_result

    ; Direction nibble with SEL=1:
    ; d3 Left, d2 Right, d1 Down, d0 Up.
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

    ; Button nibble with SEL=0:
    ; d3 Run, d2 Select, d1 II, d0 I.
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
    ; Runtime BAT changes are much larger than one VBlank. Keep BG disabled
    ; for this one dirty upload so CPU VRAM writes are deterministic, then
    ; restore the normal BG+VBlank control value.
    st0 #VDC_CR
    st1 #$08
    st2 #$00
    jsr pce_upload_cave
    st0 #VDC_CR
    st1 #$88
    st2 #$00
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
