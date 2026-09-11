; ------------------------------------------------------------------------------------------------------------ ;
; Boulder Dash I - Zero Page Equates
; ------------------------------------------------------------------------------------------------------------ ;
B1Z_MoveTilesRowMax       = $02                     ; 

B1Z_CopyFromP1            = $02                     ; 
B1Z_CopyFromP1_Lo         = $02                     ; 
B1Z_CopyFromP1_Hi         = $03                     ; 
B1Z_CopyFromP2            = $04                     ; 
B1Z_CopyFromP2_Lo         = $04                     ; 
B1Z_CopyFromP2_Hi         = $05                     ; 

B1Z_TimeToScoreTuneFix    = $02                     ; 
B1Z_TimeToScoreTuneFix_Ini  = $0f                   ; 
B1Z_TimeToScoreTuneVar    = $03                     ; 
B1Z_TimeToScoreTuneVar_Ini  = $d0                   ; 

B1Z_PlayFieldRowTab       = $02                     ; 
B1Z_PlayFieldRowTab_Lo    = $02                     ; 
B1Z_PlayFieldRowTab_Hi    = $03                     ; 
B1Z_PlayFieldRowTab_Len     = $2e                   ; 

B1Z_CaveCtrlFieldPos      = $32                     ; 
B1Z_CaveCtrlFieldPos_Lo   = $32                     ; 
B1Z_CaveCtrlFieldPos_Hi   = $33                     ; 

B1Z_CavePlayFieldPos      = $34                     ; 
B1Z_CavePlayFieldPos_Lo   = $34                     ; pointer playfield row lo
B1Z_CavePlayFieldPos_Hi   = $35                     ; pointer playfield row hi

B1Z_CaveScreenPos         = $36                     ; 
B1Z_CaveScreenPos_Lo      = $36                     ; pointer screen row lo
B1Z_CaveScreenPos_Hi      = $37                     ; pointer screen row hi

B1Z_SubMovesTiles         = $0038                   ; 
B1Z_SubMovesTiles_Lo      = $38                     ; 
B1Z_SubMovesTiles_Hi      = $39                     ; 

B1Z_GameScrnPos           = $3a                     ; 
B1Z_GameScrnPos_Lo        = $3a                     ; 
B1Z_GameScrnPos_Hi        = $3b                     ; 

B1Z_CopyCaveData          = $3c                     ; 
B1Z_CopyCaveData_Lo       = $3c                     ; copy cave data ptr lo
B1Z_CopyCaveData_Hi       = $3d                     ; copy cave data ptr hi

B1Z_SeedPseudoRND         = $3e                     ; rnd seed2
B1Z_StartPseudoRND        = $3f                     ; rnd seed1

B1Z_NoUuse_40             = $40                     ; .honz.unused
B1Z_NoUuse_41             = $41                     ; .honz.unused

B1Z_AmoebaGrowing         = $42                     ; 
B1Z_AmoebaGrowing_Yes       = $00                   ; 
B1Z_AmoebaGrowing_No        = $01                   ; 

B1Z_SfxAmoebaGrowth       = $43                     ; 
B1Z_SfxAmoebaGrowth_Yes     = $01                   ; 
B1Z_SfxAmoebaGrowth_No      = $00                   ; 

B1Z_RoFoPosX              = $44                     ; RockFord posX
B1Z_RoFoPosY              = $45                     ; RockFord posY

B1Z_ColorRam              = $46                     ; 
B1Z_ColorRam_Lo           = $46                     ; pointer Color RAM lo
B1Z_ColorRam_Hi           = $47                     ; pointer Color RAM hi

B1Z_StatusRow             = $46                     ; 
B1Z_StatusRow_Lo          = $46                     ; pointer status line data lo
B1Z_StatusRow_Hi          = $47                     ; pointer status line data hi

B1Z_ActualScore           = $4e                     ; 
B1Z_ActualScore_100000    = $4e                     ; game score diamond/time value 100000s
B1Z_ActualScore_010000    = $4f                     ; game score diamond/time value 10000s
B1Z_ActualScore_001000    = $50                     ; game score diamond/time value 1000s
B1Z_ActualScore_000100    = $51                     ; game score diamond/time value 100s
B1Z_ActualScore_000010    = $52                     ; game score diamond/time value 10s
B1Z_ActualScore_000001    = $53                     ; game score diamond/time value 1s

B1Z_VicSCROLY             = $54                     ; raster value  flip flop 1st for SCROLY
B1Z_VicSCROLY_2           = $55                     ; raster value  flip flop 2nd for SCROLY
B1Z_VicSCROLX             = $56                     ; raster value  flip flop 1st for SCROLX
B1Z_VicSCROLX_2           = $57                     ; raster value  flip flop 2nd for SCROLX
B1Z_VicVMCSB              = $58                     ; raster value  flip flop 1st for VMCSB 
B1Z_VicVMCSB_2            = $59                     ; raster value  flip flop 2nd for VMCSB 
B1Z_VicRASTER             = $5a                     ; raster value  flip flop 1st for RASTER
B1Z_VicRASTER_2           = $5b                     ; raster value  flip flop 2nd for RASTER
; ------------------------------------------------------------------------------------------------------------ ;
; Work Area of the Active Player
; ------------------------------------------------------------------------------------------------------------ ;
B1Z_GameWorkArea          = $5c                     ; 
B1Z_GameWorkArea_Len        = $0e                   ; 

B1Z_GameWorkHdr           = $5c                     ; 
B1Z_GameWorkHdr_Len         = $03                   ; 

B1Z_GameNumLives          = $5c                     ; 
B1Z_GameNumLives_Ini        = $03                   ; 
B1Z_GameNumLives_Max        = $09                   ; 
B1Z_GameCaveNo            = $5d                     ; actual player cave number
B1Z_CaveNoMin               = $01                   ; 
B1Z_CaveNoMax               = $15                   ; 
B1Z_GameDifficulty        = $5e                     ; 
B1Z_GameDifficulty_Min      = $00                   ; 
B1Z_GameDifficulty_Max      = $04                   ; 

B1Z_GameScore             = $5f                     ; 
B1Z_GameScore_Len           = $05                   ; 
B1Z_GameScore_100000      = $5f                     ; actual player high score byte 05 - 100000s
B1Z_GameScore_010000      = $60                     ; actual player high score byte 04 - 10000s
B1Z_GameScore_001000      = $61                     ; actual player high score byte 03 - 1000s
B1Z_GameScore_000100      = $62                     ; actual player high score byte 02 - 100s
B1Z_GameScore_000010      = $63                     ; actual player high score byte 01 - 10s
B1Z_GameScore_000001      = $64                     ; actual player high score byte 00 - 1s

B1Z_GameScoreHigh         = $65                     ; 
B1Z_GameScoreChr_100000   = $65                     ; actual player high score byte 05
B1Z_GameScoreChr_010000   = $66                     ; actual player high score byte 04
B1Z_GameScoreChr_001000   = $67                     ; actual player high score byte 03
B1Z_GameScoreChr_000100   = $68                     ; actual player high score byte 02
B1Z_GameScoreChr_000010   = $69                     ; actual player high score byte 01
B1Z_GameScoreChr_000001   = $6a                     ; actual player high score byte 00
; -------------------------------------------------------------------------------------------------------------- ;
; Save Area Player One
; -------------------------------------------------------------------------------------------------------------- ;
B1Z_SavP1Area             = $6b                     ; 
B1Z_HdrP1Sav              = $6b                     ; 

B1Z_SavP1NumLives         = $6b                     ; player 1 no of lives        
B1Z_SavP1CaveNo           = $6c                     ; player 1 player cave number 
B1Z_SavP1Difficulty       = $6d                     ; player 1 difficult level 1-5

B1Z_SavP1Score            = $6e                     ;  
B1Z_SavP1Score_100000     = $6e                     ; player 1 last score byte 05
B1Z_SavP1Score_010000     = $6f                     ; player 1 last score byte 04
B1Z_SavP1Score_001000     = $70                     ; player 1 last score byte 03
B1Z_SavP1Score_000100     = $71                     ; player 1 last score byte 02
B1Z_SavP1Score_000010     = $72                     ; player 1 last score byte 01
B1Z_SavP1Score_000001     = $73                     ; player 1 last score byte 00                          

B1Z_SavP1ScoreHigh        = $74                     ;  
B1Z_SavP1ScoreHigh_100000 = $74                     ; player 1 high score byte 05
B1Z_SavP1ScoreHigh_010000 = $75                     ; player 1 high score byte 04
B1Z_SavP1ScoreHigh_001000 = $76                     ; player 1 high score byte 03
B1Z_SavP1ScoreHigh_000100 = $77                     ; player 1 high score byte 02
B1Z_SavP1ScoreHigh_000010 = $78                     ; player 1 high score byte 01
B1Z_SavP1ScoreHigh_000001 = $79                     ; player 1 high score byte 00
; -------------------------------------------------------------------------------------------------------------- ;
; Save Area Player Two
; -------------------------------------------------------------------------------------------------------------- ;
B1Z_SavP2Area             = $7a                     ; 
B1Z_SavP2Hdr              = $7a                     ; 

B1Z_SavP2NumLives         = $7a                     ; player 1 no of lives
B1Z_SavP2CaveNo           = $7b                     ; player 1 player cave number
B1Z_SavP2Difficulty       = $7c                     ; player 1 difficult level 1-5

B1Z_SavP2Score            = $7d                     ; 
B1Z_SavP2Score_100000     = $7d                     ; player 2 last score byte 05
B1Z_SavP2Score_010000     = $7e                     ; player 2 last score byte 04
B1Z_SavP2Score_001000     = $7f                     ; player 2 last score byte 03
B1Z_SavP2Score_000100     = $80                     ; player 2 last score byte 02
B1Z_SavP2Score_000010     = $81                     ; player 2 last score byte 01
B1Z_SavP2Score_000001     = $82                     ; player 2 last score byte 00

B1Z_SavP2ScoreHigh        = $83                     ; 
B1Z_SavP2ScoreHigh_100000 = $83                     ; player 2 high score byte 05
B1Z_SavP2ScoreHigh_010000 = $84                     ; player 2 high score byte 04
B1Z_SavP2ScoreHigh_001000 = $85                     ; player 2 high score byte 03
B1Z_SavP2ScoreHigh_000100 = $86                     ; player 2 high score byte 02
B1Z_SavP2ScoreHigh_000010 = $87                     ; player 2 high score byte 01
B1Z_SavP2ScoreHigh_000001 = $88                     ; player 2 high score byte 00
; -------------------------------------------------------------------------------------------------------------- ;
B1Z_ExplodeTileNo         = $89                     ; explode tile no

B1Z_CaveTileGameNo        = $8a                     ; 

B1Z_MovesPort_B           = $8b                     ; 

B1Z_AmoebaToDiamond       = $8c                     ; 
B1Z_AmoebaToDiamond_Yes     = $00                   ; 
B1Z_AmoebaToDiamond_No      = $01                   ; 

B1Z_SfxMagicWall          = $8d                     ; 
B1Z_SfxMagicWall_On         = $01                   ; 
B1Z_SfxMagicWall_Off        = $00                   ; 
B1Z_SfxMagicWall_Reset      = $02                   ; reset wall bricks

B1Z_MagicWallTimePause    = $8e                     ; 
B1Z_MagicWallTimePause_Max  = $3c                   ; 

B1Z_MagicWallTime         = $8f                     ; 

B1Z_DiaGotAll             = $90                     ; 
B1Z_DiaGotAll_Yes           = $01                   ; 
B1Z_DiaGotAll_No            = $00                   ; 

B1Z_CaveCtrlFieldCol      = $91                     ; column number
B1Z_CaveCtrlFieldRow      = $92                     ; row number

B1Z_RoFoBorn              = $93                     ; 
B1Z_RoFoBorn_Yes            = $00                   ; 
B1Z_RoFoBorn_No             = $01                   ; 

B1Z_SfxPlay               = $94                     ; 
B1Z_SfxPlay_Yes             = $01                   ; 
B1Z_SfxPlay_No              = $00                   ; 

B1Z_RoFoWaitBirth         = $95                     ; 

B1Z_WaitChkFire           = $96                     ; 
B1Z_WaitChkFire_Ini         = $00                   ; 
B1Z_WaitChkFire_Max         = $10                   ; 

B1Z_CaveCompleted         = $97                     ; 
B1Z_CaveCompleted_Yes       = $02                   ; 
B1Z_CaveCompleted_No        = $00                   ; 

B1Z_RoFoMoveDir           = $98                     ; flag rockford move direction left right
B1Z_RoFoMoveDir_Le          = $01                   ; 
B1Z_RoFoMoveDir_Ri          = $00                   ; 

B1Z_GameCaveNoLast        = $99                     ; old cave no

B1Z_GamePaused            = $9b                     ; flag pause mode $00=no >$00=yes
B1Z_GamePaused_Yes          = $01                   ; 
B1Z_GamePaused_No           = $00                   ; 

B1Z_GameSpeed             = $9c                     ; value for game speed slow down

B1Z_GamePlayerNo          = $9d                     ; actual player no $00-$01

B1Z_PlayerNo              = $9e                     ; no of players

B1Z_TimeToScore           = $9f                     ; 
B1Z_TimeToScore_Yes         = $01                   ; 
B1Z_TimeToScore_No          = $00                   ; 

B1Z_GameOver              = $a0                     ; 
B1Z_GameOver_Yes            = $00                   ; 
B1Z_GameOver_No             = $01                   ; 

B1Z_NewGameScoreHi        = $a1                     ; 
B1Z_NewGameScoreHi_Yes      = $00                   ; 
B1Z_NewGameScoreHi_No       = $01                   ; 

B1Z_GamePlay              = $a2                     ; flag $00=game $01=demo
B1Z_GamePlay_Yes            = $00                   ; 
B1Z_GamePlay_No             = $01                   ; 

B1Z_CopyRight             = $a3                     ; flag $00=show start screen values / $01=show start screen copyrights
B1Z_CopyRight_Off           = $00                   ; 
B1Z_CopyRight_On            = $01                   ; 

B1Z_JoyStickNo            = $a4                     ; no of joysticks

B1Z_GameFlashTime         = $a5                     ; duration cave finished flash
B1Z_GameFlashTime_Ini       = $06                   ; 
B1Z_GameFlashTime_Off       = $00                   ; 

B1Z_CaveType              = $a6                     ; $00=normal $01=extra

B1Z_OptsFlipFlopSel       = $a7                     ; raster values flip flop pointer
B1Z_OptsFlipFlopSel_Gfx     = $00                   ; 
B1Z_OptsFlipFlopSel_Txt     = $01                   ; 
B1Z_OptsFlipFlopSel_Ini     = $02                   ; 

B1Z_FlickerTimeOneUp      = $a8                     ; bonus life flicker empty time
B1Z_FlickerTimeOneUp_Ini    = $80                   ; 

B1Z_PlSaveScore_001000    = $a9                     ; actual player high score byte 03 - save
B1Z_PlSaveScore_000100    = $aa                     ; actual player high score byte 03 - save

B1Z_CaveTime              = $ab                     ; 
B1Z_CaveTime_Len            = $02                   ; 
B1Z_CaveTime_100          = $ab                     ; game time 100s
B1Z_CaveTime_010          = $ac                     ; game time 10s
B1Z_CaveTime_001          = $ad                     ; game time 1s

B1Z_CountDownWait         = $ae                     ; 
B1Z_CountDownWait_Ini       = $00                   ; 
B1Z_CountDownWait_Max       = $3c                   ; 

B1Z_TimeCountSec          = $af                     ; actual cave time

B1Z_DiaGot                = $b0                     ; 
B1Z_DiaGot_Len              = $01                   ; 
B1Z_DiaGot_10             = $b0                     ; diamonds got 10
B1Z_DiaGot_01             = $b1                     ; diamonds got 1

B1Z_DiaToGet              = $b2                     ; 
B1Z_DiaToGet_Len            = $01                   ; 
B1Z_DiaToGet_10           = $b2                     ; diamonds to get 10
B1Z_DiaToGet_01           = $b3                     ; diamonds to get 1

B1Z_DiaValueSpecial       = $b4                     ; 
B1Z_DiaValueSpecial_100   = $b4                     ; diamond value after cave was finished
B1Z_DiaValueSpecial_010   = $b5                     ; 
B1Z_DiaValueSpecial_001   = $b6                     ; 

B1Z_RoFoMoves             = $b7                     ; 
B1Z_RoFoMoves_Yes           = $01                   ; 
B1Z_RoFoMoves_No            = $00                   ; 

B1Z_FirePort_A_B          = $b8                     ; status fire both joysticks

B1Z_BlinkStartDoor        = $b9                     ; 

B1Z_CaveScrnCharSelect    = $ba                     ; 

B1Z_CaveUncoverCount      = $bb                     ; number of rnd uncover game screen turns
B1Z_CaveUncoverCount_Ini    = $45                   ; 

B1Z_CaveUncoverSeed       = $bc                     ; rnd col no

B1Z_SfxRNDPlay            = $bd                     ; 
B1Z_SfxRNDPlay_Yes          = $01                   ; 
B1Z_SfxRNDPlay_No           = $00                   ; 

B1Z_AnimRoFoTaps          = $be                     ; 
B1Z_AnimRoFoTaps_Yes        = $01                   ; flag random animation anmimation 01
B1Z_AnimRoFoTaps_No         = $00                   ; 

B1Z_AnimRoFoBlink         = $bf                     ; flag random animation anmimation 02
B1Z_AnimRoFoBlink_Yes       = $01                   ; 
B1Z_AnimRoFoBlink_No        = $00                   ; 

B1Z_AnimTilePhaseOff      = $c0                     ; 

B1Z_IrqOptsAnimChar       = $c1                     ; 
B1Z_IrqOptsAnimChar_Yes     = $01                   ; 
B1Z_IrqOptsAnimChar_No      = $00                   ; 

B1Z_ScrollType            = $c2                     ; 
B1Z_ScrollType_Soft         = $00                   ; 
B1Z_ScrollType_Hard         = $01                   ; 

B1Z_HexToDecResult        = $c3                     ; 
B1Z_HexToDec_100          = $c3                     ; hex2dec value 100
B1Z_HexToDec_010          = $c4                     ; hex2dec value 10
B1Z_HexToDec_001          = $c5                     ; hex2dec value 1

B1Z_HexToDecValue         = $c6                     ; no of hex to decimal add rounds

B1Z_TimeCaveSec           = $c7                     ; max cave time

B1Z_CaveVarDrawLineLen    = $c8                     ; 
B1Z_CaveVarDrawLineDirLo  = $c9                     ; 
B1Z_CaveVarDrawLineDirHi  = $ca                     ; 

B1Z_CaveDataVarPtr        = $cb                     ; 

B1Z_OffCavBldrDat         = $cb                     ;

B1Z_StatusStartRow        = $cc                     ;
B1Z_StatusStartRow_Info     = $00                   ; 
B1Z_StatusStartRow_CC       = $01                   ; 

B1Z_DemoRun               = $cd                     ; 
B1Z_DemoRun_Yes             = $01                   ; 
B1Z_DemoRun_No              = $00                   ; 

B1Z_FlgGame               = $ce                     ; flag $00=game screen $01=start screen
B1Z_GameShowOpts          = $ce                     ; 
B1Z_GameShowOpts_Yes        = $01                   ; 
B1Z_GameShowOpts_No         = $00                   ; 
B1Z_GameShowOpts_Ini        = $ff                   ; 

B1Z_IrqOptsInit           = $cf                     ; flag IRQ StartScreen handling ready
B1Z_IrqOptsInit_Yes         = $01                   ; 
B1Z_IrqOptsInit_No          = $00                   ; 

B1Z_OptCountPressF3       = $d0                     ; 

B1Z_DemoMoveTime          = $d2                     ; duration demo move
B1Z_DemoMoveTabPtr        = $d3                     ; pointer demo moves
B1Z_DemoFinish            = $d4                     ; flag demo mode
B1Z_DemoFinish_Yes          = $00                   ; 
B1Z_DemoFinish_No           = $01                   ; 

B1Z_IniVoTaSpPart2        = $d5                     ; 
B1Z_IniVoTaSpPart2_Yes      = $00                   ; 
B1Z_IniVoTaSpPart2_No       = $01                   ; 

B1Z_ScrnScrollData        = $d6                     ; 
B1Z_ScrnScrollData_Lo     = $d6                     ; 
B1Z_ScrnScrollData_Hi     = $d7                     ; 


B1Z_PtrLoRow              = $d6                     ; pointer TabPlFldRowOff $4003
B1Z_PtrHiRow              = $d7                     ; 

B1Z_SfxPlayBang           = $d8                     ; 
B1Z_SfxPlayBang_Yes         = $01                   ; 
B1Z_SfxPlayBang_No          = $00                   ; 

B1Z_SfxPlayBangTime       = $d9                     ; 
B1Z_SfxPlayBangTime_Ini     = $21                   ; 

B1Z_CaveDataVarParm_00    = $da                     ; cave tile
B1Z_CaveDataVarParm_01    = $db                     ; cave tile posX
B1Z_CaveDataVarParm_02    = $dc                     ; cave tile posY
B1Z_CaveDataVarParm_03    = $dd                     ; cave tile len 
B1Z_CaveDataVarParm_04    = $df                     ; cave tile dir 
B1Z_CaveDataVarParm_05    = $e0                     ; cave tile fill
; ------------------------------------------------------------------------------------------------------------- ;
B1Z_ScrollSoftValX        = $e1                     ; 
B1Z_ScrollSoftValX_Sav    = $e2                     ; 
B1Z_ScrollSoftValY        = $e3                     ; 
B1Z_ScrollSoftValY_Sav    = $e4                     ; 
B1Z_RoFoScreenPosY        = $e5                     ; 
B1Z_RoFoScreenPosY_Max      = $0b                   ; 
B1Z_RoFoScreenPosY_Min      = $05                   ; 
B1Z_RoFoScreenPosX        = $e6                     ; 
B1Z_RoFoScreenPosX_Max      = $11                   ; 
B1Z_RoFoScreenPosX_Min      = $03                   ; 
B1Z_ScrollSoftOffTabX     = $e7                     ; 
B1Z_RoFoScrollPosX        = $e8                     ; 
B1Z_ScrollSoftDirLeRi_Lo  = $e9                     ; 
B1Z_ScrollSoftDirLeRi_Hi  = $ea                     ; 
B1Z_ScrollSoftOffTabY     = $eb                     ; 
B1Z_RoFoScrollPosY        = $ec                     ; 
B1Z_ScrollSoftDirUpDo_Lo  = $ed                     ; 
B1Z_ScrollSoftDirUpDo_Hi  = $ee                     ; 
; ------------------------------------------------------------------------------------------------------------- ;
B1Z_KeyPressedNew_0       = $fb                     ; scan value for keyboard row 00
B1Z_KeyPressedNew_7       = $fc                     ; scan value for keyboard row 07
B1Z_KeyPressedOld_0       = $fd                     ; scan value for keyboard row 00 - 2nd
B1Z_KeyPressedOld_7       = $fe                     ; scan value for keyboard row 07 - 2nd
; ------------------------------------------------------------------------------------------------------------- ;
B1Z_AnimateTile           = $ff                     ; bit pattern tile animation on/off
; ------------------------------------------------------------------------------------------------------------- ;
