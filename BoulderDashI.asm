; ------------------------------------------------------------------------------------------------------------- ;
; Boulder Dash 01             - BD1.PRG from $5000 to $8E7F
; ------------------------------------------------------------------------------------------------------------- ;
; Memory Map                                               ; 
; ------------------------------------------------------------------------------------------------------------- ;

; ------------------------------------------------------------------------------------------------------------- ;
                              * = $5000                    ; 2nd Start address - entry: GameStart
; ------------------------------------------------------------------------------------------------------------- ;
                              incdir  ..\inc               ; C64 System Includes
                              
C64CIA1                       include cia1.asm             ; Complex Interface Adapter (CIA) #1 Registers  $DC00-$DC0F
C64CIA2                       include cia2.asm             ; Complex Interface Adapter (CIA) #2 Registers  $DD00-$DD0F
C64SID                        include sid.asm              ; Sound Interface Device (SID) Registers        $D400-$D41C
C64VicII                      include vic.asm              ; Video Interface Chip (VIC-II) Registers       $D000-$D02E
C64Kernel                     include kernel.asm           ; Kernel Vectors
C64Colors                     include color.asm            ; Colour RAM Address / Colours
C64Memory                     include mem.asm              ; C64 Memory Layout
C64StdMem                     include C64_mem.asm          ; Standard Zeropage / Stack / Vectors
;                                                          ; 
ZeroPageVars                  include inc\B1_Zpg.asm       ; Zero Page Variables
InGameVars                    include inc\B1_Vars.asm      ; Game Variables
Macros                        include inc\B1_CaveMacs.asm  ; Cave Function Macros
; ------------------------------------------------------------------------------------------------------------- ;
; Start Of Data                                            ; 
; ------------------------------------------------------------------------------------------------------------- ;
Chr                           include  inc\B1_ChrS.asm     ; Charcter Set
; ------------------------------------------------------------------------------------------------------------- ;
CavePlayFieldPosAdd_Id        equ  *        ; 
CavePlayFieldPosAdd_Lo        equ [* + $01] ; 
CavePlayFieldPosAdd_Hi        equ [* + $02] ; 
                              
.PrevRow                      dc.b B1_CtrlData_RowUp1_ColLe                    ; 
                              dc.w [$00 - [B1_DataGfxScrnFullLen * $01] - $02] ; 
                              dc.b B1_CtrlData_RowUp1_ColUp                    ; 
                              dc.w [$00 - [B1_DataGfxScrnFullLen * $01] + $00] ; 
                              dc.b B1_CtrlData_RowUp1_ColRi                    ; 
                              dc.w [$00 - [B1_DataGfxScrnFullLen * $01] + $02] ; 
                              
.SameRow                      dc.b B1_CtrlData_Row_ColLe1                      ; 
                              dc.w [$00 + [B1_DataGfxScrnFullLen * $00] - $02] ; 
                              dc.b B1_CtrlData_Row_ColLe2                      ; 
                              dc.w [$00 + [B1_DataGfxScrnFullLen * $00] - $04] ; 
                              
.Center                       dc.b B1_CtrlData_Row_Col                         ; 
                              dc.w $00                                         ; 
                              
                              dc.b B1_CtrlData_Row_ColRi1                      ; 
                              dc.w [$00 + [B1_DataGfxScrnFullLen * $00] + $02] ; 
                              dc.b B1_CtrlData_Row_ColRi2                      ; 
                              dc.w [$00 + [B1_DataGfxScrnFullLen * $00] + $04] ; 
                              
.1stNextRow                   dc.b B1_CtrlData_RowDo1_ColLe                    ; 
                              dc.w [$00 + [B1_DataGfxScrnFullLen * $01] - $02] ; 
                              dc.b B1_CtrlData_RowDo1_ColUp                    ; 
                              dc.w [$00 + [B1_DataGfxScrnFullLen * $01] + $00] ; 
                              dc.b B1_CtrlData_RowDo1_ColRi                    ; 
                              dc.w [$00 + [B1_DataGfxScrnFullLen * $01] + $02] ; 
                              
.2ndNextRow                   dc.b B1_CtrlData_RowDo2_ColLe                    ; 
                              dc.w [$00 + [B1_DataGfxScrnFullLen * $02] - $02] ; 
                              dc.b B1_CtrlData_RowDo2_ColUp                    ; 
                              dc.w [$00 + [B1_DataGfxScrnFullLen * $02] + $00] ; 
                              dc.b B1_CtrlData_RowDo2_ColRi                    ; 
                              dc.w [$00 + [B1_DataGfxScrnFullLen * $02] + $02] ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabScrnDataRowOff             equ  * ; 
TabScrnDataRowOff_Lo          equ  * ; 
TabScrnDataRowOff_Hi          equ  [* + $01] ; 
                        
                              dc.w B1_PlayField + [$00 * B1_ColMax * 4] + 3 ; $4003
                              dc.w B1_PlayField + [$01 * B1_ColMax * 4] + 3 ; $40a3
                              dc.w B1_PlayField + [$02 * B1_ColMax * 4] + 3 ; $4143
                              dc.w B1_PlayField + [$03 * B1_ColMax * 4] + 3 ; $41e3
                              dc.w B1_PlayField + [$04 * B1_ColMax * 4] + 3 ; $4283
                              dc.w B1_PlayField + [$05 * B1_ColMax * 4] + 3 ; $4323
                              dc.w B1_PlayField + [$06 * B1_ColMax * 4] + 3 ; $43c3
                              dc.w B1_PlayField + [$07 * B1_ColMax * 4] + 3 ; $4463
                              dc.w B1_PlayField + [$08 * B1_ColMax * 4] + 3 ; $4503
                              dc.w B1_PlayField + [$09 * B1_ColMax * 4] + 3 ; $45a3
                              dc.w B1_PlayField + [$0a * B1_ColMax * 4] + 3 ; $4643
                              dc.w B1_PlayField + [$0b * B1_ColMax * 4] + 3 ; $46e3
                              dc.w B1_PlayField + [$0c * B1_ColMax * 4] + 3 ; $4783
                              dc.w B1_PlayField + [$0d * B1_ColMax * 4] + 3 ; $4823
                              dc.w B1_PlayField + [$0e * B1_ColMax * 4] + 3 ; $48c3
                              dc.w B1_PlayField + [$0f * B1_ColMax * 4] + 3 ; $4963
                              dc.w B1_PlayField + [$10 * B1_ColMax * 4] + 3 ; $4a03
                              dc.w B1_PlayField + [$11 * B1_ColMax * 4] + 3 ; $4aa3
                              dc.w B1_PlayField + [$12 * B1_ColMax * 4] + 3 ; $4b43
                              dc.w B1_PlayField + [$13 * B1_ColMax * 4] + 3 ; $4be3
                              dc.w B1_PlayField + [$14 * B1_ColMax * 4] + 3 ; $4c83
                              dc.w B1_PlayField + [$15 * B1_ColMax * 4] + 3 ; $4d23
; ------------------------------------------------------------------------------------------------------------- ;
Misc                          include  inc\B1_MiscS.asm    ; Misc Chracter Set
Caves                         include  asm\B1_CaveData.asm ; Cave Descriptions
Demo                          include  inc\B1_Demo.asm     ; Demo Moves for Level 1
; ------------------------------------------------------------------------------------------------------------- ;
TabCaveTileReplace            equ  * ; 
                              
                              dc.b $00 ; $00 -         B1_TileEmpty
                              dc.b $00 ; $01 -         B1_TileSoil
                              dc.b $00 ; $02 -         B1_TileWallBrick
                              dc.b $00 ; $03 -         B1_TileWallMagic
                              dc.b $00 ; $04 -         B1_TileXitClose
                              dc.b $00 ; $05 -         B1_TileXitOpen
                              dc.b $00 ; $06 -         B1_Tile06
                              dc.b $00 ; $07 -         B1_TileWallSteel
                              dc.b $00 ; $08 -         B1_TileFireFly0
                              dc.b $00 ; $09 -         B1_TileFireFly1
                              dc.b $00 ; $0a -         B1_TileFireFly2
                              dc.b $00 ; $0b -         B1_TileFireFly3
                              dc.b $08 ; $0c - replace B1_TileFireFly0
                              dc.b $09 ; $0d - replace B1_TileFireFly1
                              dc.b $0a ; $0e - replace B1_TileFireFly2
                              dc.b $0b ; $0f - replace B1_TileFireFly3
                              dc.b $00 ; $10 -         B1_TileBldrFix
                              dc.b $10 ; $11 - replace B1_TileBldrFix
                              dc.b $00 ; $12 -         B1_TileBldrFall
                              dc.b $12 ; $13 - replace B1_TileBldrFall
                              dc.b $00 ; $14 -         B1_TileDmndFix
                              dc.b $14 ; $15 - replace B1_TileDmndFix
                              dc.b $00 ; $16 -         B1_TileDmndFal1
                              dc.b $16 ; $17 - replace B1_TileDmndFall
                              dc.b $00 ; $18 -         B1_Tile18
                              dc.b $00 ; $19 -         B1_Tile19
                              dc.b $00 ; $1a -         B1_Tile1a
                              dc.b $00 ; $1b -         B1_TileXplEmpty0
                              dc.b $00 ; $1c -         B1_TileXplEmpty1
                              dc.b $00 ; $1d -         B1_TileXplEmpty2
                              dc.b $00 ; $1e -         B1_TileXplEmpty3
                              dc.b $00 ; $1f -         B1_TileXplEmpty4
                              dc.b $00 ; $20 -         B1_TileExplDmnd0
                              dc.b $00 ; $21 -         B1_TileExplDmnd1
                              dc.b $00 ; $22 -         B1_TileExplDmnd2
                              dc.b $00 ; $23 -         B1_TileExplDmnd3
                              dc.b $00 ; $24 -         B1_TileExplDmnd4
                              dc.b $00 ; $25 -         B1_TileBirthRF0
                              dc.b $00 ; $26 -         B1_TileBirthRF1
                              dc.b $00 ; $27 -         B1_TileBirthRF2
                              dc.b $00 ; $28 -         B1_TileBirthRF3
                              dc.b $00 ; $29 -         B1_Tile29
                              dc.b $00 ; $2a -         B1_Tile2a
                              dc.b $00 ; $2b -         B1_Tile2b
                              dc.b $00 ; $2c -         B1_Tile2c
                              dc.b $00 ; $2d -         B1_Tile2d
                              dc.b $00 ; $2e -         B1_Tile2e
                              dc.b $00 ; $2f -         B1_Tile2f
                              dc.b $00 ; $30 -         B1_TileBttrFly0
                              dc.b $00 ; $31 -         B1_TileBttrFly1
                              dc.b $00 ; $32 -         B1_TileBttrFly2
                              dc.b $00 ; $33 -         B1_TileBttrFly3
                              dc.b $30 ; $34 - replace B1_TileBttrFly0
                              dc.b $31 ; $35 - replace B1_TileBttrFly1
                              dc.b $32 ; $36 - replace B1_TileBttrFly2
                              dc.b $33 ; $37 - replace B1_TileBttrFly3
                              dc.b $00 ; $38 -         B1_TileRockFord
                              dc.b $38 ; $39 - replace B1_TileRockFord
                              dc.b $00 ; $3a -         B1_TileAmoeba
                              dc.b $3a ; $3b - replace B1_TileAmoeba
                              dc.b $00 ; $3c -         B1_Tile3c
                              dc.b $00 ; $3d -         B1_Tile3d
                              dc.b $00 ; $3e -         B1_Tile3e
                              dc.b $00 ; $3f -         B1_Tile3f
; ------------------------------------------------------------------------------------------------------------- ;
TabCaveTileCharNo             equ  *   ; 
                              
                              dc.b $60 ; $00 - B1_TileEmpty; 
                              dc.b $46 ; $01 - B1_TileSoil ; 
                              dc.b $4e ; $02 - B1_TileWallBrick
                              dc.b $22 ; $03 - B1_TileWallMagic
                              dc.b $2e ; $04 - B1_TileXitClose
                              dc.b $62 ; $05 - B1_TileXitOpen
                              dc.b $2e ; $06 - 
                              dc.b $4a ; $07 - B1_TileWallSteel
                              dc.b $64 ; $08 - B1_TileFireFly0
                              dc.b $64 ; $09 - B1_TileFireFly1
                              dc.b $64 ; $0a - B1_TileFireFly2
                              dc.b $64 ; $0b - B1_TileFireFly3
                              dc.b $64 ; $0c - B1_TileFireFly0
                              dc.b $64 ; $0d - B1_TileFireFly1
                              dc.b $64 ; $0e - B1_TileFireFly2
                              dc.b $64 ; $0f - B1_TileFireFly3
                              dc.b $44 ; $10 - B1_TileBldrFix
                              dc.b $44 ; $11 - B1_TileBldrFix
                              dc.b $44 ; $12 - B1_TileBldrFall
                              dc.b $44 ; $13 - B1_TileBldrFall
                              dc.b $48 ; $14 - B1_TileDmndFix
                              dc.b $48 ; $15 - B1_TileDmndFix
                              dc.b $48 ; $16 - B1_TileDmndFall
                              dc.b $48 ; $17 - B1_TileDmndFal1
                              dc.b $00 ; $18 - 
                              dc.b $00 ; $19 - 
                              dc.b $00 ; $1a - 
                              dc.b $66 ; $1b - B1_TileXplEmpty0
                              dc.b $68 ; $1c - B1_TileXplEmpty1
                              dc.b $6a ; $1d - B1_TileXplEmpty2
                              dc.b $68 ; $1e - B1_TileXplEmpty3
                              dc.b $66 ; $1f - B1_TileXplEmpty4
                              dc.b $24 ; $20 - B1_TileExplDmnd0
                              dc.b $26 ; $21 - B1_TileExplDmnd1
                              dc.b $28 ; $22 - B1_TileExplDmnd2
                              dc.b $2a ; $23 - B1_TileExplDmnd3
                              dc.b $2c ; $24 - B1_TileExplDmnd4
                              dc.b $62 ; $25 - B1_TileBirthRF0
                              dc.b $66 ; $26 - B1_TileBirthRF1
                              dc.b $68 ; $27 - B1_TileBirthRF2
                              dc.b $6a ; $28 - B1_TileBirthRF3
                              dc.b $00 ; $29 - 
                              dc.b $00 ; $2a - 
                              dc.b $00 ; $2b - 
                              dc.b $00 ; $2c - 
                              dc.b $00 ; $2d - 
                              dc.b $00 ; $2e - 
                              dc.b $00 ; $2f - 
                              dc.b $20 ; $30 - B1_TileBttrFly0
                              dc.b $20 ; $31 - B1_TileBttrFly1
                              dc.b $20 ; $32 - B1_TileBttrFly2
                              dc.b $20 ; $33 - B1_TileBttrFly3
                              dc.b $20 ; $34 - B1_TileBttrFly0
                              dc.b $20 ; $35 - B1_TileBttrFly1
                              dc.b $20 ; $36 - B1_TileBttrFly2
                              dc.b $20 ; $37 - B1_TileBttrFly3
                              dc.b $4c ; $38 - B1_TileRockFord
                              dc.b $4c ; $39 - B1_TileRockFord
                              dc.b $40 ; $3a - B1_TileAmoeba
                              dc.b $40 ; $3b - B1_TileAmoeba
                              dc.b $00 ; $3c - 
                              dc.b $00 ; $3d - 
                              dc.b $00 ; $3e - 
                              dc.b $00 ; $3f - 
; ------------------------------------------------------------------------------------------------------------- ;
TabSubMovesTiles              equ  *                  ; 
TabSubMovesTiles_Lo           equ  *                  ; 
TabSubMovesTiles_Hi           equ  [* + $01]          ; 
                        

                              dc.w $0000              ; 00 - B1_TileEmpty
                              dc.w $0000              ; 01 - B1_TileSoil
                              dc.w $0000              ; 02 - B1_TileWallStone
                              dc.w $0000              ; 03 - B1_TileWallMagic
                              dc.w DynChkExitToOpen   ; 04 - B1_TileXitClose
                              dc.w DynAnimStartDoor   ; 05 - B1_TileXitOpen
                              dc.w $0000              ; 06 - B1_Tile06
                              dc.w $0000              ; 07 - B1_TileWallSteel
                              dc.w DynMoveFireFly     ; 08 - B1_TileFireFly0
                              dc.w DynMoveFireFly     ; 09 - B1_TileFireFly1
                              dc.w DynMoveFireFly     ; 0a - B1_TileFireFly2
                              dc.w DynMoveFireFly     ; 0b - B1_TileFireFly3
                              dc.w $0000              ; 0c - B1_TileFireFly0_
                              dc.w $0000              ; 0d - B1_TileFireFly1_
                              dc.w $0000              ; 0e - B1_TileFireFly2_
                              dc.w $0000              ; 0f - B1_TileFireFly3_
                              dc.w DynChkMoveBoulder  ; 10 - B1_TileBldrFix
                              dc.w $0000              ; 11 - B1_TileBldrFix_
                              dc.w DynMoveBoulder     ; 12 - B1_TileBldrFall
                              dc.w $0000              ; 13 - B1_TileBldrFall_
                              dc.w DynChkMoveDiamond  ; 14 - B1_TileDmndFix
                              dc.w $0000              ; 15 - B1_TileDmndFix_
                              dc.w DynMoveDiamond     ; 16 - B1_TileDmndFall
                              dc.w $0000              ; 17 - B1_TileDmndFall_
                              dc.w $0000              ; 18 - B1_Tile18
                              dc.w $0000              ; 19 - B1_Tile19
                              dc.w $0000              ; 1a - B1_Tile1a
                              dc.w DynExplodeHandler  ; 1b - B1_TileXplEmpty0
                              dc.w DynExplodeHandler  ; 1c - B1_TileXplEmpty1
                              dc.w DynExplodeHandler  ; 1d - B1_TileXplEmpty2
                              dc.w DynExplodeHandler  ; 1e - B1_TileXplEmpty3
                              dc.w DynExplodeHandler  ; 1f - B1_TileXplEmpty4
                              dc.w DynExplodeHandler  ; 20 - B1_TileExplDmnd0
                              dc.w DynExplodeHandler  ; 21 - B1_TileExplDmnd1
                              dc.w DynExplodeHandler  ; 22 - B1_TileExplDmnd2
                              dc.w DynExplodeHandler  ; 23 - B1_TileExplDmnd3
                              dc.w DynExplodeHandler  ; 24 - B1_TileExplDmnd4
                              dc.w DynAnimStartDoor   ; 25 - B1_TileBirthRF0
                              dc.w DynBirthRoFo       ; 26 - B1_TileBirthRF1
                              dc.w DynBirthRoFo       ; 27 - B1_TileBirthRF2
                              dc.w DynBirthRoFo       ; 28 - B1_TileBirthRF3
                              dc.w $0000              ; 29 - B1_Tile29
                              dc.w $0000              ; 2a - B1_TileWallExpand
                              dc.w $0000              ; 2b - B1_TileWallExpand_
                              dc.w $0000              ; 2s - B1_Tile2c
                              dc.w $0000              ; 2d - B1_Tile2d
                              dc.w $0000              ; 2e - B1_Tile2e
                              dc.w $0000              ; 2f - B1_Tile2f
                              dc.w DynMoveButterFly   ; 30 - B1_TileBttrFly0
                              dc.w DynMoveButterFly   ; 31 - B1_TileBttrFly1
                              dc.w DynMoveButterFly   ; 32 - B1_TileBttrFly2
                              dc.w DynMoveButterFly   ; 33 - B1_TileBttrFly3
                              dc.w $0000              ; 34 - B1_TileBttrFly0_
                              dc.w $0000              ; 35 - B1_TileBttrFly1_
                              dc.w $0000              ; 36 - B1_TileBttrFly2_
                              dc.w $0000              ; 37 - B1_TileBttrFly3_
                              dc.w DynMoveRockFord    ; 38 - B1_TileRockFord
                              dc.w $0000              ; 39 - B1_TileRockFord_
                              dc.w DynMoveAmoeba      ; 3a - B1_TileAmoeba
                              dc.w $0000              ; 3b - B1_TileAmoeba_
                              dc.w $0000              ; 3c - B1_Tile3c
                              dc.w $0000              ; 3d - B1_Tile3d
                              dc.w $0000              ; 3e - B1_TileSlime
                              dc.w $0000              ; 3f - B1_Tile3f
; ------------------------------------------------------------------------------------------------------------- ;
Music                         include  inc\B1_Music.asm    ; Start Screen Music
Gfx                           include  inc\B1_GfxS.asm     ; Graphics Charcter Set
Title                         include  inc\B1_Title.asm    ; Title Screen Text
; ------------------------------------------------------------------------------------------------------------- ;
; Start Of Code
; ------------------------------------------------------------------------------------------------------------- ;
GetValRND                     subroutine                   ; 
                              lda TIMALO                   ; CIA 1 - $DC04 = Timer A (Low Byte)
                              eor TIMAHI                   ; CIA 1 - $DC05 = Timer A (High Byte)
                              eor TI2ALO                   ; CIA 2 - $DD04 = Timer A (Low Byte)
                              adc TI2AHI                   ; CIA 2 - $DD05 = Timer A (High Byte)
                              eor TI2BLO                   ; CIA 2 - $DD06 = Timer B (Low Byte)
                              eor TI2BHI                   ; CIA 2 - $DD07 = Timer B (High Byte)
                              
GetValRNDX                    rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
InitColorRam                  subroutine                   ; 
                              pha                          ; save color
                              
                              ldx #[B1_ColMax - $01]       ; 
;                              lda #BROWN                   ; 
                              lda #[WHITE | %00001000 ]    ; multi color
.SetColorRam1stRow            sta COLORAM,x                ; 
                              dex                          ; 
                              bpl .SetColorRam1stRow       ; 
                              
                              ldx #<COLORAM                ; 
                              stx B1Z_ColorRam_Lo          ; 
                              ldx #>COLORAM                ; 
                              stx B1Z_ColorRam_Hi          ; 
                              
                              ldx #$03                     ; pages
                              pla                          ; restore color
.SetColorRam                  sta (B1Z_ColorRam),y         ; 
                              iny                          ; 
                              bne .SetColorRam             ; 
                              
                              inc B1Z_ColorRam_Hi          ; 
                              dex                          ; 
                              bpl .SetColorRam             ; 
                              
InitColorRamX                 rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
StatusRowDataSave             subroutine                   ; 
                              ldx #$00                     ; 
                              ldy #$00                     ; 
.Copy                         lda B1_PlayScrHdr,x          ; only the first chr part
                              sta B1_SavRowTemp,y          ; 
                              
                              inx                          ; 
                              inx                          ; 
                              
                              iny                          ; 
                              cpy #B1_LenTxtRow            ; 
                              bne .Copy                    ; 
                              
StatusRowDataSaveX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
StatusRowFill                 subroutine                   ; 
                              ldx #WHITE                   ; 
                              ldy #$03                     ; 
                              lda (B1Z_StatusRow),y        ; 
                              cmp #$3c                     ; diamond left part
                              bne .GetColorPart1           ; 
                              
                              ldx #YELLOW                  ; 
                              
.GetColorPart1                txa                          ; 
                              
                              ldx #$03                     ; 
.SetColorPart1                sta [COLORAM + $0e],x        ; 
                              dex                          ; 
                              bpl .SetColorPart1           ; 
                              
                              ldx #WHITE                   ; 
                              
                              ldy #$01                     ; 
                              lda (B1Z_StatusRow),y        ; 
                              cmp #$19                     ; 
                              bpl .GetColorPart2           ; 
                              
                              ldx #YELLOW                  ; 
                              
.GetColorPart2                txa                          ; 
                              
                              ldx #$03                     ; 
.SetColorPart2                sta [COLORAM + $02],x        ; 
                              dex                          ; 
                              bpl .SetColorPart2           ; 
                              
                              ldx #$00                     ; 
                              ldy #$00                     ; 
.GetChr                       lda (B1Z_StatusRow),y        ; variable text lines
                              cmp #$01                     ; 
                              bne .Put1stChr               ; 
                              
                              lda #$20                     ; <blank>
                              
.Put1stChr                    sta B1_PlayScrHdr,x          ; 
                              
                              inx                          ; 
                              
                              clc                          ; make second half
                              adc #$34                     ; 
.Put2ndChr                    sta B1_PlayScrHdr,x          ; 
                              
                              inx                          ; 
                              
                              iny                          ; 
                              cpy #B1_LenTxtRow            ; 
                              bne .GetChr                  ; 
                              
StatusRowFillX                rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GetMovesPort_B                subroutine                   ; 
                              lda CIAPRB                   ; CIA 1 - $DC01 = Data Port B
                              and #[CIA_Joy_Ri | CIA_Joy_Le | CIA_Joy_Do | CIA_Joy_Up] ; ....#### - isolate move directions
                              
GetMovesPort_BX               rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GetMovesPort_A                subroutine                   ; 
                              lda CIAPRA                   ; CIA 1 - $DC00 = Data Port A
                              and #[CIA_Joy_Ri | CIA_Joy_Le | CIA_Joy_Do | CIA_Joy_Up] ; ....#### - isolate move directions
                              
GetMovesPort_AX               rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GetFireForPlayer              subroutine                   ; 
                              lda B1Z_GamePlayerNo         ; actual player no $00-$01
; ------------------------------------------------------------------------------------------------------------- ;
GetFirePort_A                 subroutine                   ; 
                              and B1Z_JoyStickNo           ; no of joysticks
                              beq GetFirePort_B            ; 
                              
                              lda CIAPRA                   ; CIA 1 - $DC00 = Data Port A
                              bne IsolateFirePort_A_B      ; 
; ------------------------------------------------------------------------------------------------------------- ;
GetFirePort_B                 subroutine                   ; 
                              lda CIAPRB                   ; CIA 1 - $DC01 = Data Port B
IsolateFirePort_A_B           and #CIA_Joy_Fi              ; ...# .... - fire button
                              sta B1Z_FirePort_A_B         ; status fire both joysticks
                              
GetFirePort_A_BX              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TxtByPeLi                     dc.b $20 ;  
                              dc.b $20 ; <blank>           ; 
                              dc.b $22 ; B                 ; 
                              dc.b $39 ; Y                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $30 ; P                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $34 ; T                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $32 ; R                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $2c ; L                 ; 
                              dc.b $29 ; I                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $30 ; P                 ; 
                              dc.b $21 ; A                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
; ------------------------------------------------------------------------------------------------------------- ;
TxtWiChGr                     dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $37 ; W                 ; 
                              dc.b $29 ; I                 ; 
                              dc.b $34 ; T                 ; 
                              dc.b $28 ; H                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $23 ; C                 ; 
                              dc.b $28 ; H                 ; 
                              dc.b $32 ; R                 ; 
                              dc.b $29 ; I                 ; 
                              dc.b $33 ; S                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $27 ; G                 ; 
                              dc.b $32 ; R                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $39 ; Y                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
; ------------------------------------------------------------------------------------------------------------- ;
Txt1Plr1Joy                   dc.b $11 ; 1                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $30 ; P                 ; 
                              dc.b $2c ; L                 ; 
                              dc.b $21 ; A                 ; 
                              dc.b $39 ; Y                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $32 ; R                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $11 ; 1                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $2a ; J                 ; 
                              dc.b $2f ; O                 ; 
                              dc.b $39 ; Y                 ; 
                              dc.b $33 ; S                 ; 
                              dc.b $34 ; T                 ; 
                              dc.b $29 ; I                 ; 
                              dc.b $23 ; C                 ; 
                              dc.b $2b ; K                 ; 
; ------------------------------------------------------------------------------------------------------------- ;
TxtPlr1Plr2                   dc.b $20 ; <blank>           ; 
                              dc.b $30 ; P                 ; 
                              dc.b $2c ; L                 ; 
                              dc.b $39 ; Y                 ; 
                              dc.b $32 ; R                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $11 ; 1                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $30 ; P                 ; 
                              dc.b $2c ; L                 ; 
                              dc.b $39 ; Y                 ; 
                              dc.b $32 ; R                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $12 ; 2                 ; 
                              dc.b $20 ; <blank>           ; 
; ------------------------------------------------------------------------------------------------------------- ;
TxtScoreLast                  dc.b $20 ; <blank>           ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $2c ; L                 ; 
                              dc.b $21 ; A                 ; 
                              dc.b $33 ; S                 ; 
                              dc.b $34 ; T                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $20 ; <blank>           ; 
; ------------------------------------------------------------------------------------------------------------- ;
TxtScoreHigh                  dc.b $20 ; <blank>           ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $28 ; H                 ; 
                              dc.b $29 ; I                 ; 
                              dc.b $27 ; G                 ; 
                              dc.b $28 ; H                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $20 ; <blank>           ; 
; ------------------------------------------------------------------------------------------------------------- ;
TxtGameOver                   dc.b $20 ; <blank>           ; 
                              dc.b $27 ; G                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $21 ; A                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $2d ; M                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $25 ; E                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $2f ; O                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $36 ; V                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $25 ; E                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $32 ; R                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
; ------------------------------------------------------------------------------------------------------------- ;
TxtPlrMen                     dc.b $30 ; P                 ; 
                              dc.b $2c ; L                 ; 
                              dc.b $21 ; A                 ; 
                              dc.b $39 ; Y                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $32 ; R                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $11 ; 1                 ; 
                              dc.b $0d ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $13 ; 3                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $2d ; M                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $2e ; N                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $21 ; A                 ; 
                              dc.b $0f ; 
                              dc.b $10 ; 0                 ; 
                              dc.b $20 ; <blank>           ; 
; ------------------------------------------------------------------------------------------------------------- ;
TxtTimeOut                    dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $2f ; O                 ; 
                              dc.b $35 ; U                 ; 
                              dc.b $34 ; T                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $2f ; O                 ; 
                              dc.b $26 ; F                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $34 ; T                 ; 
                              dc.b $29 ; I                 ; 
                              dc.b $2d ; M                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
; ------------------------------------------------------------------------------------------------------------- ;
TxtBonusLife                  dc.b $20 ; <blank>           ; 
                              dc.b $22 ; B                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $2f ; O                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $2e ; N                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $35 ; U                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $33 ; S                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $2c ; L                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $29 ; I                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $26 ; F                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $25 ; E                 ; 
                              dc.b $20 ; <blank>           ; 
; ------------------------------------------------------------------------------------------------------------- ;
TxtCavLvl                     dc.b $20 ; <blank>           ; 
                              dc.b $23 ; C                 ; 
                              dc.b $21 ; A                 ; 
                              dc.b $36 ; V                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $1a ; :                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $21 ; A                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $2c ; L                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $36 ; V                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $2c ; L                 ; 
                              dc.b $1a ; :                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $11 ; 1                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $20 ; <blank>           ; 
; ------------------------------------------------------------------------------------------------------------- ;
TxtSpc2Res                    dc.b $20 ; <blank>           ; 
                              dc.b $33 ; S                 ; 
                              dc.b $30 ; P                 ; 
                              dc.b $21 ; A                 ; 
                              dc.b $23 ; C                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $22 ; B                 ; 
                              dc.b $21 ; A                 ; 
                              dc.b $32 ; R                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $34 ; T                 ; 
                              dc.b $2f ; O                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $32 ; R                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $33 ; S                 ; 
                              dc.b $35 ; U                 ; 
                              dc.b $2d ; M                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $20 ; <blank>           ; 
; ------------------------------------------------------------------------------------------------------------- ;
TxtPrBu2Play                  dc.b $30 ; P                 ; 
                              dc.b $32 ; R                 ; 
                              dc.b $25 ; E                 ; 
                              dc.b $33 ; S                 ; 
                              dc.b $33 ; S                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $22 ; B                 ; 
                              dc.b $35 ; U                 ; 
                              dc.b $34 ; T                 ; 
                              dc.b $34 ; T                 ; 
                              dc.b $2f ; O                 ; 
                              dc.b $2e ; N                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $34 ; T                 ; 
                              dc.b $2f ; O                 ; 
                              dc.b $20 ; <blank>           ; 
                              dc.b $30 ; P                 ; 
                              dc.b $2c ; L                 ; 
                              dc.b $21 ; A                 ; 
                              dc.b $39 ; Y                 ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameScreenOutTile             subroutine                   ; 
                              ldx B1Z_CaveTileGameNo       ; gfx tile no $00-$3f
.CaveCharNoPart_01_a          lda TabCaveTileCharNo,x       ; 
                              ldy #$00                     ; 
                              sta (B1Z_CaveScreenPos),y    ; ptr screen pos - top left chr
                              
                              clc                          ; 
.CaveCharNoPart_01_b          adc #$01                     ; next chr half
                              iny                          ; 
                              sta (B1Z_CaveScreenPos),y    ; ptr screen pos - top right chr
                              
.CaveCharNoPart_02_a          adc #$0f                     ; set bottom 2 gfx chrs
                              ldy #$50                     ; 
                              sta (B1Z_CaveScreenPos),y    ; ptr screen pos - bottom left chr
                              
.CaveCharNoPart_02_b          adc #$01                     ; next chr half
                              iny                          ; 
                              sta (B1Z_CaveScreenPos),y    ; ptr screen pos - bottom right chr
                              
GameScreenOutTileX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameScreenGetPointer          subroutine                   ; 
                              ldx #B1Z_KeyPressedOld_0     ; force start $00
                              tya                          ; 
                              
.TabSearch                    inx                          ; 
                              inx                          ; 
                              inx                          ; 
                              cmp CavePlayFieldPosAdd_Id,x ; 
                              bne .TabSearch               ; 
                              
                              clc                          ; 
                              lda B1Z_CavePlayFieldPos_Lo  ; ptr lo playfield row
                              adc CavePlayFieldPosAdd_Lo,x ; 
                              sta B1Z_CaveScreenPos_Lo     ; ptr lo screen pos
                              
                              lda B1Z_CavePlayFieldPos_Hi  ; ptr hi playfield row
                              adc CavePlayFieldPosAdd_Hi,x ; 
                              sta B1Z_CaveScreenPos_Hi     ; ptr hi screen pos
                              
GameScreenGetPointerX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameScreenOutHandler          subroutine                   ; 
                              sta B1Z_CaveTileGameNo       ; gfx tile no $00-$3f
                              sta (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              
.GetCtrlPosTile               lda B1Z_CaveCtrlFieldRow     ; row no
                              asl a                        ; 
                              tax                          ; 
                              lda B1Z_CaveCtrlFieldCol     ; col no
                              asl a                        ; 
                              
.GetScrnPosTile               clc                          ; 
                              adc TabScrnDataRowOff_Lo,x   ; 
                              sta B1Z_CavePlayFieldPos_Lo  ; ptr lo playfield row
                              lda #$00                     ; 
                              adc TabScrnDataRowOff_Hi,x   ; 
                              sta B1Z_CavePlayFieldPos_Hi  ; ptr hi playfield row
                              
                              jsr GameScreenGetPointer     ; 
                              jsr GameScreenOutTile        ; 
                              
                              lda B1Z_CaveTileGameNo       ; gfx tile no $00-$3f
                              
GameScreenOutHandlerX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynClearLastPos               subroutine                   ; 
                              lda #$00                     ; 
                              sta B1Z_CaveTileGameNo       ; gfx tile no $00-$3f
                              
                              ldy #B1_CtrlData_Row_Col     ; 
                              sta (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              
                              lda B1Z_CavePlayFieldPos_Lo  ; ptr lo playfield row
                              sta B1Z_CaveScreenPos_Lo     ; ptr lo screen pos
                              
                              lda B1Z_CavePlayFieldPos_Hi  ; ptr hi playfield row
                              sta B1Z_CaveScreenPos_Hi     ; ptr hi screen pos
                              
                              jsr GameScreenOutTile        ; 
                              
                              jmp MoveTilesReturn          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GetValPseudoRND               subroutine                   ; 
                              lda B1Z_StartPseudoRND       ; pseudo rnd generator seed 2
                              ror a                        ; 
                              ror a                        ; 
                              and #$80                     ; 
                              sta B1_PseudoRND_01          ; 
                              
                              lda B1Z_SeedPseudoRND        ; pseudo rnd generator seed 2
                              ror a                        ; 
                              and #$7f                     ; 
                              sta B1_PseudoRND_02          ; 
                              
                              lda B1Z_SeedPseudoRND        ; pseudo rnd generator seed 2
                              ror a                        ; 
                              ror a                        ; 
                              and #$80                     ; 
                              clc                          ; 
                              adc B1Z_SeedPseudoRND        ; pseudo rnd generator seed 2
                              adc #$13                     ; 
                              sta B1Z_SeedPseudoRND        ; pseudo rnd generator seed 2
                              
                              lda B1Z_StartPseudoRND       ; pseudo rnd generator seed 2
                              adc B1_PseudoRND_01          ; 
                              adc B1_PseudoRND_02          ; 
                              sta B1Z_StartPseudoRND       ; pseudo rnd generator seed 2
                              
GetValPseudoRNDX              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynExplodeTileOut             subroutine                   ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              cmp #B1_TileWallSteel        ; 
                              beq DynExplodeTileOutX       ; 
                              
                              lda B1Z_ExplodeTileNo        ; explode tile no
                              jsr GameScreenOutHandler     ; 
                              
DynExplodeTileOutX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynExplodeDropHandler         subroutine                   ; 
                              ldy #B1_CtrlData_Row_ColLe1  ; 
                              jsr DynExplodeTileOut        ; 
                              
                              ldy #B1_CtrlData_Row_Col     ; 
                              jsr DynExplodeTileOut        ; 
                              
                              dec B1Z_ExplodeTileNo        ; explode tile no
                              
                              ldy #B1_CtrlData_Row_ColRi1  ; 
                              jsr DynExplodeTileOut        ; 
                              
                              ldy #B1_CtrlData_RowDo1_ColLe; 
                              jsr DynExplodeTileOut        ; 
                              
                              ldy #B1_CtrlData_RowDo1_ColUp; 
                              jsr DynExplodeTileOut        ; 
                              
                              ldy #B1_CtrlData_RowDo1_ColRi; 
                              jsr DynExplodeTileOut        ; 
                              
                              ldy #B1_CtrlData_RowDo2_ColLe; 
                              jsr DynExplodeTileOut        ; 
                              
                              ldy #B1_CtrlData_RowDo2_ColUp; 
                              jsr DynExplodeTileOut        ; 
                              
                              ldy #B1_CtrlData_RowDo2_ColRi; 
                              jsr DynExplodeTileOut        ; 
                              
DynExplodeDropHandlerX        jmp DynExplodeSfxHandler     ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynChkExitToOpen              subroutine                   ; 
                              lda B1Z_DiaGotAll            ; flag got all diamonds $00=no $01=yes
                              beq DynChkExitToOpenX        ; B1Z_DiaGotAll_No
                              
                              ldy #$29                     ; 
                              lda #B1_TileXitOpen          ; 
                              jsr GameScreenOutHandler     ; 
                              
DynChkExitToOpenX             jmp MoveTilesReturn          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynExplodeFlyHandler          subroutine                   ; 
                              ldy #B1_CtrlData_RowUp1_ColLe; 
                              jsr DynExplodeTileOut        ; 
                              
                              ldy #B1_CtrlData_RowUp1_ColUp;  
                              jsr DynExplodeTileOut        ; 
                              
                              ldy #B1_CtrlData_RowUp1_ColRi; 
                              jsr DynExplodeTileOut        ; 
                              
                              ldy #B1_CtrlData_Row_ColLe1  ; 
                              jsr DynExplodeTileOut        ; 
                              
                              ldy #B1_CtrlData_Row_Col     ; 
                              jsr DynExplodeTileOut        ; 
                              
                              dec B1Z_ExplodeTileNo        ; explode tile no
                              
                              ldy #B1_CtrlData_Row_ColRi1  ; 
                              jsr DynExplodeTileOut        ; 
                              
                              ldy #B1_CtrlData_RowDo1_ColLe; 
                              jsr DynExplodeTileOut        ; 
                              
                              ldy #B1_CtrlData_RowDo1_ColUp; 
                              jsr DynExplodeTileOut        ; 
                              
                              ldy #B1_CtrlData_RowDo1_ColRi; 
DynExplodeFlyHandlerX         jsr DynExplodeTileOut        ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynExplodeSfxHandler          subroutine                   ; 
                              lda #$50                     ; 
                              sta B1_IRQSfxTime            ; 
                              jsr GetIniVoc2Ctrl           ; 
                              
                              ldx #B1_LenSfxData           ; 
.Expolsion                    lda TabSfxExplosion,x        ; 
                              sta FRELO2,x                 ; SID - $D407 = Oscillator 2 Frequency Control (low byte)
                              dex                          ; 
                              bpl .Expolsion               ; 
                              
DynExplodeSfxHandlerX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabSfxExplosion               dc.w $1432 ; freq
                              dc.b $0f ; 
                              dc.b $00 ; 
                              dc.b $81 ; 
                              dc.b $1b ; 
                              dc.b $00 ; 
; -------------------------------------------------------------------------------------------------------------- ;
TabFliesMoveTargPosLe         dc.b B1_CtrlData_Row_ColLe1   ; try move left 1st
                              dc.b B1_CtrlData_RowUp1_ColUp ; 
                              dc.b B1_CtrlData_Row_ColRi1   ; 
                              dc.b B1_CtrlData_RowDo1_ColUp ; 
; -------------------------------------------------------------------------------------------------------------- ;
TabFliesMoveTargPosDo         dc.b B1_CtrlData_RowDo1_ColUp ; try move down 1st
                              dc.b B1_CtrlData_Row_ColLe1   ; 
                              dc.b B1_CtrlData_RowUp1_ColUp ; 
                              dc.b B1_CtrlData_Row_ColRi1   ; 
; -------------------------------------------------------------------------------------------------------------- ;
DynChkFlyExplodeTiles         subroutine                   ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              cmp #B1_TileRockFord         ; 
                              bcc DynChkFlyExplodeTilesX   ; ac lower
                              
                              cmp #$3b                     ; 
                              bcs DynChkFlyExplodeTilesX   ; ac higher/equal
                              
                              ldx #$00                     ; 
                              
DynChkFlyExplodeTilesX        rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynGetFlyExplodeFlag          subroutine                   ; 
                              ldx #$01                     ; 
                              
                              ldy #B1_CtrlData_RowUp1_ColUp; 
                              jsr DynChkFlyExplodeTiles    ; 
                              
                              ldy #B1_CtrlData_Row_ColLe1  ; 
                              jsr DynChkFlyExplodeTiles    ; 
                              
                              ldy #B1_CtrlData_Row_ColRi1  ; 
                              jsr DynChkFlyExplodeTiles    ; 
                              
                              ldy #B1_CtrlData_RowDo1_ColUp; 
                              jsr DynChkFlyExplodeTiles    ; 
                              
                              cpx #$00                     ; 
DynGetFlyExplodeFlagX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynMoveFireFly                subroutine                   ; 
                              jsr DynGetFlyExplodeFlag     ; 
                              bne .MoveFly                 ; 
                              
                              lda #B1_TileXplEmpty1        ; 
                              sta B1Z_ExplodeTileNo        ; explode tile no
                              jsr DynExplodeFlyHandler     ; 
                              
                              jmp MoveTilesReturn          ; 
                              
.MoveFly                      ldy #B1_CtrlData_Row_Col     ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              and #$03                     ; 
                              tax                          ; 
                              ldy TabFliesMoveTargPosDo,x  ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .TryFlyNextMove          ; 
                              
                              clc                          ; 
                              txa                          ; 
                              adc #$03                     ; 
                              and #$03                     ; 
                              adc #B1_TileFireFly0_        ; 
                              jsr GameScreenOutHandler     ; 
                              jmp DynClearLastPos          ; 
                              
.TryFlyNextMove               ldy TabFliesMoveTargPosLe,x  ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .SetNextAnimPhase        ; 
                              
                              clc                          ; 
                              txa                          ; 
                              adc #B1_TileFireFly0_        ; 
                              ldy TabFliesMoveTargPosLe,x  ; 
                              jsr GameScreenOutHandler     ; 
                              jmp DynClearLastPos          ; 
                              
.SetNextAnimPhase             clc                          ; 
                              ldy #B1_CtrlData_Row_Col     ; 
                              txa                          ; 
                              adc #$01                     ; 
                              and #$03                     ; 
                              adc #B1_TileFireFly0_        ; 
                              sta (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              
DynMoveFireFlyX               jmp MoveTilesReturn          ; 
; ------------------------------------------------------------------------------------------------------------- ;
SetSfxDiamondFall             subroutine                   ; 
                              inc B1_SfxToPlayCount        ; 
                              
                              ldx #[B1_SfxToPlayBuffer_Len / $02] ; 
.Copy                         lda TabSfxDiamondFall,x      ; 
                              sta [B1_SfxToPlayBuffer + $02],x ; 
                              dex                          ; 
                              bpl .Copy                    ; 
                              
                              lda #$a0                     ; 
                              sta [B1_SfxToPlayBuffer + B1_SfxToPlayBuffer_Len] ; 
                              
                              jsr GetValRND                ; 
                              sta [B1_SfxToPlayBuffer + $00] ; 
                              
                              jsr GetValRND                ; 
                              and #$07                     ; 
                              asl a                        ; 
                              asl a                        ; 
                              asl a                        ; 
                              adc #$86                     ; 
                              sta [B1_SfxToPlayBuffer + $01] ; 
                              
SetSfxDiamondFallX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabSfxBoulderFall             dc.w $0932 ; freq            ; 
                              dc.b $07 ; 
                              dc.b $00 ; 
                              dc.b $81 ; 
                              dc.b $00 ; 
                              dc.b $f0 ; 
; ------------------------------------------------------------------------------------------------------------- ;
SetSfxBoulderFall             subroutine                   ; 
                              inc B1_SfxToPlayCount        ; 
                              
                              ldx #B1_SfxToPlayBuffer_Len  ; 
.SetFall                      lda TabSfxBoulderFall,x      ; 
                              sta B1_SfxToPlayBuffer,x     ; 
                              dex                          ; 
                              bpl .SetFall                 ; 
                              
SetSfxBoulderFallX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynCheckObstacle              subroutine                   ; 
                              ldx #$00                     ; 
                              
                              cmp #B1_TileBldrFix          ; 
                              bne .ChkDiamond              ; 
                              ldx #$01                     ; 
                              
.ChkDiamond                   cmp #B1_TileDmndFix          ; 
                              bne .ChkWallStone            ; 
                              ldx #$01                     ; 
                              
.ChkWallStone                 cmp #B1_TileWallStone        ; 
                              bne .ChkObstacle             ; 
                              ldx #$01                     ; 
                              
.ChkObstacle                  cpx #$01                     ; 
DynCheckObstacleX             rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynBoulderChkHitFlies         subroutine                   ; 
.IniReturnCodeButterFly       ldx #$01                     ; 
                              
.ChkButterFly                 lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              and #$33                     ; ..##..## - B1_TileButtrFlies  $30-$33 ..##..../..##...#/..##..#./..##..##
                              cmp (B1Z_CaveCtrlFieldPos),y ;          - B1_TileButtrFlies_ $34-$37 ..##.#../..##.#.#/..##.##./..##.###
                              bne .ChkReturnCodeButterFly  ; 
                              
                              ora #$30                     ; ..##....
                              cmp (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkReturnCodeButterFly  ; 
                              
                              ldx #$00                     ; 
                              lda #B1_TileExplDmnd1        ; 
                              sta B1Z_ExplodeTileNo        ; explode tile no
                              
.ChkReturnCodeButterFly       cpx #$00                     ; 
                              beq .SetReturnCode           ; 
                              
.IniReturnCodeFireFly         ldx #$01                     ; 
                              
.ChkFireFly                   lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              and #$0b                     ; ....#.## - B1_TileFireFlies  $08-$0b ....#.../....#..#/....#.#./....#.##
                              cmp (B1Z_CaveCtrlFieldPos),y ;          - B1_TileFireFlies_ $0c-$0f ....##../....##.#/....###./....####
                              bne .SetReturnCode           ; 
                              
                              and #$08                     ; ....#...
                              beq .SetReturnCode           ; 
                              
                              ldx #$00                     ; 
                              lda #B1_TileXplEmpty1        ; 
                              sta B1Z_ExplodeTileNo        ; explode tile no
                              
.SetReturnCode                cpx #$00                     ; 
                              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynMoveButterFly              subroutine                   ; 
                              jsr DynGetFlyExplodeFlag     ; 
                              bne .MoveFly                 ; 
                              
.ExplodeFly                   lda #B1_TileExplDmnd1        ; 
                              sta B1Z_ExplodeTileNo        ; explode tile no
                              jsr DynExplodeFlyHandler     ; 
                              jmp MoveTilesReturn          ; 
                              
.MoveFly                      ldy #B1_CtrlData_Row_Col     ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              and #$03                     ; 
                              tax                          ; 
                              ldy TabFliesMoveTargPosLe,x  ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .TryFlyNextMove          ; 
                              
.SetNextAnimPhase_            clc                          ; 
                              txa                          ; 
                              adc #$01                     ; 
                              and #$03                     ; 
                              adc #B1_TileBttrFly0_        ; 
                              jsr GameScreenOutHandler     ; 
                              jmp DynClearLastPos          ; 
                              
.TryFlyNextMove               ldy TabFliesMoveTargPosDo,x  ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .SetNextAnimPhase        ; 
                              
                              clc                          ; 
                              txa                          ; 
                              adc #B1_TileBttrFly0_        ; 
                              ldy TabFliesMoveTargPosDo,x  ; 
                              jsr GameScreenOutHandler     ; 
                              jmp DynClearLastPos          ; 
                              
.SetNextAnimPhase             clc                          ; 
                              ldy #B1_CtrlData_Row_Col     ; 
                              txa                          ; 
                              adc #$03                     ; 
                              and #$03                     ; 
                              adc #B1_TileBttrFly0_        ; 
                              sta (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              
DynMoveButterFlyX             jmp MoveTilesReturn          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynOutDiamondFix              subroutine                   ; 
                              ldy #B1_CtrlData_Row_Col     ; 
                              lda #B1_TileDmndFix_         ; 
                              jsr GameScreenOutHandler     ; 
                              
DynOutDiamondFixX             jmp MoveTilesReturn          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynMoveDiamond                subroutine                   ; 
                              ldy #B1_CtrlData_RowDo1_ColUp; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkWallMagic            ; 
                              
                              lda #B1_TileDmndFall_        ; 
                              jsr GameScreenOutHandler     ; 
                              jmp DynClearLastPos          ; 
                              
.ChkWallMagic                 cmp #B1_TileWallMagic        ; 
                              bne .GoSetSfxDiaFall         ; 
                              
                              lda B1Z_SfxMagicWall         ; 
                              bne .ChkWallMagicOn          ; 
                              
                              lda #B1Z_SfxMagicWall_On     ; 
                              sta B1Z_SfxMagicWall         ; 
                              
.ChkWallMagicOn               cmp #$01                     ; 
                              bne .GoSetSfxBoulderFall     ; 
                              
                              ldy #B1_CtrlData_RowDo2_ColUp; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .GoSetSfxBoulderFall     ; 
                              
.DiamondTurnIntoBoulder       lda #B1_TileBldrFall_        ; 
                              jsr GameScreenOutHandler     ; 
.GoSetSfxBoulderFall          jsr SetSfxBoulderFall        ; 
.ClrDiamond                   jmp DynClearLastPos          ; 
                              
.GoSetSfxDiaFall              jsr SetSfxDiamondFall        ; 
                              
.ChkObstaclePos_01            ldy #B1_CtrlData_RowDo1_ColUp; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              jsr DynCheckObstacle         ; 
                              bne .ChkRoFo                 ; blocked
                              
                              ldy #B1_CtrlData_RowDo1_ColLe; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkObstaclePos_02       ; 
                              
                              ldy #B1_CtrlData_Row_ColLe1  ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkObstaclePos_02       ; 
                              
                              lda #B1_TileDmndFall_        ; 
                              jsr GameScreenOutHandler     ; 
                              jmp DynClearLastPos          ; 
                              
.ChkObstaclePos_02            ldy #B1_CtrlData_RowDo1_ColRi; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .GoOutDiamondFix         ; 
                              
                              ldy #B1_CtrlData_Row_ColRi1  ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .GoOutDiamondFix         ; 
                              
                              lda #B1_TileDmndFall_        ; 
                              jsr GameScreenOutHandler     ; 
                              jmp DynClearLastPos          ; 
                              
.GoOutDiamondFix              jmp DynOutDiamondFix         ; 
                              
.ChkRoFo                      cmp #B1_TileRockFord         ; 
                              bne .GoBoulderCheckHitFlies  ; 
                              
                              lda #B1_TileXplEmpty1        ; 
                              sta B1Z_ExplodeTileNo        ; explode tile no
                              jsr DynExplodeDropHandler    ; 
                              
                              jmp MoveTilesReturn          ; 
                              
.GoBoulderCheckHitFlies       jsr DynBoulderChkHitFlies    ; 
                              bne DynMoveDiamondX          ; 
                              
                              jsr DynExplodeDropHandler    ; 
                              jmp MoveTilesReturn          ; 
                              
DynMoveDiamondX               jmp DynOutDiamondFix         ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynChkMoveDiamond             subroutine                   ; 
                              ldy #B1_CtrlData_RowDo1_ColUp; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkObstacles            ; 
                              
                              lda #B1_TileDmndFall_        ; 
                              jsr GameScreenOutHandler     ; 
                              jsr SetSfxDiamondFall        ; 
                              jmp DynClearLastPos          ; 
                              
.ChkObstacles                 ldy #B1_CtrlData_RowDo1_ColUp; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              jsr DynCheckObstacle         ; 
                              bne DynChkMoveDiamondX       ; 
                              
.ChkOverbalance_Le            ldy #B1_CtrlData_RowDo1_ColLe; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkOverbalance_Ri       ; 
                              
                              ldy #B1_CtrlData_Row_ColLe1  ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkOverbalance_Ri       ; 
                              
                              lda #B1_TileDmndFall_        ; 
                              jsr GameScreenOutHandler     ; 
                              jmp DynClearLastPos          ; 
                              
.ChkOverbalance_Ri            ldy #B1_CtrlData_RowDo1_ColRi; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne DynChkMoveDiamondX       ; 
                              
                              ldy #B1_CtrlData_Row_ColRi1  ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne DynChkMoveDiamondX       ; 
                              
                              lda #B1_TileDmndFall_        ; 
                              jsr GameScreenOutHandler     ; 
                              jmp DynClearLastPos          ; 
                              
DynChkMoveDiamondX            jmp MoveTilesReturn          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabAmoebaMoveTargPos          dc.b B1_CtrlData_RowUp1_ColUp ; 
                              dc.b B1_CtrlData_Row_ColLe1   ; 
                              dc.b B1_CtrlData_Row_ColRi1   ; 
                              dc.b B1_CtrlData_RowDo1_ColUp ; 
TabAmoebaMoveTargLen          = [* - TabAmoebaMoveTargPos - $01]
; ------------------------------------------------------------------------------------------------------------- ;
DynMoveAmoeba                 subroutine                   ; 
                              inc B1_AmoebaCountThis       ; actual count
                              
.ChkAmoebaMax                 lda B1_AmoebaCountLast       ; count last round
                              cmp #$c8                     ; 
                              bcc .ChkAmoebaToDiamond      ; 
                              
.TurnAmoebaIntoBoulder        lda #B1_TileBldrFix_         ; 
                              jsr GameScreenOutHandler     ; 
                              jmp MoveTilesReturn          ; 
                              
.ChkAmoebaToDiamond           lda B1Z_AmoebaToDiamond      ; 
                              bne .ChkAmoebaGrowing        ; B1Z_AmoebaToDiamond_No
                              
.TurnAmoebaIntoDiamond        lda #B1_TileDmndFix          ; 
                              jsr GameScreenOutHandler     ; 
                              jmp MoveTilesReturn          ; 
                              
.ChkAmoebaGrowing             lda B1Z_AmoebaGrowing        ; 
                              bne .GetAmoebaGrowthRND      ; 
                              
.IniNextMoveTargPos           lda #$03                     ; 
                              sta $46                      ; 
                              
.IniGrowthStopped             ldx #$01                     ; 
                              
.ChkNextMoveTargPos           ldy $46                      ; 
                              lda TabAmoebaMoveTargPos,y   ; 
                              tay                          ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              cmp #$02                     ; 
                              bcs .SetNextMoveTargPos      ; 
                              
                              ldx #$00                     ; 
                              
.SetNextMoveTargPos           dec $46                      ; 
                              bpl .ChkNextMoveTargPos      ; 
                              
.ChkGrowthStopped             cpx #$00                     ; 
                              bne .GetAmoebaGrowthRND      ; 
                              
.SetGrowthStopped             lda #$01                     ; 
                              sta B1Z_AmoebaGrowing        ; 
                              
.GetAmoebaGrowthRND           jsr GetValRND                ; 
                              and $9a                      ; RND control value
                              cmp #$04                     ; 
                              bcs DynMoveAmoebaX           ; 
                              
                              tax                          ; 
                              ldy TabAmoebaMoveTargPos,x   ; 
                              
.IniReturnCodeAmoeba_02       ldx #$01                     ; 
                              
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkSoil                 ; 
                              
                              ldx #$00                     ; 
                              
.ChkSoil                      cmp #B1_TileSoil             ; 
                              bne .SetReturnCode           ; 
                              
                              ldx #$00                     ; 
                              
.SetReturnCode                cpx #$00                     ; 
                              bne DynMoveAmoebaX           ; 
                              
                              lda #B1_TileAmoeba_          ; 
                              jsr GameScreenOutHandler     ; 
DynMoveAmoebaX                jmp MoveTilesReturn          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameIncNumLives               subroutine                   ; 
                              lda B1Z_GameNumLives         ; actual player no of lives
                              cmp #B1Z_GameNumLives_Max    ; 
                              beq GameIncNumLivesX         ; 
                              
                              inc B1Z_GameNumLives         ; actual player no of lives
                              
                              lda #B1Z_FlickerTimeOneUp_Ini; 
                              sta B1Z_FlickerTimeOneUp     ; bonus life flicker empty time
                              
GameIncNumLivesX              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameIncNumLivesCheck          subroutine                   ; 
                              lda B1Z_PlSaveScore_001000   ; actual player high score byte 03 - save
                              cmp B1Z_GameScore_001000     ; actual player high score byte 03 - 1000s
                              beq .Chk100s                 ; 
                              
                              jsr GameIncNumLives          ; 
                              
.Chk100s                      lda B1Z_PlSaveScore_000100   ; actual player high score byte 02 - save
                              cmp #$04                     ; 
                              bne GameIncNumLivesCheckX    ; 
                              
                              cmp B1Z_GameScore_000100     ; actual player high score byte 02 - 100s
                              beq GameIncNumLivesCheckX    ; 
                              
                              jsr GameIncNumLives          ; 
                              
GameIncNumLivesCheckX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameAddScore                  subroutine                   ; 
                              lda B1Z_GameScore_001000     ; actual player high score byte 03 - 1000s
                              sta B1Z_PlSaveScore_001000   ; actual player high score byte 03 - save
                              
                              lda B1Z_GameScore_000100     ; actual player high score byte 02 - 100s
                              sta B1Z_PlSaveScore_000100   ; actual player high score byte 02 - save
                              
                              ldx #B1_LenScores            ; 
                              clc                          ; 
.Add                          lda B1Z_GameScore,x          ; actual player score
                              adc B1Z_ActualScore,x        ; game scores
                              cmp #$0a                     ; 
                              bcc .SetScore                ; 
                              
                              sbc #$0a                     ; 
                              
.SetScore                     sta B1Z_GameScore,x          ; actual player score
                              ora #$10                     ; make chr 0-9
                              sta B1_SavRowStScore,x       ; 
                              dex                          ; 
                              bpl .Add                     ; 
                              
                              jsr GameIncNumLivesCheck     ; 
                              
GameAddScoreX                 rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabSfxBang                    dc.w $2f32 ; freq
                              dc.b $00 ; 
                              dc.b $00 ; 
                              dc.b $81 ; 
                              dc.b $19 ; 
                              dc.b $01 ; 
; ------------------------------------------------------------------------------------------------------------- ;
SetBangFlag                   subroutine                   ; 
                              lda #B1Z_SfxPlayBang_Yes     ; 
                              sta B1Z_SfxPlayBang          ; flag start/finish bang
                              
SetBangFlagX                  rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
CaveChkTimeCountDown          subroutine                   ; 
                              lda B1Z_CaveTime_100         ; game time 100s
                              bne CaveTuneCountDownX       ; 
                              
                              lda B1Z_CaveTime_010         ; game time 10s
                              bne CaveTuneCountDownX       ; 
                              
                              lda B1Z_CaveTime_001         ; game time 1s
                              bne CaveTuneCountDown        ; 
                              
                              lda #B1Z_CaveCompleted_Yes   ; 
                              sta B1Z_CaveCompleted        ; flag cave completed
                              
CaveChkTimeCountDownX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
CaveTuneCountDown             subroutine                   ; 
                              lda B1_IRQSfxTime            ; 
                              bne CaveTuneCountDownX       ; 
                              
                              jsr GetIniVoc2Ctrl           ; 
                              
                              lda #$0a                     ; 
                              sta ATDCY2                   ; SID - $D40C = Oscillator 2 Attack/Decay
                              
                              lda #$00                     ; 
                              sta SUREL2                   ; SID - $D40D = Oscillator 2 Sustain/Release
                              
                              lda #$27                     ; 
                              sec                          ; 
                              sbc B1Z_CaveTime_001         ; game time 1s - freq from $1e00-$2700 for secs $09-$01
                              sta FREHI2                   ; SID - $D408 = Oscillator 2 Frequency Control (High Byte)
                              
                              lda #$11                     ; 
                              sta VCREG2                   ; SID - $D40B = Oscillator 2 Control
                              
                              lda B1_SfxToPlayCount        ; 
                              ora #$80                     ; 
                              sta B1_SfxToPlayCount        ; 
                              
CaveTuneCountDownX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
CaveTimeDec                   subroutine                   ; 
                              ldx #B1_LenGameTime          ; 
                              clc                          ; clear only the first time
.GetTime                      lda B1Z_CaveTime,x           ; game time 1 10 100
                              adc #$09                     ; add carry if 1s or 10s were greater 10
                              cmp #$0a                     ; 10
                              bcc .Store                   ; lower
                              
                              sbc #$0a                     ; correct
                              
.Store                        sta B1Z_CaveTime,x           ; write back
                              
                              ora #$10                     ; make chr
                              sta B1_SavRowStTime,x        ; to status row
                              
                              dex                          ; 
                              bpl .GetTime                 ; 
                              
                              jsr CaveChkTimeCountDown     ; 
                              
CaveTimeDecX                  rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_CaveTimeCountDown         subroutine                   ; 
                              jsr CaveTimeDec              ; 
                              
                              inc B1Z_TimeCountSec         ; actual cave time
                              
                              lda B1Z_TimeCountSec         ; actual cave time
                              cmp B1_CaveTimWall           ; 
                              bne IRQ_CaveTimeCountDownX   ; 
                              
                              lda #$0f                     ; 
                              sta $9a                      ; RND control value
                              
IRQ_CaveTimeCountDownX        rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_RoFoWaitBirth             subroutine                   ; 
                              dec B1Z_RoFoWaitBirth        ; 
                              bne IRQ_RoFoWaitBirthX       ; 
                              
                              jsr SetBangFlag              ; 
                              
                              lda #$00                     ; 
                              sta B1Z_RoFoBorn             ; B1Z_RoFoBorn_Yes
                              sta B1Z_KeyPressedNew_0      ; scan value for keyboard row 00
                              sta B1Z_KeyPressedNew_7      ; scan value for keyboard row 07
                              
                              lda #B1Z_SfxPlay_Yes         ; 
                              sta B1Z_SfxPlay              ; 
                              
IRQ_RoFoWaitBirthX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameStatusInfoData            subroutine                   ; 
                              lda #<B1_SavRowStatus        ; 
                              sta B1Z_StatusRow_Lo         ; 
                              lda #>B1_SavRowStatus        ; 
                              sta B1Z_StatusRow_Hi         ; 
                              jsr StatusRowFill            ; 
                              
GameStatusInfoDataX           rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_TimeCountDown             subroutine                   ; 
                              inc B1Z_CountDownWait        ; count IRQs up to 60
                              
                              lda B1Z_CountDownWait        ; count IRQs up to 60
                              cmp #B1Z_CountDownWait_Max   ; 60
                              bne IRQ_TimeCountDownX       ; 
                              
                              lda #B1Z_CountDownWait_Ini   ; reset
                              sta B1Z_CountDownWait        ; count IRQs up to 60
                              
                              lda B1Z_GamePaused           ; flag pause mode $00=no >$00=yes
                              bne IRQ_TimeCountDownX       ; 
                              
                              lda B1Z_RoFoBorn             ; 
                              bne .GORoFoWaitBirth         ; B1Z_RoFoBorn_No
                              
                              jsr IRQ_CaveTimeCountDown    ; 
                              rts                          ; 
                              
.GORoFoWaitBirth              jsr IRQ_RoFoWaitBirth        ; 
IRQ_TimeCountDownX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameDiaGotInc                 subroutine                   ; 
                              ldx #B1_LenGameDiGot         ; 
                              clc                          ; clear only the first time
.GetDiaGot                    txa                          ; 
                              adc B1Z_DiaGot,x             ; diamonds got 1 10
                              cmp #$0a                     ; 10
                              bcc .Store                   ; 
                              
                              sbc #$0a                     ; correct
                              
.Store                        sta B1Z_DiaGot,x             ; write back
                              
                              ora #$10                     ; make chr
                              sta B1_SavRowStDiGot,x       ; 
                              
                              dex                          ; 
                              bpl .GetDiaGot               ; 
                              
GameDiaGotIncX                rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
StatusDiamondsToGet           subroutine                   ; 
                              ldx #B1_LenGameDiGet         ; 
.GetDiaGet                    lda B1Z_DiaToGet,x           ; diamonds to get 1 10
                              ora #$10                     ; make chr 0-9
                              sta B1_SavRowStDiGet,x       ; 
                              dex                          ; 
                              bpl .GetDiaGet               ; 
                              
StatusDiamondsToGetX          rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
StatusDiamondValue            subroutine                   ; 
                              ldx #B1_LenGameDiPts         ; 
.GetDiaPts                    lda B1Z_ActualScore_000010,x ; diamond value 1s 10s
                              ora #$10                     ; make chr
                              sta B1_SavRowStDiPts,x       ; 
                              dex                          ; 
                              bpl .GetDiaPts               ; 
                              
StatusDiamondValueX           rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameDiaGotAllCheck            subroutine                   ; 
                              lda B1Z_DiaGot_10            ; diamonds got 10s
                              cmp B1Z_DiaToGet_10          ; diamonds to get 10s
                              bne GameDiaGotAllCheckX      ; 
                              
                              lda B1Z_DiaGot_01            ; diamonds got 1s
                              cmp B1Z_DiaToGet_01          ; diamonds to get 1s
                              bne GameDiaGotAllCheckX      ; 
                              
                              lda #B1Z_DiaGotAll_Yes       ; 
                              sta B1Z_DiaGotAll            ; flag got all diamonds $00=no $01=yes
                              
                              ldx #B1_LenGameTime          ; 
.CopyLevelTime                lda B1Z_DiaValueSpecial,x    ; diamond value after cave was finished
                              sta B1Z_ActualScore_000100,x ; diamond value 100s
                              dex                          ; 
                              bpl .CopyLevelTime           ; 
                              
                              jsr StatusDiamondValue       ; 
                              
                              lda #$3c                     ; chr diamond
                              sta B1_SavRowStDiGet         ; wipe out diamonds to get
                              sta B1_SavRowStDiGet+1       ; 
                              
                              jsr SetBangFlag              ; 
                              
                              lda #B1Z_GameFlashTime_Ini   ; 
                              sta B1Z_GameFlashTime        ; duration finish flash
                              
GameDiaGotAllCheckX           rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabSfxDiamondPick             dc.w $1478 ; freq
TabSfxDiamondFall             dc.b $07 ; 
                              dc.b $00 ; 
                              dc.b $11 ; 
                              dc.b $00 ; 
                              dc.b $f0 ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynMovePickDiamond            subroutine                   ; 
                              inc B1_SfxToPlayCount        ; 
                              
                              ldx #B1_SfxToPlayBuffer_Len  ; 
.SetGet                       lda TabSfxDiamondPick,x      ; 
                              sta B1_SfxToPlayBuffer,x     ; 
                              dex                          ; 
                              bpl .SetGet                  ; 
                              
                              jsr GameAddScore             ; 
                              jsr GameDiaGotInc            ; 
                              jsr GameDiaGotAllCheck       ; 
                              
                              inc B1Z_RoFoMoves            ; flag moved $00=no $01=yes
                              
DynMovePickDiamondX           rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
RoFoPushBoulder               subroutine                   ; 
                              jsr GetValRND                ; 
                              
                              and #$03                     ; delay move sometimes
                              bne RoFoPushBoulderX         ; 
                              
                              inc B1Z_RoFoMoves            ; flag moved $00=no $01=yes
                              jsr SetSfxBoulderFall        ; 
                              
                              lda #B1_TileBldrFix_         ; 
                              jsr GameScreenOutHandler     ; 
                              
RoFoPushBoulderX              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynMoveRoFoChkTrail           subroutine                   ; 
                              lda #B1Z_RoFoMoves_No        ; 
                              sta B1Z_RoFoMoves            ; flag moved $00=no $01=yes
                              
.GetNextTileInMoveDir         lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkSoil                 ; 
                              
                              inc B1Z_RoFoMoves            ; flag moved $00=no $01=yes
                              
                              lda #$35                     ; 
                              sta B1_IRQSfx                ; 
                              rts                          ; 
                              
.ChkSoil                      cmp #B1_TileSoil             ; 
                              bne .ChkDiamond              ; 
                              
                              inc B1Z_RoFoMoves            ; flag moved $00=no $01=yes
                              
                              lda #$a5                     ; 
                              sta B1_IRQSfx                ; 
                              rts                          ; 
                              
.ChkDiamond                   cmp #B1_TileDmndFix          ; 
                              bne .ChkXitOpen              ; 
                              
                              jmp DynMovePickDiamond       ; 
                              
.ChkXitOpen                   cmp #B1_TileXitOpen          ; 
                              bne .ChkBoulder              ; 
                              
                              lda #B1Z_CaveCompleted_Yes   ; 
                              sta B1Z_CaveCompleted        ; flag cave completed
                              
                              lda #B1Z_TimeToScore_Yes     ; 
                              sta B1Z_TimeToScore          ; 
                              
                              inc B1Z_RoFoMoves            ; flag moved $00=no $01=yes
                              
.ChkBoulder                   cmp #B1_TileBldrFix          ; 
                              bne DynMoveRoFoChkTrailX     ; 
                              
.ChkPushLeft                  cpy #B1_CtrlData_Row_ColLe1  ; tried move left
                              bne .ChkPushRight            ; 
                              
                              ldy #B1_CtrlData_Row_ColLe2  ; tile left behind boulder
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .SetLeft                 ; not empty
                              
                              jsr RoFoPushBoulder          ; 
                              
.SetLeft                      ldy #B1_CtrlData_Row_ColLe1  ; 
                              
.ChkPushRight                 cpy #B1_CtrlData_Row_ColRi1  ; 
                              bne DynMoveRoFoChkTrailX     ; no push tried
                              
                              ldy #B1_CtrlData_Row_ColRi2  ; tile right behind boulder
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .SetRight                ; not empty
                              
                              jsr RoFoPushBoulder          ; 
                              
.SetRight                     ldy #B1_CtrlData_Row_ColRi1  ; 
DynMoveRoFoChkTrailX          rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynMoveRoFoHandler            subroutine                   ; 
                              jsr DynMoveRoFoChkTrail      ; 
                              
                              lda B1Z_RoFoMoves            ; flag moved $00=no $01=yes
                              beq DynMoveRoFoHandlerX      ; 
                              
                              jsr GetFireForPlayer         ; 
                              bne .RoFoShoot               ; 
                              
.ShootFire                    lda #B1_TileEmpty            ; 
                              jsr GameScreenOutHandler     ; 
                              
                              lda #B1Z_RoFoMoves_No        ; 
                              sta B1Z_RoFoMoves            ; flag moved $00=no $01=yes
.Exit                         rts                          ; 
                              
.RoFoShoot                    lda #B1_TileRockFord_        ; 
                              jsr GameScreenOutHandler     ; 
                              
                              ldy #B1_CtrlData_Row_Col     ; 
                              lda #B1_TileEmpty            ; 
                              jsr GameScreenOutHandler     ; 
                              
                              inc B1Z_RoFoMoves            ; flag moved $00=no $01=yes
                              
DynMoveRoFoHandlerX           rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynMoveRockFordChkUpDo        subroutine                   ; 
                              cmp #$0d                     ; ....##.# - down
                              bne DynMoveRockFordUp        ; 
                              
                              lda B1Z_RoFoScreenPosY       ; 
                              cmp #$06                     ; 
                              bne DynMoveRockFordDo        ; 
                              
                              lda B1Z_ScrollSoftDirUpDo_Hi ; 
                              beq DynMoveRockFordDo        ; 
                              
DynMoveRockFordChkUpDoX       rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynMoveRockFordDo             subroutine                   ; 
                              ldy #B1_CtrlData_RowDo1_ColUp; 
                              jsr DynMoveRoFoHandler       ; 
                              
                              lda B1Z_RoFoMoves            ; flag moved $00=no $01=yes
                              beq DynMoveRockFordDoX       ; 
                              
                              inc B1Z_RoFoPosY             ; RockFord posY
                              
DynMoveRockFordDoX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynMoveRockFordUp             subroutine                   ; 
                              cmp #$0e                     ; ....###. - up
                              bne DynMoveRockFordChkLeRi   ; 
                              
                              ldy #B1_CtrlData_RowUp1_ColUp; 
                              jsr DynMoveRoFoHandler       ; 
                              
                              lda B1Z_RoFoMoves            ; flag moved $00=no $01=yes
                              beq DynMoveRockFordUpX       ; 
                              
                              dec B1Z_RoFoPosY             ; RockFord posY
                              
DynMoveRockFordUpX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynMoveRockFordChkLeRi        subroutine                   ; 
                              cmp #$08                     ; ....#... - right
                              bcs DynMoveRockFordLe        ; 
                              
                              lda B1Z_RoFoScreenPosX       ; 
                              cmp #$08                     ; 
                              bne DynMoveRockFordRi        ; 
                              
                              lda B1Z_ScrollSoftDirLeRi_Hi ; 
                              beq DynMoveRockFordRi        ; 
                              
DynMoveRockFordChkLeRiX       rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynMoveRockFordRi             subroutine                   ; 
                              lda #B1Z_RoFoMoveDir_Ri      ; 
                              sta B1Z_RoFoMoveDir          ; flag rockford move direction left right
                              
                              ldy #B1_CtrlData_Row_ColRi1  ; 
                              jsr DynMoveRoFoHandler       ; 
                              
                              lda B1Z_RoFoMoves            ; flag moved $00=no $01=yes
                              beq DynMoveRockFordRiX       ; 
                              
                              inc B1Z_RoFoPosX             ; RockFord posX
                              
DynMoveRockFordRiX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynMoveRockFordLe             subroutine                   ; 
                              cmp #$0c                     ; 
                              bcs DynMoveRockFordLeX       ; 
                              
                              lda #B1Z_RoFoMoveDir_Le      ; 
                              sta B1Z_RoFoMoveDir          ; flag rockford move direction left right
                              
                              ldy #B1_CtrlData_Row_ColLe1  ; 
                              jsr DynMoveRoFoHandler       ; 
                              
                              lda B1Z_RoFoMoves            ; flag moved $00=no $01=yes
                              beq DynMoveRockFordLeX       ; 
                              
                              dec B1Z_RoFoPosX             ; RockFord posX
                              
DynMoveRockFordLeX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynMoveRockFord               subroutine                   ; 
                              lda B1Z_GamePlay             ; flag $00=game $01=demo
                              beq .GetJoyNo                ; 
                              
                              lda B1Z_MovesPort_B          ; direction move
                              jmp .TryMove                 ; 
                              
.GetJoyNo                     lda B1Z_JoyStickNo           ; no of joysticks
                              and B1Z_GamePlayerNo         ; actual player no $00-$01
                              beq .GetJoy01                ; 
                              
.GetJoy02                     jsr GetMovesPort_A           ; 
                              bne .SetJoyVal               ; 
                              
.GetJoy01                     jsr GetMovesPort_B           ; 
                              
.SetJoyVal                    sta B1Z_MovesPort_B          ; direction move
                              
.TryMove                      jsr DynMoveRockFordChkUpDo   ; 
                              
                              lda #B1Z_WaitChkFire_Ini     ; 
                              sta B1Z_WaitChkFire          ; 
                              
DynMoveRockFordX              jmp MoveTilesReturn          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabTileExplode                dc.b B1_TileXplEmpty4        ; 
TabTileExpRepl                dc.b B1_TileEmpty            ; 
                              
                              dc.b B1_TileXplEmpty3        ; 
                              dc.b B1_TileXplEmpty4        ; 
                              
                              dc.b B1_TileXplEmpty2        ; 
                              dc.b B1_TileXplEmpty3        ; 
                              
                              dc.b B1_TileXplEmpty1        ; 
                              dc.b B1_TileXplEmpty2        ; 
                              
                              dc.b B1_TileXplEmpty0        ; 
                              dc.b B1_TileXplEmpty1        ; 
                              
                              dc.b B1_TileExplDmnd4        ; 
                              dc.b B1_TileDmndFix          ; 
                              
                              dc.b B1_TileExplDmnd3        ; 
                              dc.b B1_TileExplDmnd4        ; 
                              
                              dc.b B1_TileExplDmnd2        ; 
                              dc.b B1_TileExplDmnd3        ; 
                              
                              dc.b B1_TileExplDmnd1        ; 
                              dc.b B1_TileExplDmnd2        ; 
                              
                              dc.b B1_TileExplDmnd0        ; 
                              dc.b B1_TileExplDmnd1        ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabTileRockFord               dc.b B1_TileBirthRF3         ; 
TabTileRockRepl               dc.b B1_TileRockFord         ; 
                              
                              dc.b B1_TileBirthRF2         ; 
                              dc.b B1_TileBirthRF3         ; 
                              
                              dc.b B1_TileBirthRF1         ; 
                              dc.b B1_TileBirthRF2         ; 
                              
                              dc.b B1_TileBirthRF0         ; 
                              dc.b B1_TileBirthRF1         ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynExplodeHandler             subroutine                   ; 
                              ldy #B1_CtrlData_Row_Col     ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              
                              ldy #$00                     ; 
.GetNext                      cmp TabTileExplode,y         ; 
                              bne .SetNext                 ; 
                              
                              ldx TabTileExpRepl,y         ; 
                              
.SetNext                      iny                          ; 
                              iny                          ; 
                              cpy #$14                     ; 
                              bne .GetNext                 ; 
                              
                              txa                          ; 
                              
                              ldy #$29                     ; 
                              jsr GameScreenOutHandler     ; 
                              
DynExplodeHandlerX            jmp MoveTilesReturn          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynBirthRoFo                  subroutine                   ; 
                              lda B1Z_RoFoWaitBirth        ; 
                              bne DynBirthRoFoX            ; 
                              
                              ldy #B1_CtrlData_Row_Col     ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              
                              ldy #$00                     ; 
.GetNext                      cmp TabTileRockFord,y        ; 
                              bne .SetNext                 ; 
                              
                              ldx TabTileRockRepl,y        ; 
                              
.SetNext                      iny                          ; 
                              iny                          ; 
                              cpy #$08                     ; 
                              bne .GetNext                 ; 
                              
                              txa                          ; 
                              ldy #$29                     ; 
                              jsr GameScreenOutHandler     ; 
                              
DynBirthRoFoX                 jmp MoveTilesReturn          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameScreenOutExitClose        subroutine                   ; 
                              lda #$2e                     ; 
.CaveCharNoPart_01_a          ldy #$00                     ; 
                              sta (B1Z_CaveScreenPos),y    ; ptr screen pos
                              
                              clc                          ; 
.CaveCharNoPart_01_b          adc #$01                     ; 
                              iny                          ; 
                              sta (B1Z_CaveScreenPos),y    ; ptr screen pos
                              
.CaveCharNoPart_02_a          adc #$0f                     ; 
                              ldy #$50                     ; 
                              sta (B1Z_CaveScreenPos),y    ; ptr screen pos
                              
.CaveCharNoPart_02_b          adc #$01                     ; 
                              iny                          ; 
                              sta (B1Z_CaveScreenPos),y    ; ptr screen pos
                              
GameScreenOutExitCloseX       rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynOutExitClose               subroutine                   ; 
                              lda B1Z_CaveCtrlFieldRow     ; row no
                              asl a                        ; 
                              tax                          ; 
                              
                              lda B1Z_CaveCtrlFieldCol     ; col no
                              asl a                        ; 
                              
                              clc                          ; 
                              adc TabScrnDataRowOff_Lo,x   ; 
                              sta B1Z_CavePlayFieldPos_Lo  ; ptr lo playfield row
                              lda #$00                     ; 
                              adc TabScrnDataRowOff_Hi,x   ; 
                              sta B1Z_CavePlayFieldPos_Hi  ; ptr hi playfield row
                              
                              jsr GameScreenGetPointer     ; 
                              jsr GameScreenOutExitClose   ; 
                              
DynOutExitCloseX              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynAnimStartDoor              subroutine                   ; 
                              ldy #B1_CtrlData_Row_Col     ; 
                              inc B1Z_BlinkStartDoor       ; 
                              lda B1Z_BlinkStartDoor       ; 
                              and #$01                     ; 
                              bne .GoOutExitClose          ; 
                              
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              jsr GameScreenOutHandler     ; 
                              
                              cmp #B1_TileBirthRF0         ; 
                              bne DynAnimStartDoorX        ; 
                              
                              jmp DynBirthRoFo             ; 
                              
.GoOutExitClose               jsr DynOutExitClose          ; 
                              
DynAnimStartDoorX             jmp MoveTilesReturn          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynChkMoveBoulder             subroutine                   ; 
                              ldy #B1_CtrlData_RowDo1_ColUp; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkObstacles            ; 
                              
                              lda #B1_TileBldrFall_        ; 
                              jsr GameScreenOutHandler     ; 
                              jsr SetSfxBoulderFall        ; 
                              jmp DynClearLastPos          ; 
                              
.ChkObstacles                 ldy #B1_CtrlData_RowDo1_ColUp; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              jsr DynCheckObstacle         ; 
                              bne DynChkMoveBoulderX       ; 
                              
.ChkOverbalance_Le            ldy #B1_CtrlData_RowDo1_ColLe; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkOverbalance_Ri       ; 
                              
                              ldy #B1_CtrlData_Row_ColLe1  ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkOverbalance_Ri       ; 
                              
                              lda #B1_TileBldrFall_        ; 
                              jsr GameScreenOutHandler     ; 
                              jmp DynClearLastPos          ; 
                              
.ChkOverbalance_Ri            ldy #B1_CtrlData_RowDo1_ColRi; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne DynChkMoveBoulderX       ; 
                              
                              ldy #B1_CtrlData_Row_ColRi1  ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne DynChkMoveBoulderX       ; 
                              
                              lda #B1_TileBldrFall_        ; 
                              jsr GameScreenOutHandler     ; 
                              jmp DynClearLastPos          ; 
                              
DynChkMoveBoulderX            jmp MoveTilesReturn          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynOutBoulderFix              subroutine                   ; 
                              ldy #$29                     ; 
                              lda #B1_TileBldrFix_         ; 
                              jsr GameScreenOutHandler     ; 
                              
DynOutBoulderFixX             rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
DynMoveBoulder                subroutine                   ; 
                              ldy #B1_CtrlData_RowDo1_ColUp; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkWallMagic            ; 
                              
                              lda #B1_TileBldrFall_        ; 
                              jsr GameScreenOutHandler     ; 
                              jmp DynClearLastPos          ; 
                              
.ChkWallMagic                 cmp #B1_TileWallMagic        ; 
                              bne .GoSfxBoulderFall        ; 
                              
                              lda B1Z_SfxMagicWall         ; 
                              bne .ChkWallMagicActive      ; 
                              
                              lda #B1Z_SfxMagicWall_On     ; 
                              sta B1Z_SfxMagicWall         ; 
                              
.ChkWallMagicActive           cmp #$01                     ; 
                              bne .ClrBoulder              ; 
                              
.ChkFreeSpaceBeyondMW         ldy #B1_CtrlData_RowDo2_ColUp; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ClrBoulder              ; 
                              
.TurnBoulderIntoDiamond       lda #B1_TileDmndFall_        ; 
                              jsr GameScreenOutHandler     ; 
                              
.ClrBoulder                   lda #B1_TileEmpty            ; 
                              ldy #$29                     ; 
                              jsr GameScreenOutHandler     ; 
                              jmp SetSfxDiamondFall        ; 
                              
.GoSfxBoulderFall             jsr SetSfxBoulderFall        ; 
                              
.ChkObstacles                 ldy #B1_CtrlData_RowDo1_ColUp; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              jsr DynCheckObstacle         ; 
                              bne .ChkFoFo                 ; 
                              
.ChkOverbalance_Le            ldy #B1_CtrlData_RowDo1_ColLe; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkOverbalance_Ri       ; 
                              
                              ldy #B1_CtrlData_Row_ColLe1  ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .ChkOverbalance_Ri       ; 
                              
                              lda #B1_TileBldrFall_        ; 
                              jsr GameScreenOutHandler     ; 
                              jmp DynClearLastPos          ; 
                              
.ChkOverbalance_Ri            ldy #B1_CtrlData_RowDo1_ColRi; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .GoDynOutBoulderFix      ; 
                              
                              ldy #B1_CtrlData_Row_ColRi1  ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              bne .GoDynOutBoulderFix      ; 
                              
                              lda #B1_TileBldrFall_        ; 
                              jsr GameScreenOutHandler     ; 
                              jmp DynClearLastPos          ; 
                              
.GoDynOutBoulderFix           jsr DynOutBoulderFix         ; 
                              jmp MoveTilesReturn          ; 
                              
.ChkFoFo                      cmp #B1_TileRockFord         ; 
                              bne .GoBoulderCheckHitFlies  ; 
                              
                              lda #B1_TileXplEmpty1        ; 
                              sta B1Z_ExplodeTileNo        ; explode tile no
                              jsr DynExplodeDropHandler    ; 
                              jmp MoveTilesReturn          ; 
                              
.GoBoulderCheckHitFlies       jsr DynBoulderChkHitFlies    ; 
                              bne .RestBoulder             ; 
                              
                              jsr DynExplodeDropHandler    ; 
                              jmp MoveTilesReturn          ; 
                              
.RestBoulder                  jsr DynOutBoulderFix         ; 
DynMoveBoulderX               jmp MoveTilesReturn          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IniEmptyTile                  subroutine                   ; 
                              lda #$00                     ; 
                              sta $3300 ; Gfx_60 - B1_TileEmpty top    left
                              sta $3304                    ; 
                              
                              sta $3308 ; Gfx_61 - B1_TileEmpty top    right
                              sta $330c                    ; 
                              
                              sta $3380 ; Gfx_70 - B1_TileEmpty bottom left
                              sta $3384                    ; 
                              
                              sta $3388 ; Gfx_71 - B1_TileEmpty bottom right
                              sta $338c                    ; 
                              
IniEmptyTileX                 rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameFlickerExtraLife          subroutine                   ; 
                              lda B1Z_FlickerTimeOneUp     ; bonus life flicker empty time
                              cmp #$01                     ; 
                              bne .SetFlickerEmptyTile     ; 
                              
                              jsr IniEmptyTile             ; 
                              
                              dec B1Z_FlickerTimeOneUp     ; bonus life flicker empty time
.Exit                         rts                          ; 
                              
.SetFlickerEmptyTile          jsr GetValRND                ; 
                              sta $3300 ; Gfx_60 - B1_TileEmpty top    left
                              sta $330c ; Gfx_61 - B1_TileEmpty top    right
                              
                              jsr GetValRND                ; 
                              sta $3384 ; Gfx_70 - B1_TileEmpty bottom left
                              sta $3388 ; Gfx_71 - B1_TileEmpty bottom right
                              
                              jsr GetValRND                ; 
                              sta $3304 ; Gfx_60 - B1_TileEmpty top    left
                              sta $3308 ; Gfx_61 - B1_TileEmpty top    right
                              
                              jsr GetValRND                ; 
                              sta $3380 ; Gfx_70 - B1_TileEmpty bottom left
                              sta $338c ; Gfx_71 - B1_TileEmpty bottom right
                              
                              dec B1Z_FlickerTimeOneUp     ; bonus life flicker empty time
                              
GameFlickerExtraLifeX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_OptsAnimCharSteel         subroutine                   ; 
                              ldy $2000                    ; save first chr byte
                              ldx #$00                     ; 
.Move                         lda $2001,x                  ; move all chr bytes on pos up
                              sta $2000,x                  ; 
                              inx                          ; 
                              cpx #$07                     ; 
                              bne .Move                    ; 
                              
                              sty $2007                    ; store first chr byte to the end
                              
IRQ_OptsAnimCharSteelX        rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabScrollSoftUpDo_Pos         equ *            ; 
TabScrollSoftUpDo_Lo          equ [* + $01]    ; 
TabScrollSoftUpDo_Hi          equ [* + $02]    ; 
                        
                              dc.b $03         ; 
                              dc.w [$00 - $40] ; 
                              
                              dc.b $07         ; 
                              dc.w $00         ; 
                              
                              dc.b $08         ; 
                              dc.w $00         ; 
                              
                              dc.b $0c         ; 
                              dc.w [$00 + $40] ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabScrollSoftLeRi_Pos         equ *            ; 
TabScrollSoftLeRi_Lo          equ [* + $01]    ; 
TabScrollSoftLeRi_Hi          equ [* + $02]    ; 
                        
                              dc.b $03         ; 
                              dc.w [$00 - $40] ; 
                              
                              dc.b $09         ; 
                              dc.w $00         ; 
                              
                              dc.b $0a         ; 
                              dc.w $00         ; 
                              
                              dc.b $10         ; 
                              dc.w [$00 + $40] ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_ScrollSetPosRoFo          subroutine                   ; 
                              lda B1Z_ScrollSoftValX       ; 
                              bne IRQ_ScrolleChkPosRoFo_Y  ; 
                              
                              lda B1Z_ScrollSoftValX_Sav   ; 
                              bne IRQ_ScrolleChkPosRoFo_Y  ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_ScrollSetPosRoFo_X        subroutine                   ; 
                              lda B1Z_RoFoScrollPosX       ; 
                              lsr a                        ; 
                              eor #$ff                     ; 
                              sec                          ; 
                              adc B1Z_RoFoPosX             ; RockFord posX
                              sta B1Z_RoFoScreenPosX       ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_ScrolleChkPosRoFo_Y       subroutine                   ; 
                              lda B1Z_ScrollSoftValY       ; 
                              bne IRQ_ScrollSetPosRoFoX    ; 
                              
                              lda B1Z_ScrollSoftValY_Sav   ; 
                              bne IRQ_ScrollSetPosRoFoX    ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_ScrollSetPosRoFo_Y        subroutine                   ; 
                              lda B1Z_RoFoScrollPosY       ; 
                              lsr a                        ; 
                              eor #$ff                     ; 
                              sec                          ; 
                              adc B1Z_RoFoPosY             ; RockFord posY
                              sta B1Z_RoFoScreenPosY       ; 
                              
IRQ_ScrollSetPosRoFoX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabSoftScrollX                dc.b $15 ; ...#.#.# - soft scrollX 05
                              dc.b $13 ; ...#..## - soft scrollX 03
                              dc.b $11 ; ...#...# - soft scrollX 01
                              dc.b $17 ; ...#.### - soft scrollX 07
; ------------------------------------------------------------------------------------------------------------- ;
TabSoftScrollY                dc.b $17 ; ...#.### - soft scrollY 07
                              dc.b $15 ; ...#.#.# - soft scrollY 05
                              dc.b $13 ; ...#..## - soft scrollY 03
                              dc.b $11 ; ...#...# - soft scrollY 01
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_ScrollHandlerUpDo         subroutine                   ; 
                              lda B1Z_ScrollSoftValY       ; 
                              bne .SetScroll               ; 
                              
                              lda B1Z_ScrollSoftValY_Sav   ; 
                              bne .SetScroll               ; 
                              
                              lda B1Z_ScrollType           ; 
                              and #B1Z_ScrollType_Hard     ; 
                              beq .ChkScrollDir            ; 
                              
                              rts                          ; 
                              
.ChkScrollDir                 lda B1Z_ScrollSoftDirUpDo_Lo ; 
                              cmp #$c0                     ; 
                              beq .SetScrollDataPtr_Up     ; 
                              
.SetScroll                    lda B1Z_ScrollSoftOffTabY    ; 
                              clc                          ; 
                              adc B1Z_ScrollSoftDirUpDo_Lo ; 
                              sta B1Z_ScrollSoftOffTabY    ; 
                              
                              lda B1Z_RoFoScrollPosY       ; 
                              adc B1Z_ScrollSoftDirUpDo_Hi ; 
                              sta B1Z_RoFoScrollPosY       ; 
                              
                              lda B1Z_ScrollSoftOffTabY    ; 
                              clc                          ; 
                              rol a                        ; 
                              rol a                        ; 
                              rol a                        ; 
                              rol a                        ; 
                              and #$07                     ; 
                              lsr a                        ; 
                              sta B1Z_ScrollSoftValY       ; 
                              
                              tax                          ; 
                              lda TabSoftScrollY,x         ; 
                              sta B1Z_VicSCROLY            ; raster value  flip flop 1st for SCROLY
                              
                              lda B1Z_ScrollSoftValY       ; 
                              cmp #$01                     ; 
                              bne .ChkScrollValY           ; 
                              
                              lda B1Z_ScrollSoftValY_Sav   ; 
                              bne .ChkScrollValY           ; 
                              
.SetScrollDataPtr_Do          lda B1Z_ScrnScrollData_Lo    ; ptr lo TabScrnDataRowOff $4003
                              clc                          ; 
                              adc #$50                     ; 
                              sta B1Z_ScrnScrollData_Lo    ; ptr lo TabScrnDataRowOff $4003
                              
                              lda B1Z_ScrnScrollData_Hi    ; ptr hi TabScrnDataRowOff $4003
                              adc #$00                     ; 
                              sta B1Z_ScrnScrollData_Hi    ; ptr hi TabScrnDataRowOff $4003
                              
.ChkScrollValY                lda B1Z_ScrollSoftValY       ; 
                              bne .SavScrollValY           ; 
                              
                              lda B1Z_ScrollSoftValY_Sav   ; 
                              cmp #$01                     ; 
                              bne .SavScrollValY           ; 
                              
                              jsr IRQ_ScrollSetPosRoFo_Y   ; 
                              lda B1Z_RoFoScrollPosY       ; 
                              beq .SavScrollValY           ; 
                              
                              lda B1Z_RoFoScreenPosY       ; 
                              cmp #$07                     ; 
                              beq .SavScrollValY           ; 
                              
.SetScrollDataPtr_Up          lda B1Z_ScrnScrollData_Lo    ; ptr lo TabScrnDataRowOff $4003
                              sec                          ; 
                              sbc #$50                     ; 
                              sta B1Z_ScrnScrollData_Lo    ; ptr lo TabScrnDataRowOff $4003
                              
                              lda B1Z_ScrnScrollData_Hi    ; ptr hi TabScrnDataRowOff $4003
                              sbc #$00                     ; 
                              sta B1Z_ScrnScrollData_Hi    ; ptr hi TabScrnDataRowOff $4003
                              
                              lda #$03                     ; 
                              sta B1Z_ScrollSoftValY_Sav   ; 
                              
                              rts                          ; 
                              
.SavScrollValY                lda B1Z_ScrollSoftValY       ; 
                              sta B1Z_ScrollSoftValY_Sav   ; 
                              
IRQ_ScrollHandlerUpDoX        rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_ScrollHandlerLeRi         subroutine                   ; 
                              lda B1Z_ScrollSoftValX       ; 
                              bne .SetScroll               ; 
                              
                              lda B1Z_ScrollSoftValX_Sav   ; 
                              bne .SetScroll               ; 
                              
                              lda B1Z_ScrollType           ; 
                              and #B1Z_ScrollType_Hard     ; 
                              beq .ChkScrollDir            ; 
                              
                              rts                          ; 
                              
.ChkScrollDir                 lda B1Z_ScrollSoftDirLeRi_Lo ; 
                              cmp #$c0                     ; 
                              beq .SetScrollDataPtr_Le     ; 
                              
.SetScroll                    lda B1Z_ScrollSoftOffTabX    ; 
                              clc                          ; 
                              adc B1Z_ScrollSoftDirLeRi_Lo ; 
                              sta B1Z_ScrollSoftOffTabX    ; 
                              
                              lda B1Z_RoFoScrollPosX       ; 
                              adc B1Z_ScrollSoftDirLeRi_Hi ; 
                              sta B1Z_RoFoScrollPosX       ; 
                              
                              lda B1Z_ScrollSoftOffTabX    ; 
                              clc                          ; 
                              rol a                        ; 
                              rol a                        ; 
                              rol a                        ; 
                              and #$03                     ; 
                              sta B1Z_ScrollSoftValX       ; 
                              
                              tax                          ; 
                              lda TabSoftScrollX,x         ; 
                              
                              ldx B1Z_RoFoWaitBirth        ; 
                              bne .SetScrollValX           ; 
                              
                              ldx B1Z_GameCaveNo           ; actual player cave number
                              cpx #$11                     ; 
                              bcc .SetScrollValX           ; 
                              
                              ora #$08                     ; ....#... - 40 columns
                              
.SetScrollValX                sta B1Z_VicSCROLX            ; raster value  flip flop 1st for SCROLX
                              
                              lda B1Z_ScrollSoftValX       ; 
                              cmp #$01                     ; 
                              bne .ChkScrollValX           ; 
                              
                              lda B1Z_ScrollSoftValX_Sav   ; 
                              bne .ChkScrollValX           ; 
                              
.SetScrollDataPtr_Ri          inc B1Z_ScrnScrollData_Lo    ; ptr lo TabScrnDataRowOff $4003
                              bne .ChkScrollValX           ; 
                              inc B1Z_ScrnScrollData_Hi    ; ptr hi TabScrnDataRowOff $4003
                              
.ChkScrollValX                lda B1Z_ScrollSoftValX       ; 
                              bne .SavScrollValX           ; 
                              
                              lda B1Z_ScrollSoftValX_Sav   ; 
                              cmp #$01                     ; 
                              bne .SavScrollValX           ; 
                              
                              jsr IRQ_ScrollSetPosRoFo_X   ; 
                              lda B1Z_RoFoScrollPosX       ; 
                              beq .SavScrollValX           ; 
                              
                              lda B1Z_RoFoScreenPosX       ; 
                              cmp #$09                     ; 
                              beq .SavScrollValX           ; 
                              
.SetScrollDataPtr_Le          lda B1Z_ScrnScrollData_Lo    ; ptr lo TabScrnDataRowOff $4003
                              sec                          ; 
                              sbc #$01                     ; 
                              sta B1Z_ScrnScrollData_Lo    ; ptr lo TabScrnDataRowOff $4003
                              
                              lda B1Z_ScrnScrollData_Hi    ; ptr hi TabScrnDataRowOff $4003
                              sbc #$00                     ; 
                              sta B1Z_ScrnScrollData_Hi    ; ptr hi TabScrnDataRowOff $4003
                              
                              lda #$03                     ; 
                              sta B1Z_ScrollSoftValX_Sav   ; 
                              
                              rts                          ; 
                              
.SavScrollValX                lda B1Z_ScrollSoftValX       ; 
                              sta B1Z_ScrollSoftValX_Sav   ; 
                              
IRQ_ScrollHandlerLeRiX        rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_ScrollSoftChkEnd          subroutine                   ; 
                              ldx #$00                     ; preset end
                              
.ChkScrollEndUpDo             lda B1Z_ScrollSoftOffTabY    ; 
                              bne .ChkScrollEndLeRi        ; 
                              
                              lda B1Z_RoFoScrollPosY       ; 
                              bne .ChkMaxDo                ; 
                              
                              ldy B1Z_ScrollSoftDirUpDo_Hi ; 
                              beq .ChkMaxDo                ; 
                              
                              stx B1Z_ScrollSoftDirUpDo_Lo ; 
                              stx B1Z_ScrollSoftDirUpDo_Hi ; 
.ChkMaxDo                     cmp #$15                     ; 
                              bne .ChkScrollEndLeRi        ; 
                              
                              ldy B1Z_ScrollSoftDirUpDo_Hi ; 
                              bne .ChkScrollEndLeRi        ; 
                              
.SetScrollEndUpDo             stx B1Z_ScrollSoftDirUpDo_Lo ; 
                              stx B1Z_ScrollSoftDirUpDo_Hi ; 
                              
.ChkScrollEndLeRi             lda B1Z_ScrollSoftOffTabX    ; 
                              bne IRQ_ScrollSoftChkEndX    ; 
                              
                              lda B1Z_RoFoScrollPosX       ; 
                              bne .ChkMaxRi                ; 
                              
                              ldy B1Z_ScrollSoftDirLeRi_Hi ; 
                              beq .ChkMaxRi                ; 
                              
                              stx B1Z_ScrollSoftDirLeRi_Lo ; 
                              stx B1Z_ScrollSoftDirLeRi_Hi ; 
.ChkMaxRi                     cmp #$2a                     ; 
                              bne IRQ_ScrollSoftChkEndX    ; 
                              
                              ldy B1Z_ScrollSoftDirLeRi_Hi ; 
                              bne IRQ_ScrollSoftChkEndX    ; 
                              
.SetScrollEndLeRi             stx B1Z_ScrollSoftDirLeRi_Lo ; 
                              stx B1Z_ScrollSoftDirLeRi_Hi ; 
                              
IRQ_ScrollSoftChkEndX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_ScrollSoftSetUpDo         subroutine                   ; 
.ChkUpDo_Max                  lda B1Z_RoFoScreenPosY       ; 
                              cmp #B1Z_RoFoScreenPosY_Max  ; 
                              bmi .ChkUpDo_Min             ; 
                              
.SetDirDo                     lda #<[$00 + $40]            ; 
                              sta B1Z_ScrollSoftDirUpDo_Lo ; 
                              lda #>[$00 + $40]            ; 
                              sta B1Z_ScrollSoftDirUpDo_Hi ; 
                              
.ChkUpDo_Min                  lda B1Z_RoFoScreenPosY       ; 
                              cmp #B1Z_RoFoScreenPosY_Min  ; 
                              bpl IRQ_ScrollSoftSetUpDoX   ; 
                              
.SetDirUp                     lda #<[$00 - $40]            ; 
                              sta B1Z_ScrollSoftDirUpDo_Lo ; 
                              lda #>[$00 - $40]            ; 
                              sta B1Z_ScrollSoftDirUpDo_Hi ; 
                              
IRQ_ScrollSoftSetUpDoX        rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_ScrollSoftSetLeRi         subroutine                   ; 
.ChkLeRi_Max                  lda B1Z_RoFoScreenPosX       ; 
                              cmp #B1Z_RoFoScreenPosX_Max  ; 
                              bmi .ChkLeRi_Min             ; 
                              
.SetDirRi                     lda #<[$00 + $40]            ; 
                              sta B1Z_ScrollSoftDirLeRi_Lo ; 
                              lda #>[$00 + $40]            ; 
                              sta B1Z_ScrollSoftDirLeRi_Hi ; 
                              
.ChkLeRi_Min                  lda B1Z_RoFoScreenPosX       ; 
                              cmp #B1Z_RoFoScreenPosX_Min  ; 
                              bpl IRQ_ScrollSoftSetLeRiX   ; 
                              
.SetDirLe                     lda #<[$00 - $40]            ; 
                              sta B1Z_ScrollSoftDirLeRi_Lo ; 
                              lda #>[$00 - $40]            ; 
                              sta B1Z_ScrollSoftDirLeRi_Hi ; 
                              
IRQ_ScrollSoftSetLeRiX        rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_ScrollSoftSetDir          subroutine                   ; 
                              ldy #$09                     ; 
                              ldx #$04                     ; 
.ChkNextScreenPosUpDo         lda B1Z_RoFoScreenPosY       ; 
                              cmp TabScrollSoftUpDo_Pos,y  ; 
                              bne .ChkScrollPosUpDo        ; 
                              
.SetScrollPosUpDo             lda TabScrollSoftUpDo_Lo,y   ; 
                              sta B1Z_ScrollSoftDirUpDo_Lo ; 
                              lda TabScrollSoftUpDo_Hi,y   ; 
                              sta B1Z_ScrollSoftDirUpDo_Hi ; 
                              
.ChkScrollPosUpDo             lda B1Z_RoFoScrollPosY       ; 
                              beq .SetNextEntry_UpDo       ; 
                              
                              lda B1Z_ScrollSoftDirUpDo_Lo ; 
                              bne .SetNextEntry_UpDo       ; 
                              
                              lda B1Z_RoFoWaitBirth        ; 
                              beq .SetNextEntry_UpDo       ; 
                              
                              lda B1Z_RoFoScreenPosY       ; 
                              cmp TabScrollSoftUpDo_Pos,y  ; 
                              bcc .SetScrollPosUpDo        ; 
                              
.SetNextEntry_UpDo            dey                          ; 
                              dey                          ; 
                              dey                          ; 
                              dex                          ; 
                              bne .ChkNextScreenPosUpDo    ; 
                              
                              jsr IRQ_ScrollSoftSetUpDo    ; 
                              
                              ldy #$09                     ; 
                              ldx #$04                     ; 
.ChkNextScreenPosLeRi         lda B1Z_RoFoScreenPosX       ; 
                              cmp TabScrollSoftLeRi_Pos,y  ; 
                              bne .ChkScrollPosLeRi        ; 
                              
.SetScrollPosLeRi             lda TabScrollSoftLeRi_Lo,y   ; 
                              sta B1Z_ScrollSoftDirLeRi_Lo ; 
                              lda TabScrollSoftLeRi_Hi,y   ; 
                              sta B1Z_ScrollSoftDirLeRi_Hi ; 
.ChkScrollPosLeRi             lda B1Z_RoFoScrollPosX       ; 
                              beq .SetNextEntry_LeRi       ; 
                              
                              lda B1Z_ScrollSoftDirLeRi_Lo ; 
                              bne .SetNextEntry_LeRi       ; 
                              
                              lda B1Z_RoFoWaitBirth        ; 
                              beq .SetNextEntry_LeRi       ; 
                              
                              lda B1Z_RoFoScreenPosX       ; 
                              cmp TabScrollSoftLeRi_Pos,y  ; 
                              bcc .SetScrollPosLeRi        ; 
                              
.SetNextEntry_LeRi            dey                          ; 
                              dey                          ; 
                              dey                          ; 
                              dex                          ; 
                              bne .ChkNextScreenPosLeRi    ; 
                              
                              jsr IRQ_ScrollSoftSetLeRi    ; 
                              
IRQ_ScrollSoftSetDirX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_ScrollHandler             subroutine                   ; 
                              lda B1Z_CaveType             ; level type $00=normal $01=extra
                              beq .ScrollPrepare           ; 
                              
                              lda B1Z_RoFoWaitBirth        ; 
                              bne .ScrollPrepare           ; 
                              
                              rts                          ; 
                              
.ScrollPrepare                jsr IRQ_ScrollSetPosRoFo     ; 
                              jsr IRQ_ScrollSoftSetDir     ; 
                              jsr IRQ_ScrollSoftChkEnd     ; 
                              jsr IRQ_ScrollHandlerLeRi    ; 
                              jsr IRQ_ScrollHandlerUpDo    ; 
                              
IRQ_ScrollHandlerX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IncCaveCtrlFieldPtr           subroutine                   ; 
                              inc B1Z_CaveCtrlFieldPos_Lo  ; ptr lo control screen
                              bne IncCaveCtrlFieldPtrX     ; 
                              inc B1Z_CaveCtrlFieldPos_Hi  ; ptr hi control screen
                              
IncCaveCtrlFieldPtrX          rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IniCaveCtrlFieldPtr           subroutine                   ; 
                              beq .AddRowLen               ; row no $00 or $01
                              
.Set2ndRow                    lda #B1_ColMax               ; 
                              
.AddRowLen                    clc                          ; 
                              adc #[B1_ColMax - $01]       ; 
                              sta B1Z_CaveCtrlFieldPos_Lo  ; ptr lo control screen
                              lda #>B1_CtrlScreen          ; 
                              sta B1Z_CaveCtrlFieldPos_Hi  ; ptr hi control screen
                              
IniCaveCtrlFieldPtrX          rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
PlayFieldCoverFull            subroutine                   ; 
                              ldx #$00                     ; 
.GetPlayFieldRowPtr           lda TabScrnDataRowOff_Lo,x   ; 
                              sta B1Z_CavePlayFieldPos_Lo  ; ptr lo playfield row
                              lda TabScrnDataRowOff_Hi,x   ; 
                              sta B1Z_CavePlayFieldPos_Hi  ; ptr hi playfield row
                              
                              ldy #$00                     ; 
                              lda #$7c                     ; 
.Cover                        sta (B1Z_CavePlayFieldPos),y ; ptr playfield row
                              iny                          ; 
                              cpy #$a0                     ; 160
                              bne .Cover                   ; 
                              
                              inx                          ; 
                              inx                          ; 
                              cpx #$2c                     ; 44
                              bne .GetPlayFieldRowPtr      ; 
                              
PlayFieldCoverFullX           rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
PlayFieldCoverRND             subroutine                   ; 
.IniZeroPageRowPtrTab         lda B1Z_ScrnScrollData_Lo    ; ptr lo TabScrnDataRowOff $4003
                              sta B1Z_PlayFieldRowTab_Lo   ; 
                              
                              lda B1Z_ScrnScrollData_Hi    ; ptr hi TabScrnDataRowOff $4003
                              sta B1Z_PlayFieldRowTab_Hi   ; 
                              
                              ldx #$00                     ; 
.SetNextZeroPageRowPtr        lda B1Z_PlayFieldRowTab_Lo,x ; 
                              clc                          ; 
                              adc #$50                     ; 
                              sta [B1Z_PlayFieldRowTab_Lo + $02],x ; 
                              
                              lda B1Z_PlayFieldRowTab_Hi,x ; 
                              adc #$00                     ; 
                              sta [B1Z_PlayFieldRowTab_Hi + $02],x ; 
                              
                              inx                          ; 
                              inx                          ; 
                              cpx #B1Z_PlayFieldRowTab_Len ; 
                              bne .SetNextZeroPageRowPtr   ; 
                              
                              lda #B1_ColMin               ; 
                              sta B1Z_CaveCtrlFieldCol     ; col no
                              
.IniPlayFieldRowPtrOff        ldx #$00                     ; 
.IniCaveScrnCharSelect        lda #$00                     ; 
                              sta B1Z_CaveScrnCharSelect   ; 
                              
.GetNextZeroPageRowPtr        lda B1Z_PlayFieldRowTab_Lo,x ; 
                              sta B1Z_CaveScreenPos_Lo     ; ptr lo screen pos
                              
                              lda B1Z_PlayFieldRowTab_Hi,x ; 
                              sta B1Z_CaveScreenPos_Hi     ; ptr hi screen pos
                              
.GoGetRND                     jsr GetValRND                ; 
                              
                              and #$3f                     ; ..######
                              cmp #B1_CtrlData_Row_ColRi2  ; 
                              bcs .GoGetRND                ; ac greater/equal
                              
                              tay                          ; 
                              
                              inc B1Z_CaveScrnCharSelect   ; 
                              bne .GetPieceWallSteel       ; always
                              
                              lda #$00                     ; 
                              sta (B1Z_CaveScreenPos),y    ; ptr screen pos
                              
.GetPieceWallSteel            lda #$7c                     ; 
                              sta (B1Z_CaveScreenPos),y    ; ptr screen pos
                              
                              inx                          ; 
                              inx                          ; 
                              cpx #$30                     ; 
                              bne .IniCaveScrnCharSelect   ; 
                              
                              inc B1Z_CaveCtrlFieldCol     ; col no
                              
                              lda B1Z_CaveCtrlFieldCol     ; col no
                              cmp #$30                     ; 
                              bne .IniPlayFieldRowPtrOff   ; 
                              
PlayFieldCoverRNDX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameCaveDataWallSteel         subroutine                   ; 
                              ldx #$00                     ; 
                              lda #$4a                     ; gfx B1_TileWallSteel top left
.SetBottom                    sta B1_PlayField + $0dc3,x   ; 
                              dex                          ; 
                              bne .SetBottom               ; 
                              
                              ldx #$02                     ; 
.SetTopLeft                   sta B1_PlayField,x           ; 
                              dex                          ; 
                              bpl .SetTopLeft              ; 
                              
GameCaveDataWallSteelX        rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameCaveUncoverRND            subroutine                   ; 
                              lda #B1Z_CaveUncoverCount_Ini; 
                              sta B1Z_CaveUncoverCount     ; 
                              
.Set1stRow                    lda #B1_RowMin               ; 1st row
                              sta B1Z_CaveCtrlFieldRow     ; row no
                              jsr IniCaveCtrlFieldPtr      ; 
                              
.GetRndCol                    jsr GetValRND                ; 
                              sta B1Z_CaveCtrlFieldCol     ; col no
                              
                              lda #[B1_ColMax - $01]       ; 
                              sec                          ; 
                              sbc B1Z_CaveCtrlFieldCol     ; col no
                              bcc .GetRndCol               ; too high
                              
                              sta B1Z_CaveUncoverSeed      ; rnd col no
                              inc B1Z_CaveUncoverSeed      ; rnd col no
                              
                              lda B1Z_CaveCtrlFieldPos_Lo  ; ptr lo control screen
                              clc                          ; 
                              adc B1Z_CaveCtrlFieldCol     ; col no
                              sta B1Z_CaveCtrlFieldPos_Lo  ; ptr lo control screen
                              
                              lda B1Z_CaveCtrlFieldPos_Hi  ; ptr hi control screen
                              adc #$00                     ; 
                              sta B1Z_CaveCtrlFieldPos_Hi  ; ptr hi control screen
                              
                              ldy #B1_CtrlData_Row_Col     ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; ptr control screen
                              jsr GameScreenOutHandler     ; 
                              
                              lda B1Z_CaveCtrlFieldPos_Lo  ; ptr lo control screen
                              clc                          ; 
                              adc B1Z_CaveUncoverSeed      ; rnd col no
                              sta B1Z_CaveCtrlFieldPos_Lo  ; ptr lo control screen
                              
                              lda B1Z_CaveCtrlFieldPos_Hi  ; ptr hi control screen
                              adc #$00                     ; 
                              sta B1Z_CaveCtrlFieldPos_Hi  ; ptr hi control screen
                              
                              inc B1Z_CaveCtrlFieldRow     ; row no
                              lda B1Z_CaveCtrlFieldRow     ; row no
                              cmp #B1_RowMax               ; 
                              bne .GetRndCol               ; 
                              
                              dec B1Z_CaveUncoverCount     ; 
                              bne .Set1stRow               ; 
                              
GameCaveUncoverRNDX           rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_SfxRNDHandler             subroutine                   ; 
                              lda B1Z_SfxRNDPlay           ; 
                              beq .IniSndLvlCtrl           ; B1Z_SfxRNDPlay_No
                              
                              lda #$00                     ; 
                              sta B1_SfxToPlayCount        ; 
                              
                              inc B1_SfxRandomCtrl         ; 
                              
.ChkCtrl                      lda B1_SfxRandomCtrl         ; 
                              cmp #$02                     ; 
                              beq .CopyCoverChrI           ; 
                              
                              cmp #$01                     ; 
                              bne .Init                    ; 
                              
                              lda #$05                     ; 
                              sta ATDCY2                   ; SID - $D40C = Oscillator 2 Attack/Decay
                              
.GetRandom                    jsr GetValRND                ; 
                              and #$7f                     ; 
                              adc #$64                     ; 
                              sta FREHI2                   ; SID - $D408 = Oscillator 2 Frequency Control (High Byte)
                              
                              lda #$11                     ; 
                              sta VCREG2                   ; SID - $D40B = Oscillator 2 Control
                              bne .CopyCoverChrI           ; 
                              
.Init                         ldx #$00                     ; 
                              stx B1_SfxRandomCtrl         ; 
                              
                              lda #$10                     ; 
                              sta VCREG2                   ; SID - $D40B = Oscillator 2 Control
                              
.CopyCoverChrI                lda B1_GfxSet + [$7c * $08]  ; 
                              sta $4a                      ; save 1st byte
                              
                              ldx #$00                     ; 
.CopyCoverChr                 lda B1_GfxSet + [$7c * $08 + $01],x ; move all bytes 1 pos up
                              sta B1_GfxSet + [$7c * $08 + $00],x ; 
                              inx                          ; 
                              cpx #$07                     ; 
                              bne .CopyCoverChr            ; rotate level cover chr
                              
                              lda $4a                      ; 
                              sta B1_GfxSet + [$7c * $08 + $07] ; insert saved byte at the end
                              
.Exit                         rts                          ; 
                              
.IniSndLvlCtrl                lda #$00                     ; 
                              sta B1_SfxRandomCtrl         ; 
                              
IRQ_SfxRNDHandlerX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameCaveDataToScreen          subroutine                   ; 
                              jsr GameCaveUncoverRND       ; 
                              
                              lda #B1_RowMin               ; 1st row
                              sta B1Z_CaveCtrlFieldRow     ; row no
                              jsr IniCaveCtrlFieldPtr      ; 
                              
.Get1stCol                    lda #B1_ColMin               ; 
                              sta B1Z_CaveCtrlFieldCol     ; col no
                              
.GetCtrlScrnOff               ldy #B1_CtrlData_Row_Col     ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; 
                              jsr GameScreenOutHandler     ; 
                              jsr IncCaveCtrlFieldPtr      ; 
                              
.SetNextCol                   inc B1Z_CaveCtrlFieldCol     ; col no
                              lda B1Z_CaveCtrlFieldCol     ; col no
                              cmp #B1_ColMax               ; 
                              bne .GetCtrlScrnOff          ; 
                              
.SetNextRow                   inc B1Z_CaveCtrlFieldRow     ; row no
                              lda B1Z_CaveCtrlFieldRow     ; row no
                              cmp #B1_RowMax               ; 
                              bne .Get1stCol               ; 
                              
                              jsr GameCaveDataWallSteel    ; 
                              
GameCaveDataToScreenX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameAnimateRoFo               subroutine                   ; 
                              lda B1Z_MovesPort_B          ; direction move
                              cmp #$0f                     ; ....#### - no move
                              beq .AnimateWait             ; 
                              
.AnimateMoves                 lda #$00                     ; 
                              sta B1Z_AnimRoFoTaps         ; flag random animation anmimation 02
                              sta B1Z_AnimRoFoBlink        ; flag random animation anmimation 01
                              
                              lda B1Z_RoFoMoveDir          ; flag rockford move direction left right
                              bne .AnimateRunLeft          ; 
                              
.AnimateRunRight              lda TabGfxStore + [$c0 * $08],x
                              sta B1_GfxSet   + [$4c * $08],y ; B1_TileRockFord top left
                              lda TabGfxStore + [$c1 * $08],x
                              sta B1_GfxSet   + [$4d * $08],y ; B1_TileRockFord top right
                              
                              lda TabGfxStore + [$d0 * $08],x
                              sta B1_GfxSet   + [$5c * $08],y ; B1_TileRockFord bot left
                              lda TabGfxStore + [$d1 * $08],x
                              sta B1_GfxSet   + [$5d * $08],y ; B1_TileRockFord bot right
                              
                              rts                          ; 
                              
.AnimateRunLeft               lda TabGfxStore + [$a0 * $08],x
                              sta B1_GfxSet   + [$4c * $08],y ; B1_TileRockFord top left
                              lda TabGfxStore + [$a1 * $08],x
                              sta B1_GfxSet   + [$4d * $08],y ; B1_TileRockFord top right
                              
                              lda TabGfxStore + [$b0 * $08],x
                              sta B1_GfxSet   + [$5c * $08],y ; B1_TileRockFord bot left
                              lda TabGfxStore + [$b1 * $08],x
                              sta B1_GfxSet   + [$5d * $08],y ; B1_TileRockFord bot left
                              
                              rts                          ; 
                              
.AnimateWait                  cpx #$00                     ; 
                              bne .ChkBlink                ; 
                              
                              lda #B1Z_AnimRoFoBlink_No    ; 
                              sta B1Z_AnimRoFoBlink        ; flag random animation anmimation 01
                              
.GetBlinkRND                  jsr GetValRND                ; 
                              and #$03                     ; 
                              bne .GetTapsRND              ; 
                              
.SetRnd01                     lda #B1Z_AnimRoFoBlink_Yes   ; 
                              sta B1Z_AnimRoFoBlink        ; flag random animation anmimation 01
                              
.GetTapsRND                   jsr GetValRND                ; 
                              and #$0f                     ; 
                              bne .ChkBlink                ; 
                              
.SetRnd02                     lda #B1Z_AnimRoFoTaps_Yes    ; 
                              eor B1Z_AnimRoFoTaps         ; flag random animation anmimation 02
                              sta B1Z_AnimRoFoTaps         ; flag random animation anmimation 02
                              
.ChkBlink                     lda B1Z_AnimRoFoBlink        ; flag random animation anmimation 01
                              beq .EyeOpen                 ; B1Z_AnimRoFoBlink_No
                              
.EyeClose                     lda TabGfxStore + [$80 * $08],x
                              sta B1_GfxSet   + [$4c * $08],y ; B1_TileRockFord top left
                              lda TabGfxStore + [$81 * $08],x
                              sta B1_GfxSet   + [$4d * $08],y ; B1_TileRockFord top right
                              jmp .ChkTaps                  ; 
                              
.EyeOpen                      lda B1_GfxSet   + [$42 * $08],y ; B1_TileRockFord top left  -- eye open
                              sta B1_GfxSet   + [$4c * $08],y ; B1_TileRockFord top Left  -- eye closed
                              lda B1_GfxSet   + [$43 * $08],y ; B1_TileRockFord top right -- eye open
                              sta B1_GfxSet   + [$4d * $08],y ; B1_TileRockFord top right -- eye closed
                              
.ChkTaps                      lda B1Z_AnimRoFoTaps         ; flag random animation anmimation 02
                              beq .SetTapsOff              ; B1Z_AnimRoFoTaps_No
                              
.SetTapsOn                    lda TabGfxStore + [$90 * $08],x
                              sta B1_GfxSet   + [$5c * $08],y ; B1_TileRockFord bottom left  -- foot up
                              lda TabGfxStore + [$91 * $08],x
                              sta B1_GfxSet   + [$5d * $08],y ; B1_TileRockFord bottom right -- foot down
                              
                              rts                          ; 
                              
.SetTapsOff                   lda B1_GfxSet   + [$52 * $08],y ; B1_TileRockFord bottom left  -- foot down/hand up
                              sta B1_GfxSet   + [$5c * $08],y ; B1_TileRockFord bottom left  -- foot up  /hand down
                              lda B1_GfxSet   + [$53 * $08],y ; B1_TileRockFord bottom right -- foot up  /hand up
                              sta B1_GfxSet   + [$5d * $08],y ; B1_TileRockFord bottom right -- foot down/hand down
                              
GameAnimateRoFoX              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_AnimateTiles              subroutine                   ; 
                              lda B1Z_RoFoWaitBirth        ; 
                              bne .GetAnimPhaseCount       ; 
                              
                              lda B1Z_SfxPlay              ; 
                              beq .GetAnimPhaseCount       ; B1Z_SfxPlay_No
                              
                              jsr GameStatusInfoData       ; 
                              
.GetAnimPhaseCount            lda B1Z_AnimTilePhaseOff     ; 
                              asl a                        ; 
                              tax                          ; 
                              
                              ldy #$00                     ; 
.GetNextAnimPhaseByte         lda T_5606,x                 ; 
                              sta B1_GfxSet   + [$48 * $08],y ; B1_TileDmnd top left
                              lda T_560e,x                 ; 
                              sta B1_GfxSet   + [$49 * $08],y ; B1_TileDmnd top lright
                              lda T_5686,x                 ; 
                              sta B1_GfxSet   + [$58 * $08],y ; B1_TileDmnd bot left
                              lda T_568e,x                 ; 
                              sta B1_GfxSet   + [$59 * $08],y ; B1_TileDmnd bot right
                              
                              lda B1Z_AnimateTile          ; 
                              beq .GoAnimateRockFord       ; 
                              
.ChkAmoeba                    cmp #$04                     ; 
                              bcc .ChkButterFly            ; 
                              
.GetAnimPhaseAmoeba           lda T_5406,x                 ; 
                              sta B1_GfxSet   + [$40 * $08],y ; B1_TileAmoeba top left
                              lda T_540e,x                 ; 
                              sta B1_GfxSet   + [$41 * $08],y ; B1_TileAmoeba top right
                              lda T_5486,x                 ; 
                              sta B1_GfxSet   + [$50 * $08],y ; B1_TileAmoeba bot left
                              lda T_548e,x                 ; 
                              sta B1_GfxSet   + [$51 * $08],y ; B1_TileAmoeba bot right
                              
.ChkButterFly                 lda B1Z_AnimateTile          ; 
                              and #$02                     ; 
                              beq .ChkFireFly              ; 
                              
.GetAnimPhaseButterFly        lda T_5706,x                 ; 
                              sta B1_GfxSet   + [$20 * $08],y ; B1_TileBttrFly top left
                              lda T_570e,x                 ; 
                              sta B1_GfxSet   + [$21 * $08],y ; B1_TileBttrFly top right
                              lda T_5786,x                 ; 
                              sta B1_GfxSet   + [$30 * $08],y ; B1_TileBttrFly bot left
                              lda T_578e,x                 ; 
                              sta B1_GfxSet   + [$31 * $08],y ; B1_TileBttrFly bot right
                              
.ChkFireFly                   lda B1Z_AnimateTile          ; 
                              and #$01                     ; 
                              beq .GoAnimateRockFord       ; 
                              
.GetAnimPhaseFireFly          lda T_5506,x                 ; 
                              sta B1_GfxSet   + [$64 * $08],y ; B1_TileFireFly top left
                              lda T_550e,x                 ; 
                              sta B1_GfxSet   + [$65 * $08],y ; B1_TileFireFly top right
                              lda T_5586,x                 ; 
                              sta B1_GfxSet   + [$74 * $08],y ; B1_TileFireFly bot left
                              lda T_558e,x                 ; 
                              sta B1_GfxSet   + [$75 * $08],y ; B1_TileFireFly bot rigt
                              
.GoAnimateRockFord            jsr GameAnimateRoFo          ; 
                              
                              inx                          ; 
                              iny                          ; 
                              cpy #$08                     ; 
                              bne .GetNextAnimPhaseByte    ; 
                              
IRQ_AnimateTilesX             rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_FlashHandler              subroutine                   ; 
                              lda B1Z_GameFlashTime        ; duration finish flash
                              beq IRQ_FlashHandlerX        ; 
                              
                              lda #WHITE                   ; 
                              sta BGCOL0                   ; VIC 2 - $D021 = BackGround Color 0
                              sta EXTCOL                   ; VIC 2 - $D020 = Border Color
                              
                              dec B1Z_GameFlashTime        ; duration finish flash
                              bne IRQ_FlashHandlerX        ; 
                              
                              lda #BLACK                   ; 
                              sta BGCOL0                   ; VIC 2 - $D021 = BackGround Color 0
                              sta EXTCOL                   ; VIC 2 - $D020 = Border Color
                              
IRQ_FlashHandlerX             rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_SfxHandler                subroutine                   ; 
                              lda #$0f                     ; 
                              sta SIGVOL                   ; SID - $D418 = Volume and Filter Select
                              
                              lda B1Z_GamePaused           ; flag pause mode $00=no >$00=yes
                              beq .ChkSfxBang              ; 
                              
                              rts                          ; 
                              
.ChkSfxBang                   lda B1Z_SfxPlayBang          ; flag start/got all bang - all except finish sound/time count down
                              beq .ChkBangTime             ; 
                              
                              lda B1Z_SfxPlayBangTime      ; 
                              bne .DecBangTime             ; 
                              
                              jsr GetIniVoc3Ctrl           ; 
                              
                              ldx #B1_LenSfxData           ; 
.GetSfxBang                   lda TabSfxBang,x             ; 
                              sta FRELO3,x                 ; SID - $D40E = Oscillator 3 Frequency Control (low byte)
                              dex                          ; 
                              bpl .GetSfxBang              ; 
                              
                              lda #B1Z_SfxPlayBangTime_Ini ; 
                              sta B1Z_SfxPlayBangTime      ; 
                              
.DecBangTime                  dec B1Z_SfxPlayBangTime      ; 
                              bne .ChkBangTime             ; 
                              
                              lda #B1Z_SfxPlayBang_No      ; 
                              sta B1Z_SfxPlayBang          ; flag start/finish bang
                              
                              jsr GetIniVoc3Ctrl           ; 
                              
.ChkBangTime                  lda B1Z_SfxPlayBangTime      ; 
                              bne .IncWaveWidth            ; 
                              
                              lda B1Z_SfxPlay              ; 
                              beq .ChkMagicWall            ; B1Z_SfxPlay_No
                              
                              lda B1Z_SfxAmoebaGrowth      ; 
                              beq .ChkMagicWall            ; B1Z_SfxAmoebaGrowth_No
                              
                              lda #$10                     ; 
                              sta VCREG3                   ; SID - $D412 = Oscillator 3 Control
.GetRNDVal                    jsr GetValRND                ; 
                              and #$1f                     ; ...#####
                              cmp #$08                     ; 
                              bcc .GetRNDVal               ; lower
                              
                              sta FREHI3                   ; SID - $D40F = Oscillator 3 Frequency Control (High Byte)
                              lda #$30                     ; 
                              sta ATDCY3                   ; SID - $D413 = Oscillator 3 Attack/Decay
                              lda #$11                     ; 
                              sta VCREG3                   ; SID - $D412 = Oscillator 3 Control
                              bne .IncWaveWidth            ; 
                              
.ChkMagicWall                 lda B1Z_SfxMagicWall         ; 
                              cmp #B1Z_SfxMagicWall_On     ; 
                              beq .IncWaveWidth            ; 
                              
                              jsr GetIniVoc3Ctrl           ; 
                              
.IncWaveWidth                 inc B1_SfxWaveForm           ; 
                              
                              lda B1_SfxWaveForm           ; 
                              and [B1_SfxToPlayWork + $02] ; 
                              bne .ChkFlagSfxRNDPlay       ; 
                              
                              lda B1_SfxToPlayCount        ; 
                              and #$7f                     ; 
                              beq .SetSfxRuRel_1           ; 
                              
                              ldx [B1_SfxToPlayWork + $04] ; 
                              dex                          ; 
                              stx VCREG1                   ; SID - $D404 = Oscillator 1 Control
                              cpx #$80                     ; 
                              bne .GetSfxBufferLen         ; 
                              
                              lda #$08                     ; 
                              sta VCREG1                   ; SID - $D404 = Oscillator 1 Control
                              
.GetSfxBufferLen              ldx #B1_SfxToPlayBuffer_Len  ; 
.IniSfxPlay                   lda B1_SfxToPlayBuffer,x     ; 
                              sta B1_SfxToPlayWork,x       ; 
                              sta FRELO1,x                 ; SID - $D400 = Oscillator 1 Frequency Control (Low Byte)
                              dex                          ; 
                              bpl .IniSfxPlay              ; 
                              
                              lda B1_SfxToPlayCount        ; 
                              and #$80                     ; 
                              sta B1_SfxToPlayCount        ; 
                              jmp .ChkFlagSfxRNDPlay       ; 
                              
.SetSfxRuRel_1                lsr [B1_SfxToPlayWork + $06] ; 
                              lda [B1_SfxToPlayWork + $06] ; 
                              and #$f0                     ; 
                              sta [B1_SfxToPlayWork + $06] ; 
                              sta SUREL1                   ; SID - $D406 = Oscillator 1 Sustain/Release
                              beq .ResetSfx                ; 
                              
                              cmp #$04                     ; 
                              bcs .ChkFlagSfxRNDPlay       ; 
                              
                              ldx [B1_SfxToPlayWork + $04] ; 
                              cpx #$11                     ; 
                              bne .ChkFlagSfxRNDPlay       ; 
                              
.ResetSfx                     ldx #$08                     ; 
                              stx VCREG1                   ; SID - $D404 = Oscillator 1 Control
                              lda #$00                     ; 
                              sta [B1_SfxToPlayWork + $06] ; 
                              
.ChkFlagSfxRNDPlay            lda B1Z_SfxRNDPlay           ; 
                              beq .ChkSfxTime_1            ; B1Z_SfxRNDPlay_No
                              
                              rts                          ; 
                              
.ChkSfxTime_1                 lda B1_IRQSfxTime            ; 
                              beq .ChkSfxCount             ; 
                              
                              dec B1_IRQSfxTime            ; 
                              
.ChkSfxCount                  lda B1_SfxToPlayCount        ; 
                              and #$80                     ; 
                              beq .ChkSfxTime_2            ; 
                              
                              rts                          ; 
                              
.ChkSfxTime_2                 lda B1_IRQSfxTime            ; 
                              beq .ChkSfxWait              ; 
                              
                              rts                          ; 
                              
.ChkSfxWait                   lda B1_IRQSfxWait            ; RockFord moves
                              bne .DecSfxWait              ; 
                              
                              ldy B1_IRQSfx                ; 
                              beq IRQ_SfxHandlerX          ; 
                              
                              jsr GetIniVoc2Ctrl           ; 
                              
                              sty FREHI2                   ; SID - $D408 = Oscillator 2 Frequency Control (High Byte)
                              
                              lda #$00                     ; 
                              sta B1_IRQSfx                ; 
                              
                              lda #$c0                     ; 
                              sta SUREL2                   ; SID - $D40D = Oscillator 2 Sustain/Release
                              lda #$30                     ; 
                              sta ATDCY2                   ; SID - $D40C = Oscillator 2 Attack/Decay
                              lda #$81                     ; 
                              sta VCREG2                   ; SID - $D40B = Oscillator 2 Control
                              
                              lda B1_IRQSfxWaitStop        ; 
                              cmp #B1_IRQSfxWaitStop_Shift ; 
                              beq .SetSfxWait              ; 
                              
                              lsr a                        ; 
                              sta B1_IRQSfxWaitStop        ; 
                              
.SetSfxWait                   sta B1_IRQSfxWait            ; 
.DecSfxWait                   dec B1_IRQSfxWait            ; 
                              
                              rts                          ; 
                              
IRQ_SfxHandlerX               jmp GetIniVoc2Ctrl           ; 
; ------------------------------------------------------------------------------------------------------------- ;
CharMagicWallInit             subroutine                   ; 
                              ldx #$07                     ; 
.ClrMagicWall                 lda B1_GfxSet   + [$4e * $08],x ; 
                              sta B1_GfxSet   + [$22 * $08],x ; char top left
                              sta B1_GfxSet   + [$23 * $08],x ; char top right
                              sta B1_GfxSet   + [$32 * $08],x ; char bot left
                              sta B1_GfxSet   + [$33 * $08],x ; char bot right
                              dex                          ; 
                              bpl .ClrMagicWall            ; 
                              
CharMagicWallInitX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_MagicWallAnimSfx          subroutine                   ; 
                              lda B1Z_ScrollType           ; 
                              and #B1Z_ScrollType_Hard     ; 
                              beq .IniAnimMagicWall        ; 
                              
                              lda #$10                     ; 
                              sta VCREG3                   ; SID - $D412 = Oscillator 3 Control
                              jsr GetValRND                ; 
                              and #$03                     ; 
                              asl a                        ; 
                              asl a                        ; 
                              asl a                        ; 
                              adc #$86                     ; 
                              sta FREHI3                   ; SID - $D40F = Oscillator 3 Frequency Control (High Byte)
                              
                              lda #$00                     ; 
                              sta ATDCY3                   ; SID - $D413 = Oscillator 3 Attack/Decay
                              
                              lda #$a0                     ; 
                              sta SUREL3                   ; SID - $D414 = Oscillator 3 Sustain/Release
                              
                              lda #$11                     ; 
                              sta VCREG3                   ; SID - $D412 = Oscillator 3 Control
                              
.IniAnimMagicWall             lda B1Z_AnimTilePhaseOff     ; 
                              and #$1f                     ; ...#####
                              tax                          ; 
                              
                              ldy #$00                     ; 
.GetAnimMagicWall             lda B1_GfxSet   + [$6c * $08],x
                              sta B1_GfxSet   + [$22 * $08],y ; char top left
                              sta B1_GfxSet   + [$23 * $08],y ; char top right
                              sta B1_GfxSet   + [$32 * $08],y ; char bot left
                              sta B1_GfxSet   + [$33 * $08],y ; char bot right
                              inx                          ; 
                              iny                          ; 
                              cpy #$08                     ; 
                              bne .GetAnimMagicWall        ; 
                              
IRQ_MagicWallAnimSfxX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_MagicWallHandler          subroutine                   ; 
                              lda B1Z_SfxMagicWall         ; 
                              cmp #B1Z_SfxMagicWall_On     ; 
                              bne .ChkReset                ; 
                              
                              jmp IRQ_MagicWallAnimSfx     ; 
                              
.ChkReset                     cmp #$02                     ; 
                              bne IRQ_MagicWallHandlerX    ; 
                              
                              jsr CharMagicWallInit        ; 
                              jsr GetIniVoc3Ctrl           ; 
                              
                              lda #$03                     ; 
                              sta B1Z_SfxMagicWall         ; 
                              
IRQ_MagicWallHandlerX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_AnimationHandler          subroutine                   ; 
                              lda B1Z_AnimTilePhaseOff     ; 
                              clc                          ; 
                              adc #$08                     ; 
                              and #$3f                     ; 
                              sta B1Z_AnimTilePhaseOff     ; 
                              
                              jsr IRQ_AnimateTiles         ; 
                              jsr IRQ_MagicWallHandler     ; 
                              
IRQ_AnimationHandlerX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_MagicWallPause            subroutine                   ; 
                              lda B1Z_GamePaused           ; flag pause mode $00=no >$00=yes
                              eor #$01                     ; 
                              and B1Z_SfxMagicWall         ; 
                              cmp #$01                     ; 
                              bne IRQ_MagicWallPauseX      ; 
                              
                              inc B1Z_MagicWallTimePause   ; 
                              
                              lda B1Z_MagicWallTimePause   ; 
                              cmp #B1Z_MagicWallTimePause_Max ; 
                              bne IRQ_MagicWallPauseX      ; 
                              
                              lda #$00                     ; 
                              sta B1Z_MagicWallTimePause   ; 
                              
                              inc B1Z_MagicWallTime        ; 
                              lda B1Z_MagicWallTime        ; 
                              cmp B1_CaveTimWall           ; 
                              bne IRQ_MagicWallPauseX      ; 
                              
                              lda #B1Z_SfxMagicWall_Reset  ; 
                              sta B1Z_SfxMagicWall         ; 
                              
IRQ_MagicWallPauseX           rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_StartGame                 subroutine                   ; 
                              lda B1Z_OptsFlipFlopSel      ; raster values flip flop pointer
                              beq .Game                   ; B1Z_OptsFlipFlopSel_Gfx
                              
                              rts                          ; 
                              
.Game                         jsr IRQ_FlashHandler         ; 
                              jsr IRQ_SfxRNDHandler        ; 
                              jsr IRQ_MagicWallPause       ; 
                              jsr IRQ_TimeCountDown        ; 
                              jsr IRQ_SfxHandler           ; 
                              
                              inc B1Z_ScrollType           ; B1Z_ScrollType_Soft / B1Z_ScrollType_Hard
                              jsr IRQ_ScrollHandler        ; 
                              
                              lda B1Z_ScrollType           ; 
                              and #B1Z_ScrollType_Hard     ; 
                              bne IRQ_GoScrollHard         ; 
                              
                              lda B1_VicVMCSB              ; 
                              sta B1Z_VicVMCSB             ; raster value  flip flop 1st for VMCSB - Chip Memory Control
                              eor #$80                     ; #.## ##. . - screen=$2c00-$2fe7 /  char set=$3000-$37ff
                              sta B1_VicVMCSB              ; 
                              
IRQ_StartGameX                rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_AdrScrollHard             = $9e00                      ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_GoScrollHard              jmp IRQ_AdrScrollHard        ; 
; -------------------------------------------------------------------------------------------------------------- ;
; Start of CopyCode - Goes to $9e00-$27ff                  ; 
; -------------------------------------------------------------------------------------------------------------- ;
CopyTo9e00                    equ *                        ; from $7b58
                              
IRQ_ScrollHard                lda B1Z_ScrnScrollData_Lo    ; ptr lo TabScrnDataRowOff $4003
                              clc                          ; 
                              adc #$20                     ; 
                              sta Mod__51                  ; 
                              
                              lda B1Z_ScrnScrollData_Hi    ; ptr hi TabScrnDataRowOff $4003
                              adc #$03                     ; 
                              sta Mod__52                  ; 
                              
                              lda B1_VicVMCSB              ; 
                              lsr a                        ; *2
                              lsr a                        ; *4
                              eor #$03                     ; ......## - flip bit0 and bit1
                              clc                          ; 
                              adc #$01                     ; 
                              sta Mod__55                  ; 
                              
                              lda #$b8                     ; 
                              sta Mod__54                  ; 
                              
                              ldx #$00                     ; 
.SetCopy1                     lda Mod__51,x                ; 
                              clc                          ; 
                              adc #$50                     ; 
                              sta Mod__57,x                ; 
                              
                              lda Mod__52,x                ; 
                              adc #$00                     ; 
                              sta Mod__58,x                ; 
                              
                              lda Mod__54,x                ; 
                              clc                          ; 
                              adc #$28                     ; 
                              sta Mod__5a,x                ; 
                              
                              lda Mod__55,x                ; 
                              adc #$00                     ; 
                              sta Mod__5b,x                ; 
                              
                              txa                          ; 
                              clc                          ; 
                              adc #$06                     ; 
                              tax                          ; 
                              cpx #$4e                     ; 
                              bcc .SetCopy1                ; 
                              
                              ldx #$27                     ; 
.Copy1                        lda TabCharStore,x           ; 
Mod__51                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 2
Mod__52                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 1
                              sta B1_PlayScrDatR02,x       ; 
Mod__54                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 2
Mod__55                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 1
                              lda TabCharStore,x           ; 
Mod__57                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 2
Mod__58                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 1
                              sta B1_PlayScrDatR02,x       ; 
Mod__5a                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 2
Mod__5b                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 1
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              dex                          ; 
                              bpl .Copy1                   ; 
                              
                              lda B1_VicVMCSB              ; 
                              lsr a                        ; 
                              lsr a                        ; 
                              eor #$03                     ; 
                              sta Mod__F4                  ; 
                              
                              lda #$28                     ; 
                              sta Mod__F3                  ; 
                              lda B1Z_ScrnScrollData_Lo    ; ptr lo TabScrnDataRowOff $4003
                              sta Mod__F0                  ; 
                              lda B1Z_ScrnScrollData_Hi    ; ptr hi TabScrnDataRowOff $4003
                              sta Mod__F1                  ; 
                              
                              ldx #$00                     ; 
.SetCopy2                     lda Mod__F0,x                ; 
                              clc                          ; 
                              adc #$50                     ; 
                              sta Mod__F6,x                ; 
                              
                              lda Mod__F1,x                ; 
                              adc #$00                     ; 
                              sta Mod__F7,x                ; 
                              
                              lda Mod__F3,x                ; 
                              clc                          ; 
                              adc #$28                     ; 
                              sta Mod__F9,x                ; 
                              
                              lda Mod__F4,x                ; 
                              adc #$00                     ; 
                              sta Mod__FA,x                ; 
                              
                              txa                          ; 
                              clc                          ; 
                              adc #$06                     ; 
                              tax                          ; 
                              cpx #$36                     ; 
                              bcc .SetCopy2                ; 
                              
                              ldx #$27                     ; 
.Copy2                        lda TabCharStore,x           ; 
Mod__F0                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 2
Mod__F1                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 1
                              sta B1_PlayScrDatR02,x       ; 
Mod__F3                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 2
Mod__F4                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 1
                              lda TabCharStore,x           ; 
Mod__F6                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 2
Mod__F7                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 1
                              sta B1_PlayScrDatR02,x       ; 
Mod__F9                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 2
Mod__FA                       = * - CopyTo9e00 + IRQ_AdrScrollHard - 1
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              lda TabCharStore,x           ; 
                              sta B1_PlayScrDatR02,x       ; 
                              dex                          ; 
                              bpl .Copy2                   ; 
                              
                              jsr IRQ_AnimationHandler     ; 
                              
                              lda B1Z_FlickerTimeOneUp     ; bonus life flicker empty time
                              beq IRQ_ScrollHardX          ; 
                              
                              jsr GameFlickerExtraLife     ; 
                              
IRQ_ScrollHardX               rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
CaveFillPseudoRND             subroutine                   ; 
                              ldx #$01                     ; 
                              jsr GetValPseudoRND          ; 
                              
                              ldy #$00                     ; 
.ChkProbability               cmp B1_CaveProbObjs,y        ; probability to set an object randomly
                              bcs .GetNext                 ; greater/equal - not within the given probability
                              
.SavObjectNo                  ldx B1_CaveTypeObjs,y        ; object no to be spread
                              
.GetNext                      iny                          ; 
                              cpy #B1_CaveRndObjLen        ; 
                              bne .ChkProbability          ; 
                              
                              txa                          ; restore object no
                              
                              ldy #B1_CtrlData_Row_Col     ; 
.SetObjectNo                  sta (B1Z_CaveCtrlFieldPos),y ; 
                              
CaveFillPseudoRNDX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameCaveGetDataRND            subroutine                   ; 
.Set2ndRow                    lda #[B1_RowMin + $01]       ; 2nd row
.Set1stRow                    sta B1Z_CaveCtrlFieldRow     ; row no
                              jsr IniCaveCtrlFieldPtr      ; 
                              
.Set1stColOfRow               lda #B1_ColMin               ; 
                              sta B1Z_CaveCtrlFieldCol     ; col no
                              
.GoGetRndTile                 jsr CaveFillPseudoRND        ; 
                              jsr IncCaveCtrlFieldPtr      ; 
                              
.SetNextCol                   inc B1Z_CaveCtrlFieldCol     ; col no
                              lda B1Z_CaveCtrlFieldCol     ; col no
                              cmp #B1_ColMax               ; 
                              bne .GoGetRndTile            ; 
                              
.SetNextRow                   inc B1Z_CaveCtrlFieldRow     ; row no
                              lda B1Z_CaveCtrlFieldRow     ; row no
                              cmp #B1_RowMax               ; 
                              bne .Set1stColOfRow          ; 
                              
GameCaveGetDataRNDX           rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabGameSpeed                  dc.b $0c ; difficulty level 0
                              dc.b $06 ; difficulty level 1
                              dc.b $03 ; difficulty level 2
                              dc.b $01 ; difficulty level 3
                              dc.b $00 ; difficulty level 4
; ------------------------------------------------------------------------------------------------------------- ;
GameSpeed                     subroutine                   ; 
                              ldy B1Z_GameSpeed            ; value for game speed slow down hi
                              beq GameSpeedX               ; 
                              
.GetWaitLo                    ldx #$10                     ; 
.Wait                         dex                          ; 
                              bne .Wait                    ; 
                              
                              dey                          ; 
                              bne .GetWaitLo               ; 
                              
GameSpeedX                    rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GetIniVoc1Ctrl                subroutine                   ; 
                              ldx #$04                     ; offset Oscillator 1 Frequency Control
                              bne GetIniVoc_Ctrl           ; always
                              
GetIniVoc2Ctrl                ldx #$0b                     ; offset Oscillator 2 Frequency Control
                              bne GetIniVoc_Ctrl           ; always
                              
GetIniVoc3Ctrl                ldx #$12                     ; offset Oscillator 3 Frequency Control
                              
GetIniVoc_Ctrl                lda #$08                     ; 
                              sta FRELO1,x                 ; SID - $D400 = Oscillator 1 Frequency Control (Low Byte)
                              lda #$00                     ; 
                              sta FRELO1,x                 ; SID - $D400 = Oscillator 1 Frequency Control (Low Byte)
                              
GetIniVoc_CtrlX               rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
InitVoc_1_2_3                 subroutine                   ; 
                              jsr GetIniVoc1Ctrl           ; 
                              jsr GetIniVoc2Ctrl           ; 
                              jsr GetIniVoc3Ctrl           ; 
                              
                              lda #$4f                     ; low pass on/full volume
                              sta SIGVOL                   ; SID - $D418 = Volume and Filter Select
                              
InitVoc_1_2_3X                rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
Wait                          subroutine                   ; 
                              ldy #$80                     ; 
.Wait                         dex                          ; 
                              bne .Wait                    ; 
                              dey                          ; 
                              bne .Wait                    ; 
                              
WaitX                         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
WaitAWhile                    subroutine                   ; 
                              jsr Wait                     ; 
                              jsr Wait                     ; 
                              jsr Wait                     ; 
                              jsr Wait                     ; 
                              
WaitAWhileX                   rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
WaitSpaceBar                  subroutine                   ; 
                              ldy #$90                     ; 
.SetWaitTimeLo                ldx #$00                     ; 
.GetKey                       lda B1Z_KeyPressedNew_7      ; scan value for keyboard row 07
.ChkKey_SPACE                 cmp #$ef                     ; ###.#### - SPACE
                              bne .Wait                    ; 
                              
                              rts                          ; 
                              
.Wait                         dex                          ; 
                              bne .GetKey                  ; 
                              dey                          ; 
                              bne .SetWaitTimeLo           ; 
                              
WaitSpaceBarX                 rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GamePause                     subroutine                   ; 
                              jsr StatusRowDataSave        ; 
                              
.ShowWaitMsg                  lda #<TxtSpc2Res             ; 
                              sta B1Z_StatusRow_Lo         ; 
                              lda #>TxtSpc2Res             ; 
                              sta B1Z_StatusRow_Hi         ; 
                              jsr StatusRowFill            ; 
                              
                              lda B1Z_GamePaused           ; flag pause mode $00=no >$00=yes
                              cmp #B1Z_GamePaused_Yes      ; 
                              bne .GoWaitSpaceBar          ; 
                              
                              inc B1Z_GamePaused           ; flag pause mode $00=no >$00=yes
                              jsr Wait                     ; 
                              
                              sta B1Z_KeyPressedNew_7      ; scan value for keyboard row 07
                              
.GoWaitSpaceBar               jsr WaitSpaceBar             ; 
                              
.ShowStatusMsg                lda #<B1_SavRowTemp          ; 
                              sta B1Z_StatusRow_Lo         ; 
                              lda #>B1_SavRowTemp          ; 
                              sta B1Z_StatusRow_Hi         ; 
                              jsr StatusRowFill            ; 
                              
                              jsr WaitSpaceBar             ; 
                              jsr WaitSpaceBar             ; CopyTo9e00 ends at jsr here - copy too long - only up to IRQ_ScrollHardX
                              jsr WaitSpaceBar             ; 
                              
                              lda B1Z_KeyPressedNew_7      ; scan value for keyboard row 07
.ChkKey_F1                    cmp #$ef                     ; ###.#### - SPACE
                              bne GamePause                ; 
                              
                              jsr Wait                     ; 
                              
                              lda #$00                     ; 
                              sta B1Z_KeyPressedNew_7      ; scan value for keyboard row 07
                              
GamePauseX                    rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameCheckKeys                 subroutine                   ; 
                              lda B1Z_KeyPressedNew_7      ; scan value for keyboard row 07
                              cmp #$ef                     ; ###.#### - SPACE
                              bne .ChkKey_STOP             ; 
                              
                              ldx #B1Z_SfxPlay_No          ; 
                              stx B1Z_SfxPlay              ; 
                              jsr InitVoc_1_2_3            ; 
                              
                              inc B1Z_GamePaused           ; flag pause mode $00=no >$00=yes
                              
                              jsr GamePause                ; 
                              
                              lda #B1Z_GamePaused_No       ; 
                              sta B1Z_GamePaused           ; flag pause mode $00=no >$00=yes
                              
                              inc B1Z_SfxPlay              ; B1Z_SfxPlay_Yes
                              
.ChkKey_STOP                  lda B1Z_KeyPressedNew_7      ; scan value for keyboard row 07
                              cmp #$7f                     ; .####### - STOP
                              bne .ResetKeyStore           ; 
                              
                              lda B1Z_RoFoWaitBirth        ; 
                              bne .ResetKeyStore           ; 
                              
                              lda #B1Z_SfxPlay_No          ; 
                              sta B1Z_SfxPlay              ; 
                              
                              lda #B1Z_CaveCompleted_Yes   ; 
                              sta B1Z_CaveCompleted        ; flag cave completed
                              
.ResetKeyStore                lda #$00                     ; 
                              sta B1Z_KeyPressedNew_7      ; scan value for keyboard row 07
                              
.ChkKey_F1                    lda B1Z_KeyPressedNew_0      ; scan value for keyboard row 00
                              cmp #$ef                     ; ###.#### - F1
                              bne GameCheckKeysX           ; 
                              
                              jmp GameStart                ; 
                              
GameCheckKeysX                rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
MoveTilesAmoebaSetVar         subroutine                   ; 
                              lda B1Z_AmoebaGrowing        ; 
                              bne .GetFlagGrowing          ; B1Z_AmoebaGrowing_No
                              
                              lda B1Z_SfxAmoebaGrowth      ; 
                              beq .GetFlagGrowing          ; B1Z_SfxAmoebaGrowth_No
                              
                              lda #B1Z_AmoebaToDiamond_Yes ; 
                              sta B1Z_AmoebaToDiamond      ; 
                              
.GetFlagGrowing               lda B1Z_AmoebaGrowing        ; 
                              sta B1Z_SfxAmoebaGrowth      ; 
                              
                              lda #B1Z_AmoebaGrowing_Yes   ; 
                              sta B1Z_AmoebaGrowing        ; 
                              
                              lda B1_AmoebaCountThis       ; actual count
                              sta B1_AmoebaCountLast       ; count last round
                              
                              lda #$00                     ; 
                              sta B1_AmoebaCountThis       ; actual count
                              
MoveTilesAmoebaSetVarX        rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
MoveTilesCheckFire            subroutine                   ; 
                              jsr GetFireForPlayer         ; 
                              
                              lda B1Z_WaitChkFire          ; 
                              cmp #B1Z_WaitChkFire_Max     ; 
                              bne MoveTilesCheckFireX      ; 
                              
                              lda B1Z_FirePort_A_B         ; status fire both joysticks
                              bne MoveTilesCheckFireX      ; 
                              
                              lda B1Z_TimeCountSec         ; actual cave time
                              beq MoveTilesCheckFireX      ; 
                              
                              lda #B1Z_CaveCompleted_Yes   ; 
                              sta B1Z_CaveCompleted        ; flag cave completed
                              
MoveTilesCheckFireX           rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
MoveTiles                     subroutine                   ; 
                              lda #B1_RowMax               ; 
                              sta B1Z_MoveTilesRowMax      ; 
                              
                              lda B1Z_GameCaveNo           ; actual player cave number
                              cmp #$11                     ; 
                              bcc .Get2ndRow               ; lower
                              
                              lda #B1_RowMaxXtra           ; 
                              sta B1Z_MoveTilesRowMax      ; 
                              
.Get2ndRow                    lda #[B1_RowMin + $01]       ; 2nd row
                              sta B1Z_CaveCtrlFieldRow     ; row no
                              jsr IniCaveCtrlFieldPtr      ; 
                              
                              lda #B1Z_WaitChkFire_Max     ; 
                              cmp B1Z_WaitChkFire          ; 
                              beq .GoChkFire               ; 
                              
                              inc B1Z_WaitChkFire          ; 
                              
.GoChkFire                    jsr MoveTilesCheckFire       ; 
                              jsr MoveTilesAmoebaSetVar    ; 
                              
MoveTilesScanColIni           lda #B1_ColMin               ; 
                              sta B1Z_CaveCtrlFieldCol     ; col no
                              
MoveTilesScanLoop             ldy #B1_CtrlData_Row_Col     ; 
                              lda (B1Z_CaveCtrlFieldPos),y ; 
                              
                              asl a                        ; 
                              tax                          ; 
                              lda TabSubMovesTiles_Hi,x    ; 
                              beq MoveTilesReturn          ; 
                              
                              sta B1Z_SubMovesTiles_Hi     ; 
                              lda TabSubMovesTiles_Lo,x    ; 
                              sta B1Z_SubMovesTiles_Lo     ; 
; -------------------------------------------------------------------------------------------------------------- ;
MoveTilesCall                 jmp (B1Z_SubMovesTiles)      ; 
MoveTilesReturn               equ  *                      ; Return MoveTiles subroutines
; -------------------------------------------------------------------------------------------------------------- ;
                              ldy #B1_CtrlData_RowUp1_ColLe; return point from dyn calls
                              lda (B1Z_CaveCtrlFieldPos),y ; 
                              tax                          ; 
                              lda TabCaveTileReplace,x     ; 
                              beq .IncCtrlScrnPtr          ; 
                              
                              sta (B1Z_CaveCtrlFieldPos),y ; 
                              
.IncCtrlScrnPtr               inc B1Z_CaveCtrlFieldPos_Lo  ; ptr lo control screen
                              bne .SetNextCol              ; 
                              inc B1Z_CaveCtrlFieldPos_Hi  ; ptr hi control screen
                              
.SetNextCol                   inc B1Z_CaveCtrlFieldCol     ; col no
                              lda B1Z_CaveCtrlFieldCol     ; col no
                              cmp #B1_ColMax               ; 
                              bne MoveTilesScanLoop        ; 
                              
                              jsr GameSpeed                ; 
                              
                              inc B1Z_CaveCtrlFieldRow     ; row no
                              lda B1Z_CaveCtrlFieldRow     ; row no
                              cmp B1Z_MoveTilesRowMax      ; 
                              bne MoveTilesScanColIni      ; 
                              
                              jsr GameCheckKeys            ; 
                              
MoveTilesX                    rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabDecAddOne                  dc.b $00 ; 
                              dc.b $00 ; 
                              dc.b $01 ; 
; ------------------------------------------------------------------------------------------------------------- ;
Hex2Dec                       subroutine                   ; 
                              ldx #B1_LenHex2Dec100        ; 
                              lda #$00                     ; 
.Init                         sta B1Z_HexToDecResult,x     ; hex2dec values 1 10 100
                              dex                          ; 
                              bpl .Init                    ; 
                              
                              lda B1Z_HexToDecValue        ; no of hex to decimal add rounds
                              beq Hex2DecX                 ; 
                              
.Start                        ldx #B1_LenHex2Dec100        ; 
                              clc                          ; 
.GetDecByte                   lda B1Z_HexToDecResult,x     ; hex2dec values 1 10 100
                              adc TabDecAddOne,x           ; 
                              cmp #$0a                     ; 10
                              bcc .SetDecByte              ; lower
                              
                              sbc #$0a                     ; reset to "0"
                              
.SetDecByte                   sta B1Z_HexToDecResult,x     ; hex2dec values 1 10 100
                              dex                          ; 
                              bpl .GetDecByte              ; 
                              
                              dec B1Z_HexToDecValue        ; no of hex to decimal add rounds
                              bne .Start                   ; 
                              
Hex2DecX                      rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabNextLevelNo                = [* - $02] ; 
TabThisLevelType              = [* - $01] ; 
                              
                              dc.b $02 ; next cave no
                              dc.b $00 ; this cave type = normal
                              
                              dc.b $03 ; 
                              dc.b $00 ; 
                              
                              dc.b $04 ; 
                              dc.b $00 ; 
                              
                              dc.b $11 ; 
                              dc.b $00 ; 
                              
                              dc.b $06 ; 
                              dc.b $00 ; 
                              
                              dc.b $07 ; 
                              dc.b $00 ; 
                              
                              dc.b $08 ; 
                              dc.b $00 ; 
                              
                              dc.b $12 ; 
                              dc.b $00 ; 
                              
                              dc.b $0a ; 
                              dc.b $00 ; 
                              
                              dc.b $0b ; 
                              dc.b $00 ; 
                              
                              dc.b $0c ; 
                              dc.b $00 ; 
                              
                              dc.b $13 ; 
                              dc.b $00 ; 
                              
                              dc.b $0e ; 
                              dc.b $00 ; 
                              
                              dc.b $0f ; 
                              dc.b $00 ; 
                              
                              dc.b $10 ; 
                              dc.b $00 ; 
                              
                              dc.b $14 ; 
                              dc.b $00 ; 
                              
                              dc.b $05 ; 
                              dc.b $01 ; this cave type = xtra
                              
                              dc.b $09 ; 
                              dc.b $01 ; this cave type = xtra
                              
                              dc.b $0d ; 
                              dc.b $01 ; this cave type = xtra
                              
                              dc.b $15 ; 
                              dc.b $01 ; this cave type = xtra
; ------------------------------------------------------------------------------------------------------------- ;
GameCaveGetDataFix            subroutine                   ; 
                              lda B1Z_GameCaveNo           ; actual player cave number
.ChkOldNo                     cmp B1Z_GameCaveNoLast       ; last cave number
                              beq .SeedRnd                 ; no copy
                              
.SetOldNo                     sta B1Z_GameCaveNoLast       ; last cave number
                              
                              asl a                        ; 
                              tax                          ; 
                              lda TabThisLevelType,x       ; 
                              sta B1Z_CaveType             ; level type $00=normal $01=extra
                              
                              clc                          ; 
                              lda #<CaveData_01            ; 
                              adc TabCaveDataOff,x         ; 
                              sta B1Z_CopyCaveData_Lo      ; 
                              
                              lda #>CaveData_01            ; 
                              adc [TabCaveDataOff + $01],x ; 
                              sta B1Z_CopyCaveData_Hi      ; 
                              
                              ldy #$00                     ; 
.GetNewData                   lda (B1Z_CopyCaveData),y     ; 
                              sta B1_CaveData,y            ; 
                              iny                          ; 
                              cpy #$f0                     ; 
                              bne .GetNewData              ; 
                              
.SeedRnd                      ldx B1Z_GameDifficulty       ; actual player difficult level
                              lda B1_CaveSeeds,x           ; 
                              sta B1Z_SeedPseudoRND        ; pseudo rnd generator seed 2
                              sta B1Z_NoUuse_40            ; 
                              
                              lda #$00                     ; 
                              sta B1Z_StartPseudoRND       ; pseudo rnd generator seed 2
                              sta B1Z_NoUuse_41            ; 
                              
.Colors                       lda B1_CaveColorB1           ; 
                              sta BGCOL1                   ; VIC 2 - $D022 = BackGround Color 1
                              lda B1_CaveColorB2           ; 
                              sta BGCOL2                   ; VIC 2 - $D023 = BackGround Color 2
                              
                              ldy #$28                     ; startpos
                              lda B1_CaveColorF1           ; 
                              jsr InitColorRam             ; C64   - $D800 = ColorRam
                              
GameCaveGetDataFixX           rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameCaveInit                  subroutine                   ; 
                              lda #$00                     ; B1Z_AmoebaGrowing_Yes / B1Z_SfxAmoebaGrowth_No
                              sta B1Z_AmoebaGrowing        ; 
                              sta B1Z_SfxAmoebaGrowth      ; 
                              
                              sta B1Z_WaitChkFire          ; 
                              sta B1Z_CaveCompleted        ; flag cave completed
                              
                              sta B1Z_SfxMagicWall         ; B1Z_SfxMagicWall_Off
                              sta B1Z_MagicWallTimePause   ; 
                              
                              sta B1Z_MagicWallTime        ; 
                              sta B1Z_DiaGotAll            ; flag got all diamonds $00=no $01=yes
                              
                              sta B1_AmoebaCountThis       ; actual count
                              
                              sta B1Z_TimeCountSec         ; actual cave time
                              sta B1Z_CountDownWait        ; count IRQs up to 60
                              
                              sta B1Z_TimeToScore          ; B1Z_TimeToScore_No
                              sta B1Z_GamePaused           ; flag pause mode $00=no >$00=yes
                              sta [B1_SfxToPlayWork + $02] ; 
                              
                              jsr CharMagicWallInit        ; 
                              
                              ldx B1Z_GameDifficulty       ; actual player difficult level
                              lda TabGameSpeed,x           ; 
                              sta B1Z_GameSpeed            ; value for game speed slow down hi
                              
                              lda B1_CaveTimes,x           ; 
                              sta B1Z_TimeCaveSec          ; max cave time
                              sta B1Z_HexToDecValue        ; no of hex to decimal add rounds
                              jsr Hex2Dec                  ; 
                              
                              ldx #B1_LenHex2Dec100        ; 
.SetCaveTime                  lda B1Z_HexToDecResult,x     ; hex2dec values 1 10 100
                              sta B1Z_CaveTime,x           ; game times 1 10 100
                              ora #$10                     ; make chr
                              sta B1_SavRowStTime,x        ; 
                              dex                          ; 
                              bpl .SetCaveTime             ; 
                              
                              ldx B1Z_GameDifficulty       ; actual player difficult level
                              lda B1_CaveGetDias,x         ; 
                              
                              sta B1Z_HexToDecValue        ; no of hex to decimal add rounds
                              jsr Hex2Dec                  ; 
                              
                              ldx #B1_LenHex2Dec10         ; 
.SetDiamondsToGet             lda B1Z_HexToDec_010,x       ; 
                              sta B1Z_DiaToGet,x           ; diamonds to get 1 10
                              dex                          ; 
                              bpl .SetDiamondsToGet        ; 
                              
                              jsr StatusDiamondsToGet      ; 
                              
                              lda B1_CavePtsDia            ; 
                              sta B1Z_HexToDecValue        ; no of hex to decimal add rounds
                              jsr Hex2Dec                  ; 
                              
                              ldx #B1_LenHex2Dec100        ; 
.SetDiamondValue              lda B1Z_HexToDecResult,x     ; hex2dec values 1 10 100
                              sta B1Z_ActualScore_000100,x ; diamond value 1 10 100
                              dex                          ; 
                              bpl .SetDiamondValue         ; 
                              
                              lda B1_CaveXtrDia            ; 
                              sta B1Z_HexToDecValue        ; no of hex to decimal add rounds
                              jsr Hex2Dec                  ; 
                              
                              ldx #B1_LenHex2Dec100        ; 
.SetDiamondValueXtra          lda B1Z_HexToDecResult,x     ; hex2dec values 1 10 100
                              sta B1Z_DiaValueSpecial,x    ; diamond value after cave was finished
                              dex                          ; 
                              bpl .SetDiamondValueXtra     ; 
                              
                              jsr StatusDiamondValue       ; 
                              
                              lda #$00                     ; 
                              sta B1Z_DiaGot_10            ; diamonds got 10
                              sta B1Z_DiaGot_01            ; diamonds got 1
                              
                              ora #$10                     ; make chr 0-9
                              sta B1_SavRowStDiGot         ; 
                              sta B1_SavRowStDiGot+1       ; 
                              
                              lda #$01                     ; 
                              sta B1Z_AmoebaToDiamond      ; B1Z_AmoebaToDiamond_No
                              sta B1Z_RoFoBorn             ; B1Z_RoFoBorn_No
                              
                              lda #$04                     ; 
                              sta B1Z_RoFoWaitBirth        ; 
                              
                              lda B1Z_TimeToScore          ; 
                              bne .ChkCaveNo               ; B1Z_TimeToScore_Yes
                              
                              lda B1Z_JoyStickNo           ; no of joysticks
                              eor #$01                     ; 
                              and B1Z_PlayerNo             ; no of players $00-$01
                              beq .ChkCaveNo               ; 
                              
                              lda #$06                     ; 
                              sta B1Z_RoFoWaitBirth        ; 
                              
.ChkCaveNo                    lda B1Z_GameCaveNo           ; actual player cave number
                              cmp #$02                     ; 
                              bne .RndCtrl                 ; 
                              
                              inc B1Z_RoFoWaitBirth        ; 
                              
.RndCtrl                      lda #$7f                     ; 
                              sta $9a                      ; RND control value
                              
                              lda #$07                     ; .....###
                              sta B1Z_AnimateTile          ; 
                              
                              ldx B1Z_GameCaveNo           ; actual player cave number
                              cpx #$11                     ; 
                              bcs GameCaveInitX            ; higher/equal
                              
                              dex                          ; 
                              lda T_8379,x                 ; 
                              sta B1Z_AnimateTile          ; 
                              
GameCaveInitX                 rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
StatusGameOver                subroutine                   ; 
                              lda #<TxtGameOver            ; 
                              sta B1Z_StatusRow_Lo         ; 
                              lda #>TxtGameOver            ; 
                              sta B1Z_StatusRow_Hi         ; 
                              
                              jsr StatusRowFill            ; 
                              jsr WaitAWhile               ; 
                              
StatusGameOverX               rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
WaitFireButton                subroutine                   ; 
                              ldy #$75                     ; 
.SetWaitX                     ldx #$80                     ; 
                              
.ChkType                      lda B1Z_CaveType             ; level type $00=normal $01=extra
                              bne .GetPlayer               ; 
                              
                              lda B1Z_GamePlayerNo         ; actual player no $00-$01
                              eor #$01                     ; flip
                              jmp .GoCheck                 ; 
                              
.GetPlayer                    lda B1Z_GamePlayerNo         ; actual player no $00-$01
.GoCheck                      jsr GetFirePort_A            ; 
                              bne .NotPressed              ; 
                              
.Pressed                      ldy #$01                     ; force exit
                              ldx #$01                     ; 
                              
.NotPressed                   dex                          ; 
                              bne .ChkType                 ; 
                              
                              dey                          ; 
                              bne .SetWaitX                ; 
                              
WaitFireButtonX               rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
StatusOutOfTimeBlink          subroutine                   ; 
                              lda #$14                     ; 
                              sta B1_StatusDataLenWrk      ; 
                              
.SaveStatus                   jsr StatusRowDataSave        ; 
                              
.SetTxtTimeOut                lda #<TxtTimeOut             ; 
                              sta B1Z_StatusRow_Lo         ; 
                              lda #>TxtTimeOut             ; 
                              sta B1Z_StatusRow_Hi         ; 
                              jsr StatusRowFill            ; show time out message in status row
                              
.WaitShort                    jsr WaitFireButton           ; 
                              
.RestoreStatus                lda #<B1_SavRowTemp          ; 
                              sta B1Z_StatusRow_Lo         ; 
                              lda #>B1_SavRowTemp          ; 
                              sta B1Z_StatusRow_Hi         ; 
                              jsr StatusRowFill            ; show status again
                              
.WaitLong                     jsr WaitFireButton           ; 
                              jsr WaitFireButton           ; 
                              jsr WaitFireButton           ; 
                              
.ChkFinish                    dec B1_StatusDataLenWrk      ; 
                              bne .ChkFire                 ; next round
                              
.SetFire                      lda #$00                     ; force fire pressed to exit
                              sta B1Z_FirePort_A_B         ; status fire both joysticks
                              
.ChkFire                      lda B1Z_FirePort_A_B         ; status fire both joysticks
                              bne .SaveStatus              ; not pressed
                              
StatusOutOfTimeBlinkX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
StatusLevelInfo               subroutine                   ; 
                              lda B1Z_GameCaveNo           ; actual player cave number
                              asl a                        ; 
                              tax                          ; 
                              lda TabThisLevelType,x       ; 
                              sta B1Z_CaveType             ; level type $00=normal $01=extra
                              beq .NormalLevel             ; 
                              
.BonusLevel                   lda #<TxtBonusLife           ; 
                              sta B1Z_StatusRow_Lo         ; 
                              lda #>TxtBonusLife           ; 
                              sta B1Z_StatusRow_Hi         ; 
                              jsr StatusRowFill            ; 
                              
                              jsr GameIncNumLives          ; 
                              jmp StatusLevelInfoX         ; 
                              
.NormalLevel                  lda #<B1_SavRowPlayer        ; 
                              sta B1Z_StatusRow_Lo         ; 
                              lda #>B1_SavRowPlayer        ; 
                              sta B1Z_StatusRow_Hi         ; 
                              jsr StatusRowFill            ; 
                              
StatusLevelInfoX              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameCaveEnd                   subroutine                   ; 
                              lda B1Z_TimeCountSec         ; actual cave time
                              cmp B1Z_TimeCaveSec          ; max cave time
                              bne .ChkGameOver             ; 
                              
.TimeOut                      lda #B1Z_SfxPlay_No          ; 
                              sta B1Z_SfxPlay              ; 
                              
                              lda #$10                     ; "0"
                              sta B1_PlayScrHdrTi1         ; header line time 1s
                              jsr StatusOutOfTimeBlink     ; 
                              
.ChkGameOver                  lda B1Z_GameOver             ; actual player still has lives $00=yes $01=no
                              beq .ChkCaveFirst            ; B1Z_GameOver_Yes
                              
                              lda #B1Z_SfxPlay_No          ; 
                              sta B1Z_SfxPlay              ; 
                              
                              jsr StatusGameOver           ; 
                              
                              lda #B1Z_SfxMagicWall_Reset  ; 
                              sta B1Z_SfxMagicWall         ; 
                              
                              jmp .CoverScreenRND          ; 
                              
.ChkCaveFirst                 lda B1Z_GameCaveNo           ; actual player cave number
                              beq .CoverScreenRND          ; 
                              
                              jsr StatusLevelInfo          ; 
                              
.CoverScreenRND               lda #B1Z_SfxRNDPlay_Yes      ; 
                              sta B1Z_SfxRNDPlay           ; 
                              
                              jsr InitVoc_1_2_3            ; 
                              
                              jsr PlayFieldCoverRND        ; 
                              jsr PlayFieldCoverFull       ; 
                              
                              lda B1Z_GameOver             ; actual player still has lives $00=yes $01=no
                              beq GameCaveEndX             ; B1Z_GameOver_Yes
                              
                              jsr WaitAWhile               ; 
                              
GameCaveEndX                  rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabCtrlDataRows               equ  * ; 
TabCtrlDataRow_Lo             equ  * ; 
TabCtrlDataRow_Hi             equ  [* + $01] ; 
                        
TabCtrlDataRow_00             dc.w B1_CtrlRow_00 ; $0800   ; 
TabCtrlDataRow_01             dc.w B1_CtrlRow_01 ; $0828   ; 
TabCtrlDataRow_02             dc.w B1_CtrlRow_02 ; $0850   ; 
TabCtrlDataRow_03             dc.w B1_CtrlRow_03 ; $0878   ; 
TabCtrlDataRow_04             dc.w B1_CtrlRow_04 ; $08a0   ; 
TabCtrlDataRow_05             dc.w B1_CtrlRow_05 ; $08c8   ; 
TabCtrlDataRow_06             dc.w B1_CtrlRow_06 ; $08f0   ; 
TabCtrlDataRow_07             dc.w B1_CtrlRow_07 ; $0918   ; 
TabCtrlDataRow_08             dc.w B1_CtrlRow_08 ; $0940   ; 
TabCtrlDataRow_09             dc.w B1_CtrlRow_09 ; $0968   ; 
TabCtrlDataRow_0a             dc.w B1_CtrlRow_10 ; $0990   ; 
TabCtrlDataRow_0b             dc.w B1_CtrlRow_11 ; $09b8   ; 
TabCtrlDataRow_0c             dc.w B1_CtrlRow_12 ; $09e0   ; 
TabCtrlDataRow_0d             dc.w B1_CtrlRow_13 ; $0a08   ; 
TabCtrlDataRow_0e             dc.w B1_CtrlRow_14 ; $0a30   ; 
TabCtrlDataRow_0f             dc.w B1_CtrlRow_15 ; $0a58   ; 
TabCtrlDataRow_10             dc.w B1_CtrlRow_16 ; $0a80   ; 
TabCtrlDataRow_11             dc.w B1_CtrlRow_17 ; $0aa8   ; 
TabCtrlDataRow_12             dc.w B1_CtrlRow_18 ; $0ad0   ; 
TabCtrlDataRow_13             dc.w B1_CtrlRow_19 ; $0af8   ; 
TabCtrlDataRow_14             dc.w B1_CtrlRow_20 ; $0b20   ; 
TabCtrlDataRow_15             dc.w B1_CtrlRow_21 ; $0b48   ; 
TabCtrlDataRow_16             dc.w B1_CtrlRow_22 ; $0b70   ; 
TabCtrlDataRow_17             dc.w B1_CtrlRow_23 ; $0b98   ; 
; ------------------------------------------------------------------------------------------------------------- ;
CaveVarDataSetOutPtr          subroutine                   ; 
                              lda B1Z_CaveDataVarParm_02   ; cave tile posY
                              asl a                        ; 
                              tay                          ; 
                              
                              clc                          ; 
                              lda TabCtrlDataRow_Lo,y      ; 
                              adc B1Z_CaveDataVarParm_01   ; cave tile posX
                              sta B1Z_GameScrnPos_Lo       ; 
                              lda TabCtrlDataRow_Hi,y      ; 
                              adc #$00                     ; 
                              sta B1Z_GameScrnPos_Hi       ; 
                              
CaveVarDataSetOutPtrX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
CaveVarDataTile               subroutine                   ; 
                              jsr CaveVarDataSetOutPtr     ; 
                              
                              lda B1Z_CaveDataVarParm_00   ; cave tile
                              ldy #$00                     ; 
                              sta (B1Z_GameScrnPos),y      ; 
                              
CaveVarDataTileX              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabCaveVarDrawDir             equ  *                       ; 
TabCaveVarDrawDir_Lo          equ  [* + $00]               ; 
TabCaveVarDrawDir_Hi          equ  [* + $01]               ; 
                              
TabCaveVarDrawDir_N           dc.b [$00 - $28      ]       ; up
                              dc.b [$00 - $01      ]       ; 
                              
TabCaveVarDrawDir_NE          dc.b [$00 - $28 + $01]       ; up/right
                              dc.b [$00 - $01      ]       ; 
                              
TabCaveVarDrawDir_E           dc.b [$00       + $01]       ; right
                              dc.b [$00            ]       ; 
                              
TabCaveVarDrawDir_SE          dc.b [$00 + $28 + $01]       ; down/right
                              dc.b [$00            ]       ; 
                              
TabCaveVarDrawDir_S           dc.b [$00 + $28 + $00]       ; down
                              dc.b [$00            ]       ; 
                              
TabCaveVarDrawDir_SW          dc.b [$00 + $28 - $01]       ; down/left
                              dc.b [$00            ]       ; 
                              
TabCaveVarDrawDir_W           dc.b [$00 - $00 - $01]       ; left
                              dc.b [$00       - $01]       ; 
                              
TabCaveVarDrawDir_NW          dc.b [$00 - $28 - $01]       ; up/left
                              dc.b [$00 - $01      ]       ; 
                              
TabCaveDrawDir_N              = [[TabCaveVarDrawDir_N  - TabCaveVarDrawDir] / $2]
TabCaveDrawDir_NE             = [[TabCaveVarDrawDir_NE - TabCaveVarDrawDir] / $2]
TabCaveDrawDir_E              = [[TabCaveVarDrawDir_E  - TabCaveVarDrawDir] / $2]
TabCaveDrawDir_SE             = [[TabCaveVarDrawDir_SE - TabCaveVarDrawDir] / $2]
TabCaveDrawDir_S              = [[TabCaveVarDrawDir_S  - TabCaveVarDrawDir] / $2]
TabCaveDrawDir_SW             = [[TabCaveVarDrawDir_SW - TabCaveVarDrawDir] / $2]
TabCaveDrawDir_W              = [[TabCaveVarDrawDir_W  - TabCaveVarDrawDir] / $2]
TabCaveDrawDir_NW             = [[TabCaveVarDrawDir_NW - TabCaveVarDrawDir] / $2]
; ------------------------------------------------------------------------------------------------------------- ;
CaveVarDrawLine               subroutine                   ; 
                              ldy #$00                     ; 
                              asl a                        ; 
                              tax                          ; 
                              lda TabCaveVarDrawDir_Lo,x   ; 
                              sta B1Z_CaveVarDrawLineDirLo ; 
                              lda TabCaveVarDrawDir_Hi,x   ; 
                              sta B1Z_CaveVarDrawLineDirHi ; 
                              
.SetNextLinePos               dec B1Z_CaveVarDrawLineLen   ; 
                              bmi CaveVarDrawLineX         ; 
                              
                              lda B1Z_CaveDataVarParm_00   ; cave tile
                              sta (B1Z_GameScrnPos),y      ; 
                              
                              clc                          ; 
                              lda B1Z_GameScrnPos_Lo       ; 
                              adc B1Z_CaveVarDrawLineDirLo ; 
                              sta B1Z_GameScrnPos_Lo       ; 
                              
                              lda B1Z_GameScrnPos_Hi       ; 
                              adc B1Z_CaveVarDrawLineDirHi ; 
                              sta B1Z_GameScrnPos_Hi       ; 
                              jmp .SetNextLinePos          ; 
                              
CaveVarDrawLineX              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
CaveVarDataLine               subroutine                   ; 
                              jsr CaveVarDataSetOutPtr     ; 
                              
                              lda B1Z_CaveDataVarParm_03   ; cave tile len
                              sta B1Z_CaveVarDrawLineLen   ; 
                              lda B1Z_CaveDataVarParm_04   ; cave tile dir
                              jsr CaveVarDrawLine          ; 
                              
CaveVarDataLineX              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
CaveVarDrawRectFill           subroutine                   ; 
                              jsr CaveVarDataSetOutPtr     ; 
                              
                              lda B1Z_CaveDataVarParm_04   ; cave tile hight
                              sta B1Z_CaveVarDrawLineLen   ; 
.SetNextLength                dec B1Z_CaveVarDrawLineLen   ; 
                              bmi CaveVarDrawRectFillX     ; 
                              
                              ldy B1Z_CaveDataVarParm_03   ; cave tile len
.SetNextHeight                dey                          ; 
                              bmi .SetNextRow              ; 
                              
                              lda B1Z_CaveDataVarParm_00   ; cave tile
                              sta (B1Z_GameScrnPos),y      ; 
                              jmp .SetNextHeight           ; 
                              
.SetNextRow                   clc                          ; 
                              lda B1Z_GameScrnPos_Lo       ; 
                              adc #$28                     ; 
                              sta B1Z_GameScrnPos_Lo       ; 
                              lda B1Z_GameScrnPos_Hi       ; 
                              adc #$00                     ; 
                              sta B1Z_GameScrnPos_Hi       ; 
                              jmp .SetNextLength           ; 
                              
CaveVarDrawRectFillX          rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
CaveVarDataRectFill           subroutine                   ; 
                              jsr CaveVarDrawRectFill      ; 
                              
                              lda B1Z_CaveDataVarParm_05   ; cave tile fill
                              sta B1Z_CaveDataVarParm_00   ; cave tile
                              
                              inc B1Z_CaveDataVarParm_01   ; cave tile posX
                              inc B1Z_CaveDataVarParm_02   ; cave tile posY
                              
                              dec B1Z_CaveDataVarParm_03   ; cave tile len
                              dec B1Z_CaveDataVarParm_03   ; cave tile len
                              
                              dec B1Z_CaveDataVarParm_04   ; cave tile hight
                              dec B1Z_CaveDataVarParm_04   ; cave tile hight
                              jsr CaveVarDrawRectFill      ; 
                              
CaveVarDataRectFillX          rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
CaveVarDataRect               subroutine                   ; 
                              jsr CaveVarDataSetOutPtr     ; 
                              
                              lda B1Z_CaveDataVarParm_03   ; cave tile len
                              sta B1Z_CaveVarDrawLineLen   ; 
                              dec B1Z_CaveVarDrawLineLen   ; 
                              lda #TabCaveDrawDir_E        ; 
                              jsr CaveVarDrawLine          ; 
                              
                              lda B1Z_CaveDataVarParm_04   ; cave tile hight
                              sta B1Z_CaveVarDrawLineLen   ; 
                              dec B1Z_CaveVarDrawLineLen   ; 
                              lda #TabCaveDrawDir_S        ; 
                              jsr CaveVarDrawLine          ; 
                              
                              lda B1Z_CaveDataVarParm_03   ; cave tile len
                              sta B1Z_CaveVarDrawLineLen   ; 
                              dec B1Z_CaveVarDrawLineLen   ; 
                              lda #TabCaveDrawDir_W        ; 
                              jsr CaveVarDrawLine          ; 
                              
                              lda B1Z_CaveDataVarParm_04   ; cave tile hight
                              sta B1Z_CaveVarDrawLineLen   ; 
                              dec B1Z_CaveVarDrawLineLen   ; 
                              lda #TabCaveDrawDir_N        ; 
                              jsr CaveVarDrawLine          ; 
                              
CaveVarDataRectX              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameCaveSetFuncLen_3          subroutine                   ; 
                              iny                          ; 
                              iny                          ; 
                              iny                          ; 
                              sty B1Z_CaveDataVarPtr       ; offset cave builder data
                              
GameCaveSetFuncLen_3X         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameCaveSetFuncLen_5          subroutine                   ; 
                              iny                          ; 
                              iny                          ; 
                              jsr GameCaveSetFuncLen_3     ; 
                              
GameCaveSetFuncLen_5X         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameCaveSetFuncLen_6          subroutine                   ; 
                              iny                          ; 
                              jsr GameCaveSetFuncLen_5     ; 
                              
GameCaveSetFuncLen_6X         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameCaveGetDataVar            subroutine                   ; 
                              ldy #$00                     ; 
                              sty B1Z_CaveDataVarPtr       ; offset cave builder data
                              
.GetNextVarFuncID             ldy B1Z_CaveDataVarPtr       ; offset cave builder data
                              lda B1_CaveTile,y            ; 
                              cmp #B1_EndOfCaveData        ; 
                              beq GameCaveGetDataVarX      ; 
                              
                              and #B1_DataBits             ; ..###### - isolate data bits
                              sta B1Z_CaveDataVarParm_00   ; cave tile
                              
                              cmp #B1_TileBirthRF0         ; RockFord birth phase 1
                              bne .SetTiles                ; 
                              
.SetRockFord                  lda B1_CaveTilePosX,y        ; 
                              sta B1Z_RoFoPosX             ; RockFord posX
                              lda B1_CaveTilePosY,y        ; 
                              sta B1Z_RoFoPosY             ; RockFord posY
                              
.SetTiles                     lda B1_CaveTilePosX,y        ; 
                              sta B1Z_CaveDataVarParm_01   ; cave tile posX
                              lda B1_CaveTilePosY,y        ; 
                              sta B1Z_CaveDataVarParm_02   ; cave tile posY
                              lda B1_CaveTileLen,y         ; 
                              sta B1Z_CaveDataVarParm_03   ; cave tile len
                              lda B1_CaveTileDir,y         ; 
                              sta B1Z_CaveDataVarParm_04   ; cave tile hight/dir
                              lda B1_CaveTileFill,y        ; 
                              sta B1Z_CaveDataVarParm_05   ; cave tile fill
                              
                              lda B1_CaveTile,y            ; 
                              and #B1_XtraBits             ; ##...... - isolate xtra bits
                              bne .ChkLine                 ; 
                              
.DrawTile                     jsr GameCaveSetFuncLen_3     ; use only 2 bytes
                              jsr CaveVarDataTile          ; 
                              jmp .GetNextFuncID           ; 
                              
.ChkLine                      cmp #$40                     ; .#...... - test bit6
                              bne .ChkRectFill             ; 
                              
.DrawLine                     jsr GameCaveSetFuncLen_5     ; use only 4 bytes
                              jsr CaveVarDataLine          ; 
                              jmp .GetNextFuncID           ; 
                              
.ChkRectFill                  cmp #$80                     ; #....... - test bit7
                              bne .ChkRect                 ; 
                              
.DrawRectFill                 jsr GameCaveSetFuncLen_6     ; use all  5 bytes
                              jsr CaveVarDataRectFill      ; 
                              jmp .GetNextFuncID           ; 
                              
.ChkRect                      cmp #B1_XtraBits             ; ##...... - isolate xtra bits
                              bne .GetNextFuncID           ; 
                              
.DrawRect                     jsr GameCaveSetFuncLen_5     ; 
                              jsr CaveVarDataRect          ; 
.GetNextFuncID                jmp .GetNextVarFuncID        ; 
                              
GameCaveGetDataVarX           rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
SetStartPlrJoy                subroutine                   ; 
                              lda B1Z_CopyRight            ; flag $00=show start screen values / $01=show start screen copyrights
                              bne SetStartPlrJoyX          ; 
                              
.SetPlayerNo                  lda B1Z_PlayerNo             ; no of players $00-$01
                              clc                          ; 
                              adc #$11                     ; make chr 1-9
                              sta B1_WaitScreenTxt + B1_WScrOffNoPlr
                              
                              adc #$34                     ; second half
                              sta B1_WaitScreenTxt + B1_WScrOffNoPlr+1
                              
.SetJoystickNo                lda B1Z_JoyStickNo           ; no of joysticks
                              clc                          ; 
                              adc #$11                     ; make chr 1-9
                              sta B1_WaitScreenTxt + B1_WScrOffNoJoy
                              
                              adc #$34                     ; second half
                              sta B1_WaitScreenTxt + B1_WScrOffNoJoy+1
                              
SetStartPlrJoyX               rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
CaveFrame                     subroutine                   ; 
                              lda #B1_TileWallSteel        ; 
                              sta B1Z_CaveDataVarParm_00   ; cave tile
                              
                              lda #$00                     ; 
                              sta B1Z_CaveDataVarParm_01   ; cave tile posX
                              
                              lda #$02                     ; 
                              sta B1Z_CaveDataVarParm_02   ; cave tile posY
                              
                              lda #B1_ColMax               ; 
                              sta B1Z_CaveDataVarParm_03   ; cave tile lenX
                              
                              lda #B1_RowMax               ; 
                              sta B1Z_CaveDataVarParm_04   ; cave tile lenY
                              
                              jsr CaveVarDataRect          ; 
                              
CaveFrameX                    rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
CopyStartScreen               subroutine                   ; 
                              ldx #$00                     ; 
.Screen                       lda TxtTitleScreen   + $0000,x  ; part 1 goes to B1_WaitScreenTxt ($0800)
                              sta B1_WaitScreenTxt + $0000,x
                              lda TxtTitleScreen   + $0100,x
                              sta B1_WaitScreenTxt + $0100,x
                              lda TxtTitleScreen   + $0200,x
                              sta B1_WaitScreenTxt + $0200,x
                              
                              lda TxtTitleScreen   + $02e8,x  ; part 2 goes to end of B1_WaitScreenGfx ($0ee8)
                              sta B1_WaitScreenGfx + $02e8,x
                              inx                          ; 
                              bne .Screen                  ; 
                              
                              lda B1Z_StatusStartRow       ; flag $00=start screen with setting rows / $01=start screen with copyright rows
                              ora B1Z_GamePlay             ; flag $00=game $01=demo
                              beq .2ndRun                  ; 
                              
.1stRun                       ldx #$00                     ; show these rows only if the game was started for the first time
                              ldy #$00                     ; 
.1stTxtRow01                  lda TxtByPeLi,y              ; 
                              sta B1_CtrlRow_19,x          ; 
                              
                              inx                          ; 
                              
                              clc                          ; 
                              adc #$34                     ; make second half
                              sta B1_CtrlRow_19,x          ; 
                              
                              inx                          ; 
                              iny                          ; 
                              cpy #$14                     ; 
                              bne .1stTxtRow01             ; 
                              
                              ldx #$00                     ; 
                              ldy #$00                     ; 
.1stTxtRow02                  lda TxtWiChGr,y              ; 
                              sta B1_CtrlRow_20,x          ; 
                              
                              inx                          ; 
                              
                              clc                          ; 
                              adc #$34                     ; 
                              sta B1_CtrlRow_20,x          ; 
                              
                              inx                          ; 
                              iny                          ; 
                              cpy #$14                     ; 
                              bne .1stTxtRow02             ; 
                              
                              ldx #$00                     ; 
                              ldy #$00                     ; 
.1stTxtRow03                  lda TxtPrBu2Play,y           ; 
                              sta B1_CtrlRow_21,x          ; 
                              
                              inx                          ; 
                              
                              clc                          ; 
                              adc #$34                     ; 
                              sta B1_CtrlRow_21,x          ; 
                              
                              inx                          ; 
                              iny                          ; 
                              cpy #$14                     ; 
                              bne .1stTxtRow03             ; 
                              
                              jmp .AllRun                  ; 
                              
.2ndRun                       ldx #$00                     ; there was at least one previous run
                              ldy #$00                     ; 
.2ndTxtRow01                  lda TxtPlr1Plr2,y            ; 
                              sta B1_CtrlRow_19,x          ; 
                              
                              inx                          ; 
                              
                              clc                          ; 
                              adc #$34                     ; 
                              sta B1_CtrlRow_19,x          ; 
                              
                              inx                          ; 
                              iny                          ; 
                              cpy #$14                     ; 
                              bne .2ndTxtRow01             ; 
                              
                              ldx #$00                     ; 
                              ldy #$00                     ; 
.2ndTxtRow02                  lda B1_SavRowScrLast,y       ; row last scores
                              sta B1_CtrlRow_20,x          ; 
                              
                              inx                          ; 
                              
                              clc                          ; 
                              adc #$34                     ; 2nd chr part
                              sta B1_CtrlRow_20,x          ; 
                              
                              inx                          ; 
                              iny                          ; 
                              cpy #B1_LenTxtRow            ; 
                              bne .2ndTxtRow02             ; 
                              
                              ldx #$00                     ; 
                              ldy #$00                     ; 
.2ndTxtRow03                  lda B1_SavRowScrHigh,y       ; row high scores
                              sta B1_CtrlRow_21,x          ; 
                              
                              inx                          ; 
                              
                              clc                          ; 
                              adc #$34                     ; 
                              sta B1_CtrlRow_21,x          ; 
                              
                              inx                          ; 
                              iny                          ; 
                              cpy #$14                     ; 
                              bne .2ndTxtRow03             ; 
                              
.AllRun                       ldx #$00                     ; 
                              ldy #$00                     ; 
.AllTxtRow05                  lda TxtCavLvl,y              ; 
                              sta B1_CtrlRow_23,x          ; 
                              
                              inx                          ; 
                              
                              clc                          ; 
                              adc #$34                     ; 
                              sta B1_CtrlRow_23,x          ; 
                              
                              inx                          ; 
                              iny                          ; 
                              cpy #$14                     ; 
                              bne .AllTxtRow05             ; 
                              
                              ldx #$00                     ; 
                              ldy #$00                     ; 
.AllTxtRow04                  lda Txt1Plr1Joy,y            ; 
                              sta B1_CtrlRow_22,x          ; 
                              
                              inx                          ; 
                              
                              clc                          ; 
                              adc #$34                     ; 
                              sta B1_CtrlRow_22,x          ; 
                              
                              inx                          ; 
                              iny                          ; 
                              cpy #$14                     ; 
                              bne .AllTxtRow04             ; 
                              
                              ldx #[B1_ColMax - $01]       ; 
                              lda #$20                     ; <blank>
.AllTxtRow06                  sta B1_CtrlRow_24,x          ; 
                              dex                          ; 
                              bpl .AllTxtRow06             ; 
                              
                              jsr SetStartPlrJoy           ; 
                              
                              lda #B1Z_StatusStartRow_Info ; 
                              sta B1Z_StatusStartRow       ; flag $00=start screen with setting rows / $01=start screen with copyright rows
                              
CopyStartScreenX              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabFrqCtrlLo                  = [* - 20] ; 
TabFrqCtrlHi                  = [* - 19] ; 
                              
                              dc.b $dc ; 
                              dc.b $02 ; 
                              dc.b $0a ; 
                              dc.b $03 ; 
                              dc.b $3a ; 
                              dc.b $03 ; 
                              dc.b $6c ; 
                              dc.b $03 ; 
                              dc.b $a0 ; 
                              dc.b $03 ; 
                              dc.b $d2 ; 
                              dc.b $03 ; 
                              dc.b $12 ; 
                              dc.b $04 ; 
                              dc.b $4c ; 
                              dc.b $04 ; 
                              dc.b $92 ; 
                              dc.b $04 ; 
                              dc.b $d6 ; 
                              dc.b $04 ; 
                              dc.b $20 ; 
                              dc.b $05 ; 
                              dc.b $6e ; 
                              dc.b $05 ; 
                              dc.b $b8 ; 
                              dc.b $05 ; 
                              dc.b $14 ; 
                              dc.b $06 ; 
                              dc.b $74 ; 
                              dc.b $06 ; 
                              dc.b $d8 ; 
                              dc.b $06 ; 
                              dc.b $40 ; 
                              dc.b $07 ; 
                              dc.b $a4 ; 
                              dc.b $07 ; 
                              dc.b $24 ; 
                              dc.b $08 ; 
                              dc.b $98 ; 
                              dc.b $08 ; 
                              dc.b $24 ; 
                              dc.b $09 ; 
                              dc.b $ac ; 
                              dc.b $09 ; 
                              dc.b $40 ; 
                              dc.b $0a ; 
                              dc.b $dc ; 
                              dc.b $0a ; 
                              dc.b $70 ; 
                              dc.b $0b ; 
                              dc.b $28 ; 
                              dc.b $0c ; 
                              dc.b $e8 ; 
                              dc.b $0c ; 
                              dc.b $b0 ; 
                              dc.b $0d ; 
                              dc.b $80 ; 
                              dc.b $0e ; 
                              dc.b $48 ; 
                              dc.b $0f ; 
                              dc.b $48 ; 
                              dc.b $10 ; 
                              dc.b $30 ; 
                              dc.b $11 ; 
                              dc.b $48 ; 
                              dc.b $12 ; 
                              dc.b $58 ; 
                              dc.b $13 ; 
                              dc.b $80 ; 
                              dc.b $14 ; 
                              dc.b $b8 ; 
                              dc.b $15 ; 
                              dc.b $e0 ; 
                              dc.b $16 ; 
                              dc.b $50 ; 
                              dc.b $18 ; 
                              dc.b $d0 ; 
                              dc.b $19 ; 
                              dc.b $60 ; 
                              dc.b $1b ; 
                              dc.b $00 ; 
                              dc.b $1d ; 
                              dc.b $90 ; 
                              dc.b $1e ; 
                              dc.b $90 ; 
                              dc.b $20 ; 
                              dc.b $60 ; 
                              dc.b $22 ; 
                              dc.b $90 ; 
                              dc.b $24 ; 
                              dc.b $b0 ; 
                              dc.b $26 ; 
                              dc.b $00 ; 
                              dc.b $29 ; 
                              dc.b $70 ; 
                              dc.b $2b ; 
                              dc.b $c0 ; 
                              dc.b $2d ; 
; ------------------------------------------------------------------------------------------------------------- ;
T_8379                        dc.b $00 ; Level 01 ; 
                              dc.b $01 ; Level 02 ; 
                              dc.b $00 ; Level 03 ; 
                              dc.b $02 ; Level 04 ; 
                              dc.b $01 ; Level 05 ; 
                              dc.b $01 ; Level 06 ; 
                              dc.b $05 ; Level 07 ; 
                              dc.b $01 ; Level 08 ; 
                              dc.b $00 ; Level 09 ; 
                              dc.b $01 ; Level 10 ; 
                              dc.b $01 ; Level 11 ; 
                              dc.b $01 ; Level 12 ; 
                              dc.b $06 ; Level 13 ; 
                              dc.b $03 ; Level 14 ; 
                              dc.b $01 ; Level 15 ; 
                              dc.b $01 ; Level 16 ; 
                              dc.b $02 ; Level 17 ; 
                              dc.b $01 ; Level 18 ; 
                              dc.b $01 ; Level 19 ; 
                              dc.b $01 ; Level 20 ; 
; ------------------------------------------------------------------------------------------------------------- ;
OptionsSetLightBlue           subroutine                   ; 
                              lda #LT_BLUE                 ; 
                              ldx #$01                     ; 
.LtBlue                       sta COLORAM + B1_WScrOffNoPlr,x ; wait screen no of players $00-$01
                              sta COLORAM + B1_WScrOffNoJoy,x ; wait screen no of joysticks
                              sta COLORAM + B1_WScrOffNoCav,x ; wait screen no of cave
                              sta COLORAM + B1_WScrOffNoLvl,x ; wait screen no of level
                              dex                          ; 
                              bpl .LtBlue                  ; 
                              
OptionsSetLightBlueX          rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
OptionsSetYellow              subroutine                   ; 
                              lda #YELLOW                  ; 
                              ldx #$4f                     ; 
.Yellow                       sta COLORAM,x                ; 
                              dex                          ; 
                              bpl .Yellow                  ; 
                              
OptionsSetYellowX             rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_PlayTitleMusic            subroutine                   ; 
                              lda B1Z_IrqOptsAnimChar      ; 
                              and #B1Z_IrqOptsAnimChar_Yes ; 
                              bne .PlayMusic               ; call every 2nd IRQ
                              
                              rts                          ; 
                              
.PlayMusic                    lda B1_TitleMusicSuRe        ; start music voice 1 sustain/release
                              cmp #$a0                     ; 
                              bne .SetSusRel               ; 
                              
.SetNext                      lda #$10                     ; 
                              sta VCREG1                   ; SID - $D404 = Oscillator 1 Control
                              sta VCREG2                   ; SID - $D40B = Oscillator 2 Control
                              
                              lda #$a8                     ; 
                              sta ATDCY2                   ; SID - $D40C = Oscillator 2 Attack/Decay
                              sta SUREL2                   ; SID - $D40D = Oscillator 2 Sustain/Release
                              
                              ldx B1_TitleMusicTabPtr      ; 
                              
                              inc B1_TitleMusicTabPtr      ; set next pointer
                              inc B1_TitleMusicTabPtr      ; 
                              
                              lda TabPtrFrqCtrl+1,x        ; 
                              asl a                        ; 
                              tay                          ; 
                              lda TabFrqCtrlLo,y           ; 
                              sta FRELO1                   ; SID - $D400 = Oscillator 1 Frequency Control (Low Byte)
                              
                              lda TabFrqCtrlHi,y           ; 
                              sta FREHI1                   ; SID - $D401 = Oscillator 1 Frequency Control (High Byte)
                              
                              lda TabPtrFrqCtrl,x          ; 
                              asl a                        ; 
                              tay                          ; 
                              lda TabFrqCtrlLo,y           ; 
                              sta FRELO2                   ; SID - $D407 = Oscillator 2 Frequency Control (Low Byte)
                              
                              lda TabFrqCtrlHi,y           ; 
                              sta FREHI2                   ; SID - $D408 = Oscillator 2 Frequency Control (High Byte)
                              
                              lda B1_TitleMusicTabPtr      ; 
                              bne .SetSusRel               ; 
                              
                              inc B1_TitleMusicEnd         ; B1_TitleMusicEnd_Yes
                              
.SetSusRel                    lda B1_TitleMusicSuRe        ; start music voice 1 sustain/release
                              eor #$07                     ; .....###
                              adc #$04                     ; .....#..
                              asl a                        ; ....#...
                              asl a                        ; ...#....
                              asl a                        ; ..#.....
                              asl a                        ; .#......
                              sta SUREL1                   ; SID - $D406 = Oscillator 1 Sustain/Release
                              
                              lda #$11                     ; 
                              sta VCREG1                   ; SID - $D404 = Oscillator 1 Control
                              sta VCREG2                   ; SID - $D40B = Oscillator 2 Control
                              
                              lda B1_TitleMusicSuRe        ; start music voice 1 sustain/release
                              clc                          ; 
                              adc #$01                     ; 
                              and #$a7                     ; #.#..###
                              sta B1_TitleMusicSuRe        ; start music voice 1 sustain/release
                              
                              lda B1Z_GamePlay             ; flag $00=game $01=demo
                              beq IRQ_PlayTitleMusicX      ; 
                              
                              lda B1_TitleMusicEnd         ; 
                              cmp #B1_TitleMusicEnd_Yes    ; 
                              bne IRQ_PlayTitleMusicX      ; 
                              
                              lda #B1Z_DemoRun_Yes         ; 
                              sta B1Z_DemoRun              ; 
                              
IRQ_PlayTitleMusicX           rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_OptsAnimChar              subroutine                   ; 
                              ldx #$07                     ; 
.Overlay                      lda B1_CharSet  + [$06 * $08],x ; chr_6
                              ora B1_CharSet  + [$00 * $08],x
                              sta B1_CharSet  + [$09 * $08],x ; chr_9
                              
                              lda B1_CharSet  + [$07 * $08],x ; chr_7
                              ora B1_CharSet  + [$00 * $08],x
                              sta B1_CharSet  + [$0a * $08],x ; chr_a
                              dex                          ; 
                              bpl .Overlay                 ; 
                              
IRQ_OptsAnimCharX             rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_OptsAnimWithMusic         subroutine                   ; 
                              lda B1Z_IrqOptsInit          ; Flag: IRQ StartScreen handling ready
                              bne .IncCounter              ; B1Z_IrqOptsInit_No
                              
                              lda #B1Z_IrqOptsInit_Yes     ; 
                              sta B1Z_IrqOptsInit          ; Flag: IRQ StartScreen handling ready
                              jmp IRQ_OptsAnimWithMusicX   ; 
                              
.IncCounter                   inc B1Z_IrqOptsAnimChar      ; 
                              
                              lda B1Z_IrqOptsAnimChar      ; 
.ChkCounter                   cmp #$04                     ; 
                              bcc .Music                   ; lower - no background handling
                              
.IniCounter                   lda #B1Z_IrqOptsAnimChar_No  ; 
                              sta B1Z_IrqOptsAnimChar      ; 
                              jsr IRQ_OptsAnimCharSteel    ; let start screen background move up
                              jsr IRQ_OptsAnimChar         ; 
                              
.Music                        jsr IRQ_PlayTitleMusic       ; 
                              
IRQ_OptsAnimWithMusicX        rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
OptionsScreenInKeybd          subroutine                   ; 
                              lda B1Z_KeyPressedNew_0      ; scan value for keyboard row 00
                              cmp #$df                     ; 
                              bne .FillReset               ; 
                              
                              lda #B1_TitleMusicEnd_No     ; 
                              sta B1_TitleMusicEnd         ; 
                              
                              inc B1Z_OptCountPressF3      ; 
                              
.Chk_04                       lda B1Z_OptCountPressF3      ; 
                              cmp #$04                     ; 
                              bne .Chk_02                  ; 
                              
.Init                         ldx #$01                     ; 
                              stx B1Z_OptCountPressF3      ; 
                              
                              dex                          ; $00
                              stx B1Z_PlayerNo             ; no of players $00-$01
                              stx B1Z_JoyStickNo           ; no of joysticks
                              beq .Fill                    ; always
                              
.Chk_02                       lda B1Z_OptCountPressF3      ; 
                              cmp #$02                     ; 
                              bne .Chk_03                  ; 
                              
                              inc B1Z_PlayerNo             ; no of players $00-$01
                              
.Chk_03                       lda B1Z_OptCountPressF3      ; 
                              cmp #$03                     ; 
                              bne .Fill                    ; 
                              
                              inc B1Z_JoyStickNo           ; no of joysticks
                              
.Fill                         jsr SetStartPlrJoy           ; 
                              jsr WaitAWhile               ; 
                              
.FillReset                    lda #$00                     ; 
                              sta B1Z_KeyPressedNew_0      ; scan value for keyboard row 00
                              
OptionsScreenInKeybdX         jmp SetStartPlrJoy           ; 
; ------------------------------------------------------------------------------------------------------------- ;
OptionsScreenInJoyst          subroutine                   ; 
                              jsr GetMovesPort_B           ; 
                              
                              cmp #$0f                     ; .... ####
                              beq .WaitAndXit              ; no moves
                              
                              ldx #B1_TitleMusicEnd_No     ;
                              stx B1_TitleMusicEnd         ; 
                              
.ChkDown                      cmp #$0d                     ; .... ##.#
                              bne .ChkUp                   ; 
                              
.ChkLevelMin                  ldx B1Z_GameDifficulty       ; actual player difficult level
                              beq .ChkUp                   ; 
                              
.DecLevel                     dec B1Z_GameDifficulty       ; actual player difficult level
                              
.ChkUp                        cmp #$0e                     ; .... ###.
                              bne .GetJoyLeft              ; 
                              
.ChkLevelMax                  lda #B1Z_GameDifficulty_Max  ; 
                              cmp B1Z_GameDifficulty       ; actual player difficult level
                              beq .ChkLevel4               ; 
                              
.IncLevel                     inc B1Z_GameDifficulty       ; actual player difficult level
                              
.ChkLevel4                    lda B1Z_GameDifficulty       ; actual player difficult level
                              cmp #$03                     ; 
                              bne .GetJoyLeft              ; 
                              
.ResetCave                    lda #$01                     ; no cave selection for level 4 and level 5
                              sta B1Z_GameCaveNo           ; actual player cave number
                              
.GetJoyLeft                   jsr GetMovesPort_B           ; 
                              
.ChkLeft                      cmp #$0b                     ; .... #.##
                              bne .GetJoyRight             ; 
                              
.ChkCaveNoMin                 lda B1Z_GameCaveNo           ; actual player cave number
                              cmp #$05                     ; 
                              bcc .GetJoyRight             ; 
                              
.DecCaveNo                    sbc #$04                     ; 
                              sta B1Z_GameCaveNo           ; actual player cave number
                              
.GetJoyRight                  jsr GetMovesPort_B           ; 
                              
.ChkRight                     cmp #$07                     ; .... .###
                              bne .ChkDisplay              ; 
                              
                              lda B1Z_GameDifficulty       ; actual player difficult level
                              cmp #$03                     ; 
                              bcs .ChkDisplay              ; 
                              
.ChkCaveNoMax                 lda B1Z_GameCaveNo           ; actual player cave number
                              cmp #$0d                     ; 
                              bcs .ChkDisplay              ; greater/equal
                              
.IncCaveNo                    adc #$04                     ; 
                              sta B1Z_GameCaveNo           ; actual player cave number
                              
.ChkDisplay                   lda B1Z_CopyRight            ; flag $00=show start screen values / $01=show start screen copyrights
                              bne .WaitAndXit              ; 
                              
                              lda B1Z_GameDifficulty       ; actual player difficult level
                              clc                          ; 
                              adc #$11                     ; make chr 1-9
                              sta B1_WaitScreenTxt + B1_WScrOffNoLvl
                              
                              adc #$34                     ; second half
                              sta B1_WaitScreenTxt + B1_WScrOffNoLvl+1
                              
                              lda B1Z_GameCaveNo           ; actual player cave number
                              clc                          ; 
                              adc #$20                     ; make chr A-Z
                              sta B1_WaitScreenTxt + B1_WScrOffNoCav
                              
                              adc #$34                     ; second half
                              sta B1_WaitScreenTxt + B1_WScrOffNoCav+1
                              
.WaitAndXit                   jsr Wait                     ; 
                              
OptionsScreenInJoystX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
OptionsGetInput               subroutine                   ; 
                              jsr OptionsScreenInKeybd     ; fill start screen with player/joystick numbers
                              jsr OptionsScreenInJoyst     ; 
                              
                              lda B1Z_CopyRight            ; flag $00=show start screen values / $01=show start screen copyrights
                              beq .GoSetLtBlue             ; 
                              
                              lda #YELLOW                  ; "micro fun ..." rows for the first time only
                              ldx #[B1_ColMax - $01]       ; 
.SetYellow                    sta COLORAM + B1_ScrnRow_23,x ; 
                              sta COLORAM + B1_ScrnRow_00,x ; 
                              dex                          ; 
                              bpl .SetYellow               ; 
                              
.ChkKey_F1                    lda B1Z_KeyPressedNew_0      ; scan value for keyboard row 00
                              cmp #$ef                     ; ###.#### - F1
                              bne .ChkCopyRight            ; 
                              
                              lda #B1Z_StatusStartRow_CC   ; 
                              sta B1Z_StatusStartRow       ; flag $00=start screen with setting rows / $01=start screen with copyright rows
                              jsr CopyStartScreen          ; 
                              
;                              lda #BROWN                   ; color
                              lda #[WHITE | %00001000 ]    ; multi color
                              ldy #$50                     ; startpos
                              jsr InitColorRam             ; 
                              
.GoSetLtBlue                  jsr OptionsSetLightBlue      ; 
                              jsr OptionsSetYellow         ; 
                              
                              lda #WHITE                   ; 
                              ldx #$0d                     ; 
.SetWhite                     sta COLORAM + [B1_ScrnRow_23 + $00],x ; 
                              sta COLORAM + [B1_ScrnRow_23 + $12],x ; 
                              dex                          ; 
                              bpl .SetWhite                ; 
                              
                              lda B1Z_GameDifficulty       ; actual player difficult level
                              clc                          ; 
                              adc #$11                     ; 
                              sta $0bba                    ; 
                              adc #$34                     ; 
                              sta $0bbb                    ; 
                              
                              lda B1Z_GameCaveNo           ; actual player cave number
                              clc                          ; 
                              adc #$20                     ; to chr
                              sta $0ba6                    ; 
                              adc #$34                     ; 
                              sta $0ba7                    ; 
                              
                              lda B1Z_PlayerNo             ; no of players $00-$01
                              cmp #$ff                     ; 
                              bne .GetPlayerNo             ; 
                              
                              inc B1Z_PlayerNo             ; no of players $00-$01
                              
.GetPlayerNo                  lda B1Z_PlayerNo             ; no of players $00-$01
                              clc                          ; 
                              adc #$11                     ; 
                              sta B1_CtrlRow_22            ; 
                              
                              lda #B1Z_CopyRight_Off       ; 
                              sta B1Z_CopyRight            ; flag $00=show start screen values / $01=show start screen copyrights
                              
.ChkCopyRight                 lda B1Z_CopyRight            ; flag $00=show start screen values / $01=show start screen copyrights
                              bne .ChkDemo                 ; 
                              
                              jsr GetFirePort_B            ; 
                              bne .ChkDemo                 ; 
                              
                              sta B1Z_GamePlay             ; flag $00=game $01=demo
                              
                              lda #B1Z_DemoRun_Yes         ; 
                              sta B1Z_DemoRun              ; 
                              
.ChkDemo                      lda B1Z_DemoRun              ; 
                              bne OptionsGetInputX         ; B1Z_DemoRun_Yes
                              
                              jmp OptionsGetInput          ; 
                              
OptionsGetInputX              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
InitVicGameStatus             subroutine                   ; 
                              ldx #$00                     ; 
.CopyChr_0b                   lda $2058,x                  ; reset chr_0b
                              sta $2000,x                  ; 
                              inx                          ; 
                              cpx #$08                     ; 
                              bne .CopyChr_0b              ; 
                              
                              lda #B1Z_CaveNoMin           ; 
                              sta B1Z_GameCaveNo           ; actual player cave number
                              sta B1Z_GamePlay             ; flag $00=game $01=demo
                              jsr OptionsGetInput          ; 
                              
                              lda #$01                     ; 
                              sta B1Z_SfxRNDPlay           ; B1Z_SfxRNDPlay_Yes
                              sta B1Z_ScrollType           ; B1Z_ScrollType_Hard
                              
                              sei                          ; 
                              
                              ldx #$07                     ; 
.SetVicGame                   lda TabFlipFlopGame,x        ; 
                              sta B1Z_VicSCROLY,x          ; raster value  flip flop 1st for SCROLY
                              dex                          ; 
                              bpl .SetVicGame              ; 
                              
                              cli                          ; 
                              
                              lda #$00                     ; game
                              sta B1Z_GameShowOpts         ; flag $00=game screen $01=start screen
                              sta B1Z_IrqOptsAnimChar      ; B1Z_IrqOptsAnimChar_No
                              sta B1Z_KeyPressedNew_0      ; scan value for keyboard row 00
                              sta B1Z_KeyPressedNew_7      ; scan value for keyboard row 07
                              jsr InitVoc_1_2_3            ; 
                              
                              lda B1Z_GamePlay             ; flag $00=game $01=demo
                              beq .FillStatusSav           ; 
                              
                              ldx #B1Z_GameDifficulty_Min  ; 
                              stx B1Z_GameDifficulty       ; actual player difficult level
                              
                              inx                          ; CaveNoMin
                              stx B1Z_GameCaveNo           ; actual player cave number
                              
.FillStatusSav                lda #$13                     ; "3"
                              sta B1_SavRowPlrMen          ; 
                              sta B1Z_RoFoWaitBirth        ; 
                              
                              lda B1Z_GameCaveNo           ; actual player cave number
                              clc                          ; 
                              adc #$20                     ; to chr A-Z
                              sta B1_SavRowPlrCave         ; 
                              
                              lda B1Z_GameDifficulty       ; actual player difficult level
                              clc                          ; 
                              adc #$11                     ; to chr 1-9
                              sta B1_SavRowPlrLvl          ; 
                              
                              lda #B1Z_SfxPlay_No          ; 
                              sta B1Z_SfxPlay              ; 
                              
                              lda #<B1_SavRowPlayer        ; 
                              sta B1Z_StatusRow_Lo         ; 
                              lda #>B1_SavRowPlayer        ; 
                              sta B1Z_StatusRow_Hi         ; 
                              jsr StatusRowFill            ; 
                              
                              lda #B1Z_CaveCompleted_Yes   ; 
                              sta B1Z_CaveCompleted        ; flag cave completed
                              
InitVicGameStatusX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabColors                     dc.b BLACK                   ; $D020 - Border Color
                              dc.b BLACK                   ; $D021 - Background Color 0
                              dc.b BLUE                    ; $D022 - Background Color 1
                              dc.b LT_BLUE                 ; $D023 - Background Color 2
                              dc.b [WHITE | %00001000 ]    ; $D024 - Background Color 3 - multi color
;                              dc.b BROWN                   ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabFlipFlopWait               dc.b $1b ; ...##.## - $54 = raster value flip flop 1st for $D011 - 25 rows/screen enable/text mode
                              dc.b $1b ; ...##.## - $55 = raster value flip flop 2nd for $D011 -
                              dc.b $18 ; ...##... - $56 = raster value flip flop 1st for $D016 - 40 cols/multi color mode
                              dc.b $18 ; ...##... - $57 = raster value flip flop 2nd for $D016 -
                              dc.b $38 ; ..###... - $58 = raster value flip flop 1st for $D018 - chr set $2000-$27ff/screen $0c00-$0fe7
                              dc.b $28 ; ..#.#... - $59 = raster value flip flop 2nd for $D018 - chr set $2000-$27ff/screen $0800-$0be7
                              dc.b $28 ; ..#.#... - $5a = raster value flip flop 1st for $D012 -
                              dc.b $c2 ; ##....#. - $5b = raster value flip flop 2nd for $D012 -
; ------------------------------------------------------------------------------------------------------------- ;
TabFlipFlopGame               dc.b $10 ; ...#.... - $54 = raster value flip flop 1st for $D011 - 24 rows/screen enable/text mode
                              dc.b $1b ; ...##.## - $55 = raster value flip flop 2nd for $D011 - 25 rows/screen enable/text mode
                              dc.b $10 ; ...#.... - $56 = raster value flip flop 1st for $D016 - 38 cols/multi color mode
                              dc.b $18 ; ...##... - $57 = raster value flip flop 2nd for $D016 - 40 cols/multi color mode
                              dc.b $3c ; ..####.. - $58 = raster value flip flop 1st for $D018 - chr set $3000-$37ff/screen $0c00-$0fe7
                              dc.b $38 ; ..###... - $59 = raster value flip flop 2nd for $D018 - chr set $2000-$27ff/screen $0c00-$0fe7
                              dc.b $28 ; ..#.#... - $5a = raster value flip flop 1st for $D012 -
                              dc.b $3b ; ..###.## - $5b = raster value flip flop 2nd for $D012 -
; ------------------------------------------------------------------------------------------------------------- ;
StartScreenShow               subroutine                   ; 
                              lda #B1Z_DemoRun_No          ; 
                              sta B1Z_DemoRun              ; 
                              
                              lda #$28                     ; chr set $2000-$27ff/screen $0800-$0be7
                              sta VMCSB                    ; VIC 2 - $D018 = Chip Memory Control
                              
                              ldx #$04                     ; 
.SetColors                    lda TabColors,x              ; 
                              sta EXTCOL,x                 ; VIC 2 - $D020 = Border Color/Background Colors 0-3
                              dex                          ; 
                              bpl .SetColors               ; 
                              
;                              lda #BROWN                   ; color
                              lda #[WHITE | %00001000 ]    ; multi color
                              ldy #$00                     ; startpos
                              jsr InitColorRam             ; 
                              
                              inc B1Z_ColorRam_Lo          ; Pointer Color RAM low
                              dec B1Z_ColorRam_Hi          ; Pointer Color RAM high
                              
                              lda #WHITE                   ; 
.SetWhite                     sta ($46),y                  ; 
                              iny                          ; 
                              bne .SetWhite                ; 
                              
.GoSetYellow                  jsr OptionsSetYellow          ; 
                              
                              lda B1Z_CopyRight            ; flag $00=show start screen values / $01=show start screen copyrights
                              bne .StartScreen             ; 
                              
.GoSetLtBlue                  jsr OptionsSetLightBlue      ; 
                              
.StartScreen                  jsr CopyStartScreen          ; 
                              
                              lda #B1Z_IrqOptsInit_No      ; 
                              sta B1Z_IrqOptsInit          ; Flag: IRQ StartScreen handling ready
                              
                              lda #B1Z_GameShowOpts_Yes    ; start
                              sta B1Z_GameShowOpts         ; flag $00=game screen $01=start screen
                              
.Wait                         lda B1Z_IrqOptsInit          ; Flag: IRQ StartScreen handling ready
                              beq .Wait                    ; B1Z_IrqOptsInit_Yes
                              
                              lda #$00                     ; 
                              sta B1_TitleMusicTabPtr      ; 
                              sta B1_TitleMusicEnd         ; B1_TitleMusicEnd_No
                              sta B1_SfxRandomCtrl         ; 
                              sta B1_Unused_01             ; 
                              sta B1_SfxWaveForm           ; 
                              sta B1_IRQSfxWait            ; 
                              sta B1_IRQSfx                ; 
                              sta B1_IRQSfxTime            ; 
                              
StartScreenShowX              rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_Start                     subroutine                   ; 
                              lda VICIRQ                   ; VIC 2 - $D019 = Interrupt Flag
                              sta VICIRQ                   ; VIC 2 - $D019 = Interrupt Flag - 1=Clear latched flag
                              
.ChkRasterIRQ                 and #$01                     ; 
                              beq .GetKey01                ; was no raster IRQ
                              
.SetVicCtrlPtr                dec B1Z_OptsFlipFlopSel      ; raster values flip flop pointer
                              bpl .GetVicCtrlPtr           ; 
                              
.IniVicCtrlPtr                lda #B1Z_OptsFlipFlopSel_Txt ; reset raster value pointer
                              sta B1Z_OptsFlipFlopSel      ; raster values flip flop pointer
                              
.GetVicCtrlPtr                ldx B1Z_OptsFlipFlopSel      ; raster values flip flop pointer
.SetVicCtrls                  lda B1Z_VicSCROLY,x          ; raster value  flip flop 1st for SCROLY
                              sta SCROLY                   ; VIC 2 - $D011 = VIC Control Register 1
                              
                              lda B1Z_VicSCROLX,x          ; raster value  flip flop 1st for SCROLX
                              sta SCROLX                   ; VIC 2 - $D016 = Control Register 2 (and Horizontal Fine Scrolling)
                              
                              lda B1Z_VicVMCSB,x           ; raster value  flip flop 1st for VMCSB - Chip Memory Control
                              sta VMCSB                    ; VIC 2 - $D018 = Chip Memory Control
                              
                              lda B1Z_VicRASTER,x          ; raster value  flip flop 1st for RASTER
                              sta RASTER                   ; VIC 2 - $D012 = Read: Raster Scan Line/ Write: Line for Raster IRQ
                              
.GetKey01                     jsr IRQ_ChkjoyStickInput     ; 
                              
.ChkKeyRow00                  lda #B1Z_KeyPressedOld_7     ; #######. - SPACE
                              sta CIAPRA                   ; CIA 1 - $DC00 = Data Port A - keyboard row select
                              
                              lda CIAPRB                   ; CIA 1 - $DC01 = Data Port B - keyboard col result
                              cmp #$ff                     ; 
                              beq .ChkKeyRow07             ; nothing pressed
                              
                              cmp B1Z_KeyPressedOld_0      ; scan value for keyboard row 00 - 2nd
                              bne .SetKey01                ; 
                              
                              sta B1Z_KeyPressedNew_0      ; scan value for keyboard row 00
                              beq .ChkKeyRow07             ; always
                              
.SetKey01                     sta B1Z_KeyPressedOld_0      ; scan value for keyboard row 00 - 2nd
                              
.ChkKeyRow07                  lda #$7f                     ; .####### - F1
                              sta CIAPRA                   ; CIA 1 - $DC00 = Data Port A - keyboard row select
                              
                              lda CIAPRB                   ; CIA 1 - $DC01 = Data Port B - keyboard col result
                              cmp #$ff                     ; none pressed
                              beq .GetKey12                ; 
                              
                              cmp B1Z_KeyPressedOld_7      ; scan value for keyboard row 07 - 2nd
                              bne .SetKey11                ; 
                              
                              sta B1Z_KeyPressedNew_7      ; scan value for keyboard row 07
                              beq .GetKey12                ; 
                              
.SetKey11                     sta B1Z_KeyPressedOld_7      ; scan value for keyboard row 07 - 2nd
                              
.GetKey12                     jsr IRQ_ChkjoyStickInput     ; 
                              
IRQ_ChkjoyStickReturn         lda B1Z_GameShowOpts         ; flag $00=game screen $01=start screen
                              cmp #B1Z_GameShowOpts_Yes    ; start
                              bne .ChkMode                 ; 
                              
                              lda B1Z_CopyRight            ; flag $00=show start screen values / $01=show start screen copyrights
                              bne .SpritesOff              ; 
                              
                              lda #$28                     ; chr set $2000-$27ff/screen $0800-$0be7
                              sta B1Z_VicVMCSB             ; raster value  flip flop 1st for VMCSB - Chip Memory Control
                              
.SpritesOff                   lda #$00                     ; 
                              sta SPENA                    ; VIC 2 - $D015 = Sprite Enable
                              
                              lda #$18                     ; 40 cols/multi color mode
                              sta B1Z_VicSCROLX            ; raster value  flip flop 1st for SCROLX
                              
                              lda #$1b                     ; 25 rows/screen enable/text mode
                              sta B1Z_VicSCROLY            ; raster value  flip flop 1st for SCROLY
                              
                              jsr IRQ_OptsAnimWithMusic    ; 
                              
.ChkMode                      lda B1Z_GameShowOpts         ; flag $00=game screen $01=start screen
                              bne .SpritesPrio             ; B1Z_GameShowOpts_Yes
                              
.SpritesOn                    lda #$7f                     ; 
                              sta SPENA                    ; VIC 2 - $D015 = Sprite Enable
                              jsr IRQ_StartGame            ; 
                              
.SpritesPrio                  lda #$00                     ; all sprites in front of background
                              sta SPBGPR                   ; VIC 2 - $D01B = Sprite to Foreground Priority
                              
                              pla                          ; 
                              tay                          ; 
                              pla                          ; 
                              tax                          ; 
                              pla                          ; 
                              
IRQMain_X                     rti                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_ChkjoyStickInput          subroutine                   ; 
                              lda #$ff                     ; ######## - all cols off
                              sta CIAPRA                   ; CIA 1 - $DC00 = Data Port A - keyboard row select
                              
                              lda CIAPRB                   ; CIA 1 - $DC01 = Data Port B - Joystick 1
                              and #$1f                     ; ...#####
                              cmp #$1f                     ;
                              beq IRQ_ChkjoyStickInputX    ; nothing pressed
                              
.ClrPressedKeys               lda #$ff                     ; 
                              sta B1Z_KeyPressedNew_0      ; scan value for keyboard row 00
                              sta B1Z_KeyPressedNew_7      ; scan value for keyboard row 07
                              sta B1Z_KeyPressedOld_0      ; scan value for keyboard row 00 - 2nd
                              sta B1Z_KeyPressedOld_7      ; scan value for keyboard row 07 - 2nd
                              
                              pla                          ; discard return address
                              pla                          ; 
                              jmp IRQ_ChkjoyStickReturn    ; 
                              
IRQ_ChkjoyStickInputX         rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameCaveSetup                 subroutine                   ; 
                              jsr GameCaveGetDataFix       ; 
                              jsr GameCaveGetDataRND       ; 
                              jsr CaveFrame                ; 
                              jsr GameCaveGetDataVar       ; 
                              jsr GameCaveInit             ; 
                              
                              lda #$00                     ; 
                              sta B1Z_ScrollSoftDirUpDo_Lo ; 
                              sta B1Z_ScrollSoftDirUpDo_Hi ; 
                              sta B1Z_ScrollSoftDirLeRi_Lo ; 
                              sta B1Z_ScrollSoftDirLeRi_Hi ; 
                              
                              jsr GameCaveDataToScreen     ; 
                              
                              lda #B1Z_SfxRNDPlay_No       ; 
                              sta B1Z_SfxRNDPlay           ; 
                              jsr InitVoc_1_2_3            ; 
                              
GameCaveSetupX                rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
InitPlayers                   subroutine                   ; 
                              lda #$00                     ; 
                              sta B1Z_GamePlayerNo         ; actual player no $00-$01
                              sta B1Z_GameOver             ; actual player still has lives $00=yes $01=no
                              
                              ldx #B1_LenScores            ; 
.Score1                       sta B1Z_GameScore,x          ; actual player score
                              sta B1Z_ActualScore,x        ; game scores
                              dex                          ; 
                              bpl .Score1                  ; 
                              
                              lda #B1Z_GameNumLives_Ini    ; 
                              sta B1Z_GameNumLives         ; actual player no of lives
                              
                              ldx #B1_LenStatus            ; 
.Score2                       lda B1Z_GameNumLives,x       ; actual player no of lives
                              
                              sta B1Z_SavP1Area,x          ; 
                              sta B1Z_SavP2Area,x          ; 
                              dex                          ; 
                              bpl .Score2                  ; 
                              
                              ldx #B1_LenScores            ; 
.Score3                       lda B1Z_SavP1ScoreHigh,x     ; saved high score player 1
                              sta B1Z_GameScoreHigh,x      ; high score
                              dex                          ; 
                              bpl .Score3                  ; 
                              
InitPlayersX                  rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameSetNextPlayer             subroutine                   ; 
                              dec B1Z_GameNumLives         ; actual player no of lives
                              
                              lda B1Z_GamePlayerNo         ; actual player no $00-$01
                              bne .SaveDataP2I             ; 
                              
                              ldx #B1_LenPlayerData        ; 
.SaveDataP1                   lda B1Z_GameNumLives,x       ; actual player no of lives
                              sta B1Z_SavP1Area,x          ; 
                              dex                          ; 
                              bpl .SaveDataP1              ; 
                              bmi .ChkNoOfPlayers          ; 
                              
.SaveDataP2I                  ldx #B1_LenPlayerData        ; 
.SaveDataP2                   lda B1Z_GameNumLives,x       ; actual player no of lives
                              sta B1Z_SavP2Area,x          ; 
                              dex                          ; 
                              bpl .SaveDataP2              ; 
                              
.ChkNoOfPlayers               lda B1Z_PlayerNo             ; no of players $00-$01
                              beq .GetActualPlayer         ; 
                              
                              lda B1Z_GamePlayerNo         ; actual player no $00-$01
                              bne .ChkSavScoreP1           ; 
                              
                              lda B1Z_SavP2NumLives        ; 
                              beq .GetActualPlayer         ; 
                              
.SetPlayer2                   inc B1Z_GamePlayerNo         ; actual player no $00-$01
                              jmp .GetActualPlayer         ; 
                              
.ChkSavScoreP1                lda B1Z_SavP1NumLives        ; 
                              beq .GetActualPlayer         ; 
                              
.SetPlayer1                   dec B1Z_GamePlayerNo         ; actual player no $00-$01
                              
.GetActualPlayer              lda B1Z_GamePlayerNo         ; actual player no $00-$01
                              bne .RestoreDataP2I          ; 
                              
                              ldx #B1_LenPlayerData        ; 
.RestoreDataP1                lda B1Z_SavP1Area,x          ; 
                              sta B1Z_GameNumLives,x       ; actual player no of lives
                              dex                          ; 
                              bpl .RestoreDataP1           ; 
                              bmi .ChkLives                ; 
                              
.RestoreDataP2I               ldx #B1_LenPlayerData        ; 
.RestoreDataP2                lda B1Z_SavP2Area,x          ; 
                              sta B1Z_GameNumLives,x       ; actual player no of lives
                              dex                          ; 
                              bpl .RestoreDataP2           ; 
                              
.ChkLives                     lda B1Z_GameNumLives         ; actual player no of lives
                              bne GameSetNextPlayerX       ; 
                              
                              lda #B1Z_GameOver_No         ; 
                              sta B1Z_GameOver             ; actual player still has lives $00=yes $01=no
                              
                              lda #B1Z_GameNumLives_Ini    ; 
                              sta B1Z_GameNumLives         ; actual player no of lives
                              
                              lda #$00                     ; 
                              sta B1Z_GamePlayerNo         ; actual player no $00-$01
                              
GameSetNextPlayerX            rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameTimeToScoreTune           subroutine                   ; 
                              dec B1Z_TimeToScoreTuneVar   ; 
                              
                              ldx #B1Z_TimeToScoreTuneFix_Ini ; no of rounds
.Rounds                       lda #$10                     ; 
                              sta VCREG3                   ; SID - $D412 = Oscillator 3 Control
                              
                              stx B1Z_TimeToScoreTuneFix   ; 
                              asl B1Z_TimeToScoreTuneFix   ; 
                              lda B1Z_TimeToScoreTuneVar   ; 
                              sec                          ; 
                              sbc B1Z_TimeToScoreTuneFix   ; 
                              sta FREHI3                   ; SID - $D40F = Oscillator 3 Frequency Control (High Byte)
                              
                              lda #$a0                     ; 
                              sta SUREL3                   ; SID - $D414 = Oscillator 3 Sustain/Release
                              
                              lda #$00                     ; 
                              sta ATDCY3                   ; SID - $D413 = Oscillator 3 Attack/Decay
                              
                              lda #$11                     ; 
                              sta VCREG3                   ; SID - $D412 = Oscillator 3 Control
                              
                              ldy #$c0                     ; 
.Hold                         dey                          ; 
                              bne .Hold                    ; 
                              
                              dex                          ; 
                              bne .Rounds                  ; 
                              
                              lda #$10                     ; 
                              sta VCREG3                   ; SID - $D412 = Oscillator 3 Control
                              
GameTimeToScoreTuneX          rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameCheckNewScoreHi           subroutine                   ; 
                              lda #B1Z_NewGameScoreHi_Yes  ; 
                              tax                          ; 
                              sta B1Z_NewGameScoreHi       ; flag new high score
                              
.GetHiScore                   lda B1Z_GameScoreHigh,x      ; actual players high score
                              cmp B1_SavRowStScore,x       ; 
                              beq .SetNext                 ; 
                              
                              ldx #B1_LenScores            ; not equal - always finish compare loop
                              
                              bcs .SetNext                 ; ac higher
                              
                              lda #B1Z_NewGameScoreHi_No   ; ac lower
                              sta B1Z_NewGameScoreHi       ; flag new high score
                              
.SetNext                      inx                          ; 
                              cpx #B1_LenScores+1          ; 
                              bne .GetHiScore              ; 
                              
                              lda B1Z_NewGameScoreHi       ; flag new high score
                              beq GameCheckNewScoreHiX     ; 
                              
                              ldx #B1_LenScores            ; 
.SetOldHiScore                lda B1_SavRowStScore,x       ; 
                              sta B1Z_GameScoreHigh,x      ; high score
                              dex                          ; 
                              bpl .SetOldHiScore           ; 
                              
GameCheckNewScoreHiX          rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
OptionsFillInScores           subroutine                   ; 
                              ldx #B1_LenScores            ; 
.Fill                         lda B1Z_SavP1ScoreHigh,x     ; saved high score player 1
                              sta B1_SavRowScrHiP1,x       ; 
                              
                              lda B1Z_SavP2ScoreHigh,x     ; saved high score player 2
                              sta B1_SavRowScrHiP2,x       ; 
                              
                              lda B1Z_SavP1Score,x         ; saved last score player 1
                              clc                          ; 
                              adc #$10                     ; make chr 1-9
                              sta B1_SavRowScrLaP1,x       ; 
                              
                              lda B1Z_SavP2Score,x         ; saved last score player 2
                              adc #$10                     ; make chr 1-9
                              sta B1_SavRowScrLaP2,x       ; 
                              
                              dex                          ; 
                              bpl .Fill                    ; 
                              
OptionsFillInScoresX          rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameNextCaveHandler           subroutine                   ; 
                              lda B1Z_GameCaveNo           ; actual player cave number
                              asl a                        ; 
                              tax                          ; 
                              lda TabNextLevelNo,x         ; 
                              cmp #B1Z_CaveNoMax           ; 
                              bne .SetPlayLvlNo            ; 
                              
.MaxReached                   lda B1Z_GameDifficulty       ; actual player difficult level
                              cmp #B1Z_GameDifficulty_Max  ; 
                              beq .Get1stCave              ; 
                              
.IncExpertLvl                 inc B1Z_GameDifficulty       ; actual player difficult level
                              
.Get1stCave                   lda #B1Z_CaveNoMin           ; 
                              
.SetPlayLvlNo                 sta B1Z_GameCaveNo           ; actual player cave number
                              
GameNextCaveHandlerX          rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameTimeScore                 subroutine                   ; 
                              ldx #$00                     ; 
                              lda #$00                     ; 
.Scores                       sta B1Z_ActualScore,x        ; game scores
                              inx                          ; 
                              cpx #B1_LenScores+1          ; 
                              bne .Scores                  ; 
                              
                              lda B1Z_GameDifficulty       ; actual player difficult level
                              clc                          ; 
                              adc #$01                     ; 
                              sta B1Z_ActualScore_000001   ; game scores 1s
                              
                              lda #B1Z_CaveCompleted_No    ; 
                              sta B1Z_CaveCompleted        ; flag cave completed
                              sta B1Z_TimeToScoreTuneFix   ; 
                              
                              lda #B1Z_TimeToScoreTuneVar_Ini ; 
                              sta B1Z_TimeToScoreTuneVar   ; 
                              
                              jsr CaveChkTimeCountDown     ; 
                              jsr InitVoc_1_2_3            ; 
                              
.ChkReady                     lda B1Z_CaveCompleted        ; flag cave completed
                              bne .Ready                   ; B1Z_CaveCompleted_Yes
                              
                              jsr CaveTimeDec              ; 
                              jsr GameAddScore             ; 
                              jsr GameTimeToScoreTune      ; 
                              bne .ChkReady                ; 
                              
.Ready                        jsr CaveTuneCountDown        ; 
                              jsr WaitAWhile               ; 
                              jsr InitVoc_1_2_3            ; 
                              jsr GameNextCaveHandler      ; 
                              
GameTimeScoreX                rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameSwitchPlayer              subroutine                   ; 
                              jsr GameCheckNewScoreHi      ; 
                              jsr GameSetNextPlayer        ; 
                              
                              lda B1Z_GameOver             ; actual player still has lives $00=yes $01=no
                              beq GameSwitchPlayerX        ; B1Z_GameOver_Yes
                              
                              lda #$00                     ; 
                              sta B1Z_GameCaveNo           ; actual player cave number
                              sta B1Z_GameDifficulty       ; actual player difficult level
                              jsr OptionsFillInScores      ; 
                              
GameSwitchPlayerX             rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameCaveFinish                subroutine                   ; 
                              ldx #B1Z_GamePaused_Yes      ; 
                              stx B1Z_GamePaused           ; flag pause mode $00=no >$00=yes
                              
                              lda B1Z_TimeToScore          ; 
                              beq .ChkCaveType             ; B1Z_TimeToScore_No
                              
                              jsr GameTimeScore            ; 
                              jmp .ChkGame                 ; 
                              
.ChkCaveType                  lda B1Z_CaveType             ; level type $00=normal $01=extra
                              beq .GoSwitchPlayer          ; 
                              
                              jsr GameNextCaveHandler      ; 
                              jmp .ChkGame                 ; 
                              
.GoSwitchPlayer               jsr GameSwitchPlayer         ; 
                              
.ChkGame                      lda B1Z_GamePlay             ; flag $00=game $01=demo
                              bne .SetReady                ; 
                              
                              lda B1Z_GamePlayerNo         ; actual player no $00-$01
                              clc                          ; 
                              adc #$11                     ; make chr 1-2
                              sta B1_SavRowPlrNo           ; 
                              
                              lda B1Z_GameNumLives         ; actual player no of lives
                              clc                          ; 
                              adc #$10                     ; make chr 0-9
                              sta B1_SavRowPlrMen          ; 
                              
                              tax                          ; 
                              lda #$25                     ; chr "E" left part - mEn
                              cpx #$11                     ; chr "1"
                              bne .SetStatusInfoManOrMen   ; more than one
                              
                              lda #$21                     ; chr "A" left part - mAn
                              
.SetStatusInfoManOrMen        sta B1_SavRowPlrType         ; 
                              
                              lda B1Z_GameCaveNo           ; actual player cave number
                              clc                          ; 
                              adc #$20                     ; 
                              sta B1_SavRowPlrCave         ; 
                              
                              lda B1Z_GameDifficulty       ; actual player difficult level
                              clc                          ; 
                              adc #$11                     ; make chr 1-5
                              sta B1_SavRowPlrLvl          ; 
                              
.SetReady                     lda #B1Z_SfxPlay_No          ; 
                              sta B1Z_SfxPlay              ; 
                              
GameCaveFinishX               rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameMoveTiles                 subroutine                   ; 
                              jsr MoveTiles                ; 
                              
                              lda B1Z_CaveCompleted        ; flag cave completed
                              beq GameMoveTiles            ; B1Z_CaveCompleted_No
                              
                              jsr InitVoc_1_2_3            ; 
                              jsr GameCaveFinish           ; 
                              
.WaitFlickerTime              lda B1Z_FlickerTimeOneUp     ; bonus life flicker empty time
                              bne .WaitFlickerTime         ; 
                              
                              sta B1_IRQSfx                ; 
                              sta B1_IRQSfxTime            ; 
                              
GameMoveTilesX                rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameDemo                      subroutine                   ; 
                              lda #$00                     ; 
                              sta B1Z_DemoMoveTabPtr       ; pointer demo moves
                              sta B1Z_DemoFinish           ; flag demo mode
                              sta B1Z_DemoMoveTime         ; duration demo move
                              
.ChkMoveTime                  lda B1Z_DemoMoveTime         ; duration demo move
                              bne .ChkJoyFire              ; 
                              
.GetNextMove                  ldx B1Z_DemoMoveTabPtr       ; pointer demo moves
                              lda TabDemoMoves,x           ; 
                              sta B1Z_DemoMoveTime         ; duration demo move
                              
                              and #$0f                     ; isolate right nybble for demo move direction
                              sta B1Z_MovesPort_B          ; direction move
                              bne .SetMoveTime             ; 
                              
.EndOfMoves                   lda #B1Z_DemoFinish_No       ; tab demo moves ended with $00
                              sta B1Z_DemoFinish           ; flag demo mode
                              
.SetMoveTime                  lsr B1Z_DemoMoveTime         ; duration demo move
                              lsr B1Z_DemoMoveTime         ; 
                              lsr B1Z_DemoMoveTime         ; 
                              lsr B1Z_DemoMoveTime         ; isolate left nybble for demo move duration
                              
                              inc B1Z_DemoMoveTabPtr       ; pointer demo moves
                              
.ChkJoyFire                   jsr GetFirePort_B            ; 
                              bne .ChkDemoStop             ; 
                              
                              lda #B1Z_DemoFinish_No       ; 
                              sta B1Z_DemoFinish           ; flag demo mode
                              
.ChkDemoStop                  lda B1Z_DemoFinish           ; flag demo mode
                              bne .DemoInterrupt           ; B1Z_DemoFinish_No
                              
                              jsr MoveTiles                ; 
                              
                              dec B1Z_DemoMoveTime         ; duration demo move
                              jmp .ChkMoveTime             ; 
                              
.DemoInterrupt                jsr InitVoc_1_2_3            ; 
                              
                              lda B1Z_TimeToScore          ; 
                              beq .SetCave                 ; B1Z_TimeToScore_No
                              
                              jsr GameCaveFinish           ; 
                              
.SetCave                      lda #$00                     ; 
                              sta B1Z_GameCaveNo           ; actual player cave number
                              
GameDemoX                     rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IniTxtScores                  subroutine                   ; 
                              ldx #[B1_LenTxtRow - $01]    ; machine length
.Init                         lda TxtScoreLast,x           ; 
                              sta B1_SavRowScrLast,x       ; 
                              
                              lda TxtScoreHigh,x           ; 
                              sta B1_SavRowScrHigh,x       ; 
                              
                              lda #$20                     ; <blank>
.BlankStatus                  sta B1_SavRowStatus,x        ; 
                              dex                          ; 
                              bpl .Init                    ; 
                              
                              lda #$3c                     ; chr diamond
                              sta B1_SavRowStDiChr         ; 
                              
IniTxtScoresX                 rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IniCharsAndSprites            subroutine                   ; 
                              ldx #B1_ColMax               ; 
                              lda #$20                     ; <blank>
.Screen1                      sta B1_PlayScrHdr - $01,x    ; 
                              dex                          ; 
                              bne .Screen1                 ; 
                              
                              lda #$60                     ; dot
.Screen2                      sta B1_PlayScrDat + $0000,x  ; 
                              
                              sta B1_PlayScrHdr + $0100,x  ; 
                              sta B1_PlayScrHdr + $0200,x  ; 
                              sta B1_PlayScrHdr + $0300,x  ; 
                              
                              sta B1_SavScreen  + $0000,x  ; 
                              sta B1_SavScreen  + $0100,x  ; 
                              sta B1_SavScreen  + $0200,x  ; 
                              sta B1_SavScreen  + $0300,x  ; 
                              inx                          ; 
                              bne .Screen2                 ; 
                              
.Screen3                      lda TabCharStore  + $0000,x  ; 
                              sta B1_CharSet    + $0000,x  ; 
                              lda TabCharStore  + $0100,x  ; 
                              sta B1_CharSet    + $0100,x  ; 
                              lda TabCharStore  + $0200,x  ; 
                              sta B1_CharSet    + $0200,x  ; 
                              lda TabCharStore  + $0300,x  ; 
                              sta B1_CharSet    + $0300,x  ; 
                              
                              lda TabGfxStore   + $0000,x  ; 
                              sta B1_GfxSet     + $0000,x  ; 
                              lda TabGfxStore   + $0100,x  ; 
                              sta B1_GfxSet     + $0100,x  ; 
                              lda TabGfxStore   + $0200,x  ; 
                              sta B1_GfxSet     + $0200,x  ; 
                              lda TabGfxStore   + $0300,x  ; 
                              sta B1_GfxSet     + $0300,x  ; 
                              inx                          ; 
                              bne .Screen3                 ; 
                              
                              ldx #$27                     ; 
.Screen4                      lda #$ff                     ; 
                              sta $3770,x                  ; 
                              
                              lda #$00                     ; 
                              sta $3798,x                  ; 
                              dex                          ; 
                              bpl .Screen4                 ; 
                              
                              ldx #$07                     ; 
.Sprites                      lda #$de                     ; 
                              sta $0ff8,x                  ; 
                              sta $2ff8,x                  ; 
                              
                              lda #$00                     ; 
                              sta SP0COL,x                 ; VIC 2 - $D027 = Color Sprites 0-7
                              dex                          ; 
                              bpl .Sprites                 ; 
                              
                              ldy #$0c                     ; 
                              lda #$37                     ; 
.SpritePos                    sta SP0X,y                   ; VIC 2 - $D000 = Sprite 0 X-Pos (Bits 70 - Bit 8 is stored in MSIGX = $D010)
                              
                              tax                          ; 
                              lda #$3a                     ; 
                              sta SP0Y,y                   ; VIC 2 - $D001 = Sprite 0 Y-Pos (Bits 70)
                              txa                          ; 
                              
                              sec                          ; 
                              sbc #$30                     ; 
                              dey                          ; 
                              dey                          ; 
                              bpl .SpritePos               ; 
                              
                              lda #$ff                     ; 
                              sta XXPAND                   ; VIC 2 - $D01D = Sprite X Expansion
                              
                              lda #$60                     ; 
                              sta MSIGX                    ; VIC 2 - $D010 = MSBs Sprites 0-7 PosX
                              
IniCharsAndSpritesX           rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
IniVoc_TabsSprts              subroutine                   ; 
                              jsr InitVoc_1_2_3            ; 
                              
                              ldx #$ff                     ; 
                              stx B1Z_GameCaveNoLast       ; last cave number
                              stx B1Z_GameShowOpts         ; flag $00=game screen $01=start screen
                              stx B1Z_KeyPressedNew_0      ; scan value for keyboard row 00
                              stx B1Z_KeyPressedNew_7      ; scan value for keyboard row 07
                              stx B1Z_KeyPressedOld_0      ; scan value for keyboard row 00 - 2nd
                              stx B1Z_KeyPressedOld_7      ; scan value for keyboard row 07 - 2nd
                              
                              inx                          ; $00
                              stx B1Z_ScrollSoftOffTabX    ; 
                              stx B1Z_RoFoScrollPosX       ; 
                              stx B1Z_ScrollSoftOffTabY    ; 
                              stx B1Z_RoFoScrollPosY       ; 
                              stx B1Z_GameFlashTime        ; duration finish flash
                              stx B1Z_GameCaveNo           ; actual player cave number
                              stx B1Z_GameDifficulty       ; actual player difficult level
                              stx B1Z_AnimTilePhaseOff     ; 
                              stx B1Z_IrqOptsAnimChar      ; B1Z_IrqOptsAnimChar_No
                              stx B1Z_ScrollSoftValY       ; 
                              stx B1Z_ScrollSoftValY_Sav   ; 
                              stx B1Z_ScrollSoftValX       ; 
                              stx B1Z_ScrollSoftValX_Sav   ; 
                              stx B1Z_SfxPlayBang          ; flag start/finish bang
                              stx B1Z_SfxPlayBangTime      ; 
                              
                              inx                          ; $01
                              stx B1Z_StatusStartRow       ; flag $00=start screen with setting rows / $01=start screen with copyright rows
                              stx B1Z_GamePlay             ; flag $00=game $01=demo
                              stx B1Z_CopyRight            ; flag $00=show start screen values / $01=show start screen copyrights
                              
                              lda B1Z_IniVoTaSpPart2       ; init marker
                              beq IniVoc_TabsSprtsX        ; omit the next part if already init
                              
.InitOnce                     ldx #$04                     ; 
                              lda #BLACK                   ; 
.Colors                       sta EXTCOL,x                 ; VIC 2 - $D020 = Border Color/Background Colors 0-3
                              dex                          ; 
                              bpl .Colors                  ; 
                              
                              ldx #$00                     ; 
                              lda #$10                     ; "0"
.InitScores                   sta B1Z_SavP1ScoreHigh,x     ; saved high score player 1
                              sta B1Z_SavP2ScoreHigh,x     ; saved high score player 2
                              sta B1Z_GameScoreHigh,x      ; high score
                              inx                          ; 
                              cpx #B1_LenScores+1          ; 
                              bne .InitScores              ; 
                              
                              lda #B1Z_IniVoTaSpPart2_Yes  ; set already init
                              sta B1Z_IniVoTaSpPart2       ; init marker
                              
                              sta B1Z_JoyStickNo           ; no of joysticks
                              sta B1Z_PlayerNo             ; no of players $00-$01
                              sta B1Z_FlickerTimeOneUp     ; bonus life flicker empty time
                              jsr IniEmptyTile             ; 
                              
                              lda #$01                     ; 
                              sta B1Z_OptCountPressF3      ; 
                              
                              jsr IniTxtScores             ; 
                              jsr IniCharsAndSprites       ; 
                              
IniVoc_TabsSprtsX             rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
InitVicOptsIRQ                subroutine                   ; 
                              lda #$3c                     ; ..## ##. . - screen=$0c00-$0fe7 / char set=$3000-$37ff
                              sta B1_VicVMCSB              ; 
                              
                              jsr PlayFieldCoverFull       ; 
                              
                              sei                          ; 
                              
                              ldx #$07                     ; 
.SetVIC                       lda TabFlipFlopWait,x        ; 
                              sta B1Z_VicSCROLY,x          ; raster value  flip flop 1st for SCROLY
                              dex                          ; 
                              bpl .SetVIC                  ;
                              
                              ldx #$01                     ; 
                              stx IRQMASK                  ; VIC 2 - $D01A = IRQ Mask
                              
                              inx                          ; $02 - init for value $01
                              stx B1Z_OptsFlipFlopSel      ; raster values flip flop pointer
                              
                              lda #$28                     ; 1st raster
                              sta RASTER                   ; VIC 2 - $D012 = Read: Raster Scan Line / Write: Line for Raster IRQ
                              
                              lda #$18                     ; 40 cols/multi color mode
                              sta SCROLY                   ; VIC 2 - $D011 = VIC Control Register 1
                              
.SetIRQ                       lda #<IRQ_Start              ; 
                              sta CINV_Lo                  ; 
                              lda #>IRQ_Start              ; 
                              sta CINV_Hi                  ; 
                              
                              cli                          ; 
                              
InitVicOptsIRQX               rts                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
NMI                           cli                          ; 
; ------------------------------------------------------------------------------------------------------------- ;
GameStart                     subroutine                   ; 
                              ldx #$ff                     ; init
                              txs                          ; stack pointer
                              
                              lda #$7f                     ; .####### - bit7=0 - clear all
                              sta CIAICR                   ; CIA 1 - $DC0D = Interrupt Control
                              sta CI2ICR                   ; CIA 2 - $DD0D = Interrupt Control
                              
                              lda #$ff                     ; value to be loaded at next start of timer
                              sta TIMALO                   ; CIA 1 - $DC04 = Timer A (Low Byte)
                              sta TIMAHI                   ; CIA 1 - $DC05 = Timer A (High Byte)
                              
                              lda #$a0                     ; value to be loaded at next start of timer
                              sta TI2ALO                   ; CIA 2 - $DD04 = Timer A (Low Byte)
                              sta TI2AHI                   ; CIA 2 - $DD05 = Timer A (High Byte)
                              
                              lda #$68                     ; value to be loaded at next start of timer
                              sta TI2BLO                   ; CIA 2 - $DD06 = Timer B (Low Byte)
                              sta TI2BHI                   ; CIA 2 - $DD07 = Timer B (High Byte)
                              
                              lda #$17                     ; ...#.### -
                              sta CI2CRA                   ; CIA 2 - $DD0E = Control A
                              sta CI2CRB                   ; CIA 2 - $DD0F = Control B
                              
                              sei                          ; 
                              
.SetNMI                       lda #<NMI                    ; 
                              sta NMINV_Lo                 ; 
                              lda #>NMI                    ; 
                              sta NMINV_Hi                 ; 
                              
                              cli                          ; 
                              
.SetMemLayout                 lda #B__off                  ; RAM at $a000-$c000 / IO at $d000-$e000 / Kernal at $e000-ffff
                              sta R6510                    ; 
                              
                              jsr IniVoc_TabsSprts         ; 
                              
                              lda #B1_IRQSfxWaitStop_Ini   ; 
                              sta B1_IRQSfxWaitStop        ; 
                              
.IniCopyCode                  ldy #$00                     ; 
                              ldx #<CopyTo9e00             ; 
                              stx B1Z_CopyFromP1_Lo        ; 
                              stx B1Z_CopyFromP2_Lo        ; 
                              
                              ldx #>CopyTo9e00             ; 
                              stx B1Z_CopyFromP1_Hi        ; 
                              
                              inx                          ; 
                              stx B1Z_CopyFromP2_Hi        ; 
                              
.CopyCode                     lda (B1Z_CopyFromP1),y       ; page 1 - from $7b58
                              sta IRQ_AdrScrollHard + $0000,y;
                              lda (B1Z_CopyFromP2),y       ; page 2 - from $7c58
                              sta IRQ_AdrScrollHard + $0100,y;
                              iny                          ; 
                              bne .CopyCode                ; 
                              
                              lda #<[B1_PlayField + $03]   ; TabScrnDataRowOff $4003 lo
                              sta B1Z_ScrnScrollData_Lo    ; ptr lo TabScrnDataRowOff $4003
                              lda #>B1_PlayField           ; TabScrnDataRowOff $4003 hi
                              sta B1Z_ScrnScrollData_Hi    ; ptr hi TabScrnDataRowOff $4003
                              
                              ldx #[B1_LenTxtRow - $01]    ; 
.TxtPlayerMen                 lda TxtPlrMen,x              ; 
                              sta B1_SavRowPlayer,x        ; 
                              dex                          ; 
                              bpl .TxtPlayerMen            ; 
                              
                              lda #$10                     ; "0"
                              ldx #B1_LenScores            ; 
.SetScore                     sta B1_SavRowStScore,x       ; 
                              dex                          ; 
                              bpl .SetScore                ; 
; ------------------------------------------------------------------------------------------------------------- ;
MainLoop                      subroutine                   ; 
                              lda B1Z_GameCaveNo           ; actual player cave number
                              bne .GoGameCaveSetup         ; 
                              
                              lda #$a0                     ; #.#..... - force next
                              sta B1_TitleMusicSuRe        ; start music voice 1 sustain/release
                              
                              jsr InitVicOptsIRQ           ; 
                              jsr StartScreenShow          ; 
                              jsr InitVicGameStatus        ; 
                              
                              ldx #$00                     ; 
                              lda #$7c                     ; 
.InitWaitScreen               sta [B1_WaitScrTxtDat + $0000],x    ; leave header row untouched
                              sta [B1_WaitScrTxtHdr + $0100],x
                              sta [B1_WaitScrTxtHdr + $0200],x
                              sta [B1_WaitScrTxtHdr + $02f8],x
                              inx                          ; 
                              bne .InitWaitScreen          ; 
                              
                              jsr InitPlayers              ; 
                              jmp .ClearI                  ; 
                              
.GoGameCaveSetup              jsr GameCaveSetup            ; 
                              
                              lda #$11                     ; 
                              sta [B1_SfxToPlayWork + $06] ; 
                              
                              lda B1Z_GamePlay             ; flag $00=game $01=demo
                              beq .GoMoveTiles             ; 
                              
                              jsr GameDemo                 ; 
                              
                              lda #B1Z_CopyRight_Off       ; 
                              sta B1Z_CopyRight            ; flag $00=show start screen values / $01=show start screen copyrights
                              jmp .GoGameCaveEnd           ; 
                              
.GoMoveTiles                  jsr GameMoveTiles            ; 
                              
                              lda #B1Z_AmoebaGrowing_Yes   ; 
                              sta B1Z_AmoebaGrowing        ; 
                              
.GoGameCaveEnd                jsr GameCaveEnd              ; 
                              
.ClearI                       ldx #$07                     ; 
                              lda #$00                     ; 
.ClearChr_00                  sta B1_CharSet,x             ; chr_00
                              dex                          ; 
                              bpl .ClearChr_00             ; 
MainLoopX                     bmi MainLoop                 ; 
; ------------------------------------------------------------------------------------------------------------- ;
Garbage                       include  inc\B1_Muell.asm    ; Obsolete code and tables
; ------------------------------------------------------------------------------------------------------------- ;
