.setcpu "HUC6280"

.include "../common/platform.inc"

.segment "CODE"

; Smoke-test platform backend. Hardware setup is added in the next milestone.
.proc platform_init
    sei
    csh             ; high-speed CPU mode
    rts
.endproc

.proc platform_wait_frame
    ; TODO: wait for/consume VDC VBlank IRQ frame flag.
    rts
.endproc

.proc platform_read_pad
    ; TODO: read the PC Engine joypad port and map to PAD_* bits.
    lda #$00
    rts
.endproc

.proc platform_video_begin
    ; TODO: prepare BAT/pattern/palette updates.
    rts
.endproc

.proc platform_video_end
    ; TODO: publish VDC/VCE updates during VBlank.
    rts
.endproc

.proc platform_audio_tick
    ; TODO: update HuC6280 PSG music/SFX state.
    rts
.endproc
