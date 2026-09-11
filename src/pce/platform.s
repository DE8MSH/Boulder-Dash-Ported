.setcpu "HUC6280"

.include "../common/platform.inc"

.import game_cave_render
.import game_player_x
.import game_player_y
.import game_view_x
.import game_view_y
.import game_video_full_dirty
.import game_progress_tick
.import game_current_cave

VDC_STATUS  = $0000
VDC_DATA_L  = $0002
VCE_CTRL    = $0400
VCE_ADDR_L  = $0402
VCE_ADDR_H  = $0403
VCE_DATA_L  = $0404
VCE_DATA_H  = $0405
TIMER_RELOAD= $0C00
TIMER_CTRL  = $0C01
JOYPAD      = $1000
IRQ_MASK    = $1402
IRQ_STATUS  = $1403

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

; Canonical C64 RGB approximations converted to HuC6260 9-bit GRB.
; Cave 1: $08 orange, $0b dark gray, $09 brown.
C64_ORANGE_PCE   = $a1
C64_DARKGRAY_PCE = $92
C64_BROWN_PCE    = $90
; Cave 2: $0a light red, $04 purple, $09 brown.
C64_LIGHTRED_PCE = $eb
C64_PURPLE_PCE   = $a4

; HuC6280 timer runs at ~6.99 kHz. Reload $74 gives 117 ticks,
; approximately 59.75 Hz, close to the PCE display rate.
PCE_TIMER_RELOAD = $74
PCE_TIMER_IRQ    = $04

.segment "ZEROPAGE"
pce_zp_src: .res 2

.segment "BSS"
pad_result:      .res 1
pce_raw_dpad:    .res 1
pce_raw_buttons: .res 1
pce_palette_cave:.res 1

pce_last_player_x: .res 1
pce_last_player_y: .res 1
pce_last_view_x:   .res 1
pce_last_view_y:   .res 1
pce_obj_x:         .res 1
pce_obj_y:         .res 1
pce_rel_x:         .res 1
pce_rel_y:         .res 1
pce_addr_lo:       .res 1
pce_addr_hi:       .res 1
pce_addr_buf:      .res 2
pce_dirty_buf:     .res 4

pce_wait_lo:             .res 1
pce_wait_hi:             .res 1
pce_vblank_timeout_count:.res 1
pce_last_vdc_status:     .res 1

.segment "CODE"

.proc pce_upload_cave
    st0 #VDC_MAWR
    st1 #$00
    st2 #$00
    st0 #VDC_DATA
    tia game_cave_render, VDC_DATA_L, CAVE_RENDER_BYTES
    rts
.endproc

.proc pce_load_cave_palette
    lda game_current_cave
    cmp pce_palette_cave
    beq @done
    sta pce_palette_cave

    stz VCE_ADDR_L
    stz VCE_ADDR_H
    stz VCE_DATA_L             ; C64 background black
    stz VCE_DATA_H

    lda game_current_cave
    cmp #2
    beq @cave2
    lda #C64_ORANGE_PCE
    sta VCE_DATA_L
    stz VCE_DATA_H
    lda #C64_DARKGRAY_PCE
    sta VCE_DATA_L
    stz VCE_DATA_H
    lda #C64_BROWN_PCE
    sta VCE_DATA_L
    stz VCE_DATA_H
    rts
@cave2:
    lda #C64_LIGHTRED_PCE
    sta VCE_DATA_L
    stz VCE_DATA_H
    lda #C64_PURPLE_PCE
    sta VCE_DATA_L
    stz VCE_DATA_H
    lda #C64_BROWN_PCE
    sta VCE_DATA_L
    stz VCE_DATA_H
@done:
    rts
.endproc

.proc pce_upload_object
    lda pce_obj_x
    sec
    sbc game_view_x
    sta pce_rel_x
    lda pce_obj_y
    sec
    sbc game_view_y
    sta pce_rel_y

    lda #<game_cave_render
    sta pce_zp_src
    lda #>game_cave_render
    sta pce_zp_src+1

    ldx pce_rel_y
    beq @src_rows_done
@src_add_row:
    clc
    lda pce_zp_src
    adc #$80
    sta pce_zp_src
    lda pce_zp_src+1
    adc #$00
    sta pce_zp_src+1
    dex
    bne @src_add_row
@src_rows_done:
    lda pce_rel_x
    asl a
    asl a
    clc
    adc pce_zp_src
    sta pce_zp_src
    lda pce_zp_src+1
    adc #$00
    sta pce_zp_src+1

    stz pce_addr_lo
    stz pce_addr_hi
    ldx pce_rel_y
    beq @addr_rows_done
@addr_add_row:
    clc
    lda pce_addr_lo
    adc #$40
    sta pce_addr_lo
    lda pce_addr_hi
    adc #$00
    sta pce_addr_hi
    dex
    bne @addr_add_row
@addr_rows_done:
    lda pce_rel_x
    asl a
    clc
    adc pce_addr_lo
    sta pce_addr_lo
    lda pce_addr_hi
    adc #$00
    sta pce_addr_hi

    ldy #$00
    lda (pce_zp_src),y
    sta pce_dirty_buf
    iny
    lda (pce_zp_src),y
    sta pce_dirty_buf+1
    iny
    lda (pce_zp_src),y
    sta pce_dirty_buf+2
    iny
    lda (pce_zp_src),y
    sta pce_dirty_buf+3

    lda pce_addr_lo
    sta pce_addr_buf
    lda pce_addr_hi
    sta pce_addr_buf+1
    st0 #VDC_MAWR
    tia pce_addr_buf, VDC_DATA_L, 2
    st0 #VDC_DATA
    tia pce_dirty_buf, VDC_DATA_L, 4

    clc
    lda pce_zp_src
    adc #$40
    sta pce_zp_src
    lda pce_zp_src+1
    adc #$00
    sta pce_zp_src+1

    clc
    lda pce_addr_lo
    adc #$20
    sta pce_addr_lo
    lda pce_addr_hi
    adc #$00
    sta pce_addr_hi

    ldy #$00
    lda (pce_zp_src),y
    sta pce_dirty_buf
    iny
    lda (pce_zp_src),y
    sta pce_dirty_buf+1
    iny
    lda (pce_zp_src),y
    sta pce_dirty_buf+2
    iny
    lda (pce_zp_src),y
    sta pce_dirty_buf+3

    lda pce_addr_lo
    sta pce_addr_buf
    lda pce_addr_hi
    sta pce_addr_buf+1
    st0 #VDC_MAWR
    tia pce_addr_buf, VDC_DATA_L, 2
    st0 #VDC_DATA
    tia pce_dirty_buf, VDC_DATA_L, 4
    rts
.endproc

.proc platform_init
    sei
    csh

    stz pce_vblank_timeout_count
    stz pce_last_vdc_status
    stz VCE_CTRL

    ; Use the CPU timer purely as a polled pacing source. SEI remains set, so
    ; no timer IRQ handler is required; the request bit is acknowledged by
    ; writing IRQ_STATUS after every tick.
    stz TIMER_CTRL
    lda #PCE_TIMER_RELOAD
    sta TIMER_RELOAD
    lda IRQ_MASK
    and #$fb
    sta IRQ_MASK
    stz IRQ_STATUS
    lda #$01
    sta TIMER_CTRL

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

    lda #$ff
    sta pce_palette_cave
    jsr pce_load_cave_palette

    ; Clear the first entry of sprite palette 0 as before.
    stz VCE_ADDR_L
    lda #$01
    sta VCE_ADDR_H
    stz VCE_DATA_L
    stz VCE_DATA_H

    st0 #VDC_CR
    st1 #$88
    st2 #$00

    lda game_player_x
    sta pce_last_player_x
    lda game_player_y
    sta pce_last_player_y
    lda game_view_x
    sta pce_last_view_x
    lda game_view_y
    sta pce_last_view_y

    lda #$01
    sta JOYPAD
    lda #$03
    sta JOYPAD
    lda #$01
    sta JOYPAD
    rts
.endproc

.proc platform_wait_frame
@wait_timer:
    lda IRQ_STATUS
    and #PCE_TIMER_IRQ
    beq @wait_timer
    stz IRQ_STATUS
    rts
.endproc

.proc platform_read_pad
    lda #$01
    sta JOYPAD
    lda #$03
    sta JOYPAD
    lda #$01
    sta JOYPAD
    pha
    pla
    nop
    lda JOYPAD
    and #$0f
    eor #$0f
    sta pce_raw_dpad

    lda #$00
    sta JOYPAD
    pha
    pla
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
    and #%00000010
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
    and #%00000100
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
    ; Apply the C64 cave palette when advancing caves, then update the BAT.
    jsr pce_load_cave_palette

    ; Physics may change many cave cells in one scan. Use a full BAT refresh for
    ; those frames; keep the small two-object path for player-only movement.
    lda game_video_full_dirty
    bne @full

    lda game_view_x
    cmp pce_last_view_x
    bne @full
    lda game_view_y
    cmp pce_last_view_y
    bne @full

    lda pce_last_player_x
    sta pce_obj_x
    lda pce_last_player_y
    sta pce_obj_y
    jsr pce_upload_object

    lda game_player_x
    sta pce_obj_x
    lda game_player_y
    sta pce_obj_y
    jsr pce_upload_object
    bra @remember

@full:
    jsr pce_upload_cave

@remember:
    lda game_player_x
    sta pce_last_player_x
    lda game_player_y
    sta pce_last_player_y
    lda game_view_x
    sta pce_last_view_x
    lda game_view_y
    sta pce_last_view_y
    rts
.endproc

.proc platform_video_end
    rts
.endproc

.proc platform_audio_tick
    jsr game_progress_tick
    ; Deferred milestone: HuC6280 PSG music and SFX backend.
    rts
.endproc

.segment "RODATA"
.include "../../build/generated/pce/charset.inc"
