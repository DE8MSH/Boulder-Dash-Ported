.export game_cave_initial
.export game_cave_cols
.export game_cave_rows
.export game_cave_bytes

; Generated from the original Boulder Dash I Cave 1 seed/probability data and
; variable draw commands. The full 40x23 C64 control field is copied to RAM by
; the shared game core so both console backends render the same mutable state.

.segment "RODATA"
.include "../../build/generated/common/cave1.inc"
