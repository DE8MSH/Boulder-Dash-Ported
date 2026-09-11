.setcpu "65816"

.include "../common/platform.inc"

.segment "CODE"

; Smoke-test platform backend. Hardware setup is added in the next milestone.
.proc platform_init
    sei
    clc
    xce             ; enter native 65C816 mode
    rep #$30        ; 16-bit A/X/Y while establishing a known state
    sep #$20        ; API byte return values use 8-bit A
    rts
.endproc

.proc platform_wait_frame
    ; TODO: wait for/consume SNES NMI frame flag.
    rts
.endproc

.proc platform_read_pad
    ; TODO: map JOY1 data to PAD_* bits.
    lda #$00
    rts
.endproc

.proc platform_video_begin
    ; TODO: prepare buffered VRAM/OAM/CGRAM updates.
    rts
.endproc

.proc platform_video_end
    ; TODO: publish updates for NMI/DMA.
    rts
.endproc

.proc platform_audio_tick
    ; TODO: communicate music/SFX commands to the SPC700 driver.
    rts
.endproc
