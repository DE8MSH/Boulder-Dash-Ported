; Shared platform ABI for Boulder Dash I console ports.
; Keep this file hardware-neutral.

.export platform_init
.export platform_wait_frame
.export platform_read_pad
.export platform_video_begin
.export platform_video_end
.export platform_audio_tick

; Common logical input bits returned by platform_read_pad in A.
PAD_LEFT   = %00000001
PAD_RIGHT  = %00000010
PAD_UP     = %00000100
PAD_DOWN   = %00001000
PAD_FIRE   = %00010000
PAD_START  = %00100000
PAD_SELECT = %01000000
