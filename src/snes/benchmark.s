.setcpu "65816"
.a8
.i8

.export platform_benchmark_reset
.export platform_benchmark_tick
.export platform_benchmark_show
.export snes_benchmark_draw

VMAIN   = $2115
VMADDL  = $2116
VMADDH  = $2117
VMDATAL = $2118
VMDATAH = $2119

; Charset slots $02-$0d are unused by every 2x2 cave tile quadrant.
; The charset is uploaded beginning at hardware tile $40.
FONT_TILE_BASE = $42
FONT_M_TILE    = $4c
FONT_S_TILE    = $4d
OVERLAY_VRAM   = $1019

.segment "BSS"
bench_frac: .res 1
bench_bcd0: .res 1        ; tens : units
bench_bcd1: .res 1        ; thousands : hundreds
bench_bcd2: .res 1        ; hundred-thousands : ten-thousands

.segment "CODE"

.proc platform_benchmark_reset
    stz bench_frac
    stz bench_bcd0
    stz bench_bcd1
    stz bench_bcd2
    rts
.endproc

.proc platform_benchmark_tick
    ; NTSC SNES frame ~= 16.639 ms.
    clc
    lda bench_frac
    adc #164
    sta bench_frac
    lda #$16
    bcc :+
    lda #$17
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
    rts
.endproc

.proc snes_put_digit
    clc
    adc #FONT_TILE_BASE
    sta VMDATAL
    stz VMDATAH
    rts
.endproc

.proc snes_benchmark_draw
    lda #$80
    sta VMAIN
    lda #<OVERLAY_VRAM
    sta VMADDL
    lda #>OVERLAY_VRAM
    sta VMADDH

    lda bench_bcd2
    and #$0f
    jsr snes_put_digit

    lda bench_bcd1
    lsr a
    lsr a
    lsr a
    lsr a
    jsr snes_put_digit

    lda bench_bcd1
    and #$0f
    jsr snes_put_digit

    lda bench_bcd0
    lsr a
    lsr a
    lsr a
    lsr a
    jsr snes_put_digit

    lda bench_bcd0
    and #$0f
    jsr snes_put_digit

    lda #FONT_M_TILE
    sta VMDATAL
    stz VMDATAH
    lda #FONT_S_TILE
    sta VMDATAL
    stz VMDATAH
    rts
.endproc
