; ------------------------------------------------------------------------------------------------------------- ;
; Kernal jump table
; ------------------------------------------------------------------------------------------------------------- ;
K_JMP_TAB   = $FF81 ; Kernal Jump Table
; ------------------------------------------------------------------------------------------------------------- ;
; The following is a list of error messages which can occur when using the KERNAL routines. 
; The carry bit is set then and the number of the error message is returned in the accumulator.
; ------------------------------------------------------------------------------------------------------------- ;
; Success           ; Indicator   : Carry Clear
;                   ; 
; Errors            ; Indicator   : Carry Set
;                   .-----------------------------------------------------------------------.
;                   | NOTE: Some KERNAL I/O routines do not use these codes for error msgs  |
;                   |       Instead, errors are identified using the KERNAL READST routine. |
;                   +-------+---------------------------------------------------------------+
;                   | NUMBER|                          MEANING                              |
;                   +-------+---------------------------------------------------------------+
; ErrorCodes        |   0   |  Routine terminated by the <STOP> key                         |
;                   |   1   |  Too many open files                                          |
;                   |   2   |  File already open                                            |
;                   |   3   |  File not open                                                |
;                   |   4   |  File not found                                               |
;                   |   5   |  Device not present                                           |
;                   |   6   |  File is not an input file                                    |
;                   |   7   |  File is not an output file                                   |
;                   |   8   |  File name is missing                                         |
;                   |   9   |  Illegal device number                                        |
;                   |  240  |  Top-of-memory change RS-232 buffer allocation/deallocation   |
; ------------------+-----------------------------------------------------------------------+------------------ ;
CINT        = $FF81 ; Purpose     : Initialize screen editor & 6567 video chip
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Sets up the 6567 video controller chip in the C64 for normal operation. 
                    ;               The KERNAL screen editor is also initialized. 
                    ;               Normally called as part of the initialization procedure of a C64 pgm cart.
                    ;                 - init VIC
                    ;                 - restore default I/O to keyboard/screen
                    ;                 - clear screen
                    ;                 - set PAL/NTSC switch and interrupt timer
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : jsr $IOINIT ; Initialise I/O
                    ;               jsr $RAMTAS ; Initialise System Constants
                    ;               jsr $RESTOR ; Restore Kernal Vectors
                    ;               jsr $CINT   ; Initialize screen editor
                    ;               
                    ;               jmp $8000   ; start the application code
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - - -
                    ; Regs out    : - - -
                    ; Regs used   : A X Y
                    ; Stack       : 4
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
CINT_Mem    = $FF5B ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
IOINIT      = $FF84 ; Purpose     : Initialize I/O devices
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Inits all I/O devices and routines.
                    ;                 - init CIA's
                    ;                 - init SID volume
                    ;                 - setup memory configuration
                    ;                 - set and start interrupt timer
                    ;               Normally called as part of the initialization procedure of a C64 pgm cart.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : see CINT
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Note        : This routine automatically distinguishes a PAL system from a NTSC system and sets
                    ;               PALCNT accordingly for use in the time routines.
                    ;                 - $02a6 = 0: NTSC
                    ;                 - $02a6 = 1: PAL
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - - -
                    ; Regs out    : - - -
                    ; Regs used   : A X Y
                    ; Stack       : none
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
IOINIT_Mem  = $FDA3 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
RAMTAS      = $FF87 ; Purpose     : Initialize RAM / Allocate tape buffer / Set screen $0400
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Clears Z-Page, sets RS-232 buffers, sets Ram top/bottom.
                    ;                 - clear $0000-$0101 (Z-Page)
                    ;                 - clear $0200-$03FF
                    ;                 - run memory test
                    ;                 - set start and end address of BASIC work area accordingly
                    ;                 - set screen memory    to $0400
                    ;                 - set datasette buffer to $033C
                    ;               Normally called as part of the initialization procedure of a C64 pgm cart.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : see CINT
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - - -
                    ; Regs out    : - - -
                    ; Regs used   : A X Y
                    ; Stack       : 2
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
RAMTAS_Mem  = $FD50 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
RESTOR      = $FF8A ; Purpose     : Restore default system and interrupt vectors
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : This routine restores the default values of all system vectors used in KERNAL
                    ;               and BASIC routines and interrupts.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : see CINT
                    ; ----------------------------------------------------------------------------------------- ;
                    ;               Fill vector table at $0314-$0333 with default values:
                    ;
                    ;          $00  CINV    = $0314 - Vector: Hardware IRQ Interrupt          address ($EA31)
                    ;          $02  CNBINV  = $0316 - Vector: BRK instruction interrupt       address ($FE66)
                    ;          $04  NMINV   = $0318 - Vector: Hardware NMI interrupt          address ($FE47)
                    ;          
                    ;          $06  IOPEN   = $031a - Vector: Indirect entry to Kernal OPEN   routine ($F34A)
                    ;          $08  ICLOSE  = $031c - Vector: Indirect entry to Kernal CLOSE  routine ($F291)
                    ;          $0a  ICHKIN  = $031e - Vector: Indirect entry to Kernal CHKIN  routine ($F20E)
                    ;          $0c  ICKOUT  = $0320 - Vector: Indirect entry to Kernal CHKOUT routine ($F250)
                    ;          $0e  ICLRCH  = $0322 - Vector: Indirect entry to Kernal CLRCHN routine ($F333)
                    ;          $10  IBASIN  = $0324 - Vector: Indirect entry to Kernal CHRIN  routine ($F157)
                    ;          $12  IBSOUT  = $0326 - Vector: Indirect entry to Kernal CHROUT routine ($F1CA)
                    ;          $14  ISTOP   = $0328 - Vector: Indirect entry to Kernal STOP   routine ($F6ED)
                    ;          $16  IGETIN  = $032a - Vector: Indirect entry to Kernal GETIN  routine ($F13E)
                    ;          $18  ICLALL  = $032c - Vector: Indirect entry to Kernal CLALL  routine ($F32F)
                    ;          $1a  USRCMD  = $032e - Vector: User Defined                            ($FE66)
                    ;          $1c  ILOAD   = $0330 - Vector: Indirect entry to Kernal LOAD   routine ($F4A5)
                    ;          $1e  ISAVE   = $0332 - Vector: Indirect entry to Kernal SAVE   routine ($F5ED)
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - - -
                    ; Regs out    : - - -
                    ; Regs used   : A - Y
                    ; Stack       : 2
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
RESTOR_Mem  = $FD15 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
VECTOR      = $FF8D ; Purpose     : Read/set vectored I/O
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Manages all system vector jump addresses stored in RAM.
                    ;               If the carry bit is set, the current contents of the RAM vectors are stored
                    ;               in a list pointed to by the X and Y registers.
                    ;               If the carry bit is clear, the user list pointed to by the X and Y registers
                    ;               is transferred to the system RAM vectors. 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : ldx #<user    ; change the input routines to new system
                    ;               ldy #>user
                    ;               sec           ; 
                    ;               jsr VECTOR    ; read old vectors
                    ;               
                    ;               lda #<myCHKIN ; 
                    ;               sta user+$0a  ; change CHKIN lo
                    ;               lda #>myCHKIN ; 
                    ;               sta user+$0b  ; change CHKIN hi
                    ;               ldx #<user    ; get pointers
                    ;               ldy #>user    ; 
                    ;               clc           ; 
                    ;               jsr VECTOR    ; alter system
                    ;               ...
                    ;         user  = *
                    ;         userX = user + $20
                    ; ----------------------------------------------------------------------------------------- ;
                    ;  NOTE       : This routine requires caution in its use. The best way to use it is to first
                    ;               read the entire vector contents into the user area, alter the desired vectors,
                    ;               and then copy the contents back to the system vectors.
                    ;             : This routine is rarely used - usually the vectors are directly changed.
                    ; ----------------------------------------------------------------------------------------- ;
                    ;               Copy vector table at $0314-$0333 from/into user table:
                    ;
                    ;         $00  CINV    = $0314 - Vector: Hardware IRQ Interrupt          address ($EA31)
                    ;         $02  CNBINV  = $0316 - Vector: BRK instruction interrupt       address ($FE66)
                    ;         $04  NMINV   = $0318 - Vector: Hardware NMI interrupt          address ($FE47)
                    ;         
                    ;         $06  IOPEN   = $031a - Vector: Indirect entry to Kernal OPEN   routine ($F34A)
                    ;         $08  ICLOSE  = $031c - Vector: Indirect entry to Kernal CLOSE  routine ($F291)
                    ;         $0a  ICHKIN  = $031e - Vector: Indirect entry to Kernal CHKIN  routine ($F20E)
                    ;         $0c  ICKOUT  = $0320 - Vector: Indirect entry to Kernal CHKOUT routine ($F250)
                    ;         $0e  ICLRCH  = $0322 - Vector: Indirect entry to Kernal CLRCHN routine ($F333)
                    ;         $10  IBASIN  = $0324 - Vector: Indirect entry to Kernal CHRIN  routine ($F157)
                    ;         $12  IBSOUT  = $0326 - Vector: Indirect entry to Kernal CHROUT routine ($F1CA)
                    ;         $14  ISTOP   = $0328 - Vector: Indirect entry to Kernal STOP   routine ($F6ED)
                    ;         $16  IGETIN  = $032a - Vector: Indirect entry to Kernal GETIN  routine ($F13E)
                    ;         $18  ICLALL  = $032c - Vector: Indirect entry to Kernal CLALL  routine ($F32F)
                    ;         $1a  USRCMD  = $032e - Vector: User Defined                            ($FE66)
                    ;         $1c  ILOAD   = $0330 - Vector: Indirect entry to Kernal LOAD   routine ($F4A5)
                    ;         $1e  ISAVE   = $0332 - Vector: Indirect entry to Kernal SAVE   routine ($F5ED)
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - X Y
                    ;             : Carry = 0 - Copy user table into vector table
                    ;             : Carry = 1 - Copy vector table into user table
                    ;             :             X/Y = Pointer to user table
                    ; Regs out    : - X -
                    ; Regs used   : A - Y
                    ; Stack       : 2
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
VECTOR_Mem  = $FD1A ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
SETMSG      = $FF90 ; Purpose     : Control KERNAL messages
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Controls the KERNAL error and control messages printing by setting the 
                    ;               system error display switch at $9D.
                    ;               EITHER print error messages or print control messages can be selected.
                    ;                 FILE NOT FOUND         is an example of an error   message.
                    ;                 PRESS PLAY ON CASSETTE is an example of a  control message.
                    ;               Bits 6 and 7 of the accumulator determine where the message will come from:
                    ;                - Bit 7 = 1: Error messages from the KERNAL are printed.
                    ;                - Bit 6 = 1: Control messages are printed.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : lda #$40    ; .#......
                    ;               jsr SETMSG  ; turn on control messages
                    ;               lda #$80    ; #.......
                    ;               jsr SETMSG  ; turn on error messages
                    ;               lda #$00    ; ........
                    ;               jsr SETMSG  ; turn off all kernal messages
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : A - -
                    ;             : A = Bit7=1 - Error msgs on
                    ;             : A = Bit6=1 - Control msgs on
                    ; Regs out    : - - -
                    ; Regs used   : A - -
                    ; Stack       : 2
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
SETMSG_Mem  = $FE18 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
SECOND      = $FF93 ; Purpose     : Send secondary address after LISTEN to serial bus
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Sends a secondary address to an I/O device after is was commanded to LISTEN.
                    ;               Secondary address are usually used to give setup information to a device
                    ;               before I/O operations begin.
                    ;               The routine canNOT be used to send a secondary address after a call to TALK.
                    ;               Must be called with a number between 00 and 31 in the accumulator.
                    ;               When a secondary address is to be sent to a device on the serial bus, the
                    ;               address must first be ORed with $60.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : see CIOUT
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : LISTEN
                    ; Regs in     : A - -
                    ;             : A = LISTEN secondary address
                    ; Regs out    : - - -
                    ; Regs used   : A - -
                    ; Stack       : 8
                    ; RC          : See READST
                    ; ----------------------------------------------------------------------------------------- ;
SECOND_Mem  = $EDB9 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
TKSA        = $FF96 ; Purpose     : Send secondary address after TALK  to serial bus
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Sends a secondary address to an I/O device after is was commanded to TALK.
                    ;               Secondary address are usually used to give setup information to a device
                    ;               before I/O operations begin.
                    ;               The routine canNOT be used to send a secondary address after a call to LISTEN.
                    ;               Must be called with a number between 00 and 31 in the accumulator.
                    ;               When a secondary address is to be sent to a device on the serial bus, the
                    ;               address must first be ORed with $60.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : see ACPTR
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : TALK
                    ; Regs in     : A - -
                    ;             : A = TALK secondary address
                    ; Regs out    : - - -
                    ; Regs used   : A - -
                    ; Stack       : 8
                    ; RC          : See READST
                    ; ----------------------------------------------------------------------------------------- ;
TKSA_Mem    = $EDC7 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
MEMTOP      = $FF99 ; Purpose     : Read/set the top of memory 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : This routine is used to set the top of memory.
                    ;               (Save or restore end address of the BASIC work area)
                    ;               If the carry bit is set, the pointer to the top of RAM will be loaded into
                    ;               the X/Y registers.
                    ;               If the carry bit is clear, the contents of the X/Y registers are loaded in
                    ;               the top of memory pointer, changing the top of memory.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : sec           ; protect one page of memory from BASIC
                    ;               jsr MEMTOP    ; get memory top to X/Y
                    ;               dey           ; set prev page
                    ;               clc           ; 
                    ;               jsr MEMTOP    ; set memory top to new value in X/Y
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - X Y
                    ;             : Carry = 0 - Set new top of memory
                    ;             :   X Y = Address lo/hi
                    ; Regs out    : - X Y
                    ;             : Carry = 1 - Get top of memory
                    ;             :   X Y = Address lo/hi
                    ; Regs used   : - (X Y if C=1)
                    ; Stack       : 2
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
MEMTOP_Mem  = $FE25 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
MEMBOT      = $FF9C ; Purpose     : Read/set the bottom of memory 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : This routine is used to set the bottom of the memory. 
                    ;               (Save or restore start address of the BASIC work area)
                    ;               If the carry bit is set, the pointer to the bottom of RAM will be loaded into
                    ;               the X/Y registers.
                    ;               On the unexpanded C64 the initial value of this pointer is $0800 (2048).
                    ;               If the carry bit is clear, the contents of the X/Y registers are loaded in
                    ;               the bottom of memory pointer, changing the bottom of memory.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : sec           ; move bottom of memory up one page
                    ;               jsr MEMBOT    ; get memory bottom to X/Y
                    ;               iny           ; set next page
                    ;               clc           ; 
                    ;               jsr MEMBOT    ; set memory bottom to new value in X/Y
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - X Y
                    ;             : Carry = 0 - Set memory bottom
                    ;             :   X Y = Address lo/hi
                    ; Regs out    : - X Y
                    ;             : Carry = 1 - Get memory bottom
                    ;             :   X Y = Address lo/hi
                    ; Regs used   : - (X Y if C=1)
                    ; Stack       : none
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
MEMBOT_Mem  = $FE34 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
SCNKEY      = $FF9F ; Purpose     : Scan keyboard 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Scans the C64 keyboard and checks for pressed keys.
                    ;               It is the same routine called by the interrupt handler. 
                    ;               Should be called only if the normal IRQ interrupt is bypassed.
                    ;               If a key is down, its ASCII value is placed in the keyboard queue.
                    ;                 - current matrix code           --> $00CB
                    ;                 - current status of shift keys  --> $028D
                    ;                 - PETSCII code                  --> Keyboard buffer
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     :             ; 
                    ; GetKey        jsr SCNKEY  ; scan keyboard
                    ;               jsr GETIN   ; get character from keyboard buffer
                    ;               cmp #$00    ; got nothing
                    ;               beq GetKey  ; again then
                    ;               
                    ;               jsr CHROUT  ; print it
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : IOINIT
                    ; Regs in     : - - -
                    ; Regs out    : - - -
                    ; Regs used   : A X Y
                    ; Stack       : 5
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
SCNKEY_Mem  = $EA87 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
SETTMO      = $FFA2 ; Purpose     : Set timeout on serial bus
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Sets the timeout flag for the IEEE bus. When the timeout flag is set, the C64
                    ;               will wait for a device on the IEEE port for 64 milliseconds. If the device
                    ;               does not respond to the C64's Data Address Valid (DAV) signal within that
                    ;               time the C64 will recognize an error condition and leave the handshake sequence.
                    ;                - Enable  timeouts: set bit 7 of the accumulator to 0
                    ;                - Disable timeouts: set bit 7 of the accumulator to 1
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : lda #$00    ; disable timeout
                    ;               jsr SETTMO  ; 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; NOTE        : The C64 uses the timeout feature ONLY to communicate that a disk file is not
                    ;               found on an attempt to OPEN a file with an IEEE add-on card.                
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : A - -
                    ; Input       : A = Timeout flag in bit 7
                    ;             :     Bit7 = 1 - Disable
                    ;             :     Bit7 = 0 - Enable
                    ; Regs out    : A - -
                    ; Regs used   : - - -
                    ; Stack       : 2
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
SETTMO_Mem  = $FE21 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
ACPTR       = $FFA5 ; Purpose     : Input byte from serial port 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Gets a byte of data off the serial from the current TALKer using full
                    ;               handshaking. The data is returned in the accumulator.
                    ;               To prepare for this routine the TALK routine must be called first to command
                    ;               the device on the serial bus to send data through the bus.
                    ;               If the input device needs a secondary command, it must be sent by using the
                    ;               TKSA KERNAL routine before calling this routine.
                    ;               A device must be talking or the status word will return a timeout.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : jsr CLRCHN    ; get disk drive status string
                    ;               
                    ;               lda #$08      ; device #
                    ;               jsr TALK      ; 
                    ;               lda #$6f      ; $60 + command channel $0f
                    ;               jsr TKSA      ; 
                    ;               
                    ;               ldy #$00      ; index to save area
                    ;      loop     jsr ACPTR     ; 
                    ;               sta status,y  ; save the byte read in a save area
                    ;               iny           ; 
                    ;               cmp #$0d      ; carriage/return
                    ;               bne loop      ; 
                    ;               
                    ;               jsr UNTALK    ; turn off the disk serial bus
                    ;               rts           ; 
                    ;               
                    ;      status   = *           ; memory to save the status string
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : TALK (TKSA)
                    ; Regs in     : - - -
                    ; Regs out    : A - -
                    ;             : A = Byte read
                    ; Regs used   : A - -
                    ; Stack       : 13
                    ; RC          : C=1 and ST=2 if timeout (See READST)
                    ; ----------------------------------------------------------------------------------------- ;
ACPTR_Mem   = $FE13 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
CIOUT       = $FFA8 ; Purpose     : Output byte to serial port 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Sends a data byte onto the serial bus to the current LISTENer using full
                    ;               serial handshaking. The accumulator is loaded with a byte to handshake as
                    ;               data on the serial bus.
                    ;               To prepare for this routine the LISTEN KERNAL routine must be used to command
                    ;               a device on the serial bus to get ready to receive data.
                    ;               If a device needs a secondary address, it must also be sent by using the SECOND
                    ;               KERNAL routine.
                    ;               A device must be listening or the status word will return a timeout.
                    ;               This routine always buffers one character. (The routine holds the previous
                    ;               character to be sent back.) So when a call to the KERNAL UNLSN routine is made to
                    ;               end the data transmission, the buffered character is sent with an End Or
                    ;               Identify (EOI) set. Then the UNLSN command is sent to the device.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : jsr CLRCHN    ; put rel file position command to disk
                    ;               
                    ;               lda #$08      ; device #
                    ;               jsr LISTEN
                    ;               lda #$6f      ; $60 + command channel $f
                    ;               jsr SECOND
                    ;               
                    ;               ldx #$00      ; byte string index
                    ;       loop    lda poscmd,x  ; get command byte
                    ;               jsr CIOUT     ; send to disk command channel
                    ;               inx           ; 
                    ;               cpx #$06      ; 
                    ;               bcc loop      ; lower - 5 bytes + carriage/return must be sent
                    ;               
                    ;               jsr UNLSN     ; send last char on the bus with EOI and turn it off
                    ;               rts                    
                    ;               
                    ;       poscmd  dc.b 'P'      ; position command
                    ;               dc.b $63      ; $60 + data channel # - here 3
                    ;       reclo   dc.b $01      ; lo byte of record # 
                    ;       rechi   dc.b $00      ; hi byte of record #
                    ;       field   dc.b $01      ; field ptr
                    ;               dc.b $0d      ; carriage/return
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : LISTEN (SECOND)
                    ; Regs in     : A - -
                    ;             : A = Byte to send
                    ; Regs out    : A - -
                    ; Regs used   : - - -
                    ; Output      : 
                    ; Stack       : 5
                    ; RC          : C=1 and ST=3 if timeout (see READST)
                    ; ----------------------------------------------------------------------------------------- ;
CIOUT_Mem   = $EDDD ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
UNTLK       = $FFAB ; Purpose     : Command serial bus to UNTALK
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Sends an UNTALK command on the serial bus. ALL devices previously set to
                    ;               TALK will stop sending data when this command is received.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : see ACPTR
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - - -
                    ; Regs out    : - - -
                    ; Regs used   : A - -
                    ; Stack       : 8
                    ; RC          : See READST
                    ; ----------------------------------------------------------------------------------------- ;
UNTLK_Mem   = $EDEF ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
UNLSN       = $FFAE ; Purpose     : Command serial bus to UNLISTEN
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Commands ALL devices on the serial bus to stop receiving data from the C64.
                    ;               Only devices previously commanded to listen are affected.
                    ;               This routine is normally used after the C64 is finished sending data to
                    ;               external devices to get the listening devices off the serial bus so it can
                    ;               be used for other purposes.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : see CIOUT
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - - -
                    ; Regs out    : - - -
                    ; Regs used   : A - -
                    ; Stack       : 8
                    ; RC          : See READST
                    ; ----------------------------------------------------------------------------------------- ;
UNLSN_Mem   = $EDFE ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
LISTEN      = $FFB1 ; Purpose     : Command a device on the serial bus to listen
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Commands a device on the serial bus to receive data.
                    ;               The accumulator must first be loaded with a device number between 00 and 31.
                    ;               LISTEN will OR the number bit by bit to convert to a LISTEN address, then
                    ;               sends this data as a command on the serial bus. The specified device will
                    ;               then go into LISTEN mode and be ready to receive data.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : see CIOUT
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : A - -
                    ;             : A = Device number (00 to 31)
                    ; Regs out    : - - -
                    ; Regs used   : A - -
                    ; Stack       : none
                    ; RC          : See READST
                    ; ----------------------------------------------------------------------------------------- ;
LISTEN_Mem  = $ED0C ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
TALK        = $FFB4 ; Purpose     : Command devices on the serial bus to TALK
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Commands a device on the serial bus to send data.
                    ;               The accumulator must first be loaded with a device number between 00 and 31.
                    ;               TALK will OR the number bit by bit to convert to a TALK address, then
                    ;               sends this data as a command on the serial bus. The specified device will
                    ;               then go into TALK mode and be ready to send data.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : see ACPTR
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : A - -
                    ;             : A = Device number (00 to 31)
                    ; Regs out    : - - -
                    ; Regs used   : A - -
                    ; Stack       : 8
                    ; RC          : See READST
                    ; ----------------------------------------------------------------------------------------- ;
TALK_Mem    = $ED09 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
READST      = $FFB7 ; Purpose     : Read I/O status word
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Returns the current status of the I/O devices in the accumulator.
                    ;               Is usually called after new communication to an I/O device and gives info
                    ;               about device status or errors that have occurred during the I/O operation.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : jsr READST  ; check for end of file during read
                    ;               and #$40    ; check eof bit
                    ;               bne eof     ; branch on eof                    
                    ; ----------------------------------------------------------------------------------------- ;
                    ;  Note       : For RS232 status is cleared
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - - -
                    ; Regs out    : A - -
                    ;             : A = Device status byte (see table)
                    ; Regs used   : A - -
                    ; Stack       : 2
                    ; RC          : none
                    ;               
                    ;             The bits returned in the accumulator contain the following information:
                    ;             +----------+------------+---------------+------------+-------------------+
                    ;             |  ST Bit  | ST Numeric |    Cassette   |   Serial   |    Tape Verify    |
                    ;             | Position |    Value   |      Read     |  Bus R/W   |      + Load       |
                    ;             +----------+------------+---------------+------------+-------------------+
                    ;             | .......1 |      1     |               |  Time out  |                   |
                    ;             |          |            |               |   write    |                   |
                    ;             +----------+------------+---------------+------------+-------------------+
                    ;             | ......1. |      2     |               |  Time out  |                   |
                    ;             |          |            |               |    read    |                   |
                    ;             +----------+------------+---------------+------------+-------------------+
                    ;             | .....1.. |      4     |  Short block  |            |    Short block    |
                    ;             +----------+------------+---------------+------------+-------------------+
                    ;             | ....1... |      8     |   Long block  |            |    Long block     |
                    ;             +----------+------------+---------------+------------+-------------------+
                    ;             | ...1.... |     16     | Unrecoverable |            |   Any mismatch    |
                    ;             |          |            |   read error  |            |                   |
                    ;             +----------+------------+---------------+------------+-------------------+
                    ;             | ..1..... |     32     |    Checksum   |            |     Checksum      |
                    ;             |          |            |     error     |            |       error       |
                    ;             +----------+------------+---------------+------------+-------------------+
                    ;             | .1...... |     64     |  End of file  |  EOI line  |                   |
                    ;             +----------+------------+---------------+------------+-------------------+
                    ;             | 1....... |   -128     |  End of tape  | Device not |    End of tape    |
                    ;             |          |            |               |   present  |                   |
                    ; ------------+----------+------------+---------------+------------+-------------------+--- ;
READST_Mem  = $FE07 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
SETLFS      = $FFBA ; Purpose     : Set logical, first, and secondary addresses
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Sets the logical file number, device address, and secondary address
                    ;               (command number) for other KERNAL routines.
                    ;               The logical file number is used by the system as a key to the file table
                    ;               created by the OPEN file routine. 
                    ;               Device addresses can range from 00 to 31.
                    ;               The following codes are used by the C64 to stand for the CBM devices:
                    ;
                    ;                ADDRESS  DEVICE
                    ;                  00     Keyboard
                    ;                  01     Datassette(TM)
                    ;                  02     RS-232C device
                    ;                  03     Screen (CRT) display
                    ;                  04     Serial bus printer
                    ;                  08     CBM serial bus disk drive
                    ; 
                    ;               The following command number can be set:
                    ;               
                    ;                ADDRESS  DEVICE
                    ;                  00     LOAD a file to the address taken from the X/Y registers
                    ;                  01     LOAD a file to the address taken from the files disk header
                    ;                  ff     No secondary address is used
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : lda #$02    ; set logical file number
                    ;               ldx #$08    ; set device number
                    ;               ldy #$00    ; set secondary command number ($00 = new load address)
                    ;               jsr SETLFS  ; 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : A X Y
                    ;             : A = logical file number
                    ;             : X = device number
                    ;             : Y = secondary command number
                    ; Regs out    : A X Y
                    ; Regs used   : - - -
                    ; Stack       : 2
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
SETLFS_Mem  = $FE00 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
SETNAM      = $FFBD ; Purpose     : Set file name
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Sets up the file name for the OPEN, SAVE, or LOAD routines.
                    ;               The accumulator must be loaded with the length of the file name.
                    ;               The X/Y registers must be loaded with the address of the file name.
                    ;               The address can be any valid memory address in the system where a string of
                    ;               characters for the file name is stored.
                    ;               If no file name is desired, the accumulator must be set to 0, representing
                    ;               a zero file length. The X/Y registers can be set to any address in that case.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : lda #(F_nameX - F_name) ; load A with number of characters in file name
                    ;               ldx #<(F_name)          ; load X and Y with address of file name
                    ;               ldy #>(F_name)          ; 
                    ;               jsr SETNAM              ; 
                    ;               
                    ;      F_name   dc.b 'FileName'
                    ;      F_nameX  = *
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : A X Y
                    ;             : A   = File name length
                    ;               X/Y = Pointer lo/hi to file name
                    ; Regs out    : A X Y
                    ; Regs used   : - - -
                    ; Output      : 
                    ; Stack       : 2
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
SETNAM_Mem  = $FDF9 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
OPEN        = $FFC0 ; Purpose     : Open a logical file
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : OPEN a logical file. Once the logical file is set up it can be used for I/O
                    ;               operations. Most of the I/O KERNAL routines call on this routine to create
                    ;               the logical files to operate on.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : jsr CLALL     ; close all files
                    ;               
                    ; .CmdChannel   lda #$00      ; no file name
                    ;               jsr SETNAM    ; set filename parameters
                    ;               
                    ;               lda #$0f      ; set logical file number
                    ;               ldx #$08      ; set device number
                    ;               ldy #$0f      ; set command channel
                    ;               jsr SETLFS    ; set logical file parameters
                    ;               jsr OPEN      ; open a logical file
                    ;               bcs DiskError ; disk error exit
                    ;                        
                    ; .DataChannel  lda #$01      ; length data set name
                    ;               ldx #<F_name  ; '#'
                    ;               ldy #>F_name  ; 
                    ;               jsr SETNAM    ; Set Filename Parameters
                    ;                        
                    ;               lda #$02      ; set logical file number
                    ;               ldx #$08      ; set device number
                    ;               ldy #$02      ; data channel
                    ;               jsr SETLFS    ; set logical file parameters
                    ;               jsr OPEN      ; open a logical file
                    ;               bcs DiskError ; disk error exit
                    ;                        
                    ; Exit          rts
                    ;               
                    ; F_Name        dc.b $23 ; #
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : SETLFS and SETNAM
                    ; Regs in     : - - -
                    ; Regs out    : - - -
                    ; Regs used   : A X Y
                    ; Stack       : none
                    ; RC          : C=1 and 0 (Tape only), 1, 2, 4, 5, 6 (if file no = $00), 240, READST
                    ; ----------------------------------------------------------------------------------------- ;
OPEN_Ptr    = $031A ; Real address vector
OPEN_Mem    = $F34A ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
CLOSE       = $FFC3 ; Purpose     : Close a logical file
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : CLOSE a logical file after all I/O operations have been completed.
                    ;             : The accumulator is loaded with the logical file number to be closed
                    ;             : (the same number used when the file was opened using the OPEN routine).
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : lda #$0f      ; set logical file number
                    ;               jsr CLOSE     ; close logical file
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : A - -
                    ;             : A = Logical file number
                    ; Regs out    : - - -
                    ; Regs used   : A X Y
                    ; Stack       : 2+
                    ; RC          : 0 (Tape write), 240, READST
                    ; ----------------------------------------------------------------------------------------- ;
CLOSE_Ptr   = $031C ; Real address vector
CLOSE_Mem   = $F291 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
CHKIN       = $FFC6 ; Purpose     : Open channel for input
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Any logical file that has already been opened by the KERNAL OPEN routine can
                    ;               be defined as an input channel by this routine.
                    ;               The device intended to open a channel to must be an input device, otherwise
                    ;               an error will occur and the routine will be aborted.
                    ;               CHKIN must be called before data can be recieved with the CHRIN or the GETIN
                    ;               KERNAL routines from anywhere other than the keyboard.
                    ;               If keyboard input is desired and no other input channels are opened
                    ;               the calls to this routine and to the OPEN routine are not needed.
                    ;               When used to open a channel to a device on the serial bus, this routine will
                    ;               automatically send the TALK address specified by the OPEN routine (and a
                    ;               secondary address if there was one).
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : jsr CLRCHN        ; restore default devices
                    ;               
                    ;               ldx #$0f          ; command channel
                    ;               jsr CHKOUT        ; define an Output Channel
                    ;               bcs DiskError     ; 
                    ;               
                    ;               ldy #$00          ; 
                    ; CmdOut        lda BlkRWCmd,y    ; read disk block: u1:02_0_tt_ss<cr>
                    ;               beq DataGet       ; 
                    ;               
                    ;               jsr CHROUT        ; output a character
                    ;               iny               ; 
                    ;               jmp CmdOut        ; 
                    ;               
                    ;               jsr CLRCHN        ; restore default devices
                    ;               
                    ; DataGet       ldx #$02          ; data channel
                    ;               jsr CHKIN         ; define an input channel
                    ;               bcs DiskError     ; 
                    ;               
                    ;               jsr CHRIN         ; input a character
                    ;               
                    ;               ldy #$00          ; 
                    ; DataIn        jsr CHRIN         ; input a character
                    ;               sta Data,y        ; get disk data byte
                    ;               iny               ; 
                    ;               bne DataIn        ; 
                    ; Exit          rts               ; 
                    ; 
                    ; BlkRWCmd      dc.b $55 ; u - u1=read
                    ; BlkRW         dc.b $31 ; 1
                    ;               dc.b $3a ; :
                    ;               dc.b $30 ; 0
                    ;               dc.b $32 ; 2
                    ;               dc.b $20 ; <blank>
                    ;               dc.b $30 ; 0
                    ;               dc.b $20 ; <blank>
                    ; BlkRWTrkHi    dc.b $30 ; 0 - Track
                    ; BlkRWTrkLo    dc.b $33 ; 3 - Track
                    ;               dc.b $20 ; <blank>
                    ; BlkRWSecHi    dc.b $30 ; 0 - Sector
                    ; BlkRWSecLo    dc.b $30 ; 0 - Sector
                    ;               dc.b $0d ; <enter>
                    ;               dc.b $00 ; <end>
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : (OPEN)
                    ; Regs in     : - X -
                    ;             : X = Logical file number
                    ; Regs out    : - - -
                    ; Regs used   : A X -
                    ; Stack       : none
                    ; RC          : 0 (Tape read), 3, 5, 6 (see ErrorCodes)
                    ; ----------------------------------------------------------------------------------------- ;
CHKIN_Ptr   = $031E ; Real address vector
CHKIN_Mem   = $F20E ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
CHKOUT      = $FFC9 ; Purpose     : Open channel for output
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Any logical file number that has been created by the KERNAL routine OPEN can
                    ;               be defined as an output channel by this routine. 
                    ;               The device intended to open a channel to must be an output device, otherwise
                    ;               an error will occur and the routine will be aborted.
                    ;               This routine must be called before any data is sent to any output device unless
                    ;               you want to use the C64 screen as your output device. 
                    ;               If screen output is desired and there are no other output channels already
                    ;               defined then calls to this routine and to the OPEN routine are not needed.
                    ;               When used to open a channel to a device on the serial bus, this routine will
                    ;               automatically send the LISTEN address specified by the OPEN routine (and a
                    ;               secondary address if there was one).
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : jsr CLRCHN        ; restore default devices
                    ;               
                    ;               ldx #$02          ; data channel
                    ;               jsr CHKOUT        ; define an output channel
                    ;               bcs DiskError     ; 
                    ;                      
                    ;               ldy #$00
                    ; DataOut       lda Data,y        ; put data byte
                    ;               jsr CHROUT        ; output a character
                    ;               iny               ; 
                    ;               bne DataOut       ; 
                    ;               
                    ;               jsr CLRCHN        ; restore default devices
                    ;               
                    ;               ldx #$0f          ; command channel
                    ;               jsr CHKOUT        ; define an output channel
                    ;               
                    ;               ldy #$00          ; 
                    ; CmdOut        lda BlkRWCmd,y    ; write disk block: u2:02_0_tt_ss<cr>
                    ;               beq Exit          ; 
                    ;               
                    ;               jsr CHROUT        ; output a character
                    ;               iny               ; 
                    ;               jmp CmdOut        ; 
                    ; Exit          rts               ; 
                    ; 
                    ; BlkRWCmd      dc.b $55 ; u - u2=write
                    ; BlkRW         dc.b $32 ; 2
                    ;               dc.b $3a ; :
                    ;               dc.b $30 ; 0
                    ;               dc.b $32 ; 2
                    ;               dc.b $20 ; <blank>
                    ;               dc.b $30 ; 0
                    ;               dc.b $20 ; <blank>
                    ; BlkRWTrkHi    dc.b $30 ; 0 - Track
                    ; BlkRWTrkLo    dc.b $33 ; 3 - Track
                    ;               dc.b $20 ; <blank>
                    ; BlkRWSecHi    dc.b $30 ; 0 - Sector
                    ; BlkRWSecLo    dc.b $30 ; 0 - Sector
                    ;               dc.b $0d ; <enter>
                    ;               dc.b $00 ; <end>
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : (OPEN)
                    ; Regs in     : - X -
                    ; Input       : X = Logical file number
                    ; Regs out    : - - -
                    ; Regs used   : A X -
                    ; Output      : 
                    ; Stack       : 4+
                    ; RC          : 0 (Tape write), 3, 5, 7 (see ErrorCodes)
                    ; ----------------------------------------------------------------------------------------- ;
CHKOUT_Ptr  = $0320 ; Real address vector
CHKOUT_Mem  = $F250 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
CLRCHN      = $FFCC ; Purpose     : Close input and output channels 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Clears all open channels and restores the I/O channels to their original
                    ;               default values.
                    ;               Called after opening other I/O channels and using them for I/O operations. 
                    ;               Automatically called when the KERNAL CLALL routine is executed.
                    ;               The default input  device is 0 (keyboard). 
                    ;               The default output device is 3 (C64 screen).
                    ;               If one of the channels to be closed is to the serial port:
                    ;                 - an UNTALK signal is sent first to clear the input channel   or
                    ;                 - an UNLISTEN is sent to clear the output channel
                    ;               By not calling this routine (and leaving listeners active on the serial bus)
                    ;               several devices can receive the same data from the C64 at the same time.
                    ;               One way to take advantage of this would be to command the printer to TALK and the
                    ;               disk to LISTEN. This would allow direct printing of a disk file.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : see CHKIN/CHKOUT
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - - -
                    ; Regs out    : - - -
                    ; Regs used   : A X -
                    ; Stack       : 9
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
CLRCHN_Ptr  = $0322 ; Real address vector
CLRCHN_Mem  = $F333 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
CHRIN       = $FFCF ; Purpose     : Input character from channel 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Gets a byte of data from a channel already set up as the input channel by the
                    ;               KERNAL routine CHKIN. 
                    ;               If the CHKIN has NOT been used to define another input channel all data is
                    ;               expected from the keyboard.
                    ;               The data byte is returned in the accumulator.
                    ;               The channel remains open after the call.
                    ;               Input from the keyboard is handled in a special way:
                    ;                 - The cursor is turned on, and blinks until a carriage return is typed on
                    ;                   the keyboard. All characters on the line (up to 88 characters) are stored
                    ;                   in the BASIC input buffer.
                    ;                 - These characters can be retrieved one at a time by calling this routine
                    ;                 - When the carriage return is retrieved the entire line has been processed.
                    ;               The next time this routine is called the whole process begins again.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : see CHKIN
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : If not keyboard: OPEN and CHKIN
                    ; Regs in     : - - -
                    ; Regs out    : A - -
                    ;             : A = Data byte
                    ; Regs used   : A - -
                    ; Stack       : 7+
                    ; RC          : See READST
                    ; ----------------------------------------------------------------------------------------- ;
CHRIN_Ptr   = $0324 ; Real address vector
CHRIN_Mem   = $F157 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
CHROUT      = $FFD2 ; Purpose     : Output character to channel
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Puts a character to an already opened channel. 
                    ;               If the CHKOUT has NOT been used to define another input channel all data is
                    ;               send to the screen.
                    ;               The data byte to be output is loaded into the accumulator.
                    ;               The channel is left open after the call.
                    ; ----------------------------------------------------------------------------------------- ;
                    ;  NOTE       : Care must be taken when using this routine to send data to a specific serial
                    ;               device since data will be sent to all open output channels on the bus. Unless
                    ;               this is desired, all open output channels on the serial bus other than the
                    ;               intended destination channel must be closed by a call to the KERNAL CLRCHN.                ;                        
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : see CHKOUT
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : If not screen: OPEN and CHKOUT
                    ; Regs in     : A - -
                    ;             : A = Data byte
                    ; Regs out    : A - -
                    ; Regs used   : - - -
                    ; Stack       : 8+
                    ; RC          : See READST
                    ; ----------------------------------------------------------------------------------------- ;
CHROUT_Ptr  = $0326 ; Real address vector
CHROUT_Mem  = $F1CA ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
LOAD        = $FFD5 ; Purpose     : Load/verify RAM from a device 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : LOADs data bytes from any input device directly into the memory of the C64.
                    ;               It can also be used for a verify operation, comparing data from a device with
                    ;               data already in memory while leaving the data stored in RAM unchanged.
                    ;               The accumulator must be set to $00 for a LOAD   operation.
                    ;               The accumulator must be set to $01 for a VERIFY operation.
                    ;               The SETLFS and SETNAM routines must be used before calling this routine.
                    ;               If the input device is OPENed with a secondary address of $00 the header info
                    ;               from the device is ignored. The X/Y registers must then contain the starting
                    ;               address for the load. 
                    ;               If the input device is is OPENed with a secondary address of $01 the data is
                    ;               loaded into memory starting at the location specified by the file header.
                    ;               The address of the highest RAM location loaded is returned in X/Y.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : lda #$02                ; set logical file number
                    ;               ldx #$08                ; set device number
                    ;               ldy #$00                ; set secondary command number (new load address)
                    ;               jsr SETLFS              ; 
                    ;               
                    ;               lda #(F_nameX - F_name) ; load a with number of characters in file name
                    ;               ldx #<(F_name)          ; load x and y with address of file name
                    ;               ldy #>(F_name)          ; 
                    ;               jsr SETNAM              ; 
                    ;               
                    ;               lda #$00                ; flag: load
                    ;               ldx #<(F_start)         ; alternate start address
                    ;               ldy #>(F_start)         ; 
                    ;               jsr LOAD                ; 
                    ;               
                    ;               rts                     ; 
                    ;               
                    ;      F_name   dc.b 'FileName'         ; 
                    ;      F_nameX  = *                     ; 
                    ;      F_start  = $2000                 ; 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; NOTE        : You can NOT LOAD from the keyboard (0), RS-232 (2), or the screen (3).
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : SETLFS and SETNAM
                    ; Regs in     : A X Y
                    ;             : A   = 0 - Load
                    ;             : A   = 1 - Verify
                    ;             : X/Y = Load address (if secondary address was 0)
                    ; Regs out    : A X Y
                    ;             : X/Y = Address of last byte loaded/verified
                    ; Regs used   : A X Y
                    ; Stack       : none
                    ; RC          : 0, 4, 5, 8 (bus only), 9, READST
                    ; ----------------------------------------------------------------------------------------- ;
LOAD_Ptr    = $0330 ; Real address vector
LOAD_Mem    = $F49E ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
SAVE        = $FFD8 ; Purpose     : Save RAM to device
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : SAVEs a section of memory from an indirect address on Z-Page specified by
                    ;               the accumulator to the address stored in the X/Y registers.
                    ;               It is then sent to a logical file on an input/outputI/O device. 
                    ;               The SETLFS and SETNAM routines must be used before calling this routine.
                    ;               A file name is not required to SAVE to device 1 (the Datassette(TM) recorder).
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : lda #$01                ; set logical file number
                    ;               ldx #$08                ; set device number
                    ;               ldy #$00                ; set secondary command number (none)
                    ;               jsr SETLFS
                    ;               
                    ;               lda #(S_nameX - S_name) ; 
                    ;               ldx #<(S_name)          ;
                    ;               ldy #>(S_name)          ; 
                    ;               jsr SETNAM              ; 
                    ;               
                    ;               ldx #<(S_data)          ; 
                    ;               ldy #>(S_data)          ; start address
                    ;               stx $fb                 ; Z-Page address
                    ;               sty $fc                 ; 
                    ;               
                    ;               lda #$fb                ; pointer to Z-Page start address
                    ;               ldx #<(S_dataX)         ; end address + $01
                    ;               ldy #>(S_dataX)         ; 
                    ;               jsr SAVE                ; 
                    ;               bcs error               ; C=1 - an error has occurred
                    ;               
                    ;               rts                     ; 
                    ;               
                    ;      S_name   dc.b "FileName"         ; 
                    ;      S_nameX  = *                     ; 
                    ;      S_data   dc.b "Useful Data"      ; 
                    ;      S_dataX  = *                     ; end + $01
                    ; ----------------------------------------------------------------------------------------- ;
                    ; NOTE        : Device 0 (the keyboard), device 2 (RS-232), and device 3 (the screen) cannot
                    ;               be SAVEd to. An attempt causes an error occurs and the SAVE is stopped.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : SETLFS and SETNAM
                    ; Regs in     : A X Y
                    ;             : A   = Address of zero page register holding start address of memory area to save
                    ;             : X/Y = End address of memory area plus 1
                    ; Regs out    : - - -
                    ; Regs used   : A X Y
                    ; Stack       : none
                    ; RC          : 5, 8 (bus only), 9, READST
                    ; ----------------------------------------------------------------------------------------- ;
SAVE_Ptr    = $0332 ; Real address vector
SAVE_Mem    = $F5DD ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
SETTIM      = $FFDB ; Purpose     : Set real time (jiffy) clock
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : A system clock is maintained by an interrupt routine that updates the clock
                    ;               every 1/60th of a second (one "jiffy"). The clock is three bytes long, which
                    ;               gives it the capability to count up to 5,184,000 jiffies (24 hours). At that
                    ;               point the clock resets to zero.
                    ;                 - Time of Day at $00A0-$00A2 (software clock)
                    ;                 - The accumulator contains the most significant byte
                    ;                 - the X index register contains the next most significant byte
                    ;                 - the Y index register contains the least significant byte
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     :             ; set the clock to 10 minutes = 3600 jiffies
                    ;               lda #00     ; most significant
                    ;               ldx #>3600  ; 
                    ;               ldy #<3600  ; least significant
                    ;               jsr SETTIM
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : A X Y
                    ;             : A = MSB ToD value
                    ;             : Y = mid ToD value
                    ;             : Y = LSB ToD value
                    ; Regs out    : - - -
                    ; Regs used   : - - -
                    ; Stack       : 2
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
SETTIM_Mem  = $F6E4 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
RDTIM       = $FFDE ; Purpose     : Read real time (jiffy) clock 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : A system clock is maintained by an interrupt routine that updates the clock
                    ;               every 1/60th of a second (one "jiffy"). The clock is three bytes long, which
                    ;               gives it the capability to count up to 5,184,000 jiffies (24 hours). At that
                    ;               point the clock resets to zero.
                    ;                 - Time of Day at $00A0-$00A2 (software clock)
                    ;                 - The accumulator contains the most significant byte
                    ;                 - the X index register contains the next most significant byte
                    ;                 - the Y index register contains the least significant byte
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : jsr RDTIM     ; read clock
                    ;               sty Time+$00  ; LSB ToD value
                    ;               stx Time+$01  ; mid ToD value
                    ;               sta Time+$02  ; MSB ToD value
                    ;               
                    ; Time          = *           ; 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - - -
                    ; Regs out    : A X Y
                    ;             : A = MSB current ToD value
                    ;             : Y = mid current ToD value
                    ;             : Y = LSB current ToD value
                    ; Regs used   : A X Y
                    ; Stack       : 2
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
RDTIM_Mem   = $F6DD ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
STOP        = $FFE1 ; Purpose     : Check if <STOP> key is pressed
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : If the <STOP> key was pressed during a UDTIM call the Z-Flag is set.
                    ;               All other flags remain unchanged.
                    ;               The channels will be reset to default values too.
                    ;               If the <STOP> key is not pressed then the accumulator will contain a byte
                    ;               representing the last row of the keyboard scan.
                    ;               The user can also check for certain other keys this way.
                    ;                 - indicator at $0091 
                    ;                 - if pressed call CLRCHN and clear keyboard buffer
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : jsr UDTIM     ; scan for <STOP>
                    ;               jsr STOP      ; check
                    ;               bne cont      ; key not down
                    ;               jmp ready     ; was <STOP>
                    ; ----------------------------------------------------------------------------------------- ;
                    ;               ldx #$08      ; logical file #
                    ;               jsr CHKIN     ; 
                    ;               bcs endread   ; C=1 - error
                    ;               
                    ;      scl_flag = $28d        ; %001=shift, %010=control, %100=logo key
                    ;                             ; 
                    ;      readloop jsr CHRIN     ; get a character from serial bus
                    ;               bcs endread   ; C=1 - error
                    ;               
                    ;               jsr CHROUT    ; print the character
                    ;               jsr READST    ; get the status byte for last I/O
                    ;               bne endread   ; EOF or disk error
                    ;               
                    ;               jsr STOP      ; check the STOP key
                    ;               beq endread   ; quit if pressed
                    ;               
                    ;      pause    lda scl_flag  ; check shift, control or logo key pressed
                    ;               bne pause     ; pause while one of them is held down
                    ;               beq readloop  ; unconditional - continue while not (EOF or STOP)
                    ;               
                    ;      endread  jsr CLRCHN    ; clear the bus
                    ;               lda #$08      ; logical file #
                    ;               jsr CLOSE     ; 
                    ;               rts           ; 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - - -
                    ; Regs out    : A - -
                    ;             : Zero = 1 - Pressed
                    ;             : X = changed
                    ;             : Zero = 0 - Not pressed
                    ;             : A = last line of keyboard matrix
                    ; Regs used   : A (X) -
                    ; Stack       : none
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
STOP_Ptr    = $0328 ; Real address vector
STOP_Mem    = $F6ED ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
GETIN       = $FFE4 ; Purpose     : Get a character
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : If the channel is the keyboard one character is removed from the keyboard
                    ;               queue and returned as an ASCII value in the accumulator. 
                    ;               If the queue is empty the value returned in the accumulator will be $00.
                    ;               Characters are put into the queue automatically by an interrupt driven
                    ;               keyboard scan routine which calls the SCNKEY routine. 
                    ;               The keyboard buffer can hold up to 10 characters. After the buffer is filled,
                    ;               additional characters are ignored until at least one character has been
                    ;               removed from the queue. 
                    ;               If the channel is RS-232 then only the accumulator is used and a single
                    ;               character is returned.
                    ;               If the channel is serial, cassette, or screen BASIN should be called.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : see SCNKEY
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : If not keyboard: OPEN and CHKIN
                    ; Regs in     : - - -
                    ; Regs out    : A - -
                    ; Output      : A = Byte read
                    ;             : A = 0 - Buffer was empty
                    ; Regs used   : A - Y
                    ;             :   RS-232 : A - -
                    ;             :   Serial : A - -
                    ;             :   Tape   : A - Y
                    ; Stack       : 7+
                    ; RC          : See READST
                    ; ----------------------------------------------------------------------------------------- ;
GETIN_Ptr   = $032A ; Real address
GETIN_Mem   = $F13E ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
CLALL       = $FFE7 ; Purpose     : Close all files (and select default I/O channels)
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : The pointers into the open file table are reset, closing all files. 
                    ;               The CLRCHN routine is automatically called to reset the I/O channels.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : see OPEN
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - - -
                    ; Regs out    : - - -
                    ; Regs used   : A X -
                    ; Stack       : 11
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
CLALL_Ptr   = $032C ; Real address vector
CLALL_Mem   = $F32F ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
UDTIM       = $FFEA ; Purpose     : Increment real time (jiffy) clock
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Updates the system clock. Normally this routine is called by the normal KERNAL
                    ;               interrupt routine every 1/60th of a second. If the user program processes its
                    ;               own interrupts this routine must be called to update the time.
                    ;               In addition, the <STOP> key routine must be called, if the <STOP> key is to
                    ;               remain functional.
                    ;                 - Time of Day at $00A0-$00A2 (software clock)
                    ;                 - Update Stop key indicator at $0091
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - - -
                    ; Regs out    : - - -
                    ; Regs used   : A X -
                    ; Stack       : 2
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
UDTIM_Mem   = $F69B ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
SCREEN      = $FFED ; Purpose     : Return X,Y organization of screen
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Returns the format of the screen (40 columns in X and 25 lines in Y).
                    ;               Can be used to determine what machine a program is running on.
                    ;               This function has been implemented on the C64 to help upward compatibility
                    ;               of a program.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : jsr SCREEN  ; 
                    ;               stx MaxCol  ; 
                    ;               sty MaxRow  ; 
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - - -
                    ; Regs out    : - X Y
                    ;             : X = Number of columns (40)
                    ;             : Y = Number of rows    (25)
                    ; Regs used   : - X Y
                    ; Stack       : 2
                    ; RC          : none
SCREEN_Mem  = $E505 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
PLOT        = $FFF0 ; Purpose     : Read/set X,Y cursor position on screen
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : A call to this routine with the carry flag set loads the current position of
                    ;               the cursor on the screen (in X/Y coordinates) into the Y/X registers.
                    ;                 Y is the column number of the cursor location (6-39)
                    ;                 X is the row    number of the cursor location (0-24).
                    ;               A call with the carry bit clear moves the cursor to X,Y as determined by the
                    ;               Y/X registers.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : ldx #$02  ; move the cursor to row 2, column 5 (5,2)
                    ;               ldy #$05
                    ;               clc
                    ;               jsr PLOT
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - X Y
                    ;             : Carry = 0 - Move cursor to X/Y position
                    ;             :         X = Cursor column number
                    ;             :         Y = Cursor row    number
                    ; Regs out    : - X Y
                    ;             : Carry = 1 - Load cursor to X/Y
                    ;             :         X = Cursor column number
                    ;             :         Y = Cursor row    number
                    ; Regs used   : - (X Y if C=1)
                    ; Stack       : 2
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
PLOT_Mem    = $E50A ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
IOBASE      = $FFF3 ; Purpose     : Define I/O memory page - CIA #1($DC00)
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Description : Sets the X/Y registers to the address of the memory section where the memory
                    ;               mapped I/O devices are located. This address can then be used with an offset
                    ;               to access the memory mapped I/O devices in the C64. The offset is the number
                    ;               of locations from the beginning of the page on which the I/O register wanted
                    ;               is located.
                    ;                 The X register contains the low  order address byte.
                    ;                 The Y register contains the high order address byte.
                    ;               This routine exists to provide compatibility between the C64, VIC-20, and
                    ;               future models of the C64. 
                    ;               If the I/O locations for a machine language program are set by a call to this
                    ;               routine, they should still remain compatible with future versions of the C64,
                    ;               the KERNAL and BASIC.
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Example     : jsr IOBASE
                    ;               stx base          ; address registers
                    ;               sty base + $01
                    ;               ldy #$02          ; offset for CIDDRA of the user port
                    ;               lda #$00
                    ;               sta (point),y     ; set CIDDRA to $00
                    ; ----------------------------------------------------------------------------------------- ;
                    ; Preps       : none
                    ; Regs in     : - - -
                    ; Regs out    : - X Y
                    ;             : X/Y = CIA #1 base address ($DC00)
                    ; Regs used   : - X Y
                    ; Stack       : 2
                    ; RC          : none
                    ; ----------------------------------------------------------------------------------------- ;
IOBASE_Mem  = $E500 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
VNMI        = $FFFA ; Non-Maskable Interrupt Hardware Vector
                    ; ----------------------------------------------------------------------------------------- ;
VNMI_Mem    = $FE43 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
VRES        = $FFFC ; System Reset (RES) Hardware Vector
                    ; ----------------------------------------------------------------------------------------- ;
VRES_Mem    = $FCE2 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
VBRK        = $FFFE ; Maskable Interrupt Request and Break Hardware Vectors
                    ; ----------------------------------------------------------------------------------------- ;
VBRK_Mem    = $FF48 ; Real address
; ------------------------------------------------------------------------------------------------------------- ;
