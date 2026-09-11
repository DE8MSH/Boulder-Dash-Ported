.include "platform.inc"

.export game_init
.export game_tick
.export game_pad_current
.export game_pad_previous
.export game_pad_pressed

.segment "BSS"
game_pad_current:  .res 1
game_pad_previous: .res 1
game_pad_pressed:  .res 1

.segment "CODE"

; First hardware-neutral entry point. Original cave/game routines will be
; migrated behind this boundary one subsystem at a time.
.proc game_init
    lda #$00
    sta game_pad_current
    sta game_pad_previous
    sta game_pad_pressed
    jsr platform_init
    rts
.endproc

.proc game_tick
    jsr platform_wait_frame

    lda game_pad_current
    sta game_pad_previous

    jsr platform_read_pad
    sta game_pad_current

    ; Newly pressed buttons = current & ~previous.
    lda game_pad_previous
    eor #$ff
    and game_pad_current
    sta game_pad_pressed

    jsr platform_video_begin

    ; TODO PORT CORE:
    ;   cave tick
    ;   Rockford/player update
    ;   falling boulders/diamonds
    ;   enemies/amoeba/magic wall
    ;   score/time state
    ; These calls will be extracted from BoulderDashI.asm while preserving
    ; original update order and 8-bit wrap behaviour.

    jsr platform_video_end

    ; Intentionally retained although currently a no-op on both targets.
    ; Audio is deferred, not forgotten.
    jsr platform_audio_tick
    rts
.endproc
