.setcpu "HUC6280"

.include "../common/platform.inc"

.import game_cave_render
.import game_player_x
.import game_player_y
.import game_view_x
.import game_view_y
.import game_pad_current
.import game_video_dirty

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

DEBUG_FONT_WORD  = $0C00
DEBUG_BLANK      = $C0
DEBUG_0          = $C1
DEBUG_S          = $D1
DEBUG_P          = $D2
DEBUG_V          = $D3
DEBUG_COMMA      = $D4
DEBUG_F          = $D0
DEBUG_D          = $CE
DEBUG_B          = $CC
DEBUG_A          = $CB
DEBUG_E          = $CF
DEBUG_C          = $CD
DEBUG_GLYPHS     = 21

.segment "ZEROPAGE"
pce_zp_src:   .res 2
pce_font_ptr: .res 2

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
pce_addr_buf:      .res 2
pce_dirty_buf:     .res 4

; Freeze diagnostic state shown in the top two BAT rows.
pce_debug_stage:    .res 1
pce_debug_frame_lo: .res 1
pce_debug_frame_hi: .res 1
pce_debug_status:   .res 1
pce_debug_line:     .res 128
pce_debug_tile_buf: .res 32

.segment "RODATA"
; Compact 8x8 1bpp diagnostic font. Order:
; blank, 0..9, A..F, S, P, V, comma.
pce_debug_font_rows:
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $3C,$66,$6E,$76,$66,$66,$3C,$00
    .byte $18,$38,$18,$18,$18,$18,$3C,$00
    .byte $3C,$66,$06,$0C,$30,$60,$7E,$00
    .byte $3C,$66,$06,$1C,$06,$66,$3C,$00
    .byte $0C,$1C,$2C,$4C,$7E,$0C,$1E,$00
    .byte $7E,$60,$7C,$06,$06,$66,$3C,$00
    .byte $1C,$30,$60,$7C,$66,$66,$3C,$00
    .byte $7E,$66,$06,$0C,$18,$18,$18,$00
    .byte $3C,$66,$66,$3C,$66,$66,$3C,$00
    .byte $3C,$66,$66,$3E,$06,$0C,$38,$00
    .byte $18,$3C,$66,$66,$7E,$66,$66,$00
    .byte $7C,$66,$66,$7C,$66,$66,$7C,$00
    .byte $3C,$66,$60,$60,$60,$66,$3C,$00
    .byte $78,$6C,$66,$66,$66,$6C,$78,$00
    .byte $7E,$60,$60,$7C,$60,$60,$7E,$00
    .byte $7E,$60,$60,$7C,$60,$60,$60,$00
    .byte $3C,$66,$60,$3C,$06,$66,$3C,$00
    .byte $7C,$66,$66,$7C,$60,$60,$60,$00
    .byte $66,$66,$66,$66,$66,$3C,$18,$00
    .byte $00,$00,$00,$00,$00,$18,$18,$30

.segment "CODE"

.proc pce_upload_debug_font
    lda #<pce_debug_font_rows
    sta pce_font_ptr
    lda #>pce_debug_font_rows
    sta pce_font_ptr+1

    st0 #VDC_MAWR
    st1 #<DEBUG_FONT_WORD
    st2 #>DEBUG_FONT_WORD
    st0 #VDC_DATA

    lda #DEBUG_GLYPHS
    sta pce_addr_lo
@glyph:
    ldy #$00
    ldx #$00
@row:
    lda (pce_font_ptr),y
    sta pce_debug_tile_buf,x
    inx
    stz pce_debug_tile_buf,x
    inx
    iny
    cpy #$08
    bne @row

    lda #$00
@clear_hi:
    sta pce_debug_tile_buf,x
    inx
    cpx #$20
    bne @clear_hi

    tia pce_debug_tile_buf, VDC_DATA_L, 32

    clc
    lda pce_font_ptr
    adc #$08
    sta pce_font_ptr
    lda pce_font_ptr+1
    adc #$00
    sta pce_font_ptr+1

    dec pce_addr_lo
    bne @glyph
    rts
.endproc

; A=value, X=byte offset in pce_debug_line. Writes two hexadecimal cells and
; advances X by four bytes.
.proc pce_debug_hex2
    sta pce_addr_hi
    lsr a
    lsr a
    lsr a
    lsr a
    clc
    adc #DEBUG_0
    sta pce_debug_line,x
    inx
    stz pce_debug_line,x
    inx

    lda pce_addr_hi
    and #$0f
    clc
    adc #DEBUG_0
    sta pce_debug_line,x
    inx
    stz pce_debug_line,x
    inx
    rts
.endproc

.proc pce_debug_init_line
    ldx #$00
@row0:
    lda #DEBUG_BLANK
    sta pce_debug_line,x
    inx
    stz pce_debug_line,x
    inx
    cpx #$40
    bne @row0

    ldx #$00
@row1:
    lda #DEBUG_BLANK
    sta pce_debug_line+$40,x
    inx
    stz pce_debug_line+$40,x
    inx
    cpx #$40
    bne @row1

    ; Row 0: Fhhhh Shh Dhh Bhh Phh,hh Vhh,hh
    lda #DEBUG_F
    sta pce_debug_line+0
    lda #DEBUG_S
    sta pce_debug_line+12
    lda #DEBUG_D
    sta pce_debug_line+20
    lda #DEBUG_B
    sta pce_debug_line+28
    lda #DEBUG_P
    sta pce_debug_line+36
    lda #DEBUG_COMMA
    sta pce_debug_line+42
    lda #DEBUG_V
    sta pce_debug_line+50
    lda #DEBUG_COMMA
    sta pce_debug_line+56

    ; Row 1: Ahh Ehh Chh
    lda #DEBUG_A
    sta pce_debug_line+$40+0
    lda #DEBUG_E
    sta pce_debug_line+$40+8
    lda #DEBUG_C
    sta pce_debug_line+$40+16
    rts
.endproc

.proc pce_debug_draw
    ; frame high/low -> cells 1..4
    ldx #$02
    lda pce_debug_frame_hi
    jsr pce_debug_hex2
    lda pce_debug_frame_lo
    jsr pce_debug_hex2

    ; stage -> cells 7..8
    ldx #$0e
    lda pce_debug_stage
    jsr pce_debug_hex2

    ; raw dpad -> cells 11..12
    ldx #$16
    lda pce_raw_dpad
    jsr pce_debug_hex2

    ; raw buttons -> cells 15..16
    ldx #$1e
    lda pce_raw_buttons
    jsr pce_debug_hex2

    ; player x/y
    ldx #$26
    lda game_player_x
    jsr pce_debug_hex2
    ldx #$2c
    lda game_player_y
    jsr pce_debug_hex2

    ; view x/y
    ldx #$34
    lda game_view_x
    jsr pce_debug_hex2
    ldx #$3a
    lda game_view_y
    jsr pce_debug_hex2

    ; Row 1: common pad, last VDC status, dirty flag.
    ldx #($40 + 2)
    lda game_pad_current
    jsr pce_debug_hex2
    ldx #($40 + 10)
    lda pce_debug_status
    jsr pce_debug_hex2
    ldx #($40 + 18)
    lda game_video_dirty
    jsr pce_debug_hex2

    ; Fixed BAT address 0, two rows x 32 cells. The fixed MAWR setup uses the
    ; dedicated HuC6280 VDC instructions; only the already-selected DATA port
    ; receives the bulk TIA transfer.
    st0 #VDC_MAWR
    st1 #$00
    st2 #$00
    st0 #VDC_DATA
    tia pce_debug_line, VDC_DATA_L, 128
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

    stz pce_debug_stage
    stz pce_debug_frame_lo
    stz pce_debug_frame_hi
    stz pce_debug_status
    stz VCE_CTRL

    jsr pce_debug_init_line

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

    jsr pce_upload_debug_font

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

    ; Temporary Cave 1 palette.
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

    lda #$01
    sta pce_debug_stage
    jsr pce_debug_draw

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
    lda #$20
    sta pce_debug_stage
    jsr pce_debug_draw
@wait_vblank:
    lda VDC_STATUS
    sta pce_debug_status
    and #$20
    beq @wait_vblank
    lda #$21
    sta pce_debug_stage
    rts
.endproc

.proc platform_read_pad
    lda #$10
    sta pce_debug_stage

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
    lda #$30
    sta pce_debug_stage
    jsr pce_debug_draw

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

    lda #$31
    sta pce_debug_stage
    bra @remember

@full:
    lda #$40
    sta pce_debug_stage
    jsr pce_debug_draw

    st0 #VDC_CR
    st1 #$08
    st2 #$00
    jsr pce_upload_cave
    jsr pce_debug_draw
    st0 #VDC_CR
    st1 #$88
    st2 #$00

    lda #$41
    sta pce_debug_stage

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
    lda #$45
    sta pce_debug_stage
    rts
.endproc

.proc platform_audio_tick
    inc pce_debug_frame_lo
    bne :+
    inc pce_debug_frame_hi
:
    lda #$50
    sta pce_debug_stage
    jsr pce_debug_draw
    ; Deferred milestone: HuC6280 PSG music and SFX backend.
    rts
.endproc

.segment "RODATA"
.include "../../build/generated/pce/charset.inc"
