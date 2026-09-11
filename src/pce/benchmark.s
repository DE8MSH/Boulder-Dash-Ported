.setcpu "HUC6280"

.export platform_benchmark_reset
.export platform_benchmark_tick
.export platform_benchmark_show

VDC_DATA_L = $0002
VDC_MAWR   = $00
VDC_DATA   = $02

; Charset slots $70-$7b are uploaded beginning at hardware tile $40.
FONT_TILE_BASE = $b0
FONT_M_TILE    = $ba
FONT_S_TILE    = $bb
OVERLAY_BAT    = 25

.segment "BSS"
bench_frac:    .res 1
bench_bcd0:    .res 1        ; tens : units
bench_bcd1:    .res 1        ; thousands : hundreds
bench_bcd2:    .res 1        ; hundred-thousands : ten-thousands
bench_overlay: .res 14

.segment "CODE"

.proc platform_benchmark_reset
    stz bench_frac
    stz bench_bcd0
    stz bench_bcd1
    stz bench_bcd2
    rts
.endproc

.proc platform_benchmark_tick
    ; Current HuC6280 timer pacing is about 18.31 ms per host tick.
    ; Keep the fractional .31 ms in binary, then add either 18 or 19 ms to
    ; a packed-BCD millisecond counter.
    clc
    lda bench_frac
    adc #79
    sta bench_frac
    lda #$18
    bcc :+
    lda #$19
:
    sed
    clc
    adc bench_bcd0
    sta bench_bcd0
    lda bench_bcd1
    adc #0
    sta bench_bcd1
    lda bench_bcd2
    adc #0
    sta bench_bcd2
    cld
    rts
.endproc

.proc platform_benchmark_show
    ; Render five decimal digits from packed BCD: d4 d3 d2 d1 d0.
    ldy #0

    lda bench_bcd2
    and #$0f
    jsr @put_digit

    lda bench_bcd1
    lsr a
    lsr a
    lsr a
    lsr a
    jsr @put_digit

    lda bench_bcd1
    and #$0f
    jsr @put_digit

    lda bench_bcd0
    lsr a
    lsr a
    lsr a
    lsr a
    jsr @put_digit

    lda bench_bcd0
    and #$0f
    jsr @put_digit

    lda #FONT_M_TILE
    jsr @put_tile
    lda #FONT_S_TILE
    jsr @put_tile

    st0 #VDC_MAWR
    st1 #<OVERLAY_BAT
    st2 #>OVERLAY_BAT
    st0 #VDC_DATA
    tia bench_overlay, VDC_DATA_L, 14
    rts

@put_digit:
    clc
    adc #FONT_TILE_BASE
@put_tile:
    sta bench_overlay,y
    iny
    lda #0
    sta bench_overlay,y
    iny
    rts
.endproc
