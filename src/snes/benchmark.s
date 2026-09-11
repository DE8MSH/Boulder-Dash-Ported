.setcpu "65816"
.a8
.i8

.export platform_benchmark_reset
.export platform_benchmark_tick
.export platform_benchmark_show

VMAIN   = $2115
VMADDL  = $2116
VMADDH  = $2117
VMDATAL = $2118
VMDATAH = $2119

FONT_TILE_BASE = $b0
FONT_M_TILE    = $ba
FONT_S_TILE    = $bb
FONT_VRAM      = $0b00
OVERLAY_VRAM   = $1019
FONT_BYTES     = 384

.segment "BSS"
bench_frac:  .res 1
bench_count: .res 1
bench_d0:    .res 1
bench_d1:    .res 1
bench_d2:    .res 1
bench_d3:    .res 1
bench_d4:    .res 1

.segment "CODE"

.proc platform_benchmark_reset
    stz bench_frac
    stz bench_d0
    stz bench_d1
    stz bench_d2
    stz bench_d3
    stz bench_d4

    lda #$80
    sta VMAIN
    lda #<FONT_VRAM
    sta VMADDL
    lda #>FONT_VRAM
    sta VMADDH
    rep #$10
    .i16
    ldx #0
@font:
    lda benchmark_font,x
    sta VMDATAL
    inx
    lda benchmark_font,x
    sta VMDATAH
    inx
    cpx #FONT_BYTES
    bne @font
    sep #$10
    .i8
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
    lda #16
    sta bench_count
    clc
    lda bench_frac
    adc #164
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
    lda #$80
    sta VMAIN
    lda #<OVERLAY_VRAM
    sta VMADDL
    lda #>OVERLAY_VRAM
    sta VMADDH
    ldx #0
@digits:
    lda bench_d0,x
    clc
    adc #FONT_TILE_BASE
    sta VMDATAL
    stz VMDATAH
    inx
    cpx #5
    bne @digits
    lda #FONT_M_TILE
    sta VMDATAL
    stz VMDATAH
    lda #FONT_S_TILE
    sta VMDATAL
    stz VMDATAH
    rts
.endproc

.segment "RODATA"
benchmark_font:
    .byte $3c,$00,$c3,$00,$c3,$00,$c3,$00,$c3,$00,$c3,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $0c,$00,$3c,$00,$0c,$00,$0c,$00,$0c,$00,$0c,$00,$3f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $3c,$00,$c3,$00,$03,$00,$0c,$00,$30,$00,$c0,$00,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $fc,$00,$03,$00,$03,$00,$3c,$00,$03,$00,$03,$00,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $03,$00,$0f,$00,$33,$00,$c3,$00,$ff,$00,$03,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $ff,$00,$c0,$00,$c0,$00,$fc,$00,$03,$00,$03,$00,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $3f,$00,$c0,$00,$c0,$00,$fc,$00,$c3,$00,$c3,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $ff,$00,$03,$00,$0c,$00,$0c,$00,$30,$00,$30,$00,$30,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $3c,$00,$c3,$00,$c3,$00,$3c,$00,$c3,$00,$c3,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $3c,$00,$c3,$00,$c3,$00,$3f,$00,$03,$00,$03,$00,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $c3,$00,$ff,$00,$ff,$00,$c3,$00,$c3,$00,$c3,$00,$c3,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $3f,$00,$c0,$00,$c0,$00,$3c,$00,$03,$00,$03,$00,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
