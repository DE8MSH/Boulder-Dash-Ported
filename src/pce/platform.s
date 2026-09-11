.setcpu "HUC6280"

.include "../common/platform.inc"

.import game_cave_render
.import game_player_x
.import game_player_y
.import game_view_x
.import game_view_y

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

.segment "ZEROPAGE"
pce_zp_src: .res 2

.segment "BSS"
pad_result:      .res 1
pce_raw_dpad:    .res 1
pce_raw_buttons: .res 1

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
pce_dirty_buf:     .res 4
pce_strip_count:   .res 1

; Executable HuC6280 RAM trampoline:
;   ST0 #reg / ST1 #low / ST2 #high / RTS
; Dynamic VDC register writes must use the dedicated HuC6280 instructions.
pce_vdc_trampoline: .res 7

.segment "RODATA"
pce_vdc_trampoline_template:
    .byte $03, $00, $13, $00, $23, $00, $60

.segment "CODE"

.proc pce_init_vdc_trampoline
    ldx #$00
@copy:
    lda pce_vdc_trampoline_template,x
    sta pce_vdc_trampoline,x
    inx
    cpx #$07
    bne @copy
    rts
.endproc

; Inputs: A = VDC register number, X = low byte, Y = high byte.
; Writes the operands of ST0/ST1/ST2 in the RAM trampoline and executes it.
.proc pce_write_vdc_reg
    sta pce_vdc_trampoline+1
    stx pce_vdc_trampoline+3
    sty pce_vdc_trampoline+5
    jsr pce_vdc_trampoline
    rts
.endproc

.proc pce_upload_cave
    st0 #VDC_MAWR
    st1 #$00
    st2 #$00
    st0 #VDC_DATA
    tia game_cave_render, VDC_DATA_L, CAVE_RENDER_BYTES
    rts
.endproc

; Upload one logical 16x16 cave object (2x2 BAT cells) from the current
; shared viewport into its physical position in the 32x32 circular BAT.
.proc pce_upload_object
    lda pce_obj_x
    sec
    sbc game_view_x
    sta pce_rel_x
    lda pce_obj_y
    sec
    sbc game_view_y
    sta pce_rel_y

    ; Source pointer = game_cave_render + rel_y*128 + rel_x*4.
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

    ; Physical BAT word address:
    ; ((world_y & 15) * 2) * 32 + ((world_x & 15) * 2).
    lda pce_obj_y
    and #$0f
    sta pce_addr_lo
    stz pce_addr_hi
    ldx #$06
@addr_shift_y:
    asl pce_addr_lo
    rol pce_addr_hi
    dex
    bne @addr_shift_y

    lda pce_obj_x
    and #$0f
    asl a
    clc
    adc pce_addr_lo
    sta pce_addr_lo
    lda pce_addr_hi
    adc #$00
    sta pce_addr_hi

    ; Top two character cells.
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

    lda #VDC_MAWR
    ldx pce_addr_lo
    ldy pce_addr_hi
    jsr pce_write_vdc_reg
    st0 #VDC_DATA
    tia pce_dirty_buf, VDC_DATA_L, 4

    ; Bottom two cells are one BAT row lower and 64 source bytes later.
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
    and #$03
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

    lda #VDC_MAWR
    ldx pce_addr_lo
    ldy pce_addr_hi
    jsr pce_write_vdc_reg
    st0 #VDC_DATA
    tia pce_dirty_buf, VDC_DATA_L, 4
    rts
.endproc

.proc pce_set_scroll
    ; BXR = view_x * 16 pixels.
    lda game_view_x
    sta pce_addr_lo
    stz pce_addr_hi
    ldx #$04
@x_shift:
    asl pce_addr_lo
    rol pce_addr_hi
    dex
    bne @x_shift
    lda #VDC_BXR
    ldx pce_addr_lo
    ldy pce_addr_hi
    jsr pce_write_vdc_reg

    ; BYR = view_y * 16 pixels.
    lda game_view_y
    sta pce_addr_lo
    stz pce_addr_hi
    ldx #$04
@y_shift:
    asl pce_addr_lo
    rol pce_addr_hi
    dex
    bne @y_shift
    lda #VDC_BYR
    ldx pce_addr_lo
    ldy pce_addr_hi
    jsr pce_write_vdc_reg
    rts
.endproc

.proc pce_upload_horizontal_edge
    lda game_view_x
    cmp pce_last_view_x
    beq @done
    bcc @left_edge

    clc
    adc #15
    bra @have_x
@left_edge:
    lda game_view_x
@have_x:
    sta pce_obj_x
    lda game_view_y
    sta pce_obj_y
    lda #14
    sta pce_strip_count
@loop:
    jsr pce_upload_object
    inc pce_obj_y
    dec pce_strip_count
    bne @loop
@done:
    rts
.endproc

.proc pce_upload_vertical_edge
    lda game_view_y
    cmp pce_last_view_y
    beq @done
    bcc @top_edge

    clc
    adc #13
    bra @have_y
@top_edge:
    lda game_view_y
@have_y:
    sta pce_obj_y
    lda game_view_x
    sta pce_obj_x
    lda #16
    sta pce_strip_count
@loop:
    jsr pce_upload_object
    inc pce_obj_x
    dec pce_strip_count
    bne @loop
@done:
    rts
.endproc

.proc platform_init
    sei
    csh

    jsr pce_init_vdc_trampoline

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

    ; Initial 32x32 BAT setup while display is disabled.
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
@wait_vblank:
    lda VDC_STATUS
    and #$20
    beq @wait_vblank
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

    ; Direction nibble: d3 Left, d2 Down, d1 Right, d0 Up.
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

    ; Button nibble: d3 Run, d2 Select, d1 II, d0 I.
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

    jsr pce_upload_horizontal_edge
    jsr pce_upload_vertical_edge
    jsr pce_set_scroll

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
    ; Deferred milestone: HuC6280 PSG music and SFX backend.
    rts
.endproc

.segment "RODATA"
.include "../../build/generated/pce/charset.inc"
