.setcpu "HUC6280"

.export platform_benchmark_reset
.export platform_benchmark_tick
.export platform_benchmark_show

VDC_DATA_L = $0002
VDC_MAWR   = $00
VDC_DATA   = $02

FONT_TILE_BASE = $b0
FONT_M_TILE    = $ba
FONT_S_TILE    = $bb
FONT_VRAM      = $0b00
FONT_BYTES     = 384
OVERLAY_BAT    = 25

.segment "BSS"
bench_frac:    .res 1
bench_count:   .res 1
bench_d0:      .res 1
bench_d1:      .res 1
bench_d2:      .res 1
bench_d3:      .res 1
bench_d4:      .res 1
bench_overlay: .res 14

.segment "CODE"

.proc platform_benchmark_reset
    stz bench_frac
    stz bench_d0
    stz bench_d1
    stz bench_d2
    stz bench_d3
    stz bench_d4

    st0 #VDC_MAWR
    st1 #<FONT_VRAM
    st2 #>FONT_VRAM
    st0 #VDC_DATA
    tia benchmark_font, VDC_DATA_L, FONT_BYTES
    rts
.endproc

.proc bench_add_one_ms
    inc bench_d4
    lda bench_d4
    cmp #10
    bcc @done
    stz bench_d4
    inc bench_d3
    lda bench_d3
    cmp #10
    bcc @done
    stz bench_d3
    inc bench_d2
    lda bench_d2
    cmp #10
    bcc @done
    stz bench_d2
    inc bench_d1
    lda bench_d1
    cmp #10
    bcc @done
    stz bench_d1
    inc bench_d0
    lda bench_d0
    cmp #10
    bcc @done
    stz bench_d0
@done:
    rts
.endproc

.proc platform_benchmark_tick
    lda #18
    sta bench_count
    clc
    lda bench_frac
    adc #79
    sta bench_frac
    bcc @add
    inc bench_count
@add:
    jsr bench_add_one_ms
    dec bench_count
    bne @add
    rts
.endproc

.proc platform_benchmark_show
    ldx #0
    ldy #0
@digits:
    lda bench_d0,x
    clc
    adc #FONT_TILE_BASE
    sta bench_overlay,y
    iny
    lda #0
    sta bench_overlay,y
    iny
    inx
    cpx #5
    bne @digits
    lda #FONT_M_TILE
    sta bench_overlay,y
    iny
    lda #0
    sta bench_overlay,y
    iny
    lda #FONT_S_TILE
    sta bench_overlay,y
    iny
    lda #0
    sta bench_overlay,y

    st0 #VDC_MAWR
    st1 #<OVERLAY_BAT
    st2 #>OVERLAY_BAT
    st0 #VDC_DATA
    tia bench_overlay, VDC_DATA_L, 14
    rts
.endproc

.segment "RODATA"
benchmark_font:
    .byte $3c,$00,$c3,$00,$c3,$00,$c3,$00,$c3,$00,$c3,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $0c,$00,$3c,$00,$0c,$00,$0c,$00,$0c,$00,$0c,$00,$3f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $3c,$00,$c3,$00,$03,$00,$0c,$00,$30,$00,$c0,$00,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $fc,$00,$03,$00,$03,$00,$3c,$00,$03,$00,$03,$00,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $03,$00,$0f,$00,$33,$00,$c3,$00,$ff,$00,$03,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $ff,$00,$c0,$00,$c0,$00,$fc,$00,$03,$00,$03,$00,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $3f,$00,$c0,$00,$c0,$00,$fc,$00,$c3,$00,$c3,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $ff,$00,$03,$00,$0c,$00,$0c,$00,$30,$00,$30,$00,$30,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $3c,$00,$c3,$00,$c3,$00,$3c,$00,$c3,$00,$c3,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $3c,$00,$c3,$00,$c3,$00,$3f,$00,$03,$00,$03,$00,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $c3,$00,$ff,$00,$ff,$00,$c3,$00,$c3,$00,$c3,$00,$c3,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $3f,$00,$c0,$00,$c0,$00,$3c,$00,$03,$00,$03,$00,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
