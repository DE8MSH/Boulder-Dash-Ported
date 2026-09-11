.setcpu "HUC6280"

.include "../common/platform.inc"

; HuC6280 I/O mapping assumes the hardware page is mapped at $0000-$1fff.
JOYPAD = $1000

.segment "BSS"
pad_result: .res 1
pce_raw_dpad: .res 1
pce_raw_buttons: .res 1

.segment "CODE"

.proc platform_init
    sei
    csh                 ; high-speed HuC6280 mode

    ; Reset the controller/multitap scan state, then leave SEL high.
    lda #$03            ; CLR=1, SEL=1
    sta JOYPAD
    lda #$01            ; CLR=0, SEL=1
    sta JOYPAD
    rts
.endproc

.proc platform_wait_frame
    ; VDC VBlank synchronization is the next hardware step. Until the VDC
    ; init/vector code is linked into a real ROM, do not fake a timing source.
    rts
.endproc

.proc platform_read_pad
    ; Standard two-button PCE pad, active low:
    ; SEL=1: d3..d0 = Left, Right, Down, Up
    ; SEL=0: d3..d0 = Run, Select, II, I
    lda #$01
    sta JOYPAD
    nop
    nop
    lda JOYPAD
    and #$0f
    eor #$0f
    sta pce_raw_dpad

    stz JOYPAD
    nop
    nop
    lda JOYPAD
    and #$0f
    eor #$0f
    sta pce_raw_buttons

    stz pad_result

    lda pce_raw_dpad
    and #%00001000
    beq :+
    lda pad_result
    ora #PAD_LEFT
    sta pad_result
:
    lda pce_raw_dpad
    and #%00000100
    beq :+
    lda pad_result
    ora #PAD_RIGHT
    sta pad_result
:
    lda pce_raw_dpad
    and #%00000001
    beq :+
    lda pad_result
    ora #PAD_UP
    sta pad_result
:
    lda pce_raw_dpad
    and #%00000010
    beq :+
    lda pad_result
    ora #PAD_DOWN
    sta pad_result
:
    lda pce_raw_buttons
    and #%00000001      ; I = Boulder Dash fire/action
    beq :+
    lda pad_result
    ora #PAD_FIRE
    sta pad_result
:
    lda pce_raw_buttons
    and #%00001000      ; Run
    beq :+
    lda pad_result
    ora #PAD_START
    sta pad_result
:
    lda pce_raw_buttons
    and #%00000100      ; Select
    beq :+
    lda pad_result
    ora #PAD_SELECT
    sta pad_result
:
    lda pad_result
    rts
.endproc

.proc platform_video_begin
    ; BAT/pattern/palette update queue comes after VDC initialization.
    rts
.endproc

.proc platform_video_end
    rts
.endproc

.proc platform_audio_tick
    ; Deferred milestone: HuC6280 PSG music and SFX backend.
    ; Keep the ABI entry point so audio cannot disappear from the plan.
    rts
.endproc
