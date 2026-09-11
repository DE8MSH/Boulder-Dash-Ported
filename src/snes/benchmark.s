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
OVERLAY_VRAM   = $1019       ; five digits + MS at columns 25..31

.segment "BSS"
bench_ms_lo:  .res 1
bench_ms_hi:  .res 1
bench_tmp_lo: .res 1
bench_tmp_hi: .res 1
bench_div_lo: .res 1
bench_div_hi: .res 1
bench_digit:  .res 1

.segment "CODE"

.proc platform_benchmark_reset
    stz bench_ms_lo
    stz bench_ms_hi
    rts
.endproc

.proc platform_benchmark_tick
    ; The ROM header declares Europe/PAL. platform_wait_frame synchronizes to
    ; one SNES VBlank, so elapsed wall time is approximately 20 ms per tick.
    clc
    lda bench_ms_lo
    adc #20
    sta bench_ms_lo
    lda bench_ms_hi
    adc #0
    sta bench_ms_hi
    rts
.endproc

.proc platform_benchmark_show
    ; Shared progress may call this outside VBlank. Actual SNES VRAM writes
    ; are deferred to snes_benchmark_draw from platform_video_begin.
    rts
.endproc

.proc snes_put_digit
    clc
    adc #FONT_TILE_BASE
    sta VMDATAL
    stz VMDATAH
    rts
.endproc

; Subtract the 16-bit divisor from bench_tmp while possible.
; Returns one decimal digit in A and leaves the remainder in bench_tmp.
.proc snes_extract_digit
    sta bench_div_lo
    stx bench_div_hi
    stz bench_digit
@again:
    lda bench_tmp_hi
    cmp bench_div_hi
    bcc @done
    bne @subtract
    lda bench_tmp_lo
    cmp bench_div_lo
    bcc @done
@subtract:
    sec
    lda bench_tmp_lo
    sbc bench_div_lo
    sta bench_tmp_lo
    lda bench_tmp_hi
    sbc bench_div_hi
    sta bench_tmp_hi
    inc bench_digit
    bra @again
@done:
    lda bench_digit
    rts
.endproc

.proc snes_benchmark_draw
    lda #$80
    sta VMAIN
    lda #<OVERLAY_VRAM
    sta VMADDL
    lda #>OVERLAY_VRAM
    sta VMADDH

    lda bench_ms_lo
    sta bench_tmp_lo
    lda bench_ms_hi
    sta bench_tmp_hi

    ; Render the complete 16-bit millisecond value as five decimal digits.
    lda #<10000
    ldx #>10000
    jsr snes_extract_digit
    jsr snes_put_digit

    lda #<1000
    ldx #>1000
    jsr snes_extract_digit
    jsr snes_put_digit

    lda #<100
    ldx #>100
    jsr snes_extract_digit
    jsr snes_put_digit

    lda #10
    ldx #0
    jsr snes_extract_digit
    jsr snes_put_digit

    lda bench_tmp_lo
    jsr snes_put_digit

    lda #FONT_M_TILE
    sta VMDATAL
    stz VMDATAH
    lda #FONT_S_TILE
    sta VMDATAL
    stz VMDATAH
    rts
.endproc
