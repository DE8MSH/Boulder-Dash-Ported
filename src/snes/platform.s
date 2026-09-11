.setcpu "65816"

.include "../common/platform.inc"

; SNES CPU / PPU registers used by the first porting stage.
INIDISP  = $2100
BGMODE   = $2105
TM       = $212C
TS       = $212D
CGADD    = $2121
CGDATA   = $2122
SETINI   = $2133
NMITIMEN = $4200
HVBJOY   = $4212
JOY1H    = $4219

.segment "BSS"
pad_result: .res 1

.segment "CODE"

.proc platform_init
    sei
    clc
    xce                 ; enter native 65C816 mode

    ; Keep the porting core deliberately 6502-like: 8-bit A/X/Y and DP=$0000.
    rep #$20
    lda #$0000
    tcd
    sep #$30

    ; Force blank while touching PPU state.
    lda #$80
    sta INIDISP

    ; Minimal deterministic PPU state. No BG/OBJ layers yet; color 0 is the
    ; visible backdrop. Mode 1 is selected now because Boulder Dash will use
    ; tile backgrounds in the next milestone.
    lda #$01
    sta BGMODE
    stz TM
    stz TS
    stz SETINI

    ; CGRAM color 0: dark blue (BGR555 = $3000).
    stz CGADD
    lda #$00
    sta CGDATA
    lda #$30
    sta CGDATA

    ; Auto joypad read on, NMI/IRQ still off for this polling bootstrap.
    lda #%00000001
    sta NMITIMEN

    ; Leave forced blank only during VBlank to avoid display glitches.
@wait_vblank:
    lda HVBJOY
    bpl @wait_vblank
    lda #$0f            ; display on, full brightness
    sta INIDISP
    rts
.endproc

.proc platform_wait_frame
    ; Poll one complete frame edge. This intentionally avoids requiring a
    ; vector/NMI setup while the port is still in bootstrap form.
@leave_vblank:
    lda HVBJOY
    bmi @leave_vblank
@enter_vblank:
    lda HVBJOY
    bpl @enter_vblank
@wait_autojoy:
    lda HVBJOY
    and #$01            ; auto-joypad read busy
    bne @wait_autojoy
    rts
.endproc

.proc platform_read_pad
    ; After auto-read, JOY1H contains the useful SNES pad bits:
    ; bit 7 B, 6 Y, 5 Select, 4 Start, 3 Up, 2 Down, 1 Left, 0 Right.
    stz pad_result

    lda JOY1H
    and #%00000010
    beq :+
    lda pad_result
    ora #PAD_LEFT
    sta pad_result
:
    lda JOY1H
    and #%00000001
    beq :+
    lda pad_result
    ora #PAD_RIGHT
    sta pad_result
:
    lda JOY1H
    and #%00001000
    beq :+
    lda pad_result
    ora #PAD_UP
    sta pad_result
:
    lda JOY1H
    and #%00000100
    beq :+
    lda pad_result
    ora #PAD_DOWN
    sta pad_result
:
    lda JOY1H
    and #%10000000      ; B = Boulder Dash fire/action
    beq :+
    lda pad_result
    ora #PAD_FIRE
    sta pad_result
:
    lda JOY1H
    and #%00010000
    beq :+
    lda pad_result
    ora #PAD_START
    sta pad_result
:
    lda JOY1H
    and #%00100000
    beq :+
    lda pad_result
    ora #PAD_SELECT
    sta pad_result
:
    lda pad_result
    rts
.endproc

.proc platform_video_begin
    ; Buffered VRAM/OAM/CGRAM uploads are added with converted C64 character
    ; data. The visible backdrop already proves PPU initialization works.
    rts
.endproc

.proc platform_video_end
    rts
.endproc

.proc platform_audio_tick
    ; Deferred milestone: SPC700/DSP music and SFX backend.
    ; Keep the ABI entry point so audio cannot disappear from the plan.
    rts
.endproc
