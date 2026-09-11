.include "platform.inc"

.export game_autoplay_read
.export game_autoplay_reset

.segment "BSS"
game_autoplay_ptr:       .res 1
game_autoplay_remaining: .res 1
game_autoplay_joy:       .res 1

.segment "CODE"

.proc game_autoplay_reset
    stz game_autoplay_ptr
    stz game_autoplay_remaining
    lda #$0f
    sta game_autoplay_joy
    rts
.endproc

; Return one logical pad level for each cave pass. The generated packet format
; is identical to the C64 demo table: high nibble = duration, low nibble =
; active-low joystick value ($07 right, $0b left, $0d down, $0e up, $0f idle).
.proc game_autoplay_read
    lda game_autoplay_remaining
    bne @have_packet

    ldx game_autoplay_ptr
    lda game_autoplay_packets,x
    beq @idle
    inc game_autoplay_ptr
    pha
    and #$0f
    sta game_autoplay_joy
    pla
    lsr a
    lsr a
    lsr a
    lsr a
    sta game_autoplay_remaining

@have_packet:
    dec game_autoplay_remaining
    lda game_autoplay_joy
    cmp #$07
    bne @left
    lda #PAD_RIGHT
    rts
@left:
    cmp #$0b
    bne @down
    lda #PAD_LEFT
    rts
@down:
    cmp #$0d
    bne @up
    lda #PAD_DOWN
    rts
@up:
    cmp #$0e
    bne @idle
    lda #PAD_UP
    rts
@idle:
    lda #$00
    rts
.endproc

.segment "RODATA"
.include "../../build/generated/common/autoplay.inc"
