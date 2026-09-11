; -------------------------------------------------------------------------------------------------------------- ;
; Boulder Dash II - Macros Cave Var Data Functions
; -------------------------------------------------------------------------------------------------------------- ;
                    mac CaveDrawLine                ; a line of a tile
                        dc.b $00                    ; ID
                        dc.b {1}                    ; Tile Number
                        dc.b {2}                    ; Row  Number
                        dc.b {3}                    ; Col  Number
                     if {4} = "n"
                        dc.b $00                    ; Direction: up
                     eif
                     if {4} = "ne"
                        dc.b $02                    ; Direction: up/right
                     eif
                     if {4} = "e"
                        dc.b $04                    ; Direction: right
                     eif
                     if {4} = "se"
                        dc.b $06                    ; Direction: down/right
                     eif
                     if {4} = "s"
                        dc.b $08                    ; Direction: down
                     eif
                     if {4} = "sw"
                        dc.b $0a                    ; Direction: down/left
                     eif
                     if {4} = "w"
                        dc.b $0c                    ; Direction: left
                     eif
                     if {4} = "nw"
                        dc.b $0e                    ; Direction: up/left
                     eif
                        dc.b {5}                    ; Length
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
                    mac CaveDrawRect                ; a rectangle of a tile
                        dc.b $01                    ; ID
                        dc.b {1}                    ; Tile Number
                        dc.b {2}                    ; Row  Number
                        dc.b {3}                    ; Col  Number
                        dc.b {4}                    ; Height
                        dc.b {5}                    ; Length
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
                    mac CaveDrawRectFill            ; a rectangle of a tile filled with another tile
                        dc.b $02                    ; ID
                        dc.b {1}                    ; Tile Number
                        dc.b {2}                    ; Row  Number
                        dc.b {3}                    ; Col  Number
                        dc.b {4}                    ; Height
                        dc.b {5}                    ; Length
                        dc.b {6}                    ; Tile Number Filler
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
                    mac CaveDrawTile                ; a single tile
                        dc.b $03                    ; ID
                        dc.b {1}                    ; Tile Number
                        dc.b {2}                    ; Row  Number
                        dc.b {3}                    ; Col  Number
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
                    mac CaveDrawRaster              ; a ratster pattern of a tile
                        dc.b $04                    ; ID
                        dc.b {1}                    ; Tile Number
                        dc.b {2}                    ; Row  Number
                        dc.b {3}                    ; Col  Number
                        dc.b {4}                    ; Row  Amount
                        dc.b {5}                    ; Col  Amount
                        dc.b {6}                    ; Row  Gap
                        dc.b {7}                    ; Col  Gap
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
                    mac CaveDrawMap                 ; a map of a tile
                        dc.b $05                    ; ID
                        dc.b {1}                    ; Tile Number
                        dc.b {2}                    ; Row  Number
                        dc.b {3}                    ; MSB of the target adress ($0850 - $0bc0)
                        dc.b {4}                    ; LSB of the target adress ($0850 - $0bc0)
                        dc.b {5}                    ; 
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
                    mac CaveDrawRelate              ; a tile relative to an existing one
                        dc.b $06                    ; ID
                        dc.b {1}                    ; Tile Existing
                        dc.b {2}                    ; Tile Number
                        dc.b {3}                    ; Gap to the Right - continued to the next row if EndOfRow reached
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
                    mac CaveSlimePerm               ; set slime permeability
                        dc.b $07                    ; ID
                        dc.b {1}                    ; Delay Bit by Bit
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
                    mac CaveGetCustom               ; use a Custom Cave
                        dc.b $08                    ; ID
                        dc.b {1}                    ; Len cave data
                        dc.b {2}                    ; 
                        dc.b {3}                    ; 
                        dc.b {4}                    ; LSB cave data
                        dc.b {5}                    ; MSB cave data
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
; Boulder Dash I - Macros Cave Var Data Functions
; -------------------------------------------------------------------------------------------------------------- ;
                    mac BD1_CaveDrawTile            ; a single tile
                        dc.b [$00 | {1}]            ; Tile Number
                        dc.b {2}                    ; Col  Number
                        dc.b {3}                    ; Row  Number
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
                    mac BD1_CaveDrawLine            ; a line of a tile
                        dc.b [$40 | {1}]            ; Tile Number
                        dc.b {2}                    ; Col  Number
                        dc.b {3}                    ; Row  Number
                        dc.b {4}                    ; Length
                     if {5} = "n"
                        dc.b $00                    ; Direction: up
                     eif
                     if {5} = "ne"
                        dc.b $01                    ; Direction: up/right
                     eif
                     if {5} = "e"
                        dc.b $02                    ; Direction: right
                     eif
                     if {5} = "se"
                        dc.b $03                    ; Direction: down/right
                     eif
                     if {5} = "s"
                        dc.b $04                    ; Direction: down
                     eif
                     if {5} = "sw"
                        dc.b $05                    ; Direction: down/left
                     eif
                     if {5} = "w"
                        dc.b $06                    ; Direction: left
                     eif
                     if {5} = "nw"
                        dc.b $07                    ; Direction: up/left
                     eif
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
                    mac BD1_CaveDrawRectFill        ; a rectangle of a tile filled with another tile
                        dc.b [$80 | {1}]            ; Tile Number
                        dc.b {2}                    ; Col  Number
                        dc.b {3}                    ; Row  Number
                        dc.b {4}                    ; Length
                        dc.b {5}                    ; Height
                        dc.b {6}                    ; Tile Number Filler
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
                    mac BD1_CaveDrawRect            ; a rectangle of a tile
                        dc.b [$c0 | {1}]            ; Tile Number
                        dc.b {2}                    ; Col  Number
                        dc.b {3}                    ; Row  Number
                        dc.b {4}                    ; Length
                        dc.b {5}                    ; Height
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
; Boulder Dash IIe - Macros Cave Var Data Functions
; -------------------------------------------------------------------------------------------------------------- ;
                    mac BD2E_CaveCompress           ; spill a tile all over the cave
                        dc.b $05                    ; ID
                        dc.b {1}                    ; Tile Number
                        dc.b {2}                    ; Number of Values
                        dc.b {3}                    ; Screen address Lo
                        dc.b {4}                    ; Screen address Lo
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
                    mac BD2E_CaveConvert            ; 200 bytes PLCK cave data
                        dc.b $09                    ; ID
                        dc.b {1}                    ; Address 1st PLCK Cave Byte Lo
                        dc.b {2}                    ; Address 1st PLCK Cave Byte Hi
                        dc.b {3}                    ; RoFo Start PosY
                        dc.b {4}                    ; RoFo Start PosX
                    endm
; -------------------------------------------------------------------------------------------------------------- ;
