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
OVERLAY_VRAM   = $1019

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
    ; NTSC SNES frame ~= 16.639 ms.
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
