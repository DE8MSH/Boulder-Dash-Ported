; -------------------------------------------------------------------------------------------------------------- ;
; Boulder Dash I - Cave Data
; -------------------------------------------------------------------------------------------------------------- ;
;                        * equ $c000
; -------------------------------------------------------------------------------------------------------------- ;
B1_CaveDataMacros       include inc\B1_CaveMacs.asm ; Cave Variable Data Descriptions
B1_CaveVarsiables       include inc\B1_Vars.asm     ; Cave Variables
; -------------------------------------------------------------------------------------------------------------- ;
TabCaveDataOff          = *-2                            ; starts with no $01

                        dc.w [CaveData_01 - CaveData_01] ; 
                        dc.w [CaveData_02 - CaveData_01] ; 
                        dc.w [CaveData_03 - CaveData_01] ; 
                        dc.w [CaveData_04 - CaveData_01] ; 
                        dc.w [CaveData_05 - CaveData_01] ; 
                        dc.w [CaveData_06 - CaveData_01] ; 
                        dc.w [CaveData_07 - CaveData_01] ; 
                        dc.w [CaveData_08 - CaveData_01] ; 
                        dc.w [CaveData_09 - CaveData_01] ; 
                        dc.w [CaveData_0a - CaveData_01] ; 
                        dc.w [CaveData_0b - CaveData_01] ; 
                        dc.w [CaveData_0c - CaveData_01] ; 
                        dc.w [CaveData_0d - CaveData_01] ; 
                        dc.w [CaveData_0e - CaveData_01] ; 
                        dc.w [CaveData_0f - CaveData_01] ; 
                        dc.w [CaveData_10 - CaveData_01] ; 
                        dc.w [CaveData_11 - CaveData_01] ; 
                        dc.w [CaveData_12 - CaveData_01] ; 
                        dc.w [CaveData_13 - CaveData_01] ; 
                        dc.w [CaveData_14 - CaveData_01] ; 
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 01
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_01             equ  *   ;
CaveData_01_Fix         equ  *   ;
                        dc.b $01 ; $00 - cave no
                        dc.b $14 ; $01 - magic wall time
                        dc.b $0a ; $02 - normal diamond value
                        dc.b $0f ; $03 - extra  diamond value
                        dc.b $0a ; $04 - rnd seed level 1
                        dc.b $0b ; $05 - rnd seed level 2
                        dc.b $0c ; $06 - rnd seed level 3
                        dc.b $0d ; $07 - rnd seed level 4
                        dc.b $0e ; $08 - rnd seed level 5
                        dc.b $0c ; $09 - diamonds to get level 1
                        dc.b $0c ; $0a - diamonds to get level 2
                        dc.b $0c ; $0b - diamonds to get level 3
                        dc.b $0c ; $0c - diamonds to get level 4
                        dc.b $0c ; $0d - diamonds to get level 5
                        dc.b $96 ; $0e - cave time level 1
                        dc.b $6e ; $0f - cave time level 2
                        dc.b $46 ; $10 - cave time level 3
                        dc.b $28 ; $11 - cave time level 4
                        dc.b $1e ; $12 - cave time level 5
                        dc.b $08 ; $13 - back colour 1
                        dc.b $0b ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $d4 ; $16 - not used -
                        dc.b $20 ; $17 - not used -
                        dc.b B1_TileEmpty   ; $18 - random object 1
                        dc.b B1_TileBldrFix ; $19 - random object 2
                        dc.b B1_TileDmndFix ; $1a - random object 3
                        dc.b B1_TileEmpty   ; $1b - random object 4
                        dc.b $3c ; $1c - probability object 1
                        dc.b $32 ; $1d - probability object 2
                        dc.b $09 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_01_Var         equ  *   ; 
                        BD1_CaveDrawLine      B1_TileWallStone  , $01 , $09 , $1e , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $09 , $10 , $1e , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $03 , $04                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $26 , $12                                 ; TileNo, Col, Row
                        dc.b $ff ; 30 <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 02
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_02             equ  *   ;
CaveData_02_Fix         equ  *   ;
                        dc.b $02 ; $00 - cave no
                        dc.b $14 ; $01 - magic wall time
                        dc.b $14 ; $02 - normal diamond value
                        dc.b $32 ; $03 - extra  diamond value
                        dc.b $03 ; $04 - rnd seed level 1
                        dc.b $00 ; $05 - rnd seed level 2
                        dc.b $01 ; $06 - rnd seed level 3
                        dc.b $57 ; $07 - rnd seed level 4
                        dc.b $58 ; $08 - rnd seed level 5
                        dc.b $0a ; $09 - diamonds to get level 1
                        dc.b $0c ; $0a - diamonds to get level 2
                        dc.b $09 ; $0b - diamonds to get level 3
                        dc.b $0d ; $0c - diamonds to get level 4
                        dc.b $0a ; $0d - diamonds to get level 5
                        dc.b $96 ; $0e - cave time level 1
                        dc.b $6e ; $0f - cave time level 2
                        dc.b $46 ; $10 - cave time level 3
                        dc.b $46 ; $11 - cave time level 4
                        dc.b $46 ; $12 - cave time level 5
                        dc.b $0a ; $13 - back colour 1
                        dc.b $04 ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileEmpty     ; $18 - random object 1
                        dc.b B1_TileBldrFix   ; $19 - random object 2
                        dc.b B1_TileDmndFix   ; $1a - random object 3
                        dc.b B1_TileFireFly0  ; $1b - random object 4
                        dc.b $3c ; $1c - probability object 1
                        dc.b $32 ; $1d - probability object 2
                        dc.b $09 ; $1e - probability object 3
                        dc.b $02 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_02_Var         equ  *   ;
                        BD1_CaveDrawLine      B1_TileWallStone  , $01 , $08 , $26 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $01 , $0f , $26 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $08 , $03 , $14 , "s"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $10 , $03 , $14 , "s"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $18 , $03 , $14 , "s"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $20 , $03 , $14 , "s"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileEmpty      , $01 , $05 , $26 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileEmpty      , $01 , $0b , $26 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileEmpty      , $01 , $12 , $26 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileEmpty      , $14 , $03 , $14 , "s"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $12 , $15                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $12 , $16                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 03
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_03             equ  *   ;
CaveData_03_Fix         equ  *   ;
                        dc.b $03 ; $00 - cave no
                        dc.b $00 ; $01 - magic wall time
                        dc.b $0f ; $02 - normal diamond value
                        dc.b $00 ; $03 - extra  diamond value
                        dc.b $00 ; $04 - rnd seed level 1
                        dc.b $32 ; $05 - rnd seed level 2
                        dc.b $36 ; $06 - rnd seed level 3
                        dc.b $34 ; $07 - rnd seed level 4
                        dc.b $37 ; $08 - rnd seed level 5
                        dc.b $18 ; $09 - diamonds to get level 1
                        dc.b $17 ; $0a - diamonds to get level 2
                        dc.b $18 ; $0b - diamonds to get level 3
                        dc.b $17 ; $0c - diamonds to get level 4
                        dc.b $15 ; $0d - diamonds to get level 5
                        dc.b $96 ; $0e - cave time level 1
                        dc.b $64 ; $0f - cave time level 2
                        dc.b $5a ; $10 - cave time level 3
                        dc.b $50 ; $11 - cave time level 4
                        dc.b $46 ; $12 - cave time level 5
                        dc.b $09 ; $13 - back colour 1
                        dc.b $08 ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $04 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileWallStone ; $18 - random object 1
                        dc.b B1_TileBldrFix   ; $19 - random object 2
                        dc.b B1_TileDmndFix   ; $1a - random object 3
                        dc.b B1_TileEmpty     ; $1b - random object 4
                        dc.b $64 ; $1c - probability object 1
                        dc.b $32 ; $1d - probability object 2
                        dc.b $09 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_03_Var         equ  *   ;
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $03 , $04                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $27 , $14                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 04
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_04             equ  *   ;
CaveData_04_Fix         equ  *   ;
                        dc.b $04 ; $00 - cave no
                        dc.b $14 ; $01 - magic wall time
                        dc.b $05 ; $02 - normal diamond value
                        dc.b $14 ; $03 - extra  diamond value
                        dc.b $00 ; $04 - rnd seed level 1
                        dc.b $6e ; $05 - rnd seed level 2
                        dc.b $70 ; $06 - rnd seed level 3
                        dc.b $73 ; $07 - rnd seed level 4
                        dc.b $77 ; $08 - rnd seed level 5
                        dc.b $24 ; $09 - diamonds to get level 1
                        dc.b $24 ; $0a - diamonds to get level 2
                        dc.b $24 ; $0b - diamonds to get level 3
                        dc.b $24 ; $0c - diamonds to get level 4
                        dc.b $24 ; $0d - diamonds to get level 5
                        dc.b $78 ; $0e - cave time level 1
                        dc.b $64 ; $0f - cave time level 2
                        dc.b $50 ; $10 - cave time level 3
                        dc.b $3c ; $11 - cave time level 4
                        dc.b $32 ; $12 - cave time level 5
                        dc.b $04 ; $13 - back colour 1
                        dc.b $08 ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileBldrFix ; $18 - random object 1
                        dc.b B1_TileEmpty   ; $19 - random object 2
                        dc.b B1_TileEmpty   ; $1a - random object 3
                        dc.b B1_TileEmpty   ; $1b - random object 4
                        dc.b $14 ; $1c - probability object 1
                        dc.b $00 ; $1d - probability object 2
                        dc.b $00 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_04_Var         equ  *   ;
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $01 , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $26 , $16                                 ; TileNo, Col, Row
                        BD1_CaveDrawRectFill  B1_TileSoil       , $08 , $0a , $04 , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileBttrFly0   , $0a , $0b                                 ; TileNo, Col, Row
                        BD1_CaveDrawRectFill  B1_TileSoil       , $10 , $0a , $04 , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileBttrFly0   , $12 , $0b                                 ; TileNo, Col, Row
                        BD1_CaveDrawRectFill  B1_TileSoil       , $18 , $0a , $04 , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileBttrFly0   , $1a , $0b                                 ; TileNo, Col, Row
                        BD1_CaveDrawRectFill  B1_TileSoil       , $20 , $0a , $04 , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileBttrFly0   , $22 , $0b                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 05
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_05             equ  *   ;
CaveData_05_Fix         equ  *   ;
                        dc.b $05 ; $00 - cave no
                        dc.b $14 ; $01 - magic wall time
                        dc.b $32 ; $02 - normal diamond value
                        dc.b $5a ; $03 - extra  diamond value
                        dc.b $00 ; $04 - rnd seed level 1
                        dc.b $00 ; $05 - rnd seed level 2
                        dc.b $00 ; $06 - rnd seed level 3
                        dc.b $00 ; $07 - rnd seed level 4
                        dc.b $00 ; $08 - rnd seed level 5
                        dc.b $04 ; $09 - diamonds to get level 1
                        dc.b $05 ; $0a - diamonds to get level 2
                        dc.b $06 ; $0b - diamonds to get level 3
                        dc.b $07 ; $0c - diamonds to get level 4
                        dc.b $08 ; $0d - diamonds to get level 5
                        dc.b $96 ; $0e - cave time level 1
                        dc.b $78 ; $0f - cave time level 2
                        dc.b $5a ; $10 - cave time level 3
                        dc.b $3c ; $11 - cave time level 4
                        dc.b $1e ; $12 - cave time level 5
                        dc.b $09 ; $13 - back colour 1
                        dc.b $0a ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileEmpty ; $18 - random object 1
                        dc.b B1_TileEmpty ; $19 - random object 2
                        dc.b B1_TileEmpty ; $1a - random object 3
                        dc.b B1_TileEmpty ; $1b - random object 4
                        dc.b $00 ; $1c - probability object 1
                        dc.b $00 ; $1d - probability object 2
                        dc.b $00 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_05_Var         equ  *   ;
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $01 , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $27 , $16                                 ; TileNo, Col, Row
                        BD1_CaveDrawRectFill  B1_TileEmpty      , $08 , $0a , $03 , $03 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileEmpty      , $10 , $0a , $03 , $03 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileEmpty      , $18 , $0a , $03 , $03 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileEmpty      , $20 , $0a , $03 , $03 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileDmndFix    , $09 , $0c                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $0a , $0a                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $11 , $0c                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $12 , $0a                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $19 , $0c                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $1a , $0a                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $21 , $0c                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $22 , $0a                                 ; TileNo, Col, Row
                        BD1_CaveDrawRectFill  B1_TileEmpty      , $08 , $10 , $03 , $03 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileEmpty      , $10 , $10 , $03 , $03 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileEmpty      , $18 , $10 , $03 , $03 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileEmpty      , $20 , $10 , $03 , $03 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileDmndFix    , $09 , $12                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $0a , $10                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $11 , $12                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $12 , $10                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $19 , $12                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $1a , $10                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $21 , $12                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $22 , $10                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 06
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_06             equ  *   ;
CaveData_06_Fix         equ  *   ;
                        dc.b $06 ; $00 - cave no
                        dc.b $14 ; $01 - magic wall time
                        dc.b $28 ; $02 - normal diamond value
                        dc.b $3c ; $03 - extra  diamond value
                        dc.b $00 ; $04 - rnd seed level 1
                        dc.b $14 ; $05 - rnd seed level 2
                        dc.b $15 ; $06 - rnd seed level 3
                        dc.b $16 ; $07 - rnd seed level 4
                        dc.b $17 ; $08 - rnd seed level 5
                        dc.b $04 ; $09 - diamonds to get level 1
                        dc.b $06 ; $0a - diamonds to get level 2
                        dc.b $07 ; $0b - diamonds to get level 3
                        dc.b $08 ; $0c - diamonds to get level 4
                        dc.b $08 ; $0d - diamonds to get level 5
                        dc.b $96 ; $0e - cave time level 1
                        dc.b $78 ; $0f - cave time level 2
                        dc.b $64 ; $10 - cave time level 3
                        dc.b $5a ; $11 - cave time level 4
                        dc.b $50 ; $12 - cave time level 5
                        dc.b $0e ; $13 - back colour 1
                        dc.b $0a ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileBldrFix ; $18 - random object 1
                        dc.b B1_TileEmpty   ; $19 - random object 2
                        dc.b B1_TileEmpty   ; $1a - random object 3
                        dc.b B1_TileEmpty   ; $1b - random object 4
                        dc.b $32 ; $1c - probability object 1
                        dc.b $00 ; $1d - probability object 2
                        dc.b $00 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_06_Var         equ  *   ;
                        BD1_CaveDrawRectFill  B1_TileWallStone  , $01 , $03 , $0a , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileWallStone  , $01 , $06 , $0a , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileWallStone  , $01 , $09 , $0a , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileWallStone  , $01 , $0c , $0a , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawLine      B1_TileSoil       , $0a , $03 , $0d , "s"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawTile      B1_TileDmndFix    , $03 , $05                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $04 , $05                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $03 , $08                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $04 , $08                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $03 , $0b                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $04 , $0b                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $03 , $0e                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $04 , $0e                                 ; TileNo, Col, Row
                        BD1_CaveDrawRectFill  B1_TileWallStone  , $1d , $03 , $0a , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileWallStone  , $1d , $06 , $0a , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileWallStone  , $1d , $09 , $0a , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileWallStone  , $1d , $0c , $0a , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawLine      B1_TileSoil       , $1d , $03 , $0d , "s"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawTile      B1_TileDmndFix    , $24 , $05                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $23 , $05                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $24 , $08                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $23 , $08                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $24 , $0b                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $23 , $0b                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $24 , $0e                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileFireFly0   , $23 , $0e                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $03 , $14                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $26 , $14                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 07
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_07             equ  *   ;
CaveData_07_Fix         equ  *   ;
                        dc.b $07 ; $00 - cave no
                        dc.b $4b ; $01 - magic wall time
                        dc.b $0a ; $02 - normal diamond value
                        dc.b $14 ; $03 - extra  diamond value
                        dc.b $02 ; $04 - rnd seed level 1
                        dc.b $07 ; $05 - rnd seed level 2
                        dc.b $08 ; $06 - rnd seed level 3
                        dc.b $0a ; $07 - rnd seed level 4
                        dc.b $09 ; $08 - rnd seed level 5
                        dc.b $0f ; $09 - diamonds to get level 1
                        dc.b $14 ; $0a - diamonds to get level 2
                        dc.b $19 ; $0b - diamonds to get level 3
                        dc.b $19 ; $0c - diamonds to get level 4
                        dc.b $19 ; $0d - diamonds to get level 5
                        dc.b $78 ; $0e - cave time level 1
                        dc.b $78 ; $0f - cave time level 2
                        dc.b $78 ; $10 - cave time level 3
                        dc.b $78 ; $11 - cave time level 4
                        dc.b $78 ; $12 - cave time level 5
                        dc.b $09 ; $13 - back colour 1
                        dc.b $0a ; $14 - back colour 2
                        dc.b $0d ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileEmpty     ; $18 - random object 1
                        dc.b B1_TileBldrFix   ; $19 - random object 2
                        dc.b B1_TileFireFly0  ; $1a - random object 3
                        dc.b B1_TileEmpty     ; $1b - random object 4
                        dc.b $64 ; $1c - probability object 1
                        dc.b $28 ; $1d - probability object 2
                        dc.b $02 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_07_Var         equ  *   ;
                        BD1_CaveDrawLine      B1_TileWallStone  , $01 , $07 , $0c , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $1c , $05 , $0b , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileAmoeba     , $13 , $15 , $02 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawTile      B1_TileDmndFix    , $04 , $06                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $04 , $0e                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $04 , $16                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $22 , $04                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $22 , $0c                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $22 , $16                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $14 , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $27 , $07                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 08
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_08             equ  *   ;
CaveData_08_Fix         equ  *   ;
                        dc.b $08 ; $00 - cave no
                        dc.b $14 ; $01 - magic wall time
                        dc.b $0a ; $02 - normal diamond value
                        dc.b $14 ; $03 - extra  diamond value
                        dc.b $01 ; $04 - rnd seed level 1
                        dc.b $03 ; $05 - rnd seed level 2
                        dc.b $04 ; $06 - rnd seed level 3
                        dc.b $05 ; $07 - rnd seed level 4
                        dc.b $06 ; $08 - rnd seed level 5
                        dc.b $0a ; $09 - diamonds to get level 1
                        dc.b $0f ; $0a - diamonds to get level 2
                        dc.b $14 ; $0b - diamonds to get level 3
                        dc.b $14 ; $0c - diamonds to get level 4
                        dc.b $14 ; $0d - diamonds to get level 5
                        dc.b $78 ; $0e - cave time level 1
                        dc.b $6e ; $0f - cave time level 2
                        dc.b $64 ; $10 - cave time level 3
                        dc.b $5a ; $11 - cave time level 4
                        dc.b $50 ; $12 - cave time level 5
                        dc.b $02 ; $13 - back colour 1
                        dc.b $0e ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileEmpty     ; $18 - random object 1
                        dc.b B1_TileBldrFix   ; $19 - random object 2
                        dc.b B1_TileFireFly0  ; $1a - random object 3
                        dc.b B1_TileEmpty     ; $1b - random object 4
                        dc.b $5a ; $1c - probability object 1
                        dc.b $32 ; $1d - probability object 2
                        dc.b $02 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_08_Var         equ  *   ;
                        BD1_CaveDrawTile      B1_TileDmndFix    , $04 , $06                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $22 , $04                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $22 , $0c                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $00 , $05                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $14 , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawLine      B1_TileWallStone  , $01 , $07 , $0c , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $01 , $0f , $0c , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $1c , $05 , $0b , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $1c , $0d , $0b , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallMagic  , $0e , $11 , $08 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawTile      B1_TileDmndFix    , $0c , $10                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileEmpty      , $0e , $12                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $13 , $12                                 ; TileNo, Col, Row
                        BD1_CaveDrawLine      B1_TileSoil       , $0e , $0f , $08 , "e"                     ; TileNo, Col, Row, Len, Dir
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 09
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_09             equ  *   ;
CaveData_09_Fix         equ  *   ;
                        dc.b $09 ; $00 - cave no
                        dc.b $14 ; $01 - magic wall time
                        dc.b $05 ; $02 - normal diamond value
                        dc.b $0a ; $03 - extra  diamond value
                        dc.b $64 ; $04 - rnd seed level 1
                        dc.b $89 ; $05 - rnd seed level 2
                        dc.b $8c ; $06 - rnd seed level 3
                        dc.b $fb ; $07 - rnd seed level 4
                        dc.b $33 ; $08 - rnd seed level 5
                        dc.b $4b ; $09 - diamonds to get level 1
                        dc.b $4b ; $0a - diamonds to get level 2
                        dc.b $50 ; $0b - diamonds to get level 3
                        dc.b $55 ; $0c - diamonds to get level 4
                        dc.b $5a ; $0d - diamonds to get level 5
                        dc.b $96 ; $0e - cave time level 1
                        dc.b $96 ; $0f - cave time level 2
                        dc.b $82 ; $10 - cave time level 3
                        dc.b $82 ; $11 - cave time level 4
                        dc.b $78 ; $12 - cave time level 5
                        dc.b $08 ; $13 - back colour 1
                        dc.b $04 ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileBldrFix ; $18 - random object 1
                        dc.b B1_TileDmndFix ; $19 - random object 2
                        dc.b B1_TileEmpty   ; $1a - random object 3
                        dc.b B1_TileEmpty   ; $1b - random object 4
                        dc.b $f0 ; $1c - probability object 1
                        dc.b $78 ; $1d - probability object 2
                        dc.b $00 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_09_Var         equ  *   ;
                        BD1_CaveDrawRectFill  B1_TileWallStone  , $05 , $0a , $0d , $0d , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileSoil       , $0c , $0a                                 ; TileNo, Col, Row
                        BD1_CaveDrawRectFill  B1_TileWallStone  , $19 , $0a , $0d , $0d , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileSoil       , $1f , $0a                                 ; TileNo, Col, Row
                        BD1_CaveDrawLine      B1_TileWallStone  , $11 , $12 , $09 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileEmpty      , $11 , $13 , $09 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $07 , $0c                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $08 , $0c                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 0a
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_0a             equ  *   ;
CaveData_0a_Fix         equ  *   ;
                        dc.b $0a ; $00 - cave no
                        dc.b $14 ; $01 - magic wall time
                        dc.b $19 ; $02 - normal diamond value
                        dc.b $3c ; $03 - extra  diamond value
                        dc.b $00 ; $04 - rnd seed level 1
                        dc.b $00 ; $05 - rnd seed level 2
                        dc.b $00 ; $06 - rnd seed level 3
                        dc.b $00 ; $07 - rnd seed level 4
                        dc.b $00 ; $08 - rnd seed level 5
                        dc.b $0c ; $09 - diamonds to get level 1
                        dc.b $0c ; $0a - diamonds to get level 2
                        dc.b $0c ; $0b - diamonds to get level 3
                        dc.b $0c ; $0c - diamonds to get level 4
                        dc.b $0c ; $0d - diamonds to get level 5
                        dc.b $96 ; $0e - cave time level 1
                        dc.b $82 ; $0f - cave time level 2
                        dc.b $78 ; $10 - cave time level 3
                        dc.b $6e ; $11 - cave time level 4
                        dc.b $64 ; $12 - cave time level 5
                        dc.b $06 ; $13 - back colour 1
                        dc.b $08 ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileEmpty ; $18 - random object 1
                        dc.b B1_TileEmpty ; $19 - random object 2
                        dc.b B1_TileEmpty ; $1a - random object 3
                        dc.b B1_TileEmpty ; $1b - random object 4
                        dc.b $00 ; $1c - probability object 1
                        dc.b $00 ; $1d - probability object 2
                        dc.b $00 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_0a_Var         equ  *   ; 
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $0d , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $27 , $16                                 ; TileNo, Col, Row
                        BD1_CaveDrawLine      B1_TileDmndFix    , $05 , $04 , $11 , "se"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileDmndFix    , $15 , $04 , $11 , "sw"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawRectFill  B1_TileEmpty      , $05 , $0b , $11 , $03 , B1_TileFireFly0   ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRect      B1_TileWallStone  , $01 , $04 , $15 , $11                     ; TileNo, Col, Row, Len, Height
                        BD1_CaveDrawTile      B1_TileEmpty      , $0d , $04                                 ; TileNo, Col, Row
                        BD1_CaveDrawRect      B1_TileWallStone  , $07 , $06 , $0d , $0d                     ; TileNo, Col, Row, Len, Height
                        BD1_CaveDrawTile      B1_TileEmpty      , $0d , $06                                 ; TileNo, Col, Row
                        BD1_CaveDrawRect      B1_TileWallStone  , $09 , $08 , $09 , $09                     ; TileNo, Col, Row, Len, Height
                        BD1_CaveDrawTile      B1_TileEmpty      , $0d , $08                                 ; TileNo, Col, Row
                        BD1_CaveDrawRect      B1_TileWallStone  , $0b , $0a , $05 , $05                     ; TileNo, Col, Row, Len, Height
                        BD1_CaveDrawTile      B1_TileEmpty      , $0d , $0a                                 ; TileNo, Col, Row
                        BD1_CaveDrawRectFill  B1_TileWallStone  , $03 , $06 , $03 , $0f , B1_TileFireFly0   ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileEmpty      , $04 , $06                                 ; TileNo, Col, Row
                        BD1_CaveDrawLine      B1_TileDmndFix    , $04 , $10 , $04 , "s"                     ; TileNo, Col, Row, Len, Dir
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 0b
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_0b             equ  *   ;
CaveData_0b_Fix         equ  *   ;
                        dc.b $0b ; $00 - cave no
                        dc.b $14 ; $01 - magic wall time
                        dc.b $32 ; $02 - normal diamond value
                        dc.b $00 ; $03 - extra  diamond value
                        dc.b $00 ; $04 - rnd seed level 1
                        dc.b $04 ; $05 - rnd seed level 2
                        dc.b $66 ; $06 - rnd seed level 3
                        dc.b $97 ; $07 - rnd seed level 4
                        dc.b $64 ; $08 - rnd seed level 5
                        dc.b $06 ; $09 - diamonds to get level 1
                        dc.b $06 ; $0a - diamonds to get level 2
                        dc.b $06 ; $0b - diamonds to get level 3
                        dc.b $06 ; $0c - diamonds to get level 4
                        dc.b $06 ; $0d - diamonds to get level 5
                        dc.b $78 ; $0e - cave time level 1
                        dc.b $78 ; $0f - cave time level 2
                        dc.b $96 ; $10 - cave time level 3
                        dc.b $96 ; $11 - cave time level 4
                        dc.b $f0 ; $12 - cave time level 5
                        dc.b $0b ; $13 - back colour 1
                        dc.b $08 ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileEmpty     ; $18 - random object 1
                        dc.b B1_TileBldrFix   ; $19 - random object 2
                        dc.b B1_TileFireFly0  ; $1a - random object 3
                        dc.b B1_TileEmpty     ; $1b - random object 4
                        dc.b $64 ; $1c - probability object 1
                        dc.b $50 ; $1d - probability object 2
                        dc.b $02 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_0b_Var         equ  *   ;
                        BD1_CaveDrawLine      B1_TileWallStone  , $0a , $03 , $09 , "s"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $14 , $03 , $09 , "s"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $1e , $03 , $09 , "s"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $09 , $16 , $09 , "n"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $0c , $0f , $11 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $05 , $0b , $09 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $0f , $0b , $09 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $19 , $0b , $09 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $1c , $13 , $0b , "ne"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawTile      B1_TileDmndFix    , $04 , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $0e , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $18 , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $22 , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $04 , $16                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileDmndFix    , $23 , $15                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $14 , $14                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $26 , $11                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 0c
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_0c             equ  *   ;
CaveData_0c_Fix         equ  *   ;
                        dc.b $0c ; $00 - cave no
                        dc.b $14 ; $01 - magic wall time
                        dc.b $14 ; $02 - normal diamond value
                        dc.b $00 ; $03 - extra  diamond value
                        dc.b $00 ; $04 - rnd seed level 1
                        dc.b $3c ; $05 - rnd seed level 2
                        dc.b $02 ; $06 - rnd seed level 3
                        dc.b $3b ; $07 - rnd seed level 4
                        dc.b $66 ; $08 - rnd seed level 5
                        dc.b $13 ; $09 - diamonds to get level 1
                        dc.b $13 ; $0a - diamonds to get level 2
                        dc.b $0e ; $0b - diamonds to get level 3
                        dc.b $10 ; $0c - diamonds to get level 4
                        dc.b $15 ; $0d - diamonds to get level 5
                        dc.b $b4 ; $0e - cave time level 1
                        dc.b $aa ; $0f - cave time level 2
                        dc.b $a0 ; $10 - cave time level 3
                        dc.b $a0 ; $11 - cave time level 4
                        dc.b $a0 ; $12 - cave time level 5
                        dc.b $0c ; $13 - back colour 1
                        dc.b $0a ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileEmpty   ; $18 - random object 1
                        dc.b B1_TileBldrFix ; $19 - random object 2
                        dc.b B1_TileDmndFix ; $1a - random object 3
                        dc.b B1_TileEmpty   ; $1b - random object 4
                        dc.b $3c ; $1c - probability object 1
                        dc.b $32 ; $1d - probability object 2
                        dc.b $09 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_0c_Var         equ  *   ;
                        BD1_CaveDrawLine      B1_TileWallStone  , $0a , $05 , $12 , "s"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $0e , $05 , $12 , "s"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $12 , $05 , $12 , "s"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $16 , $05 , $12 , "s"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $02 , $06 , $0b , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $02 , $0a , $0b , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $02 , $0e , $0f , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $02 , $12 , $0b , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawRectFill  B1_TileSoil       , $1e , $04 , $04 , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileFireFly0   , $20 , $05                                 ; TileNo, Col, Row
                        BD1_CaveDrawRectFill  B1_TileSoil       , $1e , $09 , $04 , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileFireFly0   , $20 , $0a                                 ; TileNo, Col, Row
                        BD1_CaveDrawRectFill  B1_TileSoil       , $1e , $0e , $04 , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileFireFly0   , $20 , $0f                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $03 , $14                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $27 , $16                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 0d
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_0d             equ  *   ;
CaveData_0d_Fix         equ  *   ;
                        dc.b $0d ; $00 - cave no
                        dc.b $8c ; $01 - magic wall time
                        dc.b $05 ; $02 - normal diamond value
                        dc.b $08 ; $03 - extra  diamond value
                        dc.b $00 ; $04 - rnd seed level 1
                        dc.b $01 ; $05 - rnd seed level 2
                        dc.b $02 ; $06 - rnd seed level 3
                        dc.b $03 ; $07 - rnd seed level 4
                        dc.b $04 ; $08 - rnd seed level 5
                        dc.b $32 ; $09 - diamonds to get level 1
                        dc.b $37 ; $0a - diamonds to get level 2
                        dc.b $3c ; $0b - diamonds to get level 3
                        dc.b $46 ; $0c - diamonds to get level 4
                        dc.b $50 ; $0d - diamonds to get level 5
                        dc.b $a0 ; $0e - cave time level 1
                        dc.b $9b ; $0f - cave time level 2
                        dc.b $96 ; $10 - cave time level 3
                        dc.b $91 ; $11 - cave time level 4
                        dc.b $8c ; $12 - cave time level 5
                        dc.b $06 ; $13 - back colour 1
                        dc.b $08 ; $14 - back colour 2
                        dc.b $0d ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileBldrFix ; $18 - random object 1
                        dc.b B1_TileEmpty   ; $19 - random object 2
                        dc.b B1_TileEmpty   ; $1a - random object 3
                        dc.b B1_TileEmpty   ; $1b - random object 4
                        dc.b $28 ; $1c - probability object 1
                        dc.b $00 ; $1d - probability object 2
                        dc.b $00 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_0d_Var         equ  *   ;
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $12 , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $0a , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileAmoeba     , $14 , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawLine      B1_TileWallStone  , $05 , $12 , $1e , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileBttrFly0   , $05 , $13 , $1e , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileBldrFix    , $05 , $14 , $1e , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawRect      B1_TileSoil       , $05 , $15 , $1e , $02                     ; TileNo, Col, Row, Len, Height
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 0e
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_0e             equ  *   ;
CaveData_0e_Fix         equ  *   ;
                        dc.b $0e ; $00 - cave no
                        dc.b $14 ; $01 - magic wall time
                        dc.b $0a ; $02 - normal diamond value
                        dc.b $14 ; $03 - extra  diamond value
                        dc.b $00 ; $04 - rnd seed level 1
                        dc.b $00 ; $05 - rnd seed level 2
                        dc.b $00 ; $06 - rnd seed level 3
                        dc.b $00 ; $07 - rnd seed level 4
                        dc.b $00 ; $08 - rnd seed level 5
                        dc.b $1e ; $09 - diamonds to get level 1
                        dc.b $23 ; $0a - diamonds to get level 2
                        dc.b $28 ; $0b - diamonds to get level 3
                        dc.b $2a ; $0c - diamonds to get level 4
                        dc.b $2d ; $0d - diamonds to get level 5
                        dc.b $96 ; $0e - cave time level 1
                        dc.b $91 ; $0f - cave time level 2
                        dc.b $8c ; $10 - cave time level 3
                        dc.b $87 ; $11 - cave time level 4
                        dc.b $82 ; $12 - cave time level 5
                        dc.b $0c ; $13 - back colour 1
                        dc.b $08 ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileBldrFix ; $18 - random object 1
                        dc.b B1_TileEmpty   ; $19 - random object 2
                        dc.b B1_TileEmpty   ; $1a - random object 3
                        dc.b B1_TileEmpty   ; $1b - random object 4
                        dc.b $00 ; $1c - probability object 1
                        dc.b $00 ; $1d - probability object 2
                        dc.b $00 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_0e_Var         equ  *   ;
                        BD1_CaveDrawRectFill  B1_TileSoil       , $0a , $0a , $0d , $0d , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawLine      B1_TileBttrFly0   , $0b , $0b , $0c , "se"                    ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawRect      B1_TileSoil       , $0c , $0a , $03 , $0d                     ; TileNo, Col, Row, Len, Height
                        BD1_CaveDrawRect      B1_TileSoil       , $10 , $0a , $03 , $0d                     ; TileNo, Col, Row, Len, Height
                        BD1_CaveDrawRect      B1_TileSoil       , $14 , $0a , $03 , $0d                     ; TileNo, Col, Row, Len, Height
                        BD1_CaveDrawLine      B1_TileBldrFix    , $16 , $08 , $0c , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileFireFly0   , $16 , $07 , $0c , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawRect      B1_TileSoil       , $17 , $06 , $03 , $04                     ; TileNo, Col, Row, Len, Height
                        BD1_CaveDrawRect      B1_TileSoil       , $1b , $06 , $03 , $04                     ; TileNo, Col, Row, Len, Height
                        BD1_CaveDrawRect      B1_TileSoil       , $1f , $06 , $03 , $04                     ; TileNo, Col, Row, Len, Height
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $03 , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $27 , $14                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 0f
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_0f             equ  *   ;
CaveData_0f_Fix         equ  *   ;
                        dc.b $0f ; $00 - cave no
                        dc.b $08 ; $01 - magic wall time
                        dc.b $0a ; $02 - normal diamond value
                        dc.b $14 ; $03 - extra  diamond value
                        dc.b $01 ; $04 - rnd seed level 1
                        dc.b $1d ; $05 - rnd seed level 2
                        dc.b $1e ; $06 - rnd seed level 3
                        dc.b $1f ; $07 - rnd seed level 4
                        dc.b $20 ; $08 - rnd seed level 5
                        dc.b $0f ; $09 - diamonds to get level 1
                        dc.b $14 ; $0a - diamonds to get level 2
                        dc.b $14 ; $0b - diamonds to get level 3
                        dc.b $19 ; $0c - diamonds to get level 4
                        dc.b $1e ; $0d - diamonds to get level 5
                        dc.b $78 ; $0e - cave time level 1
                        dc.b $78 ; $0f - cave time level 2
                        dc.b $78 ; $10 - cave time level 3
                        dc.b $78 ; $11 - cave time level 4
                        dc.b $8c ; $12 - cave time level 5
                        dc.b $08 ; $13 - back colour 1
                        dc.b $0e ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileEmpty     ; $18 - random object 1
                        dc.b B1_TileBldrFix   ; $19 - random object 2
                        dc.b B1_TileFireFly0  ; $1a - random object 3
                        dc.b B1_TileEmpty     ; $1b - random object 4
                        dc.b $64 ; $1c - probability object 1
                        dc.b $50 ; $1d - probability object 2
                        dc.b $02 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_0f_Var         equ  *   ;
                        BD1_CaveDrawLine      B1_TileWallStone  , $02 , $04 , $0a , "se"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallStone  , $0f , $0d , $0a , "ne"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileSoil       , $0c , $0e , $03 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallMagic  , $0c , $0f , $03 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawTile      B1_TileXitClose   , $14 , $16                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $14 , $03                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 10
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_10             equ  *   ;
CaveData_10_Fix         equ  *   ;
                        dc.b $10 ; $00 - cave no
                        dc.b $14 ; $01 - magic wall time
                        dc.b $0a ; $02 - normal diamond value
                        dc.b $14 ; $03 - extra  diamond value
                        dc.b $01 ; $04 - rnd seed level 1
                        dc.b $78 ; $05 - rnd seed level 2
                        dc.b $81 ; $06 - rnd seed level 3
                        dc.b $7e ; $07 - rnd seed level 4
                        dc.b $7b ; $08 - rnd seed level 5
                        dc.b $0c ; $09 - diamonds to get level 1
                        dc.b $0f ; $0a - diamonds to get level 2
                        dc.b $0f ; $0b - diamonds to get level 3
                        dc.b $0f ; $0c - diamonds to get level 4
                        dc.b $0c ; $0d - diamonds to get level 5
                        dc.b $96 ; $0e - cave time level 1
                        dc.b $96 ; $0f - cave time level 2
                        dc.b $96 ; $10 - cave time level 3
                        dc.b $96 ; $11 - cave time level 4
                        dc.b $96 ; $12 - cave time level 5
                        dc.b $09 ; $13 - back colour 1
                        dc.b $0a ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileBldrFix ; $18 - random object 1
                        dc.b B1_TileEmpty   ; $19 - random object 2
                        dc.b B1_TileEmpty   ; $1a - random object 3
                        dc.b B1_TileEmpty   ; $1b - random object 4
                        dc.b $32 ; $1c - probability object 1
                        dc.b $00 ; $1d - probability object 2
                        dc.b $00 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_10_Var         equ  *   ;
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $01 , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $27 , $04                                 ; TileNo, Col, Row
                        BD1_CaveDrawRectFill  B1_TileSoil       , $08 , $13 , $04 , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileFireFly0   , $0a , $14                                 ; TileNo, Col, Row
                        BD1_CaveDrawRect      B1_TileWallStone  , $07 , $0a , $06 , $08                     ; TileNo, Col, Row, Len, Height
                        BD1_CaveDrawLine      B1_TileWallMagic  , $07 , $0a , $06 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawRectFill  B1_TileSoil       , $10 , $13 , $04 , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileFireFly0   , $12 , $14                                 ; TileNo, Col, Row
                        BD1_CaveDrawRect      B1_TileWallStone  , $0f , $0a , $06 , $08                     ; TileNo, Col, Row, Len, Height
                        BD1_CaveDrawLine      B1_TileWallMagic  , $0f , $0a , $06 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawRectFill  B1_TileSoil       , $18 , $13 , $04 , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileFireFly0   , $1a , $14                                 ; TileNo, Col, Row
                        BD1_CaveDrawRectFill  B1_TileSoil       , $20 , $13 , $04 , $04 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileFireFly0   , $22 , $14                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 11
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_11             equ  *   ;
CaveData_11_Fix         equ  *   ;
                        dc.b $11 ; $00 - cave no
                        dc.b $14 ; $01 - magic wall time
                        dc.b $1e ; $02 - normal diamond value
                        dc.b $00 ; $03 - extra  diamond value
                        dc.b $0a ; $04 - rnd seed level 1
                        dc.b $0b ; $05 - rnd seed level 2
                        dc.b $0c ; $06 - rnd seed level 3
                        dc.b $0d ; $07 - rnd seed level 4
                        dc.b $0e ; $08 - rnd seed level 5
                        dc.b $06 ; $09 - diamonds to get level 1
                        dc.b $06 ; $0a - diamonds to get level 2
                        dc.b $06 ; $0b - diamonds to get level 3
                        dc.b $06 ; $0c - diamonds to get level 4
                        dc.b $06 ; $0d - diamonds to get level 5
                        dc.b $0a ; $0e - cave time level 1
                        dc.b $0a ; $0f - cave time level 2
                        dc.b $0a ; $10 - cave time level 3
                        dc.b $0a ; $11 - cave time level 4
                        dc.b $0a ; $12 - cave time level 5
                        dc.b $0e ; $13 - back colour 1
                        dc.b $02 ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileEmpty   ; $18 - random object 1
                        dc.b B1_TileDmndFix ; $19 - random object 2
                        dc.b B1_TileEmpty   ; $1a - random object 3
                        dc.b B1_TileEmpty   ; $1b - random object 4
                        dc.b $ff ; $1c - probability object 1
                        dc.b $09 ; $1d - probability object 2
                        dc.b $00 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_11_Var         equ  *   ;
                        BD1_CaveDrawRectFill  B1_TileWallSteel  , $00 , $02 , $28 , $16 , B1_TileWallSteel  ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileWallSteel  , $00 , $02 , $14 , $0c , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileBttrFly2   , $0a , $0c                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileBldrFix    , $0a , $04                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileSoil       , $0a , $05                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $03 , $05                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $12 , $0c                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 12
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_12             equ  *   ;
CaveData_12_Fix         equ  *   ;
                        dc.b $12 ; $00 - cave no
                        dc.b $14 ; $01 - magic wall time
                        dc.b $0a ; $02 - normal diamond value
                        dc.b $00 ; $03 - extra  diamond value
                        dc.b $0a ; $04 - rnd seed level 1
                        dc.b $0b ; $05 - rnd seed level 2
                        dc.b $0c ; $06 - rnd seed level 3
                        dc.b $0d ; $07 - rnd seed level 4
                        dc.b $0e ; $08 - rnd seed level 5
                        dc.b $10 ; $09 - diamonds to get level 1
                        dc.b $10 ; $0a - diamonds to get level 2
                        dc.b $10 ; $0b - diamonds to get level 3
                        dc.b $10 ; $0c - diamonds to get level 4
                        dc.b $10 ; $0d - diamonds to get level 5
                        dc.b $0f ; $0e - cave time level 1
                        dc.b $0f ; $0f - cave time level 2
                        dc.b $0f ; $10 - cave time level 3
                        dc.b $0f ; $11 - cave time level 4
                        dc.b $0f ; $12 - cave time level 5
                        dc.b $06 ; $13 - back colour 1
                        dc.b $0f ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileEmpty ; $18 - random object 1
                        dc.b B1_TileEmpty ; $19 - random object 2
                        dc.b B1_TileEmpty ; $1a - random object 3
                        dc.b B1_TileEmpty ; $1b - random object 4
                        dc.b $00 ; $1c - probability object 1
                        dc.b $00 ; $1d - probability object 2
                        dc.b $00 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_12_Var         equ  *   ;
                        BD1_CaveDrawRectFill  B1_TileWallSteel  , $00 , $02 , $28 , $16 , B1_TileWallSteel  ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileWallSteel  , $00 , $02 , $14 , $0c , B1_TileSoil       ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawLine      B1_TileBldrFix    , $01 , $03 , $09 , "se"                    ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileFireFly0   , $02 , $03 , $08 , "se"                    ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileDmndFix    , $01 , $05 , $08 , "se"                    ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileBldrFix    , $01 , $06 , $07 , "se"                    ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileBldrFix    , $12 , $03 , $09 , "sw"                    ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileDmndFix    , $12 , $05 , $08 , "sw"                    ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileBldrFix    , $12 , $06 , $07 , "sw"                    ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $01 , $04                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $12 , $04                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 13
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_13             equ  *   ;
CaveData_13_Fix         equ  *   ;
                        dc.b $13 ; $00 - cave no
                        dc.b $04 ; $01 - magic wall time
                        dc.b $0a ; $02 - normal diamond value
                        dc.b $00 ; $03 - extra  diamond value
                        dc.b $0a ; $04 - rnd seed level 1
                        dc.b $0b ; $05 - rnd seed level 2
                        dc.b $0c ; $06 - rnd seed level 3
                        dc.b $0d ; $07 - rnd seed level 4
                        dc.b $0e ; $08 - rnd seed level 5
                        dc.b $0e ; $09 - diamonds to get level 1
                        dc.b $0e ; $0a - diamonds to get level 2
                        dc.b $0e ; $0b - diamonds to get level 3
                        dc.b $0e ; $0c - diamonds to get level 4
                        dc.b $0e ; $0d - diamonds to get level 5
                        dc.b $14 ; $0e - cave time level 1
                        dc.b $14 ; $0f - cave time level 2
                        dc.b $14 ; $10 - cave time level 3
                        dc.b $14 ; $11 - cave time level 4
                        dc.b $14 ; $12 - cave time level 5
                        dc.b $06 ; $13 - back colour 1
                        dc.b $08 ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileEmpty ; $18 - random object 1
                        dc.b B1_TileEmpty ; $19 - random object 2
                        dc.b B1_TileEmpty ; $1a - random object 3
                        dc.b B1_TileEmpty ; $1b - random object 4
                        dc.b $00 ; $1c - probability object 1
                        dc.b $00 ; $1d - probability object 2
                        dc.b $00 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_13_Var         equ  *   ;
                        BD1_CaveDrawRectFill  B1_TileWallSteel  , $00 , $02 , $28 , $16 , B1_TileWallSteel  ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileWallSteel  , $00 , $02 , $14 , $0c , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawLine      B1_TileDmndFix    , $01 , $0c , $12 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawRectFill  B1_TileFireFly0   , $0f , $09 , $04 , $04 , B1_TileFireFly0   ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $08 , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $12 , $07                                 ; TileNo, Col, Row
                        dc.b $ff ; <EndOfCave>
; -------------------------------------------------------------------------------------------------------------- ;
; Cave 14
; -------------------------------------------------------------------------------------------------------------- ;
CaveData_14             equ  *   ;
CaveData_14_Fix         equ  *   ;
                        dc.b $14 ; $00 - cave no
                        dc.b $03 ; $01 - magic wall time
                        dc.b $1e ; $02 - normal diamond value
                        dc.b $00 ; $03 - extra  diamond value
                        dc.b $00 ; $04 - rnd seed level 1
                        dc.b $00 ; $05 - rnd seed level 2
                        dc.b $00 ; $06 - rnd seed level 3
                        dc.b $00 ; $07 - rnd seed level 4
                        dc.b $00 ; $08 - rnd seed level 5
                        dc.b $06 ; $09 - diamonds to get level 1
                        dc.b $06 ; $0a - diamonds to get level 2
                        dc.b $06 ; $0b - diamonds to get level 3
                        dc.b $06 ; $0c - diamonds to get level 4
                        dc.b $06 ; $0d - diamonds to get level 5
                        dc.b $14 ; $0e - cave time level 1
                        dc.b $14 ; $0f - cave time level 2
                        dc.b $14 ; $10 - cave time level 3
                        dc.b $14 ; $11 - cave time level 4
                        dc.b $14 ; $12 - cave time level 5
                        dc.b $06 ; $13 - back colour 1
                        dc.b $08 ; $14 - back colour 2
                        dc.b $09 ; $15 - fore colour
                        dc.b $00 ; $16 - - not used -
                        dc.b $00 ; $17 - - not used -
                        dc.b B1_TileEmpty ; $18 - random object 1
                        dc.b B1_TileEmpty ; $19 - random object 2
                        dc.b B1_TileEmpty ; $1a - random object 3
                        dc.b B1_TileEmpty ; $1b - random object 4
                        dc.b $00 ; $1c - probability object 1
                        dc.b $00 ; $1d - probability object 2
                        dc.b $00 ; $1e - probability object 3
                        dc.b $00 ; $1f - probability object 4
; ------------------------------------------------------------------------------------------------------------- ;
CaveData_14_Var         equ  *   ;
                        BD1_CaveDrawRectFill  B1_TileWallSteel  , $00 , $02 , $28 , $16 , B1_TileWallSteel  ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRectFill  B1_TileWallSteel  , $00 , $02 , $14 , $0c , B1_TileSoil       ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawRect      B1_TileBldrFix    , $0b , $03 , $03 , $02                     ; TileNo, Col, Row, Len, Height
                        BD1_CaveDrawRectFill  B1_TileEmpty      , $0b , $07 , $03 , $06 , B1_TileEmpty      ; TileNo, Col, Row, Len, Height, TileNo_Fill
                        BD1_CaveDrawLine      B1_TileWallMagic  , $0b , $06 , $03 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileWallMagic  , $0b , $0a , $03 , "e"                     ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawLine      B1_TileBldrFix    , $08 , $07 , $03 , "se"                    ; TileNo, Col, Row, Len, Dir
                        BD1_CaveDrawTile      B1_TileBirthRF0   , $03 , $03                                 ; TileNo, Col, Row
                        BD1_CaveDrawTile      B1_TileXitClose   , $09 , $0a                                 ; TileNo, Col, Row
                        dc.b $ff
; -------------------------------------------------------------------------------------------------------------- ;
