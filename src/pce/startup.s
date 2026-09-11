.setcpu "HUC6280"

.import game_init
.import game_tick

.segment "STARTUP"

.proc reset
    sei
    csh

    ; Map hardware I/O into page $0000-$1FFF and 8 KiB work RAM into
    ; page $2000-$3FFF. The HuC6280 zero page and stack then live in RAM.
    lda #$FF
    tam #$01
    lda #$F8
    tam #$02

    ldx #$FF
    txs

    jsr game_init

@main:
    jsr game_tick
    jmp @main
.endproc

.proc default_irq
    rti
.endproc

.segment "VECTORS"
    .word default_irq           ; $FFF6 IRQ2 / BRK
    .word default_irq           ; $FFF8 IRQ1 / VDC
    .word default_irq           ; $FFFA timer
    .word default_irq           ; $FFFC NMI
    .word reset                 ; $FFFE reset
