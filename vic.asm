; ------------------------------------------------------------------------------------------------------------- ;
; Video Interface Chip (VIC-II) Registers - $D000-$D02E
; ------------------------------------------------------------------------------------------------------------- ;
; Control Registers         ; $D000-$D01f
; ------------------------------------------------------------------------------------------------------------- ;
VIC2              = $D000     ; Base Address
; ------------------------------------------------------------------------------------------------------------- ;
SP0X              = $D000     ; Sprite 0 X-Pos (Bits 7…0 - Bit 8 is stored in MSIGX = $D010)
SP0Y              = $D001     ; Sprite 0 Y-Pos (Bits 7…0)
                  
_M0X              = SP0X      ; 
_M0Y              = SP0Y      ; 
; ------------------------------------------------------------------------------------------------------------- ;
SP1X              = $D002     ; Sprite 1 X-Pos (Bits 7…0 - Bit 8 is stored in MSIGX = $D010)
SP1Y              = $D003     ; Sprite 1 Y-Pos (Bits 7…0)
                  
_M1X              = SP1X      ; 
_M1Y              = SP1Y      ; 
; ------------------------------------------------------------------------------------------------------------- ;
SP2X              = $D004     ; Sprite 2 X-Pos (Bits 7…0 - Bit 8 is stored in MSIGX = $D010)
SP2Y              = $D005     ; Sprite 2 Y-Pos (Bits 7…0)
                  
_M2X              = SP2X      ; 
_M2Y              = SP2Y      ; 
; ------------------------------------------------------------------------------------------------------------- ;
SP3X              = $D006     ; Sprite 3 X-Pos (Bits 7…0 - Bit 8 is stored in MSIGX = $D010)
SP3Y              = $D007     ; Sprite 3 Y-Pos (Bits 7…0)
                  
_M3X              = SP3X      ; 
_M3Y              = SP3Y      ; 
; ------------------------------------------------------------------------------------------------------------- ;
SP4X              = $D008     ; Sprite 4 X-Pos (Bits 7…0 - Bit 8 is stored in MSIGX = $D010)
SP4Y              = $D009     ; Sprite 4 Y-Pos (Bits 7…0)
                  
_M4X              = SP4X      ; 
_M4Y              = SP4Y      ; 
; ------------------------------------------------------------------------------------------------------------- ;
SP5X              = $D00A     ; Sprite 5 X-Pos (Bits 7…0 - Bit 8 is stored in MSIGX = $D010)
SP5Y              = $D00B     ; Sprite 5 Y-Pos (Bits 7…0)
                  
_M5X              = SP5X      ; 
_M5Y              = SP5Y      ; 
; ------------------------------------------------------------------------------------------------------------- ;
SP6X              = $D00C     ; Sprite 6 X-Pos (Bits 7…0 - Bit 8 is stored in MSIGX = $D010)
SP6Y              = $D00D     ; Sprite 6 Y-Pos (Bits 7…0)
                  
_M6X              = SP6X      ; 
_M6Y              = SP6Y      ; 
; ------------------------------------------------------------------------------------------------------------- ;
SP7X              = $D00E     ; Sprite 7 X-Pos (Bits 7…0 - Bit 8 is stored in MSIGX = $D010)
SP7Y              = $D00F     ; Sprite 7 Y-Pos (Bits 7…0)
                  
_M7X              = SP7X      ; 
_M7Y              = SP7Y      ; 
; ------------------------------------------------------------------------------------------------------------- ;
                              ; Top/Left Corner of the Screen has X/Y coordinates: 24/50
                              ; 
                              ; Sprite Pointers stored at the end of the Video Matrix
                              ;   One Byte per Sprite for Bits  6…13
                              ;                           Bits 14…15 are stored (inverted) at CI2PRA = $DD00 Bits 0…1 
; ------------------------------------------------------------------------------------------------------------- ;
MSIGX             = $D010     ; Most Significant Bit of X-Pos Sprites 0-7
                              ; Setting a bit to 1 adds 256 to the X-Pos of the corresponding sprite
VIC_Sprt0_MsbX    = %00000001 ; Bit 0: MSB X-Pos Sprite 0
VIC_Sprt1_MsbX    = %00000010 ; Bit 1: MSB X-Pos Sprite 1
VIC_Sprt2_MsbX    = %00000100 ; Bit 2: MSB X-Pos Sprite 2
VIC_Sprt3_MsbX    = %00001000 ; Bit 3: MSB X-Pos Sprite 3
VIC_Sprt4_MsbX    = %00010000 ; Bit 4: MSB X-Pos Sprite 4
VIC_Sprt5_MsbX    = %00100000 ; Bit 5: MSB X-Pos Sprite 5
VIC_Sprt6_MsbX    = %01000000 ; Bit 6: MSB X-Pos Sprite 6
VIC_Sprt7_MsbX    = %10000000 ; Bit 7: MSB X-Pos Sprite 7

_M0X8             = VIC_Sprt0_MsbX ; 
_M1X8             = VIC_Sprt1_MsbX ; 
_M2X8             = VIC_Sprt2_MsbX ; 
_M3X8             = VIC_Sprt3_MsbX ; 
_M4X8             = VIC_Sprt4_MsbX ; 
_M5X8             = VIC_Sprt5_MsbX ; 
_M6X8             = VIC_Sprt6_MsbX ; 
_M7X8             = VIC_Sprt7_MsbX ; 
; ------------------------------------------------------------------------------------------------------------- ;
SCROLY            = $D011     ; VIC Control Register 1 (and Vertical Fine Scrolling)  see: SCROLX
VIC_SoftY_Max     = %00000111 ; Bit 0-2: Soft Scrolling Y-Position by 0-7 scan lines
VIC_Rows25        = %00001000 ; Bit 3  : Select a 25-row text display
VIC_Screen_On     = %00010000 ; Bit 4  : Screen Enable
VIC_BMM_On        = %00100000 ; Bit 5  : Bitmap Mode         (BMM)
VIC_ECM_On        = %01000000 ; Bit 6  : Extended Color Mode (ECM)
VIC_RasterHi      = %10000000 ; Bit 7  : Bit 8 (high bit) of raster compare register at RASTER($D012)
                              ; 
VIC_SoftY_Clear   = %11111000 ; Bit 0-2: Soft Scrolling Y-Position by 0-7 scan lines
VIC_Rows24        = %11110111 ; Bit 3  : Select a 24-row text display
VIC_Screen_Off    = %11101111 ; Bit 4  : Screen Disable
VIC_BMM_Off       = %11011111 ; Bit 5  : Text   Mode
VIC_ECM_Off       = %10111111 ; Bit 6  : 
VIC_RasterHi_Off  = %01111111 ; Bit 7  : Bit 8 (high bit) of raster compare register at RASTER($D012)

_YSCROLL           = VIC_SoftY_Max ; 
_RSEL              = VIC_Rows25    ; 
_DEN               = VIC_Screen_On ; 
_BMM               = VIC_BMM_On    ; 
_ECM               = VIC_ECM_On    ; 
_RST8              = VIC_RasterHi  ; 
; ------------------------------------------------------------------------------------------------------------- ;
                              ; Graphic Modes with SCROLY and SCROLX
                              ;
                              ;   Standard   Text    Mode    (ECM, BMM, MCM = 0, 0, 0)
                              ;   Multicolor Text    Mode    (ECM, BMM, MCM = 0, 0, 1)
                              ;   Standard   BitMap  Mode    (ECM, BMM, MCM = 0, 1, 0)
                              ;   Multicolor BitMap  Mode    (ECM, BMM, MCM = 0, 1, 1)
                              ;   ECM        Text    Mode    (ECM, BMM, MCM = 1, 0, 0)
                              ;   ----------------------------------------------------
                              ;   Invalid    Text    Mode    (ECM, BMM, MCM = 1, 0, 1)
                              ;   Invalid    Bitmap  Mode 1  (ECM, BMM, MCM = 1, 1, 0)
                              ;   Invalid    Bitmap  Mode 2  (ECM, BMM, MCM = 1, 1, 1)
; ------------------------------------------------------------------------------------------------------------- ;
RASTER            = $D012     ; Read : Current Raster Scan Line (Bits 7…0, Bit 8 is available in SCROLY = $D011)
                              ; Write: Line to Compare for Raster IRQ
                              ;
                              ; Visible Area: $32-$f9 (050-249) = 200 horizontal lines
                              ; 
                              ; Read:  Returns the screen line the electron beam is currently scanning
                              ;        NTSC: $106 horizontal lines (262) - Bit8 in SCROLY = $D011
                              ;        PAL : $138 horizontal lines (312) - Bit8 in SCROLY = $D011
                              ; 
                              ;        Every one of these lines is scanned and updated 60 times per second
                              ;        Only 200 of these lines are part of the visible display
                              ;
                              ; Write: Set comparison value for the Raster Compare Interrupt
                              ; 
                              ; Note:
                              ; Bit 8 (high bit) is Bit 7 of SCROLY = $D011
                              ; Move sprites only when the raster scanning is off-screen to avoid flickers
                              ; 
                              ;   WAIT  lda SCROLY
                              ;         bpl WAIT
; ------------------------------------------------------------------------------------------------------------- ;
LPENX             = $D013     ; Light Pen Horizontal Position
                              ; 8 Bits for 320 possible horizontal screen positions
                              ;   Accurate only to every second dot position
                              ;   The Value will range from 0 to 160 and must be multiplied by 2
                              
_LPX              = LPENX     ;
; ------------------------------------------------------------------------------------------------------------- ;
LPENY             = $D014     ; Light Pen Vertical Position
                              ; 200 visible scan lines fit exactly into this register
                              
_LPY              = LPENY     ;
; ------------------------------------------------------------------------------------------------------------- ;
SPENA             = $D015     ; Sprite Enable Register
VIC_Sprt0_On      = %00000001 ; Bit 0: Enable  Sprite 0
VIC_Sprt1_On      = %00000010 ; Bit 1: Enable  Sprite 1
VIC_Sprt2_On      = %00000100 ; Bit 2: Enable  Sprite 2
VIC_Sprt3_On      = %00001000 ; Bit 3: Enable  Sprite 3
VIC_Sprt4_On      = %00010000 ; Bit 4: Enable  Sprite 4
VIC_Sprt5_On      = %00100000 ; Bit 5: Enable  Sprite 5
VIC_Sprt6_On      = %01000000 ; Bit 6: Enable  Sprite 6
VIC_Sprt7_On      = %10000000 ; Bit 7: Enable  Sprite 7
                              ; 
VIC_Sprt0_Off     = %11111110 ; Bit 0: Disable Sprite 0
VIC_Sprt1_Off     = %11111101 ; Bit 1: Disable Sprite 1
VIC_Sprt2_Off     = %11111011 ; Bit 2: Disable Sprite 2
VIC_Sprt3_Off     = %11110111 ; Bit 3: Disable Sprite 3
VIC_Sprt4_Off     = %11101111 ; Bit 4: Disable Sprite 4
VIC_Sprt5_Off     = %11011111 ; Bit 5: Disable Sprite 5
VIC_Sprt6_Off     = %10111111 ; Bit 6: Disable Sprite 6
VIC_Sprt7_Off     = %01111111 ; Bit 7: Disable Sprite 7

VIC_Sprts_On      = %11111111 ; All Sprite enabled
VIC_Sprts_Off     = %00000000 ; All Sprite disabled

_M0E              = VIC_Sprt0_On ; 
_M1E              = VIC_Sprt1_On ; 
_M2E              = VIC_Sprt2_On ; 
_M3E              = VIC_Sprt3_On ; 
_M4E              = VIC_Sprt4_On ; 
_M5E              = VIC_Sprt5_On ; 
_M6E              = VIC_Sprt6_On ; 
_M7E              = VIC_Sprt7_On ; 
; ------------------------------------------------------------------------------------------------------------- ;
SCROLX            = $D016     ; VIC Control Register 2 (and Horizontal Fine Scrolling)   see: SCROLY
VIC_SoftX_Max     = %00000111 ; Bit 0-2: Soft Scrolling X-Position by 0-7 dot positions
VIC_Cols40        = %00001000 ; Bit 3  : Select a 40-column text display
VIC_MCM_On        = %00010000 ; Bit 4  : Multi Color Mode    (MCM)
VIC_Off           = %00100000 ; Bit 5  : VIC video completely off
                  ;  .#...... ; Bit 6  : <unused>
                  ;  #....... ; Bit 7  : <unused>
                  ; 
VIC_SoftX_Clear   = %11111000 ; Bit 0-2: Soft Scrolling X-Position by 0-7 dot positions
VIC_Cols38        = %11110111 ; Bit 3  : Select a 38-column text display
VIC_MCM_Off       = %11101111 ; Bit 4  : 
VIC_On            = %11011111 ; Bit 5  : VIC normal operation
                  ;  .#...... ; Bit 6  : <unused>
                  ;  #....... ; Bit 7  : <unused>
                  
_XSCROLL          = VIC_SoftX_Max ; 
_CSEL             = VIC_Cols40    ; 
_MCM              = VIC_MCM_On    ; 
_RES              = VIC_Off       ; 
; ------------------------------------------------------------------------------------------------------------- ;
                              ; Graphic Modes with SCROLX and SCROLY
                              ; 
                              ;   Standard   Text    Mode    (ECM, BMM, MCM = 0, 0, 0)
                              ;   Multicolor Text    Mode    (ECM, BMM, MCM = 0, 0, 1)
                              ;   Standard   BitMap  Mode    (ECM, BMM, MCM = 0, 1, 0)
                              ;   Multicolor BitMap  Mode    (ECM, BMM, MCM = 0, 1, 1)
                              ;   ECM        Text    Mode    (ECM, BMM, MCM = 1, 0, 0)
                              ;   ----------------------------------------------------
                              ;   Invalid    Text    Mode    (ECM, BMM, MCM = 1, 0, 1)
                              ;   Invalid    Bitmap  Mode 1  (ECM, BMM, MCM = 1, 1, 0)
                              ;   Invalid    Bitmap  Mode 2  (ECM, BMM, MCM = 1, 1, 1)
; ------------------------------------------------------------------------------------------------------------- ;
YXPAND            = $D017     ; Sprite Scale Double Height
VIC_Sprt0_YY_On   = %00000001 ; Bit 0: Sprite 0 double height
VIC_Sprt1_YY_On   = %00000010 ; Bit 1: Sprite 1 double height
VIC_Sprt2_YY_On   = %00000100 ; Bit 2: Sprite 2 double height
VIC_Sprt3_YY_On   = %00001000 ; Bit 3: Sprite 3 double height
VIC_Sprt4_YY_On   = %00010000 ; Bit 4: Sprite 4 double height
VIC_Sprt5_YY_On   = %00100000 ; Bit 5: Sprite 5 double height
VIC_Sprt6_YY_On   = %01000000 ; Bit 6: Sprite 6 double height
VIC_Sprt7_YY_On   = %10000000 ; Bit 7: Sprite 7 double height
                              ; 
VIC_Sprt0_YY_Off  = %11111110 ; Bit 0: Sprite 0 normal height
VIC_Sprt1_YY_Off  = %11111101 ; Bit 1: Sprite 1 normal height
VIC_Sprt2_YY_Off  = %11111011 ; Bit 2: Sprite 2 normal height
VIC_Sprt3_YY_Off  = %11110111 ; Bit 3: Sprite 3 normal height
VIC_Sprt4_YY_Off  = %11101111 ; Bit 4: Sprite 4 normal height
VIC_Sprt5_YY_Off  = %11011111 ; Bit 5: Sprite 5 normal height
VIC_Sprt6_YY_Off  = %10111111 ; Bit 6: Sprite 6 normal height
VIC_Sprt7_YY_Off  = %01111111 ; Bit 7: Sprite 7 normal height

VIC_Sprts_YY_On   = %11111111 ; All Sprites double height
VIC_Sprts_YY_Off  = %00000000 ; All Spritea normal height

_M0YE             = VIC_Sprt0_YY_On ; 
_M1YE             = VIC_Sprt1_YY_On ; 
_M2YE             = VIC_Sprt2_YY_On ; 
_M3YE             = VIC_Sprt3_YY_On ; 
_M4YE             = VIC_Sprt4_YY_On ; 
_M5YE             = VIC_Sprt5_YY_On ; 
_M6YE             = VIC_Sprt6_YY_On ; 
_M7YE             = VIC_Sprt7_YY_On ; 
; ------------------------------------------------------------------------------------------------------------- ;
VMCSB             = $D018     ; VIC-II Chip Memory Control
                              ;   Bit    0: Unused
                              ;   Bits 1-3: Bits 11…13 of Char   RAM Address in Text   Mode (1k blocks)
                              ;   Bit    3: Bit     13 of Bitmap     Address in Bitmap Mode (8k blocks)
                              ;   Bits 4-7: Bits 10…13 of Video  RAM Address
                              ;             Bits 14…15 of both values are stored (negated) in CI2PRA = $DD00 of CIA2
                              ;             Bits 0…9/10 are always 0
                              ;   Note:
                              ;   At the following storage locations a VIC read for sprite/bitmap/screen value data
                              ;   is always from the CHARACTER ROM instead from the RAM
                              ;
                              ;   --> $1000-$2000 - do not store sprite/bitmap/screen data here ...
                              ;       $9000-$a000 - ... and here
                              ;   
VIC_CharS_unus    = %00000001 ; Bit  0 <unused>
VIC_CharSetMask   = %11110000 ; Bits 1-3: Character Set base address within the  VIC-II address space
VIC_CharS_0000    = %00000000 ;  ...  0=$0000-$07ff
VIC_CharS_0800    = %00000010 ;  ..#  1=$0800-$0fff
VIC_CharS_1000    = %00000100 ;  .#.  2=$1000-$17ff - ROM image mirror in bank 0 or 2 / no mirror in bank 1 or 3
VIC_CharS_1800    = %00000110 ;  .##  3=$1800-$1fff - ROM image mirror in bank 0 or 2 / no mirror in bank 1 or 3
VIC_CharS_2000    = %00001000 ;  #..  4=$2000-$27ff
VIC_CharS_2800    = %00001010 ;  #.#  5=$2800-$2fff
VIC_CharS_3000    = %00001100 ;  ##.  6=$3000-$37ff
VIC_CharS_3800    = %00001110 ;  ###  7=$3800-$3fff 
                              ;                
VIC_VideoMask     = %00001111 ; Bits 4-7: Video Matrix base address within the VIC-II address space
VIC_Video_0000    = %00000000 ; ....  0=$0000-$03e7 - Sprite Pointers: $03f8…$03ff - possible bitmap
VIC_Video_0400    = %00010000 ; ...#  1=$0400-$07e7 - Sprite Pointers: $07f8…$07ff
VIC_Video_0800    = %00100000 ; ..#.  2=$0800-$0be7 - Sprite Pointers: $0bf8…$0bff
VIC_Video_0c00    = %00110000 ; ..##  3=$0c00-$0fe7 - Sprite Pointers: $0ff8…$0fff
VIC_Video_1000    = %01000000 ; .#..  4=$1000-$13e7 - Sprite Pointers: $13f8…$13ff
VIC_Video_1400    = %01010000 ; .#.#  5=$1400-$17e7 - Sprite Pointers: $17f8…$17ff
VIC_Video_1800    = %01100000 ; .##.  6=$1800-$1be7 - Sprite Pointers: $1bf8…$1bff
VIC_Video_1c00    = %01110000 ; .###  7=$1c00-$1fe7 - Sprite Pointers: $1ff8…$1fff
VIC_Video_2000    = %10000000 ; #...  8=$2000-$23e7 - Sprite Pointers: $23f8…$23ff - possible bitmap
VIC_Video_2400    = %10010000 ; #..#  9=$2400-$27e7 - Sprite Pointers: $27f8…$27ff
VIC_Video_2800    = %10100000 ; #.#.  a=$2800-$2be7 - Sprite Pointers: $2bf8…$2bff
VIC_Video_2c00    = %10110000 ; #.##  b=$2c00-$2fe7 - Sprite Pointers: $2ff8…$2fff
VIC_Video_3000    = %11000000 ; ##..  c=$3000-$33e7 - Sprite Pointers: $33f8…$33ff
VIC_Video_3400    = %11010000 ; ##.#  d=$3400-$37e7 - Sprite Pointers: $37f8…$37ff
VIC_Video_3800    = %11100000 ; ###.  e=$3800-$3be7 - Sprite Pointers: $3bf8…$3bff
VIC_Video_3c00    = %11110000 ; ####  f=$3c00-$3fe7 - Sprite Pointers: $3ff8…$3fff

; –               = %00000001 ; <not used>
_CB11             = %00000010 ; 
_CB12             = %00000100 ; 
_CB13             = %00001000 ; 
_VM10             = %00010000 ; 
_VM11             = %00100000 ; 
_VM12             = %01000000 ; 
_VM13             = %10000000 ; 
; ------------------------------------------------------------------------------------------------------------- ;
VICIRQ            = $D019     ; Interrupt Flag Register - Latched flags cleared if set to 1
VIC_IrqWasRaster  = %00000001 ; Bit 0: Flag: Raster Compare IRQ          caused an IRQ? (1=yes)
VIC_IrqWasSpBkgr  = %00000010 ; Bit 1: Flag: Sprite:Background collision caused an IRQ? (1=yes)
VIC_IrqWasSpSp    = %00000100 ; Bit 2: Flag: Sprite:Sprite     collision caused an IRQ? (1=yes)
VIC_IrqWasPen     = %00001000 ; Bit 3: Flag: Light pen trigger           caused an IRQ? (1=yes)
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
VIC_IrqHappened   = %10000000 ; Bit 7: Flag: At least one of the above IRQ's  has happened? (1=yes)

VIC_IrqClear      = %11111111 ; Latched flags cleared if set to 1

_IRST             = VIC_IrqWasRaster ; 
_IMBC             = VIC_IrqWasSpBkgr ; 
_IMMC             = VIC_IrqWasSpSp   ; 
_ILP              = VIC_IrqWasPen    ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
_IRQ              = VIC_IrqHappened  ; 
; ------------------------------------------------------------------------------------------------------------- ;
IRQMASK           = $D01A     ; IRQ Mask Register
VIC_IrqSetAll     = %11111111 ; 
VIC_IrqSetRaster  = %00000001 ; Bit 0: Raster Compare              can cause an IRQ
VIC_IrqSetSpBkgr  = %00000010 ; Bit 1: Sprite:Background collision can cause an IRQ
VIC_IrqSetSpSp    = %00000100 ; Bit 2: Sprite:Sprite     collision can cause an IRQ
VIC_IrqSetPen     = %00001000 ; Bit 3: Light Pen                   can cause an IRQ
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
                              ;                
VIC_IrqOffAll     = %11110000 ; 
VIC_IrqOffRaster  = %11111110 ; Bit 0: Raster Compare              cannot cause an IRQ
VIC_IrqOffSpBkgr  = %11111101 ; Bit 1: Sprite:Background collision cannot cause an IRQ
VIC_IrqOffSpSp    = %11111011 ; Bit 2: Sprite:Sprite     collision cannot cause an IRQ
VIC_IrqOffPen     = %11110111 ; Bit 3: Light Pen                   cannot cause an IRQ
                  ;  ###.#### ; Bit 4: <not used>
                  ;  ##.##### ; Bit 5: <not used>
                  ;  #.###### ; Bit 6: <not used>
                  ;  .####### ; Bit 7: <not used>
                  
_ERST             = VIC_IrqSetRaster ; 
_EMBC             = VIC_IrqSetSpBkgr ; 
_EMMC             = VIC_IrqSetSpSp   ; 
_ELP              = VIC_IrqSetPen    ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
SPBGPR            = $D01B     ; Sprite to Background Display Priority
VIC_Sprt0_PrioB   = %00000001 ; Bit 0: Sprite 0 display priority: 'behind'      background
VIC_Sprt1_PrioB   = %00000010 ; Bit 1: Sprite 1 display priority: 'behind'      background
VIC_Sprt2_PrioB   = %00000100 ; Bit 2: Sprite 2 display priority: 'behind'      background
VIC_Sprt3_PrioB   = %00001000 ; Bit 3: Sprite 3 display priority: 'behind'      background
VIC_Sprt4_PrioB   = %00010000 ; Bit 4: Sprite 4 display priority: 'behind'      background
VIC_Sprt5_PrioB   = %00100000 ; Bit 5: Sprite 5 display priority: 'behind'      background
VIC_Sprt6_PrioB   = %01000000 ; Bit 6: Sprite 6 display priority: 'behind'      background
VIC_Sprt7_PrioB   = %10000000 ; Bit 7: Sprite 7 display priority: 'behind'      background
                              ; 
VIC_Sprt0_PrioF   = %11111110 ; Bit 0: Sprite 0 display priority: 'in front of' background
VIC_Sprt1_PrioF   = %11111101 ; Bit 1: Sprite 1 display priority: 'in front of' background
VIC_Sprt2_PrioF   = %11111011 ; Bit 2: Sprite 2 display priority: 'in front of' background
VIC_Sprt3_PrioF   = %11110111 ; Bit 3: Sprite 3 display priority: 'in front of' background
VIC_Sprt4_PrioF   = %11101111 ; Bit 4: Sprite 4 display priority: 'in front of' background
VIC_Sprt5_PrioF   = %11011111 ; Bit 5: Sprite 5 display priority: 'in front of' background
VIC_Sprt6_PrioF   = %10111111 ; Bit 6: Sprite 6 display priority: 'in front of' background
VIC_Sprt7_PrioF   = %01111111 ; Bit 7: Sprite 7 display priority: 'in front of' background
                              ;
                              ; Each sprite has priority over all higher-number sprites
                              ;
                              ; Note: 
                              ; Creates three-dimensional effects by allowing some objects
                              ; on the screen to pass in front of or behind other objects
                              ; 
                              ; The '01' bit-pair of multicolor graphics modes is considered
                              ; to display a background color and therefore will be shown
                              ; behind sprite graphics even if the background graphics data
                              ; takes priority
                              
_M0DP             = VIC_Sprt0_PrioB ; 
_M1DP             = VIC_Sprt1_PrioB ; 
_M2DP             = VIC_Sprt2_PrioB ; 
_M3DP             = VIC_Sprt3_PrioB ; 
_M4DP             = VIC_Sprt4_PrioB ; 
_M5DP             = VIC_Sprt5_PrioB ; 
_M6DP             = VIC_Sprt6_PrioB ; 
_M7DP             = VIC_Sprt7_PrioB ; 
; ------------------------------------------------------------------------------------------------------------- ;
SPMC              = $D01C     ; Sprite Multicolor
VIC_Sprt0_MC_On   = %00000001 ; Bit 0: Sprite 0 multicolor mode on
VIC_Sprt1_MC_On   = %00000010 ; Bit 1: Sprite 1 multicolor mode on
VIC_Sprt2_MC_On   = %00000100 ; Bit 2: Sprite 2 multicolor mode on
VIC_Sprt3_MC_On   = %00001000 ; Bit 3: Sprite 3 multicolor mode on
VIC_Sprt4_MC_On   = %00010000 ; Bit 4: Sprite 4 multicolor mode on
VIC_Sprt5_MC_On   = %00100000 ; Bit 5: Sprite 5 multicolor mode on
VIC_Sprt6_MC_On   = %01000000 ; Bit 6: Sprite 6 multicolor mode on
VIC_Sprt7_MC_On   = %10000000 ; Bit 7: Sprite 7 multicolor mode on
                              ; 
VIC_Sprt0_MC_Off  = %11111110 ; Bit 0: Sprite 0 multicolor mode off
VIC_Sprt1_MC_Off  = %11111101 ; Bit 1: Sprite 1 multicolor mode off
VIC_Sprt2_MC_Off  = %11111011 ; Bit 2: Sprite 2 multicolor mode off
VIC_Sprt3_MC_Off  = %11110111 ; Bit 3: Sprite 3 multicolor mode off
VIC_Sprt4_MC_Off  = %11101111 ; Bit 4: Sprite 4 multicolor mode off
VIC_Sprt5_MC_Off  = %11011111 ; Bit 5: Sprite 5 multicolor mode off
VIC_Sprt6_MC_Off  = %10111111 ; Bit 6: Sprite 6 multicolor mode off
VIC_Sprt7_MC_Off  = %01111111 ; Bit 7: Sprite 7 multicolor mode off

VIC_Sprts_MC_On   = %11111111 ; All Sprites multicolor mode on
VIC_Sprts_MC_Off  = %00000000 ; All Sprites multicolor mode off
                              ;
                              ; The bits of sprite shape data are grouped together in pairs
                              ; and display dot colors from the following sources:
                              ;
                              ;   00=Background Color Register 0  (transparent)
                              ;   01=Sprite Multicolor Register 0 ($D025)
                              ;   10=Sprite Color Registers       ($D027-$D02E)
                              ;   11=Sprite Multicolor Register 1 ($D026)
                              
_M0MC             = VIC_Sprt0_MC_On ; 
_M1MC             = VIC_Sprt1_MC_On ; 
_M2MC             = VIC_Sprt2_MC_On ; 
_M3MC             = VIC_Sprt3_MC_On ; 
_M4MC             = VIC_Sprt4_MC_On ; 
_M5MC             = VIC_Sprt5_MC_On ; 
_M6MC             = VIC_Sprt6_MC_On ; 
_M7MC             = VIC_Sprt7_MC_On ; 
; ------------------------------------------------------------------------------------------------------------- ;
XXPAND            = $D01D     ; Sprite Scale Double Width
VIC_Sprt0_XX_On   = %00000001 ; Bit 0: Sprite 0 double width
VIC_Sprt1_XX_On   = %00000010 ; Bit 1: Sprite 1 double width
VIC_Sprt2_XX_On   = %00000100 ; Bit 2: Sprite 2 double width
VIC_Sprt3_XX_On   = %00001000 ; Bit 3: Sprite 3 double width
VIC_Sprt4_XX_On   = %00010000 ; Bit 4: Sprite 4 double width
VIC_Sprt5_XX_On   = %00100000 ; Bit 5: Sprite 5 double width
VIC_Sprt6_XX_On   = %01000000 ; Bit 6: Sprite 6 double width
VIC_Sprt7_XX_On   = %10000000 ; Bit 7: Sprite 7 double width
                              ; 
VIC_Sprt0_XX_Off  = %11111110 ; Bit 0: Sprite 0 normal width
VIC_Sprt1_XX_Off  = %11111101 ; Bit 1: Sprite 1 normal width
VIC_Sprt2_XX_Off  = %11111011 ; Bit 2: Sprite 2 normal width
VIC_Sprt3_XX_Off  = %11110111 ; Bit 3: Sprite 3 normal width
VIC_Sprt4_XX_Off  = %11101111 ; Bit 4: Sprite 4 normal width
VIC_Sprt5_XX_Off  = %11011111 ; Bit 5: Sprite 5 normal width
VIC_Sprt6_XX_Off  = %10111111 ; Bit 6: Sprite 6 normal width
VIC_Sprt7_XX_Off  = %01111111 ; Bit 7: Sprite 7 normal width

VIC_Sprts_XX_On   = %11111111 ; All Sprites double width
VIC_Sprts_XX_Off  = %00000000 ; All Sprites normal width

_M0XE             = VIC_Sprt0_XX_On ; 
_M1XE             = VIC_Sprt1_XX_On ; 
_M2XE             = VIC_Sprt2_XX_On ; 
_M3XE             = VIC_Sprt3_XX_On ; 
_M4XE             = VIC_Sprt4_XX_On ; 
_M5XE             = VIC_Sprt5_XX_On ; 
_M6XE             = VIC_Sprt6_XX_On ; 
_M7XE             = VIC_Sprt7_XX_On ; 
; ------------------------------------------------------------------------------------------------------------- ;
SPSPCL            = $D01E     ; Sprite to Sprite Collision - Cleared on read
VIC_Sprt0_CollS   = %00000001 ; Bit 0: Sprite 0 collided with another sprite? (1=yes)
VIC_Sprt1_CollS   = %00000010 ; Bit 1: Sprite 1 collided with another sprite? (1=yes)
VIC_Sprt2_CollS   = %00000100 ; Bit 2: Sprite 2 collided with another sprite? (1=yes)
VIC_Sprt3_CollS   = %00001000 ; Bit 3: Sprite 3 collided with another sprite? (1=yes)
VIC_Sprt4_CollS   = %00010000 ; Bit 4: Sprite 4 collided with another sprite? (1=yes)
VIC_Sprt5_CollS   = %00100000 ; Bit 5: Sprite 5 collided with another sprite? (1=yes)
VIC_Sprt6_CollS   = %01000000 ; Bit 6: Sprite 6 collided with another sprite? (1=yes)
VIC_Sprt7_CollS   = %10000000 ; Bit 7: Sprite 7 collided with another sprite? (1=yes)

_M0M              = VIC_Sprt0_CollS ; 
_M1M              = VIC_Sprt1_CollS ; 
_M2M              = VIC_Sprt2_CollS ; 
_M3M              = VIC_Sprt3_CollS ; 
_M4M              = VIC_Sprt4_CollS ; 
_M5M              = VIC_Sprt5_CollS ; 
_M6M              = VIC_Sprt6_CollS ; 
_M7M              = VIC_Sprt7_CollS ; 
; ------------------------------------------------------------------------------------------------------------- ;
SPBGCL            = $D01F     ; Sprite to Background Collision - Cleared on read
VIC_Sprt0_CollB   = %00000001 ; Bit 0: Sprite 0 collided with background (1=yes)
VIC_Sprt1_CollB   = %00000010 ; Bit 1: Sprite 1 collided with background (1=yes)
VIC_Sprt2_CollB   = %00000100 ; Bit 2: Sprite 2 collided with background (1=yes)
VIC_Sprt3_CollB   = %00001000 ; Bit 3: Sprite 3 collided with background (1=yes)
VIC_Sprt4_CollB   = %00010000 ; Bit 4: Sprite 4 collided with background (1=yes)
VIC_Sprt5_CollB   = %00100000 ; Bit 5: Sprite 5 collided with background (1=yes)
VIC_Sprt6_CollB   = %01000000 ; Bit 6: Sprite 6 collided with background (1=yes)
VIC_Sprt7_CollB   = %10000000 ; Bit 7: Sprite 7 collided with background (1=yes)

_M0D              = VIC_Sprt0_CollB ; 
_M1D              = VIC_Sprt1_CollB ; 
_M2D              = VIC_Sprt2_CollB ; 
_M3D              = VIC_Sprt3_CollB ; 
_M4D              = VIC_Sprt4_CollB ; 
_M5D              = VIC_Sprt5_CollB ; 
_M6D              = VIC_Sprt6_CollB ; 
_M7D              = VIC_Sprt7_CollB ; 
; ------------------------------------------------------------------------------------------------------------- ;
; Color Registers             ; $D020-$D02E
                              ; Only the lower 4 bits are connected
                              ; The upper 4 bits must be masked out
; ------------------------------------------------------------------------------------------------------------- ;
EXTCOL            = $D020     ; Border Color
                  
_EC               = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
BGCOL0            = $D021     ; Background Color 0 (all text modes, sprite graphics, and multicolor bitmap graphics)
                  
_B0C              = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
BGCOL1            = $D022     ; Background Color 1
                              ;   Color for the 01 bit-pair of the Extended Colour Mode
                              ;   Background color for characters having screen codes 64-127
                              ;     in extended background color text mode (default: 1=white)
                  
_B1C              = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
BGCOL2            = $D023     ; Background Color 2
                              ;   Color for the 10 bit-pair of the Extended Colour Mode
                              ;   Background color for characters having screen codes 128-191
                              ;     in extended background color text mode (default: 2=red)
                  
_B2C              = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
BGCOL3            = $D024     ; Background Color 3
                              ;   Background color for characters having screen codes 192-255
                              ;     in extended background color text mode (default: 3=cyan)
                  
_B3C              = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
SPMC0             = $D025     ; Sprite Multicolor Register 0
                              ;   Color displayed by the 01 bit-pair (default: 4=purple)
                  
_MM0              = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
SPMC1             = $D026     ; Sprite Multicolor Register 1
                              ;   Color displayed by the 11 bit-pair (default: 0=black)
                  
_MM1              = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
SP0COL            = $D027     ; Color Sprite 0
                              ;   Color displayed by data bits=1 or the multicolor 10 bit-pair (default: 1=white)
                  
_M0C              = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
SP1COL            = $D028     ; Color Sprite 1
                              ;   Color displayed by data bits=1 or the multicolor 10 bit-pair (default: 2=red)
_M1C              = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
SP2COL            = $D029     ; Color Sprite 2
                              ;   Color displayed by data bits=1 or the multicolor 10 bit-pair (default: 3=cyan)
_M2C              = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
SP3COL            = $D02A     ; Color Sprite 3
                              ;   Color displayed by data bits=1 or the multicolor 10 bit-pair (default: 4=purple)
_M3C              = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
SP4COL            = $D02B     ; Color Sprite 4
                              ;   Color displayed by data bits=1 or the multicolor 10 bit-pair (default: 5=green)
_M4C              = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
SP5COL            = $D02C     ; Color Sprite 5
                              ;   Color displayed by data bits=1 or the multicolor 10 bit-pair (default: 6=blue)
_M5C              = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
SP6COL            = $D02D     ; Color Sprite 6
                              ;   Color displayed by data bits=1 or the multicolor 10 bit-pair (default: 7=yellow)
_M6C              = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
SP7COL            = $D02E     ; Color Sprite 7
                              ;   Color displayed by data bits=1 or the multicolor 10 bit-pair (default: 12=medium grey)
_M7C              = %00001111 ; 
                  ;  ...#.... ; Bit 4: <not used>
                  ;  ..#..... ; Bit 5: <not used>
                  ;  .#...... ; Bit 6: <not used>
                  ;  #....... ; Bit 7: <not used>
; ------------------------------------------------------------------------------------------------------------- ;
; $D02F-$D03F                 ; Not Connected - always $ff when read even after writes
; ------------------------------------------------------------------------------------------------------------- ;
; $D040-$D3FF                 ; VIC-II Register Images - Mirrors of $D000-$D03F
; ------------------------------------------------------------------------------------------------------------- ;
