; -------------------------------------------------------------------------------------------------------------- ;
; Standard Zeropage / Stack / Vectors
; -------------------------------------------------------------------------------------------------------------- ;
             ifnconst D6510 ; 
D6510         =   $00   ;          6510 On-chip Data Direction Register
             endif      ; 
             ifnconst R6510 ; 
R6510         =   $01   ;          6510 On-chip 8-bit Input/Output Register
             endif      ; 
; -------------------------------------------------------------------------------------------------------------- ;
Unused        set $02   ;          Unused
                        ; 
ADRAY1        =   $03   ; - $04    Vector: Convert FAC to Integer in (A/Y) ($B1AA)
ADRAY2        =   $05   ; - $06    Vector: Convert Integer in (A/Y) to FAC ($B391)
CHARAC        =   $07   ;          Search char for scanning basic text input/temp integer during INT
ENDCHR        =   $08   ;          Flag: scan for Quote at end of String
INTEGR        =   $07   ; - $08    Temporary integer during OR/AND
TRMPOS        =   $09   ;          Cursor column pos before the last TAB or SPC
VERCK         =   $0a   ;          Flag: BASIC - Type of load
VERCK_Load        = $00 ;                Load
VERCK_Verify      = $01 ;                Verify
COUNT         =   $0b   ;          Index into the text input buffer/Number of array subscripts
DIMFLG        =   $0c   ;          Flag: default Array dimension
VALTYP        =   $0d   ;          Flag: type of data
VALTYP_Num        = $00 ;                Numeric
VALTYP_Str        = $ff ;                String
INTFLG        =   $0e   ;          Flag: type of numeric data
INTFLG_Flt        = $00 ;                Floating point
INTFLG_Int        = $80 ;                Integer
GARBFL        =   $0f   ;          Flag: LIST quoted string/text line tokenization/garbage collection already tried
SUBFLG        =   $10   ;          Flag: subscript reference/user function call used by PTRGET routine
INPFLG        =   $11   ;          Flag: Data to get from keyword
INPFLG_Input      = $00 ;                INPUT
INPFLG_Get        = $40 ;                GET
INPFLG_Read       = $98 ;                READ
TANSGN        =   $12   ;          Flag: TAN sign/SIN sign/comparative result
CHANNL        =   $13   ;          File number of current I/O channel ($00 if default keyboard/screen)
LINNUM        =   $14   ; - $15    Temp: Integer line number value for GOTO/LIST/ON/GOSUB
TEMPPT        =   $16   ;          Pointer: address next available space in the temporary string stack
LASTPT        =   $17   ; - $18    Pointer: address last string in the temporary string stack
TEMPST        =   $19   ; - $21    descriptor stack for temporary strings
INDEX         =   $22   ; - $25    Utility Pointer Area
INDEX1        =   $22   ; - $23    First  Utility Pointer
INDEX2        =   $24   ; - $25    Second Utility Pointer
RESHO         =   $26   ; - $2A    Floating point product of Multiply and Divide
TXTTAB        =   $2b   ; - $2C    Pointer: Start of BASIC Text Area ($0801)
VARTAB        =   $2d   ; - $2E    Pointer: Start of BASIC Variables
ARYTAB        =   $2f   ; - $30    Pointer: Start of BASIC Arrays
STREND        =   $31   ; - $32    Pointer: End of BASIC Arrays + 1
FRETOP        =   $33   ; - $34    Pointer: Bottom of String space
FRESPC        =   $35   ; - $36    Pointer: Utility String
MEMSIZ        =   $37   ; - $38    Pointer: Highest Address available to BASIC ($A000)
CURLIN        =   $39   ; - $3A    Current BASIC Line number
OLDLIN        =   $3b   ; - $3C    Previous BASIC Line number
OLDTXT        =   $3d   ; - $3E    Pointer: BASIC Statement for CONT
DATLIN        =   $3f   ; - $40    Current DATA Line number
DATPTR        =   $41   ; - $42    Pointer: Used by READ - current DATA Item Address
INPPTR        =   $43   ; - $44    Pointer: Temporary storage of Pointer during INPUT Routine
VARNAM        =   $45   ; - $46    Name of Variable being sought in Variable Table
VARPNT        =   $47   ; - $48    Pointer: to value of (VARNAM) if Integer, to descriptor if String
FORPNT        =   $49   ; - $4A    Pointer: Index Variable for FOR/NEXT loop
VARTXT        =   $4b   ; - $4C    Temporary storage for TXTPTR during READ, INPUT and GET
OPMASK        =   $4d   ;          Mask used during FRMEVL
TEMPF3        =   $4e   ; - $52    Temporary storage for FLPT value
FOUR6         =   $53   ;          Length of String Variable during Garbage collection
JMPER         =   $54   ; - $56    Jump Vector used in Function Evaluation - JMP + Address ($4C lo hi)
TEMPF1        =   $57   ; - $5B    Temporary storage for FLPT value
TEMPF2        =   $5c   ; - $60    Temporary storage for FLPT value
FAC           =   $61   ; - $66    Main Floating point Accumulator
FACEXP        =   $61   ;          FAC #1: Exponent
FACHO         =   $62   ; - $65    FAC #1: Mantissa
FACSGN        =   $66   ;          FAC #1: Sign
SGNFLG        =   $67   ;          Pointer: Series Evaluation Constant
BITS          =   $68   ;          FAC #1: Bit Overflow Area during normalisation Routine
AFAC          =   $69   ; - $6E    Auxiliary Floating point Accumulator
ARGEXP        =   $69   ;          FAC #2: Exponent
ARGHO         =   $6a   ; - $6D    FAC #2: Mantissa
ARGSGN        =   $6e   ;          FAC #2: Sign
ARISGN        =   $6f   ;          Sign Comparison Result: FAC #1 vs FAC #2
FACOV         =   $70   ;          FAC #1: Low-order rounding
FBUFPT        =   $71   ; - $72    Pointer: Cassette Buffer
CHRGET        =   $73   ; - $8A    Subroutine: Get next Byte of BASIC Text
CHRGOT        =   $79   ;          Entry to Get same Byte again
TXTPTR        =   $7a   ; - $7B    Pointer: Current Byte of BASIC Text
RNDX          =   $8b   ; - $8F    Floating RND Function Seed Value
STATUS        =   $90   ;          Kernal: I/O Status Word (ST)
STKEY         =   $91   ;          Flag: STOP key pressed
STKEY_Hit         = $7f ;                STOP key
SVXT          =   $92   ;          Timing Constant for Tape
VERCKK        =   $93   ;          Flag: KERNEL - Type of load
VERCKK_Load       = $00 ;                Load
VERCKK_Verify     = $01 ;                Verify
C3PO          =   $94   ;          Flag: Serial Bus - Output char buffered
BSOUR         =   $95   ;          Buffered char for serial bus
SYNO          =   $96   ;          Cassette sync number
TEMPX         =   $97   ;          Temp storage of X Register during CHRIN
TEMPY         =   $97   ;          Temp storage of Y Register during RS232 fetch
LDTND         =   $98   ;          Number of open files / Index to file table
DFLTN         =   $99   ;          Default Input  Device ($00=keyboard)
DFLTO         =   $9a   ;          Default Output Device ($03=screen)
PRTY          =   $9b   ;          Parity of byte output to tape
DPSW          =   $9c   ;          Flag: Byte received from Tape
MSGFLG        =   $9d   ;          Flag: Type of error messages
MSGFLG_Off        = $00 ;                Program mode: Suppress Error Messages
MSGFLG_Kern       = $40 ;                Kernal Error Messages only
MSGFLG_Full       = $80 ;                Direct mode: Full Error Messages
FNMIDX        =   $9e   ;          Index to Cassette File name/Header ID for Tape write
PTR1          =   $9e   ;          Tape error log pass 1
PTR2          =   $9f   ;          Tape error log pass 2
TIME          =   $a0   ; - $A2    Real-time jiffy Clock updated 1/60 sec by IRQ in UDTIMK ($F69B)
TSFCNT        =   $a3   ;          Bit counter tape READ or WRITE / Flag: Serial bus EOI 
TBTCNT        =   $a4   ;          Pulse counter tape READ or WRITE / Serial bus shift counter
CNTDN         =   $a5   ;          Tape: Sync count down
BUFPNT        =   $a6   ;          Pointer: Tape I/O buffer
INBIT         =   $a7   ;          RS232: Temp for received bit / Tape: Temp
BITC1         =   $a8   ;          RS232: Input bit count       / Tape: Temp
RINONE        =   $a9   ;          RS232: Flag: Start bit check / Tape: Temp
RIDATA        =   $aa   ;          RS232: Input byte buffer     / Tape: Temp
RIPRTY        =   $ab   ;          RS232: Input parity          / Tape: Temp
SAL           =   $ac   ; - $AD    Pointer: Tape buffer / Screen scrolling
EAL           =   $ae   ; - $AF    Tape: End address / End of program
CMPO          =   $b0   ; - $B1    Tape: Timing constants
TAPE1         =   $b2   ; - $B3    Pointer: Start address tape buffer ($033C)
BITTS         =   $b4   ;          RS232: Write bit count    / Tape: Read - Timing Flag
NXTBIT        =   $b5   ;          RS232: Next Bit to send   / Tape: Read - End of Tape
RODATA        =   $b6   ;          RS232: Output Byte Buffer / Tape: Read - Error Flag
FNLEN         =   $b7   ;          Current File: Name length
LA            =   $b8   ;          Current File: Logical file number
SA            =   $b9   ;          Current File: Secondary address
FA            =   $ba   ;          Current File: First address (Device number)- OPEN LA,FA,SA = OPEN 1,8,15,"I0":CLOSE 1
FNADR         =   $bb   ; - $BC    Current File: Address of file name
ROPRTY        =   $bd   ;          RS232: Output parity / Tape: Byte to be READ or WRITE
FSBLK         =   $be   ;          Tape: READ or WRITE Block Count
MYCH          =   $bf   ;          Serial word buffer
CAS1          =   $c0   ;          Tape motor switch
STAL          =   $c1   ; - $C2    Start address for LOAD and cassette WRITE
MEMUSS        =   $c3   ; - $C4    Pointer: Type 3 tape LOAD and general use
LSTX          =   $c5   ;          Matrix value of last key pressed (NoKey = $40)
NDX           =   $c6   ;          Number of chars in keyboard buffer queue
RVS           =   $c7   ;          Flag: Reverse mode
RVS_Off           = $00 ;                Reverse Off 
RVS_On            = $01 ;                Reverse On                 
INDX          =   $c8   ;          Pointer: End of logical line for INPUT (to suppress trailing spaces)
LXSP          =   $c9   ; - $CA    Cursor X/Y (Line/Column) pos at start of INPUT
SFDX          =   $cb   ;          Flag: Print shifted chars
BLNSW         =   $cc   ;          Flag: Cursor blink 
BLNSW_Enab        = $00 ;                Enabled
BLNSW_Disab       = $01 ;                Disabled
BLNCT         =   $cd   ;          Timer: Count down for Cursor blink toggle
GDBLN         =   $ce   ;          Char under Cursor while cursor is inverted
BLNON         =   $cf   ;          Flag: Cursor status
BLNON_Off         = $00 ;                Off
BLNON_On          = $01 ;                On
CRSW          =   $d0   ;          Flag: Input Origin
CRSW_Srcn         = $03 ;                Input from screen  
CRSW_Keyb         = $00 ;                Input from keyboard
PNT           =   $d1   ; - $D2    Pointer: Current screen line address
PNTR          =   $d3   ;          Cursor column on current line (including wrap-around line - if any)
QTSW          =   $d4   ;          Flag: Editor mode
QTSW_Off          = $00 ;                Editor NOT in quote mode
QTSW_On           = $01 ;                Editor     in quote mode
LNMX          =   $d5   ;          Current logical line length (39 or 79)
TBLX          =   $d6   ;          Current cursor screen line number
SCHAR         =   $d7   ;          Screen value of current input character / last character output
INSRT         =   $d8   ;          Count: >0 = Number of outstanding insertions
LDTB1         =   $d9   ; - $F2    Screen line link table / Editor temp high byte of line screen memory location
USER          =   $f3   ; - $F4    Pointer: Current screen colour RAM location
KEYTAB        =   $f5   ; - $F6    Vector: Current keyboard decoding table ($EB81)
RIBUF         =   $f7   ; - $F8    RS232: Pointer Input  Buffer
ROBUF         =   $f9   ; - $FA    RS232: Pointer Output Buffer
FREKZP        =   $fb   ; - $FE    Free Zero Page space for User Programs
BASZPT        =   $ff   ;          BASIC temp data area
; -------------------------------------------------------------------------------------------------------------- ;
; Stacks
; -------------------------------------------------------------------------------------------------------------- ;
ASCWRK        = $00ff   ; - $010A  Assembly Area for Floating point to ASCII conversion
BAD           = $0100   ; - $013E  Tape Input Error log
             ifnconst STACK ; 
STACK         = $0100   ; - $01FF  6510 Hardware Stack Area
             endif      ; 
BSTACK        = $013f   ; - $01FF  BASIC Stack Area
; -------------------------------------------------------------------------------------------------------------- ;
; Misc
; -------------------------------------------------------------------------------------------------------------- ;
BUF           = $0200   ; - $0258  BASIC Input Buffer (Input Line from Screen)
LAT           = $0259   ; - $0262  Kernal Table: Active logical File numbers
FAT           = $0263   ; - $026C  Kernal Table: Active File First Addresses (Device numbers)
SAT           = $026d   ; - $0276  Kernal Table: Active File Secondary Addresses
KEYD          = $0277   ; - $0280  Keyboard Buffer Queue (FIFO)
MEMSTR        = $0281   ; - $0282  Pointer: Bottom of Memory for Operating System ($0800)
MEMEND        = $0283   ; - $0284  Pointer: Top of Memory for Operating System    ($A000)
TIMOUT        = $0285   ;          Serial IEEE Bus timeout defeat Flag
COLOR         = $0286   ;          Current Character Colour code
GDCOL         = $0287   ;          Background Colour under Cursor
HIBASE        = $0288   ;          High Byte of Screen Memory Address ($04)
XMAX          = $0289   ;          Maximum number of Bytes in Keyboard Buffer ($0A)
RPTFLG        = $028a   ;          Flag: Repeat keys
RPTFLG_Pgm      = $00   ;                Cursors, INST/DEL & Space repeat
RPTFLG_Off      = $40   ;                No Keys repeat
RPTFLG_All      = $80   ;                All Keys repeat ($00)
KOUNT         = $028b   ;          Repeat Key: Speed Counter ($04)
DELAY         = $028c   ;          Repeat Key: First repeat delay Counter ($10)
SHFLAG        = $028d   ;          Flag: Shift Keys: $00 = None
SHFLAG_Shift    = %00000001 ;                Bit 0 = Shift
SHFLAG_CBM      = %00000010 ;                Bit 1 = CBM
SHFLAG_Ctrl     = %00000100 ;                Bit 2 = CTRL
LSTSHF        = $028e   ;          Last Shift Key used for debouncing
KEYLOG        = $028f   ; - $0290  Vector: Routine to determine Keyboard table to use based on Shift Key Pattern ($EB48)
MODE          = $0291   ;          Flag: Upper/Lower Case change: $00 = Disabled, $80 = Enabled ($00)
AUTODN        = $0292   ;          Flag: Auto scroll down: $00 = Disabled ($00)
M51CTR        = $0293   ;          RS232 Pseudo 6551 control Register Image
M51CDR        = $0294   ;          RS232 Pseudo 6551 command Register Image
M51AJB        = $0295   ; - $0296  RS232 Non-standard Bits/Second
RSSTAT        = $0297   ;          RS232 Pseudo 6551 Status Register Image
BITNUM        = $0298   ;          RS232 Number of Bits left to send
BAUDOF        = $0299   ; - $029A  RS232 Baud Rate; Full Bit time microseconds
RIDBE         = $029b   ;          RS232 Index to End of Input Buffer
RIDBS         = $029c   ;          RS232 Pointer: High Byte of Address of Input Buffer
RODBS         = $029d   ;          RS232 Pointer: High Byte of Address of Output Buffer
RODBE         = $029e   ;          RS232 Index to End of Output Buffer
IRQTMP        = $029f   ; - $02A0  Temporary store for IRQ Vector during Tape operations
ENABL         = $02a1   ;          RS232 Enables
TODSNS        = $02a2   ;          TOD sense during Tape I/O
TRDTMP        = $02a3   ;          Temporary storage during Tape READ
TD1IRQ        = $02a4   ;          Temporary D1IRQ Indicator during Tape READ
TLNIDX        = $02a5   ;          Temporary for Line Index
TVSFLG        = $02a6   ;          Flag: TV Standard:
TVSFLG_NTSC     = $00   ;                NTSC
TVSFLG_PAL      = $01   ;                PAL
                        ; 
Unused      set $02a7   ; - $02FF  Unused
                        ; 
SPR11         = $02c0   ; - $02FE  Sprite #11 Data Area. (SCREEN + $03F8 + SPR number)
                        ; 
IERROR        = $0300   ; - $0301  Vector: Indirect entry to BASIC Error Message, (X) points to Message ($E38B)
IMAIN         = $0302   ; - $0303  Vector: Indirect entry to BASIC Input Line and Decode      ($A483)
ICRNCH        = $0304   ; - $0305  Vector: Indirect entry to BASIC Tokenise Routine           ($A57C)
IQPLOP        = $0306   ; - $0307  Vector: Indirect entry to BASIC LIST Routine               ($A71A)
IGONE         = $0308   ; - $0309  Vector: Indirect entry to BASIC Character dispatch Routine ($A7E4)
IEVAL         = $030a   ; - $030B  Vector: Indirect entry to BASIC Token evaluation           ($AE86)
SAREG         = $030c   ;          Storage for 6510 Accumulator during SYS
SXREG         = $030d   ;          Storage for 6510 X-Register during SYS
SYREG         = $030e   ;          Storage for 6510 Y-Register during SYS
SPREG         = $030f   ;          Storage for 6510 Status Register during SYS
USRPOK        = $0310   ;          USR Function JMP Instruction ($4C)
USRADD        = $0311   ; - $0312  USR Address ($LB,$MB)
                                  ; 
Unused      set $0313   ;          Unused
; -------------------------------------------------------------------------------------------------------------- ;
; Kernel Indirect Vectors
; -------------------------------------------------------------------------------------------------------------- ;
CINV          = $0314   ;          Vector: Hardware IRQ Interrupt Address
CINV_Lo         = $0314 ; 
CINV_Hi         = $0315 ; 
CINV_Ini        = $ea31 ; 
; -------------------------------------------------------------------------------------------- ;
CNBINV        = $0316   ;          Vector: BRK Instruction Interrupt Address
CNBINV_Lo       = $0316 ; 
CNBINV_Hi       = $0317 ; 
CNBINV_Ini      = $fe66 ; 
; -------------------------------------------------------------------------------------------- ;
NMINV         = $0318   ;          Vector: Hardware NMI Interrupt Address
NMINV_Lo        = $0318 ; 
NMINV_Hi        = $0319 ; 
NMINV_Ini       = $fe47 ; 
; ---------------------------------------------------------------------------------- ;
IOPEN         = $031a   ;          Vector: Indirect entry to Kernal OPEN   Routine
IOPEN_Lo        = $031a ; 
IOPEN_Hi        = $031b ; 
IOPEN_Ini       = $f34a ; 
; ---------------------------------------------------------------------------------- ;
ICLOSE        = $031c   ;          Vector: Indirect entry to Kernal CLOSE  Routine
ICLOSE_Lo       = $031c ; 
ICLOSE_Hi       = $031d ; 
ICLOSE_Ini      = $f291 ; 
; ---------------------------------------------------------------------------------- ;
ICHKIN        = $031e   ;          Vector: Indirect entry to Kernal CHKIN  Routine
ICHKIN_Lo       = $031e ; 
ICHKIN_Hi       = $031f ; 
ICHKIN_Ini      = $f20e ; 
; ---------------------------------------------------------------------------------- ;
ICKOUT        = $0320   ;          Vector: Indirect entry to Kernal CHKOUT Routine
ICKOUT_Lo       = $0320 ; 
ICKOUT_Hi       = $0321 ; 
ICKOUT_Ini      = $f250 ; 
; ---------------------------------------------------------------------------------- ;
ICLRCH        = $0322   ;          Vector: Indirect entry to Kernal CLRCHN Routine
ICLRCH_Lo       = $0322 ; 
ICLRCH_Hi       = $0323 ; 
ICLRCH_Ini      = $f333 ; 
; ---------------------------------------------------------------------------------- ;
IBASIN        = $0324   ;          Vector: Indirect entry to Kernal CHRIN  Routine
IBASIN_Lo       = $0324 ; 
IBASIN_Hi       = $0325 ; 
IBASIN_Ini      = $f157 ; 
; ---------------------------------------------------------------------------------- ;
IBSOUT        = $0326   ;          Vector: Indirect entry to Kernal CHROUT Routine
IBSOUT_Lo       = $0326 ; 
IBSOUT_Hi       = $0327 ; 
IBSOUT_Ini      = $f1ca ; 
; ---------------------------------------------------------------------------------- ;
ISTOP         = $0328   ;          Vector: Indirect entry to Kernal STOP   Routine
ISTOP_Lo        = $0328 ; 
ISTOP_Hi        = $0329 ; 
ISTOP_Ini       = $f6ed ; 
; ---------------------------------------------------------------------------------- ;
IGETIN        = $032a   ;          Vector: Indirect entry to Kernal GETIN  Routine
IGETIN_Lo       = $032a ; 
IGETIN_Hi       = $032b ; 
IGETIN_Ini      = $f13e ; 
; ---------------------------------------------------------------------------------- ;
ICLALL        = $032c   ;          Vector: Indirect entry to Kernal CLALL  Routine
ICLALL_Lo       = $032c ; 
ICLALL_Hi       = $032d ; 
ICLALL_Ini      = $f32f ; 
; ---------------------------------------------------------------------------------- ;
USRCMD        = $032e   ;          User Defined Vector
USRCMD_Lo       = $032e ; 
USRCMD_Hi       = $032f ; 
USRCMD_Ini      = $fe66 ; 
; ---------------------------------------------------------------------------------- ;
ILOAD         = $0330   ;          Vector: Indirect entry to Kernal LOAD   Routine
ILOAD_Lo        = $0330 ; 
ILOAD_Hi        = $0331 ; 
ILOAD_Ini       = $f4a5 ; 
; ---------------------------------------------------------------------------------- ;
ISAVE         = $0332   ;          Vector: Indirect entry to Kernal SAVE   Routine
ISAVE_Lo        = $0332 ; 
ISAVE_Hi        = $0333 ; 
ISAVE_Ini       = $f5ed ; 
; -------------------------------------------------------------------------------------------- ;
Unused      set $0334   ; - $033B  Unused
                                  ; 
TBUFFR        = $033c   ; - $03FB  Tape I/O Buffer
SPR13         = $0340   ; - $037E  Sprite #13
SPR14         = $0380   ; - $03BE  Sprite #14
SPR15         = $03c0   ; - $03FE  Sprite #15
                                  
Unused      set $03fc   ; - $03FF  Unused
; -------------------------------------------------------------------------------------------- ;
VICSCN        = $0400   ; - $07E7  Default: Screen Video Matrix
Unused      set $07e8   ; - $07F7  Unused
SPNTRS        = $07f8   ; - $07FF  Default: Sprite Data Pointers
; -------------------------------------------------------------------------------------------------------------- ;
