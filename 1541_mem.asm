; -------------------------------------------------------------------------------------------------------------- ;
;  1541 - Original ROM V3
; -------------------------------------------------------------------------------------------------------------- ;
JOBSTCC           = $00       ; Interface Main Program - Disc Controller
                              ;   main program writes the job command codes into the appropriate job cmd memory area
                              ;   bit7 set    - job will be executed with the next interrupt
                              ;   bit7 clear  - bit0-bit6 contain the jobs status code
                              ; 
                              ; Table: Addresses and the assigned buffers:
                              ; 
                              ; JOB TRACK SECTOR  BUFFER
                              ; $00  $06    $07   $0300-$03ff
                              ; $01  $08    $09   $0400-$04ff
                              ; $02  $0a    $0b   $0500-$05ff
                              ; $03  $0c    $0d   $0600-$06ff
                              ; $04  $0e    $0f   $0700-$07ff
                              ; $05  $10    $11   -no ram-
                              ; 
JOBSTCC_ID_Mask   = %10000000 ; Bit  7  : 1 = job code / 0 = error code
JOBCC_Mask        = %11110000 ; Bits 4-7: command code
JOBCC_READ          = $80     ; %10000000 - Read   a sector
JOBCC_WRITE         = $90     ; %10010000 - Write  a sector
JOBCC_VERIFY        = $a0     ; %10100000 - Verify a sector
JOBCC_SEEK          = $b0     ; %10110000 - Find   a sector
JOBCC_BUMP          = $c0     ; %11000000 - Bump head - find track 01
JOBCC_JUMP          = $d0     ; %11010000 - Execute program in buffer
JOBCC_EXECUTE       = $e0     ; %11100000 - Execute program - first switch drive on and find track
JOBST_Mask        = %00001111 ; Bits 0-3: error code
JOBST_OK            = $01     ; %00000001 - Everything OK                   00, OK
JOBST_MISHDR_ER     = $02     ; %00000010 - Header block not found          20, READ ERROR
JOBST_NOSYNC_ER     = $03     ; %00000011 - SYNC not found                  21, READ ERROR
JOBST_NODATA_ER     = $04     ; %00000100 - Data block not found            22, READ ERROR
JOBST_CRCDATA_ER    = $05     ; %00000101 - Checksum error in data block    23, READ ERROR
JOBST_FMT_ER        = $06     ; %00000110 - Format error                    24, READ ERROR        - not used on the 1541
JOBST_VERERR_ER     = $07     ; %00000111 - Verify error                    25, WRITE ERROR
JOBST_WRTPROT_ER    = $08     ; %00001000 - Disk write protected            26, WRITE PROTECT ON
JOBST_CRCHDR_ER     = $09     ; %00001001 - Checksum error in header block  27, READ ERROR
JOBST_LONGDATA_ER   = $0a     ; %00001100 - Data block too long             28, READ ERROR
JOBST_DSKCHG_ER     = $0b     ; %00001011 - Id mismatch                     29, DISK ID MISMATCH
JOBST_NODISC_ER     = $0f     ; %00001111 - Disk not inserted               74, DRIVE NOT READY
JOBSTCC0          = $00       ; buffer #0 - command and status registers
JOBSTCC1          = $01       ; buffer #1 - command and status registers
JOBSTCC2          = $02       ; buffer #2 - command and status registers
JOBSTCC3          = $03       ; buffer #3 - command and status registers
JOBSTCC4          = $04       ; buffer #4 - command and status registers
JOBSTCC5          = $05       ; buffer #5 - command and status registers - unused - buffer #5 not existing

TRASEC            = $06       ; track/sector area for jobs
JOB0TRA           = $06       ; buffer #0 - track
JOB0SEC           = $07       ; buffer #0 - sector
JOB1TRA           = $08       ; buffer #1 - track
JOB1SEC           = $09       ; buffer #1 - sector
JOB2TRA           = $0a       ; buffer #2 - track
JOB2SEC           = $0b       ; buffer #2 - sector
JOB3TRA           = $0c       ; buffer #3 - track
JOB3SEC           = $0d       ; buffer #3 - sector
JOB4TRA           = $0e       ; buffer #4 - track
JOB4SEC           = $0f       ; buffer #4 - sector
JOB5TRA           = $10       ; buffer #5 - track  - unused - buffer #5 not existing
JOB5SEC           = $11       ; buffer #5 - sector - unused - buffer #5 not existing

DISKID            = $12       ; drive #0 - expected sector header ID
DISKID_CHR1       = $12       ; 
DISKID_CHR2       = $13       ; 
DISKID1           = $14       ; drive #1 - expected sector header ID - unused
DISKID1_CHR1      = $14       ; 
DISKID1_CHR2      = $15       ; 

HDRID             = $16       ; header ID from header of sector last read from disk
HDRID_CHR1        = $16       ; first  ID character
HDRID_CHR2        = $17       ; second ID character
HDRTRK            = $18       ; header block id     - track  number from header of sector last read from disk
HDRSEC            = $19       ; header block sector - sector number from header of sector last read from disk
HDRCHK            = $1a       ; header block parity - checksum from header of sector last read from disk

unused_1B         = $1b       ; free - not used

WPSW              = $1c       ; flag: drive #0 - disk change indicator
WPSW_Flag         = %00000001 ; 
WPSW_SAME           = $00     ; disk has not changed
WPSW_DIFF           = $01     ; disk has changed
WPSW1             = $1d       ; flag: drive #1 - disk change indicator - unused

DRVWPT            = $1e       ; flag: drive #0 - previous status of write protect photocell
DRVWPT_Flag       = %00010000 ; 
DRVWPT_NO           = $00     ; 
DRVWPT_YES          = $10     ; 
DRVWPT1           = $1f       ; flag: drive #1 - previous status of write protect photocell  - unused

DRVST             = $20       ; drive #0 - disk drive status
DRVST_Mask        = $11110000 ; 
DRVST_SW_OFF_NO   = $00010000 ; switch off motor       (1 = no , 0 = yes)
DRVST_IS_ON       = $00100000 ; motor is on            (1 = yes, 0 = no )
DRVST_IS_BUSY     = $01000000 ; read/write head moving (1 = yes, 0 = no )
DRVST_IS_RDY      = $10000000 ; disk drive ready       (1 = yes, 0 = no )

DRVST_SW_OFF_YES  = $11101111 ; switch off motor
DRVST_IS_ON_NO    = $11011111 ; motor is on
DRVST_IS_BUSY_NO  = $10111111 ; read/write head moving
DRVST_IS_RDY_NO   = $01111111 ; disk drive ready

DRVST1            = $21       ; drive #1 - disk drive status - unused
DRVTRK            = $22       ; drive #0 - current track under head
SBUSMODE          = $23       ; serial bus communication speed switch
SBUS_C64            = $00     ; C64    mode - lower speed (extra waits are needed as compensation for the delays caused by sprite DMA in the host)
SBUS_V20            = $01     ; VIC-20 mode - higher speed ($01-$ff)
STAB0             = $24       ; scratch pad of GCR conversion / storage for BIN -> GCR conversions
STAB1             = $25       ; 
SAVPTR            = $2e       ; pointer: current byte in buffer during GCR-encoding/decoding
SAVPTR_LO         = $2e       ; 
SAVPTR_HI         = $2f       ; 
BUFPTR            = $30       ; pointer: begin of currently active buffer
BUFPTR_LO         = $30       ; 
BUFPTR_HI         = $31       ; 
HDRPTR            = $32       ; pointer: track and sector registers of current buffer
HDRPTR_TRK        = $32       ; pointer: *** active track
HDRPTR_SEC        = $33       ; pointer: *** active sector
GCRPTR            = $34       ; pointer to last converted character during GCR-encoding/decoding

unused_35         = $35       ; free - not used

BYTCNT            = $36       ; byte counter during GCR-encoding/decoding

unused_37         = $37       ; free - not used

BID               = $38       ; ID mark for start of data block
BID_CHAR            = $07     ; 
HBID              = $39       ; ID mark for start of block header
HBID_CHAR           = $08     ; 
CHKSUM            = $3a       ; computed data or header checksum

unused_3b         = $3b       ; free - not used
unused_3c         = $3c       ; free - not used

DRIVE             = $3d       ; disk controller current unit number
DRIVE_0             = $00     ; 
DRIVE_1             = $01     ; unused - will not work

CURDRV            = $3e       ; disk controller previous unit number
CURDRV_0            = $00     ; 
CURDRV_1            = $01     ; unused - will not work
CURDRV_OFF          = $ff     ; motor is off - must spin up before seeking

JOBN              = $3f       ; disk controller current buffer number
JOBN_0              = $00     ; 
JOBN_1              = $01     ; 
JOBN_2              = $02     ; 
JOBN_3              = $03     ; 
JOBN_4              = $04     ; 
JOBN_5              = $05     ; unused - buffer #5 not existing

TRACC             = $40       ; byte counter for GCR-encoding/decoding
NXTJOB            = $41       ; position of next job in queue
NXTJOB_0            = $00     ; 
NXTJOB_0            = $01     ; 
NXTJOB_0            = $02     ; 
NXTJOB_0            = $03     ; 
NXTJOB_0            = $04     ; 
NXTJOB_0            = $05     ; unused - buffer #5 not existing

NXTTRK            = $42       ; destination (next) track to move head to
SECCNT            = $43       ; number of sectors per track for formatting
WORK              = $44       ; temporary workspace
JOB               = $45       ; temporary storage of job code

unused_46         = $46       ; free - not used

DBID              = $47       ; data block ID code - data block can be written with a different if
DBID_CHAR_DFLT      = $07     ; default
DBID_CHAR_MIN       = $00     ; allowed values: $00-$0f
DBID_CHAR_MAX       = $0f     ; allowed values: $00-$0f
ACLTIM            = $48       ; timer for acceleration of head movement
SAVSP             = $49       ; temporary save of stackpointer
STEPS             = $4a       ; number of steps to move head to desired track
                              ; $00-$7f - move head out (from disk centre)
                              ; $80-$ff - move head in  (to disk centre)
TMP               = $4b       ; retry counter for reading sector header / temporary storage during seeking
CSECT             = $4c       ; last sector read
NEXTS             = $4d       ; next sector to service
NXTBF             = $4e       ; pointer: next buffer of GCR-bytes to be changed to binary
NXTBF_HI            = $4e     ; byte swapped!
NXTBF_LO            = $4f     ; byte swapped!
GCRFLG            = $50       ; flag: buffer data currently being in GCR-encoded form
GCRFLG_BIN          = $00     ; $00    : Data in normal form
GCRFLG_GCR          = $01     ; $01-$FF: Data in GCR-encoded form - must be decoded
FTNUM             = $51       ; current track number for formatting
BTAB              = $52       ; temp area for 4 data bytes during GCR-encoding/decoding
BTAB0             = $52       ; 
BTAB1             = $53       ; 
BTAB2             = $54       ; 
BTAB3             = $55       ; 
GTAB              = $56       ; temp area for data nybbles/5 GCR bytes during GCR-encoding/decoding
GTAB0             = $56       ; 
GTAB1             = $57       ; 
GTAB2             = $58       ; 
GTAB3             = $59       ; 
GTAB4             = $5a       ; 
GTAB5             = $5b       ; 
GTAB6             = $5c       ; 
GTAB7             = $5d       ; 
ACCS              = $5e       ; number of halftracks (steps) to accelerate/decelerate
ACCS_DFLT           = $04     ; twice this value must be less than value of MINSTP
ACCAF             = $5f       ; acceleration/deceleration factor
ACCF_DFLT           = $04     ; value of PortB2.T1LH2 plus/minus value of ACCS times this value must not be
                              ;   too low  – below about 12-20 (depends on drive mechanics) or
                              ;   too high – above 255
ACLSTP            = $60       ; number of steps left to ac/decelerate when stepping the head
RSTEPS            = $61       ; number of steps left to step the head when in fast stepping (run) mode
NXTST             = $62       ; pointer: head stepping routine ($FA05)
NXTST_LO          = $62       ;
NXTST_HI          = $63       ;
MINSTP            = $64       ; minimum of steps to go when in fast stepping (run) mode
UIPTR             = $65       ; pointer: warm start ("UI" command) routine [$EB22]
UIPTR_LO          = $65       ; 
UIPTR_HI          = $66       ; 
NMIFLG            = $67       ; flag: NMI in progress
AUTOFG            = $68       ; flag: enable/disable automatic disk initialisation if ID MISMATCH occurred 
AUTOFG_YES          = $00     ; 
AUTOFG_NO           = $01     ; 
SECINC            = $69       ; soft interleave - distance (in sectors) for allocating the next sector for files
SECINC_DFLT         = $0a     ; 
REVCNT            = $6a       ; number of retries on dos commands in case of an error
REVCNT_Mask       = %00111111 ; number of retries
REVCNT_AHT        = %01000000 ; retry on adjacent halftracks
REVCNT_BUMP       = %10000000 ; bump head
REVCNT_AHT_NO     = %10111111 ; do not retry on adjacent halftracks
REVCNT_BUMP_NO    = %01111111 ; do not bump head
REVCNT_DFLT         = $05     ; 
USRJMP            = $6b       ; pointer: start of jump table for "Ux" commands [$ffea]
USRJMP_LO         = $6b       ; 
USRJMP_HI         = $6c       ; 
BMPTR             = $6d       ; pointer: start of bitmap [$0400]
BMPTR_LO          = $6d       ; 
BMPTR_HI          = $6e       ; 
MBJUMP            = $6f       ; pointer: address for M & B commands
MBJUMP_LO         = $6f       ; 
MBJUMP_HI         = $70       ; 
TEMP1             = $71       ; 
TEMP2             = $72       ; 
TEMP3             = $73       ; 
TEMP4             = $74       ; 
IP                = $75       ; pointer: current byte during memory test upon startup / exec address current "Ux" user command
IP_LO             = $75       ; 
IP_HI             = $76       ; 
LSNADR            = $77       ; listener address (device number + $20)
LSNADR_DFLT         = $28     ; 
TLKADR            = $78       ; talker   address (device number + $40)
TLKADR_DFLT         = $48     ; 
LSNACT            = $79       ; flag: active listener
LSNACT_YES          $01       ; $01-$FF: LISTEN command currently active
LSNACT_NO           $00       ; $00    : no LISTEN command active
TLKACT            = $7a       ; flag: active talker
TLKACT_YES          = $01     ; $01-$FF: TALK command currently active
TLKACT_NO           = $00     ; $00    : no TALK command active
ADRMODE           = $7b       ; flag: addressing mode
ATNPND            = $7c       ; flag: ATN from serial bus receiving
ATNPND_YES          = $01     ; $01-$FF: ATN signal arrived
ATNPND_NO           = $00     ; $00    : ATN inactive
ATNMOD            = $7d       ; flag: end of command (6502 in attention mode)
ATNMOD_YES          = $00     ; $00    : Command fully arrived, ATN became inactive
ATNMOD_NO           = $01     ; $01-$FF: Command still transferring
LASTTRACK         = $7e       ; track number ($01-$ff) of previously opened file (used when opening "*")
LASTTRACK_NONE      = $00     ; no file has been opened yet
DRVNBR            = $7f       ; current drive number
TRACK             = $80       ; current track number
SECTOR            = $81       ; current sector number
CURCHN            = $82       ; current channel
CURCHN0             = $00     ; buffer #00
CURCHN1             = $01     ; buffer #01
CURCHN2             = $02     ; buffer #02
CURCHN3             = $03     ; buffer #03
CURCHN4             = $04     ; buffer #04
CURCHN5             = $05     ; buffer #05 - error message
SA                = $83       ; secondary address
SA_Mask           = %00000111 ; 
ORGSA             = $84       ; original secondary address
ORGSA_DFLT          = $6f     ; 
DATA              = $85       ; data byte read from serial bus
R0                = $86       ; temporary results
R1                = $87       ; 
R2                = $88       ; 
R3                = $89       ; 
R4                = $8a       ; 
RESULT0           = $8b       ; result area
RESULT1           = $8c       ; 
RESULT2           = $8d       ; 
RESULT3           = $8e       ; 
ACCUM0            = $8f       ; accumulator
ACCUM1            = $90       ; 
ACCUM2            = $91       ; 
ACCUM3            = $92       ; 
ACCUM4            = $93       ; 
DIRBUF            = $94       ; pointer: current directory entry - directory buffer ($0205)
DIRBUF_LO         = $94       ; 
DIRBUF_HI         = $95       ; 

unused_96         = $96       ; free - not used
unused_97         = $97       ; free - not used

CONT              = $98       ; bit counter during serial bus input/output
BUFTAB            = $99       ; pointer table to buffer 0..4 - normally: $0300..$0700
BUFPTR0           = $99       ; pointer: next byte in buffer #0 - default: $0300
BUFPTR0_LO        = $99       ; 
BUFPTR0_HI        = $9a       ; 
BUFPTR1           = $9b       ; pointer: next byte in buffer #1 - default: $0400
BUFPTR1_LO        = $9b       ; 
BUFPTR1_HI        = $9c       ; 
BUFPTR2           = $9d       ; pointer: next byte in buffer #2 - default: $0500
BUFPTR2_LO        = $9d       ; 
BUFPTR2_HI        = $9e       ; 
BUFPTR3           = $9f       ; pointer: next byte in buffer #3 - default: $0600
BUFPTR3_LO        = $9f       ; 
BUFPTR3_HI        = $a0       ; 
BUFPTR4           = $a1       ; pointer: next byte in buffer #4 - default: $0700
BUFPTR4_LO        = $a1       ; 
BUFPTR4_HI        = $a2       ; 
INPPTR            = $a3       ; pointer: next byte in command buffer - default: $0200
INPPTR_LO         = $a3       ; 
INPPTR_HI         = $a4       ; 
ERRPTR            = $a5       ; pointer: next byte in error message buffer - default: $02D5
ERRPTR_LO         = $a5       ; 
ERRPTR_HI         = $a6       ; 
BUF0CH            = $a7       ; table: primary buffer number assigned to channels
BUF0CH_Num_Mask   = $01111111 ; bit0-bit6: buffer number
BUF0CH_Act_Mask   = $10000000 ; bit7     : 1 = no buffer assigned to channel
BUF0CH1           = $a7       ; 
BUF0CH2           = $a8       ; 
BUF0CH3           = $a9       ; 
BUF0CH4           = $aa       ; 
BUF0CH5           = $ab       ; 
BUF0CH6           = $ac       ; 
BUF0CH7           = $ad       ; 
BUF1CH            = $ae       ; table: secondary buffer number assigned to channels
BUF1CH_Num_Mask   = $01111111 ; bit0-bit6: buffer number
BUF1CH_Act_Mask   = $10000000 ; bit7     : 1 = no buffer assigned to channel
BUF1CH1           = $ae       ; 
BUF1CH2           = $ae       ; 
BUF1CH3           = $ae       ; 
BUF1CH4           = $ae       ; 
BUF1CH5           = $ae       ; 
BUF1CH6           = $ae       ; 
BUF1CH7           = $b4       ; 
RECLO             = $b5       ; table: low byte - length of file assigned to channels / rel files: number of records
RECL1             = $b5       ; 
RECL2             = $b6       ; 
RECL3             = $b7       ; 
RECL4             = $b8       ; 
RECL5             = $b9       ; 
RECL6             = $ba       ; 
RECHI             = $bb       ; table: high byte - length of file assigned to channels / rel files: number of records
RECHI1            = $bb       ; 
RECHI2            = $bc       ; 
RECHI3            = $bd       ; 
RECHI4            = $be       ; 
RECHI5            = $bf       ; 
RECHI6            = $c0       ; 
WRIPNT            = $c1       ; table: offset of current byte in buffer assigned to channels
WRIPNT1           = $c1       ; 
WRIPNT2           = $c2       ; 
WRIPNT3           = $c3       ; 
WRIPNT4           = $c4       ; 
WRIPNT5           = $c5       ; 
WRIPNT6           = $c6       ; 
RECLENGTH         = $c7       ; table: record length of relative file assigned to channels
RECLENGTH1        = $c7       ; 
RECLENGTH2        = $c8       ; 
RECLENGTH3        = $c9       ; 
RECLENGTH4        = $ca       ; 
RECLENGTH5        = $cb       ; 
RECLENGTH6        = $cc       ; 
SIDSEC            = $cd       ; buffer number holding side sector of relative file assigned to channels
SIDSEC_Num_Mask   = $01111111 ; bit0-bit6: buffer number
SIDSEC_Act_Mask   = $10000000 ; bit7     : 1 = no buffer assigned to channel
SIDSEC1           = $cd       ; 
SIDSEC2           = $ce       ; 
SIDSEC3           = $cf       ; 
SIDSEC4           = $d0       ; 
SIDSEC5           = $d1       ; 
SIDSEC6           = $d2       ; 

CHNNUM            = $d3       ; comma counter during fetch unit numbers from command
RECORDPOS         = $d4       ; offset: current byte in relative file record
NUMSIDSEC         = $d5       ; side sector number belonging to current relative file record
PTRSIDESEC        = $d6       ; offset of track and sector number of current relative file record in side sector
RELPOINTER        = $d7       ; offset: record in relative file data sector
DIRSECP           = $d8       ; table: sector number of directory entry of files pointer directory sectors
DIRSECP1          = $d8       ; 
DIRSECP2          = $d9       ; 
DIRSECP3          = $da       ; 
DIRSECP4          = $db       ; 
DIRSECP5          = $dc       ; 
BUFPTR            = $dd       ; table: offset of directory entry of files
BUFPTR1           = $dd       ; 
BUFPTR2           = $de       ; 
BUFPTR3           = $df       ; 
BUFPTR4           = $e0       ; 
BUFPTR5           = $e1       ; 
DRVNUM            = $e2       ; table: unit number of files
DRVNUM_Num_Mask   = %00000001 ; bit0: unit number
DRVNUM_Act_Mask   = %10000000 ; bit7: 1 = no valid unit number has been specified in command - must try both units
DRVNUM1           = $e2       ; 
DRVNUM2           = $e3       ; 
DRVNUM3           = $e4       ; 
DRVNUM4           = $e5       ; 
DRVNUM5           = $e6       ; 
COMFLG            = $e7       ; table: file type / flags of files
COMFLG_TPYE_Mask  = %00000111 ; 
COMFLG_TYPE_DEL     = $00     ; 
COMFLG_TYPE_SEQ     = $01     ; 
COMFLG_TYPE_PRG     = $02     ; 
COMFLG_TYPE_USR     = $03     ; 
COMFLG_TYPE_REL     = $04     ; 
COMFLG_CLOSED     = %11011111 ; 0 = file has been closed
COMFLG_OPEN       = %00100000 ; 
COMFLG_PROT_YES   = %01000000 ; 1 = file is write protected
COMFLG_PROT_NO    = %10111111 ; 
COMFLG_WICA_YES   = %10000000 ; 1 = wildcards present in file name
COMFLG_WICA_NO    = %01111111 ; 
COMFLG1           = $e7       ; 
COMFLG2           = $e8       ; 
COMFLG3           = $e9       ; 
COMFLG4           = $ea       ; 
COMFLG5           = $eb       ; 
DIACFL            = $ec       ; table: unit number / file type / flags of files assigned to channels
DIACFL_UNIT       = %00000001 ; unit number
DIACFL_TYPE_Mask  = %00001110 ; file type
DIACFL_TYPE_DEL   = %00000000 ; 
DIACFL_TYPE_SEQ   = %00000010 ; 
DIACFL_TYPE_PRG   = %00000100 ; 
DIACFL_TYPE_USR   = %00000110 ; 
DIACFL_TYPE_REL   = %00001000 ; 
DIACFL_TYPE_DDA   = %00001110 ; "#" - direct disk access
DIACFL_EOR        = %00100000 ; end of record
DIACFL_EOF        = %01000000 ; end of file
DIACFL_DIR        = %10000000 ; directory entry of file must be updated
DIACFL1           = $ec       ; 
DIACFL2           = $ed       ; 
DIACFL3           = $ee       ; 
DIACFL4           = $ef       ; 
DIACFL5           = $f0       ; 
DIACFL6           = $f1       ; 
REWRFL            = $f2       ; table: flags - input/output flags of channels
REWRFL_WRITE      = %00000001 ; bit0 - 1 = write allowed
REWRFL_EOF        = %11110111 ; bit3 - 0 = end of file
REWRFL_READ       = %10000000 ; bit7 - 1 = read allowed
REWRFL1           = $f2       ; 
REWRFL2           = $f3       ; 
REWRFL3           = $f4       ; 
REWRFL4           = $f5       ; 
REWRFL5           = $f6       ; 
REWRFL6           = $f7       ; 
EOIFLG            = $f8       ; end of file indicator current channel
EOIFLG_YES          = $00     ; $00    : end of file
EOIFLG_NO           = $01     ; $01-$FF: file has not ended yet
ACTBUFNUM         = $f9       ; job number
LRUTBL            = $fa       ; table: last used
LRUTBL1           = $fa       ; 
LRUTBL2           = $fb       ; 
LRUTBL3           = $fc       ; 
LRUTBL4           = $fd       ; 
LRUTBL5           = $fe       ; 
DISKRDY           = $ff       ; drive #0 ready
DISKRDY_YES         = $00     ; drive #0 ready
DISKRDY_NO          = $ff     ; drive #0 not ready (no disk)
; -------------------------------------------------------------------------------------------------------------- ;
unused_0100       = $0100     ; free - not used

TypeChk           = $0101     ; contains code for type of disk ... 0102
BufGCR            = $01bb     ; buffer for GCR de/encoding
CMDBUF            = $0200     ; 
INSTRU            = $022a     ; instruction number
LINTAB            = $022b     ; 
CH4WFL            = $023a     ; Write-flag channel 4
CH5WFL            = $023b     ; Write-flag channel 5

unused_023C       = $023c     ; free - not used
unused_023D       = $023d     ; free - not used

OUTREG            = $023e     ; output registers
ENDPNT            = $0244     ; 
TYPE              = $024a     ; active file type
STRSIZ            = $024b     ; length of string
TEMPSA            = $024c     ; temporary secondary address
CMD               = $024d     ; temporary job command
BSTSEC            = $024e     ; best sector to do
BUFUSEL           = $024f     ; 
BUFUSEH           = $0250     ; 
MDIRTY            = $0251     ; <> 0  means: BAM changed flag (dr 0) $0252 = same for drive 1
ENTFND            = $0253     ; directory entry found flag
DIRLST            = $0254     ; directory listing flag, 0 = no
CMDWAT            = $0255     ; command waiting flag
LINUSE            = $0256     ; LINDX use word
LSTUSEDBUF        = $0257     ; last used buffer
RECORDSIZE        = $0258     ; record size (directory routine)
TRKSS             = $0259     ; side sector track
SECSS             = $025a     ; side sector sector
LSTJOB            = $025b     ; last job / drive number
DSEC              = $0260     ; sector of directory entry by buffer
DIND              = $0266     ; index of directory entry by buffer
ERWORD            = $026c     ; error word
ERLED             = $026d     ; which LED must blink during error
PRGDRV            = $026e     ; last program drive
PRGSEC            = $026f     ; last program sector
WLINDX            = $0270     ; write LINDX
NBTEMP0           = $0272     ; 
NBTEMP1           = $0273     ; 
CMDSIZ            = $0274     ; size of command string
CHAR              = $0275     ; character under parser
LIMIT             = $0276     ; PTR limit in comparison
F1CNT             = $0277     ; file stream 1 count
F2CNT             = $0278     ; file stream 2 count / number of drives
F2PTR             = $0279     ; file stream 2 pointer
FILTBL            = $027a     ; table of filename pointers
FILTRK            = $0280     ; first file link (track)
FILSEC            = $0285     ; first file link (sector)
PATFLG            = $028a     ; pattern present flag
IMAGE             = $028b     ; file stream image / flag syntax check
DRVCNT            = $028c     ; number of drive searches
DRVFLG            = $028d     ; drive search flag
LSTDRV            = $028e     ; last drive w/o error
FOUND             = $028f     ; found flag in directory searches
DIRSEC            = $0290     ; directory sector
DELSEC            = $0291     ; sector of first available entry
DELIND            = $0292     ; index of first available entry
LSTBUF            = $0293     ; O if last block
INDEX             = $0294     ; current index in buffer
FILCNT            = $0295     ; counter of file entries
TYPFLG            = $0296     ; match by type of flag
MODE              = $0297     ; active file mode (R,W)
JOBRTN            = $0298     ; job return flag
EPTR              = $0299     ; pointer for recovery
TOFF              = $029a     ; total track offset
UBAM              = $029b     ; last BAM update pointer
TBAM              = $029d     ; track # of BAM image
BAMIMG            = $02a1     ; BAM images
NAMEBUFFER        = $02b1     ; directory output buffer

unused_02C3       = $02c3     ; free - not used
unused_02C4       = $02c4     ; free - not used

ERRBUF            = $02d5     ; error message output buffer
WBAM              = $02f9     ; 'don't write BAM'-flag. set at start
NDBL              = $02fa     ; # of disk blocks free (lo byte 0/1)

unused_02FB       = $02fb     ; free - not used

NDBH              = $02fc     ; # of disk blocks free (hi byte 0/1)

unused_02FD       = $02fd     ; free - not used

PHASE             = $02fe     ; current phase of head stepper motor
BUF0              = $0300     ; 

unused_0345       = $0345     ; free - not used

BUF2              = $0500     ; 
BUF3              = $0600     ; 

unused_0620       = $0620     ; free - not used
unused_0621       = $0621     ; free - not used
unused_0622       = $0622     ; free - not used
unused_0623       = $0623     ; free - not used
unused_0624       = $0624     ; free - not used
unused_0625       = $0625     ; free - not used
unused_0626       = $0626     ; free - not used
unused_0627       = $0627     ; free - not used
unused_0628       = $0628     ; free - not used
; -------------------------------------------------------------------------------------------------------------- ;
