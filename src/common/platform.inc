; Shared platform ABI for Boulder Dash I console ports.
; Keep this file hardware-neutral.
;
; .global lets a module provide one of these symbols or consume it as an
; external. This is important because both platform backends define the API,
; while src/common/game.s calls it.

.global platform_init
.global platform_wait_frame
.global platform_read_pad
.global platform_video_tick
.global platform_video_begin
.global platform_video_end
.global platform_audio_tick

; Common logical input bits returned by platform_read_pad in A.
PAD_LEFT   = %00000001
PAD_RIGHT  = %00000010
PAD_UP     = %00000100
PAD_DOWN   = %00001000
PAD_FIRE   = %00010000
PAD_START  = %00100000
PAD_SELECT = %01000000
