; ------------------------------------------------------------------------------------------------------------- ;
; CPU Port Data Direction Register
; ------------------------------------------------------------------------------------------------------------- ;
         ifnconst D6510 ; 
D6510     = $00   ; 6510 On-Chip I/O Data Direction
         endif    ; 
                  ;   0: Input  = Corresponding bit in R6510 can only be read
                  ;   1: Output = Corresponding bit in R6510 can also be written
                  ;
                  ; default: $2f = 0010 1111
; ------------------------------------------------------------------------------------------------------------- ;
; CPU Port Data Register
; ------------------------------------------------------------------------------------------------------------- ;                
         ifnconst R6510 ; 
R6510     = $01   ; 6510 On-Chip I/O Data
         endif    ; 
                  ;
                  ; Bits 0…2: Select Memory Configuration
                  ;
LORAM       = $01 ; Bit 0: = L  1=BASIC  0=RAM
HIRAM       = $02 ; Bit 1: = H  1=Kernal 0=RAM & BASIC switched out too as it needs the KERNAL
CHAREN      = $04 ; Bit 2: = C  1=I/O    0=ROM
                  ; Bit 3: Tape - Data Output Signal Level
                  ; Bit 4: Tape - Play Button Status 
                  ;        0=one of PLAY/RECORD/F.FWD/REW pressed
                  ;        1=no button Pressed
                  ; Bit 5: Tape - Motor Control
                  ;        0=motor on
                  ;        1=motor off
                  ; Bit 6: Not Implemented
                  ; Bit 7: Not Implemented
                  ;
                  ; default: $37 = 0011 0111
                  ; -------------------------------------
                  ;              $D000     $E000    $A000
                  ;       CHL    $DFFF     $FFFF    $BFFF
                  ; -------------------------------------
                  ; ..... 000 -> ram       ram      ram  
                  ; ..... 001 -> Charset   ram      ram  
                  ; ..... 010 -> Charset   Kernal   ram  
                  ; ..... 011 -> Charset   Kernal   BASIC
                  ; ..... 100 -> ram       ram      ram  
                  ; ..... 101 -> I/O       ram      ram  
                  ; ..... 110 -> I/O       Kernal   ram  
                  ; ..... 111 -> I/O       Kernal   BASIC <-- default
; ---------------------------------------------------------------------------------------------------------- ;                
BIKon       = $37 ; ..##. ### -> IO   ---  Kernal - Basic  - switch all on
B__off      = $36 ; ..##. ##. -> IO   ---  Kernal - RAM   
B_Koff      = $35 ; ..##. #.# -> IO   ---  RAM    - RAM   
BIKoff      = $34 ; ..##. #.. -> RAM  ---  RAM    - RAM   
BcKoff      = $33 ; ..##. .## -> CHAR ---  RAM    - RAM    - switch char on

Mem_BasOff  = %11111110 ; switch basic off
Mem_KerOff  = %11111101 ; switch kernal off
Mem_IoOff   = %11111011 ; switch IO off
Tap_MotOff  = %11011111 ; switch tape motor off

Mem_BasOn   = %00000001 ; switch basic on
Mem_KerOn   = %00000010 ; switch kernal on
Mem_IoOn    = %00000100 ; switch IO on

Tap_Stat    = %00010000 ; tape status
Tap_MotOn   = %00100000 ; switch tape motor on
; ------------------------------------------------------------------------------------------------------------- ;                
         ifnconst STACK ; 
STACK     = $0100       ; 
         endif          ; 
; ------------------------------------------------------------------------------------------------------------- ;                
CHARGEN   = $d000 ; character generator ROM
CHR_UP    = $d000 ; upper case
CHR_UPR   = $d400 ; upper case / reversed
CHR_LO    = $d800 ; lower case
CHR_LOR   = $dc00 ; lower case / reversed
; ------------------------------------------------------------------------------------------------------------- ;                
