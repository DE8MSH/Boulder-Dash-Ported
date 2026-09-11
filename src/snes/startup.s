.setcpu "65816"

.import game_init
.import game_tick

.segment "STARTUP"

.proc reset
    sei
    clc
    xce

    ; Enter a known native-mode state. X/Y must be 16-bit before loading
    ; the 16-bit stack pointer value, otherwise ca65 treats #$1FFF as an
    ; 8-bit immediate and correctly reports a range error.
    rep #$30
    lda #$0000
    tcd
    ldx #$1FFF
    txs

    ; Keep the shared game core deliberately 6502-like after startup.
    sep #$30

    jsr game_init

@main:
    jsr game_tick
    bra @main
.endproc

.proc default_irq
    rti
.endproc

.segment "HEADER"
    .byte "BOULDER DASH PORT    " ; 21 bytes
    .byte $20                   ; LoROM, slow ROM
    .byte $00                   ; ROM only
    .byte $05                   ; 32 KiB ROM
    .byte $00                   ; no SRAM
    .byte $02                   ; Europe/PAL region code
    .byte $00                   ; licensee
    .byte $00                   ; version
    .word $FFFF                 ; checksum complement (placeholder)
    .word $0000                 ; checksum (placeholder)

.segment "VECTORS"
    ; Native mode vectors ($FFE0-$FFEF)
    .word $0000
    .word $0000
    .word default_irq           ; COP
    .word default_irq           ; BRK
    .word default_irq           ; ABORT
    .word default_irq           ; NMI
    .word $0000                 ; reserved
    .word default_irq           ; IRQ

    ; Emulation mode vectors ($FFF0-$FFFF)
    .word $0000
    .word $0000
    .word default_irq           ; COP
    .word $0000                 ; reserved
    .word default_irq           ; ABORT
    .word default_irq           ; NMI
    .word reset                 ; RESET
    .word default_irq           ; IRQ/BRK
