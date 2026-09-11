.export game_cave_view
.export game_cave_view_width
.export game_cave_view_height

; Generated from the original Boulder Dash I Cave 1 seed/probability data and
; variable draw commands. The generator advances the full 40-column RNG stream
; even though the current console viewport only displays columns 0..31.

.segment "RODATA"
.include "../../build/generated/common/cave1.inc"
