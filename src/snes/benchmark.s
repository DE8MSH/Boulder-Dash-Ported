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
bench_frac:  .res 1
bench_ms_lo: .res 1
bench_ms_hi: .res 1
bench_tmp_lo:.res 1
bench_tmp_hi:.res 1
bench_digit: .res 1

.segment "CODE"

.proc platform_benchmark_reset
    stz bench_frac
    stz bench_ms_lo
    stz bench_ms_hi
    rts
.endproc

.proc platform_benchmark_tick
    ; NTSC SNES frame ~= 16.639 ms. Keep elapsed time as a plain binary
    ; millisecond counter. Avoid CPU decimal mode entirely: it made the
    ; on-screen benchmark dependent on processor-state details unrelated to
    ; gameplay timing.
    clc
    lda bench_frac
    adc #164
    sta bench_frac
    lda #16
    bcc :+
    lda #17
:
    clc
    adc bench_ms_lo
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

; Subtract the 16-bit constant in A(low)/X(high) from bench_tmp while possible.
; Returns the decimal digit in A and leaves the remainder in bench_tmp.
.proc snes_extract_digit
    sta @sub_lo+1
    stx @sub_hi+1
    stz bench_digit
@again:
    lda bench_tmp_hi
    cmp @sub_hi+1
    bcc @done
    bne @subtract
    lda bench_tmp_lo
    cmp @sub_lo+1
    bcc @done
@subtract:
    sec
    lda bench_tmp_lo
@sub_lo:
    sbc #$00
    sta bench_tmp_lo
    lda bench_tmp_hi
@sub_hi:
    sbc #$00
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

    ; Convert the frozen 16-bit millisecond count to five decimal digits.
    ; Maximum displayed value is 65535 ms, more than enough for Cave 1.
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
