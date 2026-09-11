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
OVERLAY_BAT    = 25          ; BAT row 0, column 25

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
    ; The current build uses HuC6280 timer reload $7f. At ~6.99 kHz this is
    ; about 18.31 ms per host tick. Use 18 ms + 79/256 ms fractional carry.
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
