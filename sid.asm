; ------------------------------------------------------------------------------------------------------------- ;
; Sound Interface Device (SID) Registers - $D400-$D41C
; ------------------------------------------------------------------------------------------------------------- ;
SID     = $D400 ;
;
FRELO1  = $D400 ; Oscillator 1 Frequency Control (low byte)       : Convert freq ctrl to actual freq -

FREHI1  = $D401 ; Oscillator 1 Frequency Control (high byte)      : FREQUENCY   = REGISTER VALUE *.060959458 Hz

PWLO1   = $D402 ; Oscillator 1 Pulse Waveform Width (low byte)    : PULSE WIDTH = (REGISTER VALUE /40.95) %

PWHI1   = $D403 ; Oscillator 1 Pulse Waveform Width (high nybble) : PULSE WIDTH = (REGISTER VALUE /40.95) %

VCREG1  = $D404 ; Oscillator 1 Control
                ;   Bit 0: Gate Bit:        1=Start attack/decay/sustain, 0=Start release
                ;   Bit 1: Sync Bit:        1=Synchronize Oscillator with Oscillator 3 frequency
                ;   Bit 2: Ring Modulation: 1=Ring modulate Oscillators 1 and 3
                ;   Bit 3: Test Bit:        1=Lock Oscillator 1
                ;   Bit 4: Select triangle     waveform - only one possible at any time - no mixing
                ;   Bit 5: Select sawtooth     waveform
                ;   Bit 6: Select pulse        waveform
                ;   Bit 7: Select random noise waveform

ATDCY1  = $D405 ; Oscillator 1 Attack/Decay Register : REGISTER VALUE= (ATTACK * 16) + DECAY
                ; Bits 0-3: Select decay cycle duration (0-15)
                ;   0 = 6   milliseconds   8 = 300 milliseconds
                ;   1 = 24  milliseconds   9 = 750 milliseconds
                ;   2 = 48  milliseconds  10 = 1.5 seconds
                ;   3 = 72  milliseconds  11 = 2.4 seconds
                ;   4 = 114 milliseconds  12 = 3 seconds
                ;   5 = 168 milliseconds  13 = 9 seconds
                ;   6 = 204 milliseconds  14 = 15 seconds
                ;   7 = 240 milliseconds  15 = 24 seconds
                ; Bits 4-7: Select attack cycle duration (0-15)
                ;   0 = 2  milliseconds    8 = 100 milliseconds
                ;   1 = 8  milliseconds    9 = 250 milliseconds
                ;   2 = 16 milliseconds   10 = 500 milliseconds
                ;   3 = 24 milliseconds   11 = 800 milliseconds
                ;   4 = 38 milliseconds   12 = 1 second
                ;   5 = 56 milliseconds   13 = 3 seconds
                ;   6 = 68 milliseconds   14 = 5 seconds
                ;   7 = 80 milliseconds   15 = 8 seconds

SUREL1  = $D406 ; Oscillator 1 Sustain/Release Control Register
                ; Bits 0-3: Select release cycle duration (0-15)
                ;   0 = 6   milliseconds   8 = 300 milliseconds
                ;   1 = 24  milliseconds   9 = 750 milliseconds
                ;   2 = 48  milliseconds  10 = 1.5 seconds
                ;   3 = 72  milliseconds  11 = 2.4 seconds
                ;   4 = 114 milliseconds  12 = 3 seconds
                ;   5 = 168 milliseconds  13 = 9 seconds
                ;   6 = 204 milliseconds  14 = 15 seconds
                ;   7 = 240 milliseconds  15 = 24 seconds
                ; Bits 4-7: Select sustain volume level   (0-15)

FRELO2  = $D407 ; Oscillator 2 Frequency Control (low byte)

FREHI2  = $D408 ; Oscillator 2 Frequency Control (high byte)

PWLO2   = $D409 ; Oscillator 2 Pulse Waveform Width (low byte)

PWHI2   = $D40A ; Oscillator 2 Pulse Waveform Width (high nybble)

VCREG2  = $D40B ; Oscillator 2 Control
                ;   Bit 0: Gate Bit:          1=Start attack/decay/sustain, 0=Start release
                ;   Bit 1: Sync Bit:          1=Synchronize oscillator with Oscillator 1 frequency
                ;   Bit 2: Ring Modulation:   1=Ring modulate Oscillators 2 and 1
                ;   Bit 3: Test Bit:          1=Disable Oscillator 2
                ;   Bit 4: Select triangle     waveform - only one possible at any time - no mixing
                ;   Bit 5: Select sawtooth     waveform
                ;   Bit 6: Select pulse        waveform
                ;   Bit 7: Select random noise waveform

ATDCY2  = $D40C ; Oscillator 2 Attack/Decay Register
                ;   Bits 0-3: Select decay cycle duration   (0-15)
                ;   Bits 4-7: Select attack cycle duration  (0-15)

SUREL2  = $D40D ; Oscillator 2 Sustain/Release Control Register
                ;   Bits 0-3:  Select release cycle duration (0-15)
                ;   Bits 4-7:  Select sustain volume level (0-15)

FRELO3  = $D40E ; Oscillator 3 Frequency Control (low byte)

FREHI3  = $D40F ; Oscillator 3 Frequency Control (high byte)

PWLO3   = $D410 ; Oscillator 3 Pulse Waveform Width (low byte)

PWHI3   = $D411 ; Oscillator 3 Pulse Waveform Width (high nybble)

VCREG3  = $D412 ; Oscillator 3 Control
                ;   Bit 0: Gate Bit:        1=Start attack/decay/sustain, 0=Start release
                ;   Bit 1: Sync Bit:        1=Synchronize oscillator with Oscillator 2 frequency
                ;   Bit 2: Ring Modulation: 1=Ring modulate Oscillators 3 and 2
                ;   Bit 3: Test Bit:        1=Disable Oscillator 3
                ;   Bit 4: Select triangle     waveform - only one possible at any time - no mixing
                ;   Bit 5: Select sawtooth     waveform
                ;   Bit 6: Select pulse        waveform
                ;   Bit 7: Select random noise waveform

ATDCY3  = $D413 ; Oscillator 3 Attack/Decay Register
                ;   Bits 0-3:  Select decay cycle duration (0-15)
                ;   Bits 4-7:  Select attack cycle duration (0-15)

SUREL3  = $D414 ; Oscillator 3 Sustain/Release Control Register
                ;   Bits 0-3:  Select release cycle duration (0-15)
                ;   Bits 4-7:  Select sustain volume level (0-15)

CUTLO   = $D415 ; Filter Cutoff Frequency (lowh byte)   : FREQUENCY = (REGISTER VALUE * 5.8) + 30Hz
                ;   Bits 0-2:  Low portion of filter cutoff frequency
                ;   Bits 5-7:  Unused

CUTHI   = $D416 ; Filter Cutoff Frequency (high byte)   : FREQUENCY = (REGISTER VALUE * 5.8) + 30Hz

RESON   = $D417 ; Filter Resonance Control Register
                ;   Bit 0:    Filter the output of voice 1?  1=yes
                ;   Bit 1:    Filter the output of voice 2?  1=yes
                ;   Bit 2:    Filter the output of voice 3?  1=yes
                ;   Bit 3:    Filter the output from the external input?  1=yes
                ;   Bits 4-7: Select filter resonance 0-15

SIGVOL  = $D418 ; Volume and Filter Select Register
                ;   Bits 0-3: Select output volume (0-15)
                ;   Bit 4:    Select low-pass filter,  1=low-pass on
                ;   Bit 5:    Select band-pass filter, 1=band-pass on
                ;   Bit 6:    Select high-pass filter, 1=high-pass on
                ;   Bit 7:    Mute Oscillator 3 - 1=off

POTX    = $D419 ; Read Game Paddle 1 (or 3) Position

POTY    = $D41A ; Read Game Paddle 2 (or 4) Position

RANDOM  = $D41B ; Current State of Oscillator 3's Wave / Random Number Generator

ENV3    = $D41C ; Current State of Oscillator 3's Envelope

; ------------------------------------------------------------------------------------------------------------- ;
; $D41D-$D41F   ; Not Connected - always $ff when read even after writes
; ------------------------------------------------------------------------------------------------------------- ;

; ------------------------------------------------------------------------------------------------------------- ;
; $D420-$D7FF   ; SID Register Images - Mirror of $D400-$D41F
; ------------------------------------------------------------------------------------------------------------- ;
