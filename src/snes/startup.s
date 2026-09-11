.setcpu "65816"

.import game_init
.import game_tick

.segment "STARTUP"

.proc reset
    sei
    clc
    xce

    rep #$30
    .a16
    .i16

    lda #$0000
    tcd
    ldx #$1FFF
    txs

    sep #$30
    .a8
    .i8

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
    .byte $07                   ; 128 KiB ROM (four 32 KiB LoROM banks)
    .byte $00                   ; no SRAM
    .byte $02                   ; Europe/PAL region code
    .byte $00                   ; licensee
    .byte $00                   ; version
    .word $FFFF                 ; checksum complement (placeholder)
    .word $0000                 ; checksum (placeholder)

.segment "VECTORS"
    .word $0000
    .word $0000
    .word default_irq
    .word default_irq
    .word default_irq
    .word default_irq
    .word $0000
    .word default_irq

    .word $0000
    .word $0000
    .word default_irq
    .word $0000
    .word default_irq
    .word default_irq
    .word reset
    .word default_irq

; Keep the fourth LoROM bank physically present as reserved expansion space.
.segment "ROM3_FILL"
    .byte $00
