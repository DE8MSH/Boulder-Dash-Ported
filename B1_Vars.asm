; ------------------------------------------------------------------------------------------------------------- ;
; Boulder Dash I Game Variables
; ------------------------------------------------------------------------------------------------------------- ;
; Tables and Screens
; ------------------------------------------------------------------------------------------------------------- ;
B1_CtrlScreen                 = $0800
                              
B1_PlayScreen                 = $0c00
B1_PlayScrHdr                 = $0c00
B1_PlayScrHdrTi3              = $0c14   ; time 100s
B1_PlayScrHdrTi2              = $0c16   ; time 10s
B1_PlayScrHdrTi1              = $0c18   ; time 1s
B1_PlayScrDat                 = $0c28
B1_PlayScrDatR02              = $0c50
                              
B1_WaitScreenTxt              = $0800
B1_WScrOffNoPlr                 = $0370 ; position player   no on start screen
B1_WScrOffNoJoy                 = $0384 ; position joystick no on start screen
B1_WScrOffNoCav                 = $03a6 ; position cave     no on start screen
B1_WScrOffNoLvl                 = $03ba ; position level    no on start screen
                              
B1_WaitScreenGfx              = $0c00
B1_WaitScrTxtHdr              = $0c00
B1_WaitScrTxtDat              = $0c50
                              
B1_CharSet                    = $2000
B1_SavScreen                  = $2c00
B1_GfxSet                     = $3000
B1_PlayField                  = $4000
; ------------------------------------------------------------------------------------------------------------- ;
B1_ScrnRow_00                  = [$00 * B1_ColMax] ; $0000  ; 
B1_ScrnRow_01                  = [$01 * B1_ColMax] ; $0028  ; 
B1_ScrnRow_02                  = [$02 * B1_ColMax] ; $0050  ; 
B1_ScrnRow_03                  = [$03 * B1_ColMax] ; $0078  ; 
B1_ScrnRow_04                  = [$04 * B1_ColMax] ; $00a0  ; 
B1_ScrnRow_05                  = [$05 * B1_ColMax] ; $00c8  ; 
B1_ScrnRow_06                  = [$06 * B1_ColMax] ; $00f0  ; 
B1_ScrnRow_07                  = [$07 * B1_ColMax] ; $0118  ; 
B1_ScrnRow_08                  = [$08 * B1_ColMax] ; $0140  ; 
B1_ScrnRow_09                  = [$09 * B1_ColMax] ; $0168  ; 
B1_ScrnRow_10                  = [$0a * B1_ColMax] ; $0190  ; 
B1_ScrnRow_11                  = [$0b * B1_ColMax] ; $01b8  ; 
B1_ScrnRow_12                  = [$0c * B1_ColMax] ; $01e0  ; 
B1_ScrnRow_13                  = [$0d * B1_ColMax] ; $0208  ; 
B1_ScrnRow_14                  = [$0e * B1_ColMax] ; $0230  ; 
B1_ScrnRow_15                  = [$0f * B1_ColMax] ; $0258  ; 
B1_ScrnRow_16                  = [$10 * B1_ColMax] ; $0280  ; 
B1_ScrnRow_17                  = [$11 * B1_ColMax] ; $02a8  ; 
B1_ScrnRow_18                  = [$12 * B1_ColMax] ; $02d0  ; 
B1_ScrnRow_19                  = [$13 * B1_ColMax] ; $02f8  ; 
B1_ScrnRow_20                  = [$14 * B1_ColMax] ; $0320  ; 
B1_ScrnRow_21                  = [$15 * B1_ColMax] ; $0348  ; 
B1_ScrnRow_22                  = [$16 * B1_ColMax] ; $0370  ; 
B1_ScrnRow_23                  = [$17 * B1_ColMax] ; $0398  ; 
B1_ScrnRow_24                  = [$18 * B1_ColMax] ; $03c0  ; 
; ------------------------------------------------------------------------------------------------------------- ;
B1_CtrlRow_00                 = [B1_CtrlScreen + B1_ScrnRow_00] ; $0800 
B1_CtrlRow_01                 = [B1_CtrlScreen + B1_ScrnRow_01] ; $0828 
B1_CtrlRow_02                 = [B1_CtrlScreen + B1_ScrnRow_02] ; $0850 
B1_CtrlRow_03                 = [B1_CtrlScreen + B1_ScrnRow_03] ; $0878 
B1_CtrlRow_04                 = [B1_CtrlScreen + B1_ScrnRow_04] ; $08a0 
B1_CtrlRow_05                 = [B1_CtrlScreen + B1_ScrnRow_05] ; $08c8 
B1_CtrlRow_06                 = [B1_CtrlScreen + B1_ScrnRow_06] ; $08f0 
B1_CtrlRow_07                 = [B1_CtrlScreen + B1_ScrnRow_07] ; $0918 
B1_CtrlRow_08                 = [B1_CtrlScreen + B1_ScrnRow_08] ; $0940 
B1_CtrlRow_09                 = [B1_CtrlScreen + B1_ScrnRow_09] ; $0968 
B1_CtrlRow_10                 = [B1_CtrlScreen + B1_ScrnRow_10] ; $0990 
B1_CtrlRow_11                 = [B1_CtrlScreen + B1_ScrnRow_11] ; $09b8 
B1_CtrlRow_12                 = [B1_CtrlScreen + B1_ScrnRow_12] ; $09e0 
B1_CtrlRow_13                 = [B1_CtrlScreen + B1_ScrnRow_13] ; $0a08 
B1_CtrlRow_14                 = [B1_CtrlScreen + B1_ScrnRow_14] ; $0a30 
B1_CtrlRow_15                 = [B1_CtrlScreen + B1_ScrnRow_15] ; $0a58 
B1_CtrlRow_16                 = [B1_CtrlScreen + B1_ScrnRow_16] ; $0a80 
B1_CtrlRow_17                 = [B1_CtrlScreen + B1_ScrnRow_17] ; $0aa8 
B1_CtrlRow_18                 = [B1_CtrlScreen + B1_ScrnRow_18] ; $0ad0 
B1_CtrlRow_19                 = [B1_CtrlScreen + B1_ScrnRow_19] ; $0af8 
B1_CtrlRow_20                 = [B1_CtrlScreen + B1_ScrnRow_20] ; $0b20 
B1_CtrlRow_21                 = [B1_CtrlScreen + B1_ScrnRow_21] ; $0b48 
B1_CtrlRow_22                 = [B1_CtrlScreen + B1_ScrnRow_22] ; $0b70 
B1_CtrlRow_23                 = [B1_CtrlScreen + B1_ScrnRow_23] ; $0b98 
B1_CtrlRow_24                 = [B1_CtrlScreen + B1_ScrnRow_24] ; $0bc0 
; ------------------------------------------------------------------------------------------------------------- ;
B1_CtrlData                   = B1_CtrlScreen      ; 
B1_CtrlData_Cols              = B1_ColMax          ; 
B1_CtrlData_Rows              = [B1_RowMax - $01]  ; 
B1_CtrlData_RowUp1_ColLe        = $01 + B1_CtrlData_Cols - [B1_CtrlData_Cols * $01] - $01 ; $00
B1_CtrlData_RowUp1_ColUp        = $01 + B1_CtrlData_Cols - [B1_CtrlData_Cols * $01] + $00 ; $01
B1_CtrlData_RowUp1_ColRi        = $01 + B1_CtrlData_Cols - [B1_CtrlData_Cols * $01] + $01 ; $02

B1_CtrlData_Row_ColLe2          = $01 + B1_CtrlData_Cols + [B1_CtrlData_Cols * $00] - $02 ; $27 
B1_CtrlData_Row_ColLe1          = $01 + B1_CtrlData_Cols + [B1_CtrlData_Cols * $00] - $01 ; $28 
B1_CtrlData_Row_Col             = $01 + B1_CtrlData_Cols + [B1_CtrlData_Cols * $00] + $00 ; $29 center: B2Z_CaveCtrlFieldPos start: CaveCtrlField + (B1_CtrlData_Cols - $01)
B1_CtrlData_Row_ColRi1          = $01 + B1_CtrlData_Cols + [B1_CtrlData_Cols * $00] + $01 ; $2a 
B1_CtrlData_Row_ColRi2          = $01 + B1_CtrlData_Cols + [B1_CtrlData_Cols * $00] + $02 ; $2b 

B1_CtrlData_RowDo1_ColLe        = $01 + B1_CtrlData_Cols + [B1_CtrlData_Cols * $01] - $01 ; $50 
B1_CtrlData_RowDo1_ColUp        = $01 + B1_CtrlData_Cols + [B1_CtrlData_Cols * $01] + $00 ; $51 
B1_CtrlData_RowDo1_ColRi        = $01 + B1_CtrlData_Cols + [B1_CtrlData_Cols * $01] + $01 ; $52 

B1_CtrlData_RowDo2_ColLe        = $01 + B1_CtrlData_Cols + [B1_CtrlData_Cols * $02] - $01 ; $78 
B1_CtrlData_RowDo2_ColUp        = $01 + B1_CtrlData_Cols + [B1_CtrlData_Cols * $02] + $00 ; $79 
B1_CtrlData_RowDo2_ColRi        = $01 + B1_CtrlData_Cols + [B1_CtrlData_Cols * $02] + $01 ; $7a
; -------------------------------------------------------------------------------------------------------------- ;
B1_DataGfxScrnFullLen         = B1_ColMax * $04 ; $a0
B1_DataGfxScrnHalfLen         = B1_ColMax * $02 ; $50
; -------------------------------------------------------------------------------------------------------------- ;
; Misc
; ------------------------------------------------------------------------------------------------------------- ;
B1_ColMin                       = $00
B1_ColMax                       = $28
B1_RowMin                       = $00
B1_RowMax                       = $16
B1_RowMaxXtra                   = $0f             ; bonus levels are smaller
B1_LenTxtRow                    = [B1_ColMax / 2] ; each chr occupies 2 cols
B1_LenGameDiPts                 = $01             ; length store diamond points
B1_LenGameDiGet                 = $01             ; length store diamond to get
B1_LenGameDiGot                 = $01             ; length store diamond already got
B1_LenHex2Dec10                 = $01             ; length convert a 2 digit hex value
B1_LenHex2Dec100                = $02             ; length convert a 3 digit hex value
B1_LenGameTime                  = $02             ; length store scores
B1_LenScores                    = $05
B1_LenStatus                    = $08
B1_LenPlayerData                = $0e             ; length player data
B1_LenSfxData                   = $06             ; length sound effects data
; ------------------------------------------------------------------------------------------------------------- ;
; Cave Tiles
; ------------------------------------------------------------------------------------------------------------- ;
B1_TileEmpty                    = $00 ; 
B1_TileSoil                     = $01 ; 
B1_TileWallStone                = $02 ; 
B1_TileWallMagic                = $03 ; 
B1_TileXitClose                 = $04 ; 
B1_TileXitOpen                  = $05 ; 
B1_Tile06                       = $06 ; 
B1_TileWallSteel                = $07 ; 
B1_TileFireFly0                 = $08 ; 
B1_TileFireFly1                 = $09 ; 
B1_TileFireFly2                 = $0a ; 
B1_TileFireFly3                 = $0b ; 
B1_TileFireFly0_                = $0c ; replacement
B1_TileFireFly1_                = $0d ; replacement 
B1_TileFireFly2_                = $0e ; replacement
B1_TileFireFly3_                = $0f ; replacement
B1_TileBldrFix                  = $10 ; 
B1_TileBldrFix_                 = $11 ; replacement
B1_TileBldrFall                 = $12 ; 
B1_TileBldrFall_                = $13 ; replacement
B1_TileDmndFix                  = $14 ; 
B1_TileDmndFix_                 = $15 ; replacement
B1_TileDmndFall                 = $16 ; 
B1_TileDmndFall_                = $17 ; replacement
B1_Tile18                       = $18 ; 
B1_Tile19                       = $19 ; 
B1_Tile1a                       = $1a ; 
B1_TileXplEmpty0                = $1b ; 
B1_TileXplEmpty1                = $1c ; 
B1_TileXplEmpty2                = $1d ; 
B1_TileXplEmpty3                = $1e ; 
B1_TileXplEmpty4                = $1f ; 
B1_TileExplDmnd0                = $20 ; 
B1_TileExplDmnd1                = $21 ; 
B1_TileExplDmnd2                = $22 ; 
B1_TileExplDmnd3                = $23 ; 
B1_TileExplDmnd4                = $24 ; 
B1_TileBirthRF0                 = $25 ; 
B1_TileBirthRF1                 = $26 ; 
B1_TileBirthRF2                 = $27 ; 
B1_TileBirthRF3                 = $28 ; 
B1_Tile29                       = $29 ; 
B1_Tile2a                       = $2a ; 
B1_Tile2b                       = $2b ; 
B1_Tile2c                       = $2c ; 
B1_Tile2d                       = $2d ; 
B1_Tile2e                       = $2e ; 
B1_Tile2f                       = $2f ; 
B1_TileBttrFly0                 = $30 ; 
B1_TileBttrFly1                 = $31 ; 
B1_TileBttrFly2                 = $32 ; 
B1_TileBttrFly3                 = $33 ; 
B1_TileBttrFly0_                = $34 ; replacement
B1_TileBttrFly1_                = $35 ; replacement
B1_TileBttrFly2_                = $36 ; replacement
B1_TileBttrFly3_                = $37 ; replacement
B1_TileRockFord                 = $38 ; 
B1_TileRockFord_                = $39 ; replacement
B1_TileAmoeba                   = $3a ; 
B1_TileAmoeba_                  = $3b ; replacement
B1_Tile3c                       = $3c ; 
B1_Tile3d                       = $3d ; 
B1_Tile3e                       = $3e ; 
B1_Tile3f                       = $3f ; 
                                
B1_TileMax                      = B1_Tile3f
; ------------------------------------------------------------------------------------------------------------- ;
B1_CaveData                     = $2400
B1_CaveDataFix                  = B1_CaveData + $00    ; cave data fix part
B1_CaveNo                       = B1_CaveData + $00
B1_CaveTimWall                  = B1_CaveData + $01
B1_CavePtsDia                   = B1_CaveData + $02    ; normal diamonds score
B1_CaveXtrDia                   = B1_CaveData + $03    ; xtra   diamonds score
B1_CaveSeeds                    = B1_CaveData + $04
B1_CaveSeedL0                     = B1_CaveData + $04
B1_CaveSeedL1                     = B1_CaveData + $05
B1_CaveSeedL2                     = B1_CaveData + $06
B1_CaveSeedL3                     = B1_CaveData + $07
B1_CaveSeedL4                     = B1_CaveData + $08
B1_CaveGetDias                  = B1_CaveData + $09    ; number of diamonds to get
B1_CaveGetDiaL0                   = B1_CaveData + $09
B1_CaveGetDiaL1                   = B1_CaveData + $0a
B1_CaveGetDiaL2                   = B1_CaveData + $0b
B1_CaveGetDiaL3                   = B1_CaveData + $0c
B1_CaveGetDiaL4                   = B1_CaveData + $0d
B1_CaveTimes                    = B1_CaveData + $0e
B1_CaveTimeL0                     = B1_CaveData + $0e
B1_CaveTimeL1                     = B1_CaveData + $0f
B1_CaveTimeL2                     = B1_CaveData + $10
B1_CaveTimeL3                     = B1_CaveData + $11
B1_CaveTimeL4                     = B1_CaveData + $12
B1_CaveColors                   = B1_CaveData + $13
B1_CaveColorB1                    = B1_CaveData + $13  ; $D022 = BackGround Color 1
B1_CaveColorB2                    = B1_CaveData + $14  ; $D023 = BackGround Color 2
B1_CaveColorF1                    = B1_CaveData + $15  ; $D800 = ColorRam
B1_Cave16                       = B1_CaveData + $16
B1_Cave17                       = B1_CaveData + $17
                                
B1_CaveRndObjLen                  = $04
B1_CaveGenerator                = B1_CaveData + $18    ; up to 4 objects will be spread pseudo randomly
B1_CaveTypeObjs                 = B1_CaveData + $18    ; object numbers
B1_CaveTypeObj0                   = B1_CaveData + $18
B1_CaveTypeObj1                   = B1_CaveData + $19
B1_CaveTypeObj2                   = B1_CaveData + $1a
B1_CaveTypeObj3                   = B1_CaveData + $1b
B1_CaveProbObjs                 = B1_CaveData + $1c    ; object probabilities
B1_CaveProbObj0                   = B1_CaveData + $1c
B1_CaveProbObj1                   = B1_CaveData + $1d
B1_CaveProbObj2                   = B1_CaveData + $1e
B1_CaveProbObj3                   = B1_CaveData + $1f
                                
B1_CaveDataVar                  = B1_CaveData + $20    ; cave data variable part - var no of structs ended by B1_EndOfCaveData
B1_CaveTile                     = B1_CaveDataVar + $00
B1_XtraBits                       = $c0                ; ##...... - struct no
B1_DataBits                       = $3f                ; ..###### - object no
B1_CaveTilePosX                 = B1_CaveDataVar + $01
B1_CaveTilePosY                 = B1_CaveDataVar + $02
B1_CaveTileLen                  = B1_CaveDataVar + $03
B1_CaveTileLenX                 = B1_CaveDataVar + $03
B1_CaveTileLenY                 = B1_CaveDataVar + $04
B1_CaveTileDir                  = B1_CaveDataVar + $04
B1_CaveDrawDir_N                  = $00
B1_CaveDrawDir_NE                 = $01
B1_CaveDrawDir_E                  = $02
B1_CaveDrawDir_SE                 = $03
B1_CaveDrawDir_S                  = $04
B1_CaveDrawDir_SW                 = $05
B1_CaveDrawDir_W                  = $06
B1_CaveDrawDir_NW                 = $07
B1_CaveTileFill                 = B1_CaveDataVar + $05
B1_EndOfCaveData                  = $ff                ; marker: end of cave description variable part
; ------------------------------------------------------------------------------------------------------------- ;
; Cave Var Data Functions
; ------------------------------------------------------------------------------------------------------------- ;
B1_CaveStrOb                    = $00                  ; FunctionID 00 - single object
___CaveTile                     = B1_CaveTile
___CaveTilePosX                 = B1_CaveTilePosX
___CaveTilePosY                 = B1_CaveTilePosY
                                
B1_CaveStrLi                    = $01                  ; FunctionID 01 - object line
___CaveTile                     = B1_CaveTile
___CaveTilePosX                 = B1_CaveTilePosX
___CaveTilePosY                 = B1_CaveTilePosY
___CaveTileLen                  = B1_CaveTileLen
___CaveTileDir                  = B1_CaveTileDir
                                
B1_CaveStrBoWiFi                = $10                  ; FunctionID 10 - object box with fill object
____CaveTile                    = B1_CaveTile
____CaveTilePosX                = B1_CaveTilePosX
____CaveTilePosY                = B1_CaveTilePosY
____CaveTileLenX                = B1_CaveTileLenX
____CaveTileLenY                = B1_CaveTileLenY
____CaveTileFill                = B1_CaveTileFill
                                
B1_CaveStrBoNoFi                = $11                  ; FunctionID 11 - object box without fill object
____CaveTile                    = B1_CaveTile
____CaveTilePosX                = B1_CaveTilePosX
____CaveTilePosY                = B1_CaveTilePosY
____CaveTileLenX                = B1_CaveTileLenX
____CaveTileLenY                = B1_CaveTileLenY
; ------------------------------------------------------------------------------------------------------------- ;
; Variable
; ------------------------------------------------------------------------------------------------------------- ;
B1_Game_Vars                    = $9800
B1_TitleMusicTabPtr             = B1_Game_Vars       + $00 ; 
B1_TitleMusicEnd                = B1_Game_Vars       + $01 ; 
B1_TitleMusicEnd_Yes            = $02 ;              
B1_TitleMusicEnd_No             = $00 ;              
B1_AmoebaCountThis              = B1_Game_Vars       + $02 ; 
B1_AmoebaCountLast              = B1_Game_Vars       + $03 ; 
B1_PseudoRND_01                 = B1_Game_Vars       + $04 ; 
B1_PseudoRND_02                 = B1_Game_Vars       + $05 ; 
B1_StatusDataLenWrk             = B1_Game_Vars       + $06 ; 
B1_VicVMCSB                     = B1_Game_Vars       + $07 ; 
B1_IRQSfx                       = B1_Game_Vars       + $08 ; 
B1_IRQSfxWait                   = B1_Game_Vars       + $09 ; 
B1_IRQSfxWaitStop               = B1_Game_Vars       + $0a ; 
B1_IRQSfxWaitStop_Ini             = $08                    ; 
B1_IRQSfxWaitStop_Shift           = $02                    ; 
B1_SfxRandomCtrl                = B1_Game_Vars       + $0b ; 
B1_TitleMusicSuRe               = B1_Game_Vars       + $0c ; start music voice 1 sustain/release
B1_SfxToPlayCount               = B1_Game_Vars       + $0d ; 
B1_Unused_01                    = B1_Game_Vars       + $0e ; 
B1_SfxWaveForm                  = B1_Game_Vars       + $0f ; 
B1_Unused_02                    = B1_Game_Vars       + $10 ; 
B1_IRQSfxTime                   = B1_Game_Vars       + $11 ; 
; ------------------------------------------------------------------------------------------------------------- ;
; Status Lines
; ------------------------------------------------------------------------------------------------------------- ;
B1_SavRowScrLast                = B1_Game_Vars       + $12 ; last scores
B1_SavRowScrLaP1                  = B1_SavRowScrLast + $01 ; 
B1_SavRowScrLaP2                  = B1_SavRowScrLast + $0d ; 

B1_SavRowScrHigh                = B1_SavRowScrLast   + (B1_LenTxtRow * 1) ; high scores
B1_SavRowScrHiP1                  = B1_SavRowScrHigh + $01 ; 
B1_SavRowScrHiP2                  = B1_SavRowScrHigh + $0d ; 

B1_SavRowStatus                 = B1_SavRowScrLast   + (B1_LenTxtRow * 2) ; status
B1_SavRowStDiGet                  = B1_SavRowStatus  + $01 ; 
B1_SavRowStDiChr                  = B1_SavRowStatus  + $03 ; 
B1_SavRowStDiPts                  = B1_SavRowStatus  + $04 ; 
B1_SavRowStDiGot                  = B1_SavRowStatus  + $07 ; 
B1_SavRowStTime                   = B1_SavRowStatus  + $0a ; 
B1_SavRowStScore                  = B1_SavRowStatus  + $0e ; 

B1_SavRowPlayer                 = B1_SavRowScrLast   + (B1_LenTxtRow * 3) ; infos
B1_SavRowPlrNo                    = B1_SavRowPlayer  + $07 ; 
B1_SavRowPlrMen                   = B1_SavRowPlayer  + $0a ; 
B1_SavRowPlrType                  = B1_SavRowPlayer  + $0d ; 
B1_SavRowPlrCave                  = B1_SavRowPlayer  + $10 ; 
B1_SavRowPlrLvl                   = B1_SavRowPlayer  + $12 ; 

B1_SavRowTemp                   = B1_SavRowScrLast   + (B1_LenTxtRow * 4) ; save 
; ------------------------------------------------------------------------------------------------------------- ;
B1_SfxToPlayWork                = B1_Game_Vars       + $76 ; 
B1_SfxToPlayBuffer              = B1_Game_Vars       + $7d ; 
B1_SfxToPlayBuffer_Len            = $06                    ; 
; ------------------------------------------------------------------------------------------------------------- ;
