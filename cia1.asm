; ------------------------------------------------------------------------------------------------------------- ;
; Complex Interface Adapter (CIA) #1 Registers - $DC00-$DC0F
; ------------------------------------------------------------------------------------------------------------- ;
CIA1              = $DC00     ; Base address
; ------------------------------------------------------------------------------------------------------------- ;
CIA_Joy_Up        = %00000001 ; Joystick 1/2 - Up     0=pressed
CIA_Joy_Do        = %00000010 ; Joystick 1/2 - Down   0=pressed
CIA_Joy_Le        = %00000100 ; Joystick 1/2 - Left   0=pressed
CIA_Joy_Ri        = %00001000 ; Joystick 1/2 - Right  0=pressed
CIA_Joy_Fi        = %00010000 ; Joystick 1/2 - Fire   0=pressed
; ------------------------------------------------------------------------------------------------------------- ;
CIAPRA            = $DC00     ; Data Port Register A  Joystick #2
CIA_Joy_Pa        = %11000000 ; Paddle Set Selection Port A or B (only one bit may be active)
                              ; 
CIA_KeySelRow_00  = %00000001 ; Keyboard Check Row Selection  Joystick #2_Up
CIA_KeySelRow_01  = %00000010 ; 0=read   this column          Joystick #2_Down
CIA_KeySelRow_02  = %00000100 ; 1=ignore this column          Joystick #2_Left
CIA_KeySelRow_03  = %00001000 ;                               Joystick #2_Right
CIA_KeySelRow_04  = %00010000 ;                               Joystick #2_Fire
CIA_KeySelRow_05  = %00100000 ; 
CIA_KeySelRow_06  = %01000000 ; 
CIA_KeySelRow_07  = %10000000 ; 
; ------------------------------------------------------------------------------------------------------------- ;
CIAPRB            = $DC01     ; Data Port Register B  Joystick #1
CIA_KeyResCol_00  = %00000001 ; Keyboard Check Column Result  Joystick #1_Up
CIA_KeyResCol_01  = %00000010 ; 0=pressed                     Joystick #1_Down
CIA_KeyResCol_02  = %00000100 ; 1=not pressed                 Joystick #1_Left
CIA_KeyResCol_03  = %00001000 ;                               Joystick #1_Right
CIA_KeyResCol_04  = %00010000 ;                               Joystick #1_Fire
CIA_KeyResCol_05  = %00100000 ; 
CIA_KeyResCol_06  = %01000000 ; 
CIA_KeyResCol_07  = %10000000 ; 
                              ; 
CIA_OutTypeTiA    = %01000000 ; Toggle or pulse data output for Timer A - see CIACRA bit1/bit2
CIA_OutTypeTiB    = %10000000 ; Toggle or pulse data output for Timer B - see CIACRB bit1/bit2
; ----------------------------+-------------------------------------------------------------------------------- ;
                              ;  CIDDRA/CIDDRB must be set 1st
                              ;  Write to   Data Port A - set row bit to check=0 / row bit to ignore=1
                              ;  Read  from Data Port B - for the checked row: the col bit of key pressed=0 
; ----------------------------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
                              ;        !  bit7  !  bit6  !  bit5  !  bit4  !  bit3  !  bit2  !  bit1  !  bit0  !
                              ;  ------+--------+--------+--------+--------+--------+--------+--------+--------+
                              ;  bit7  !  Stop  !   Q    !   C=   !  Space !   2    !  Ctrl  !   <-   !   1    !
                              ;  ------+--------+--------+--------+--------+--------+--------+--------+--------+
                              ;  bit6  !   /    !   ^    !   =    ! Shft_R !  Home  !   ;    !   *    !  LIRA  !
                              ;  ------+--------+--------+--------+--------+--------+--------+--------+--------+
                              ;  bit5  !   ,    !   @    !   :    !   .    !   -    !   L    !   P    !   +    !
                              ;  ------+--------+--------+--------+--------+--------+--------+--------+--------+
                              ;  bit4  !   N    !   O    !   K    !   M    !   0    !   J    !   I    !   9    !
                              ;  ------+--------+--------+--------+--------+--------+--------+--------+--------+
                              ;  bit3  !   V    !   U    !   H    !   B    !   8    !   G    !   Y    !   7    !
                              ;  ------+--------+--------+--------+--------+--------+--------+--------+--------+
                              ;  bit2  !   X    !   T    !   F    !   C    !   6    !   D    !   R    !   5    !
                              ;  ------+--------+--------+--------+--------+--------+--------+--------+--------+
                              ;  bit1  ! Shft_L !   E    !   S    !   Z    !   4    !   A    !   W    !   3    !
                              ;  ------+--------+--------+--------+--------+--------+--------+--------+--------+
                              ;  bit0  ! Crsr_D !   F5   !   F3   !   F1   !   F7   ! Crsr_R ! Return ! Delete !
; ----------------------------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
;                             !  count !  $38   !   $30  !   $28  !   $20  !   $18  !   $10  !   $08  !   $00  !
; ----------------------------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
CIA_KeyWas_Stop   = %01111111 ; row 7
CIA_KeyWas_Q      = %10111111 ; 
CIA_KeyWas_Cmdre  = %11011111 ; 
CIA_KeyWas_Space  = %11101111 ; 
CIA_KeyWas_2      = %11110111 ; 
CIA_KeyWas_Ctrl   = %11111011 ; 
CIA_KeyWas_Arrow  = %11111101 ; 
CIA_KeyWas_1      = %11111110 ; 

CIA_KeyWas_Slash  = %01111111 ; row 6
CIA_KeyWas_Carret = %10111111 ; 
CIA_KeyWas_Equal  = %11011111 ; 
CIA_KeyWas_Shft_R = %11101111 ; 
CIA_KeyWas_Home   = %11110111 ; 
CIA_KeyWas_SemiK  = %11111011 ; 
CIA_KeyWas_Mult   = %11111101 ; 
CIA_KeyWas_Lira   = %11111110 ; 

CIA_KeyWas_Comma  = %01111111 ; row 5
CIA_KeyWas_At     = %10111111 ; 
CIA_KeyWas_Colon  = %11011111 ; 
CIA_KeyWas_Period = %11101111 ; 
CIA_KeyWas_Minus  = %11110111 ; 
CIA_KeyWas_L      = %11111011 ; 
CIA_KeyWas_P      = %11111101 ; 
CIA_KeyWas_Plus   = %11111110 ; 

CIA_KeyWas_N      = %01111111 ; row 4
CIA_KeyWas_O      = %10111111 ; 
CIA_KeyWas_K      = %11011111 ; 
CIA_KeyWas_M      = %11101111 ; 
CIA_KeyWas_0      = %11110111 ; 
CIA_KeyWas_J      = %11111011 ; 
CIA_KeyWas_I      = %11111101 ; 
CIA_KeyWas_9      = %11111110 ; 

CIA_KeyWas_V      = %01111111 ; row 3
CIA_KeyWas_U      = %10111111 ; 
CIA_KeyWas_H      = %11011111 ; 
CIA_KeyWas_B      = %11101111 ; 
CIA_KeyWas_8      = %11110111 ; 
CIA_KeyWas_G      = %11111011 ; 
CIA_KeyWas_Y      = %11111101 ; 
CIA_KeyWas_7      = %11111110 ; 

CIA_KeyWas_X      = %01111111 ; row 2
CIA_KeyWas_T      = %10111111 ; 
CIA_KeyWas_F      = %11011111 ; 
CIA_KeyWas_C      = %11101111 ; 
CIA_KeyWas_6      = %11110111 ; 
CIA_KeyWas_D      = %11111011 ; 
CIA_KeyWas_R      = %11111101 ; 
CIA_KeyWas_5      = %11111110 ; 

CIA_KeyWas_Shft_L = %01111111 ; row 1
CIA_KeyWas_E      = %10111111 ; 
CIA_KeyWas_S      = %11011111 ; 
CIA_KeyWas_Z      = %11101111 ; 
CIA_KeyWas_4      = %11110111 ; 
CIA_KeyWas_A      = %11111011 ; 
CIA_KeyWas_W      = %11111101 ; 
CIA_KeyWas_3      = %11111110 ; 

CIA_KeyWas_Crsr_D = %01111111 ; row 0
CIA_KeyWas_F5     = %10111111 ; 
CIA_KeyWas_F3     = %11011111 ; 
CIA_KeyWas_F1     = %11101111 ; 
CIA_KeyWas_F7     = %11110111 ; 
CIA_KeyWas_Crsr_R = %11111011 ; 
CIA_KeyWas_Return = %11111101 ; 
CIA_KeyWas_Delete = %11111110 ; 
; ------------------------------------------------------------------------------------------------------------- ;
CIDDRA            = $DC02     ; Data Direction Register A
                              ;   for keybord scan set all for output ($ff=default)
                              ;     Bit 0: Select Bit 0 of Data Port A for input or output (0=input, 1=output)
                              ;     Bit 1: Select Bit 1 of Data Port A for input or output (0=input, 1=output)
                              ;     Bit 2: Select Bit 2 of Data Port A for input or output (0=input, 1=output)
                              ;     Bit 3: Select Bit 3 of Data Port A for input or output (0=input, 1=output)
                              ;     Bit 4: Select Bit 4 of Data Port A for input or output (0=input, 1=output)
                              ;     Bit 5: Select Bit 5 of Data Port A for input or output (0=input, 1=output)
                              ;     Bit 6: Select Bit 6 of Data Port A for input or output (0=input, 1=output)
                              ;     Bit 7: Select Bit 7 of Data Port A for input or output (0=input, 1=output)
; ------------------------------------------------------------------------------------------------------------- ;
CIDDRB            = $DC03     ; Data Direction Register B
                              ;   for keybord scan set all for input ($00=default)
                              ;     Bit 0: Select Bit 0 of Data Port B for input or output (0=input, 1=output)
                              ;     Bit 1: Select Bit 1 of Data Port B for input or output (0=input, 1=output)
                              ;     Bit 2: Select Bit 2 of Data Port B for input or output (0=input, 1=output)
                              ;     Bit 3: Select Bit 3 of Data Port B for input or output (0=input, 1=output)
                              ;     Bit 4: Select Bit 4 of Data Port B for input or output (0=input, 1=output)
                              ;     Bit 5: Select Bit 5 of Data Port B for input or output (0=input, 1=output)
                              ;     Bit 6: Select Bit 6 of Data Port B for input or output (0=input, 1=output)
                              ;     Bit 7: Select Bit 7 of Data Port B for input or output (0=input, 1=output)
; ------------------------------------------------------------------------------------------------------------- ;
TIMALO            = $DC04     ; Timer A (low byte)  : TIME = LATCH VALUE / CLOCK SPEED
                              ;   Read : Current State of Timer A
                              ;   Write: Value to be loaded at next start of Timer A
                              ;
                              ;   LATCH VALUE = TIMER LOW + 256 * TIMER HIGH
                              ;   CLOCK SPEED = 1,022,370 cycles per second for NTSC monitors
                              ;               =   985,250 cycles per second for PAL  monitors
; ------------------------------------------------------------------------------------------------------------- ;
TIMAHI            = $DC05     ; Timer A (high byte) : TIME = LATCH VALUE / CLOCK SPEED
; ------------------------------------------------------------------------------------------------------------- ;
TIMBLO            = $DC06     ; Timer B (low byte)  : TIME = LATCH VALUE / CLOCK SPEED
; ------------------------------------------------------------------------------------------------------------- ;
TIMBHI            = $DC07     ; Timer B (high byte) : TIME = LATCH VALUE / CLOCK SPEED
; ------------------------------------------------------------------------------------------------------------- ;
; The ToD clock registers stop update the registers (latch) as soon as the HOURS register is read/written
; The ToD clock continues to keep time internally
; The ToD clock starts updating the registers again when the TENTHS of seconds register is read
; 
; If MINUTES or SECONDS or TENTHS are read/written no latching will occur
; 
; ==> Anytime HOURS are read/write a read/write of TENTHS must follow 
;     or else the registers will not continue to update
; ------------------------------------------------------------------------------------------------------------- ;
TODTEN            = $DC08     ; Time of Day Clock Tenths of Seconds
                              ;   Bits 0-3: Time of Day tenths of second digit (BCD)
                              ;   Bits 4-7: Unused
; ------------------------------------------------------------------------------------------------------------- ;
TODSEC            = $DC09     ; Time of Day Clock Seconds
                              ;   Bits 0-3: Second digit of Time of Day seconds (BCD)
                              ;   Bits 4-6: First digit of Time of Day seconds  (BCD)
                              ;   Bit    7: Unused
; ------------------------------------------------------------------------------------------------------------- ;
TODMIN            = $DC0A     ; Time of Day Clock Minutes
                              ;   Bits 0-3: Second digit of Time of Day minutes (BCD)
                              ;   Bits 4-6: First digit of Time of Day minutes (BCD)
                              ;   Bit    7: Unused
; ------------------------------------------------------------------------------------------------------------- ;
TODHRS            = $DC0B     ; Time of Day Clock Hours
                              ;   Bits 0-3: Second digit of Time of Day hours (BCD)
                              ;   Bit    4: First digit of Time of Day hours (BCD)
                              ;   Bits 5-6: Unused
                              ;   Bit    7: AM/PM Flag (1=PM, 0=AM)
; ------------------------------------------------------------------------------------------------------------- ;
CIASDR            = $DC0C     ; Serial Data Port
; ------------------------------------------------------------------------------------------------------------- ;
CIAICR            = $DC0D     ; Interrupt Control Register
                              ;   Bit 0:  Read / did Timer A count down to 0?         (1=yes)
                              ;           Write/ enable or disable Timer A interrupt  (1=enable, 0=disable)
                              ;   Bit 1:  Read / did Timer B count down to 0?         (1=yes)
                              ;           Write/ enable or disable Timer B interrupt  (1=enable, 0=disable)
                              ;   Bit 2:  Read / did Time of Day Clock reach the alarm time?  (1=yes)
                              ;           Write/ enable or disable TOD clock alarm interrupt  (1=enable, 0=disable)
                              ;   Bit 3:  Read / did the serial shift register finish a byte?       (1=yes)
                              ;           Write/ enable or disable serial shift register interrupt  (1=enable, 0=disable)
                              ;   Bit 4:  Read / was a signal sent on the flag line?    (1=yes)
                              ;           Write/ enable or disable FLAG line interrupt  (1=enable, 0=disable)
                              ;   Bit 5:  Not used
                              ;   Bit 6:  Not used
                              ;   Bit 7:  Read / did any CIA #1 source cause an interrupt?  (1=yes)
                              ;           Write/ set or clear bits of this register         
                              ;             (1=bits written with 1 will be set, 0=bits written with 1 will be cleared)
; ------------------------------------------------------------------------------------------------------------- ;
CIACRA            = $DC0E     ; Control Register A
                              ;   Bit 0:  Start Timer A (1=start, 0=stop)
                              ;   Bit 1:  Select Timer A output on Port B (1=Timer A output appears on Bit 6 of Port B)
                              ;   Bit 2:  Port B output mode  (1=toggle Bit 6, 0=pulse Bit 6 for one cycle)
                              ;   Bit 3:  Timer A run mode    (1=one-shot, 0=continuous)
                              ;   Bit 4:  Force latched value to be loaded to Timer A counter (1=force load strobe)
                              ;   Bit 5:  Timer A input mode  
                              ;             (1=count microprocessor cycles, 0=count signals on CNT line at pin 4 of User Port)
                              ;   Bit 6:  Serial Port (56332, $DC0C) mode (1=output, 0=input)
                              ;   Bit 7:  Time of Day Clock frequency (1=50 Hz required on TOD pin, 0=60 Hz)
; ------------------------------------------------------------------------------------------------------------- ;
CIACRB            = $DC0F     ; Control Register B
                              ;   Bit    0: Start Timer B (1=start, 0=stop)
                              ;   Bit    1: Select Timer B output on Port B (1=Timer B output appears on Bit 7 of Port B)
                              ;   Bit    2: Port B output mode (1=toggle Bit 7, 0=pulse Bit 7 for one cycle)
                              ;   Bit    3: Timer B run mode (1=one-shot, 0=continuous)
                              ;   Bit    4: Force latched value to be loaded to Timer B counter (1=force load strobe)
                              ;   Bits 5-6: Timer B input mode
                              ;               00 = Timer B counts microprocessor cycles
                              ;               01 = Count signals on CNT line at pin 4 of User Port
                              ;               10 = Count each time that Timer A counts down to 0
                              ;               11 = Count Timer A 0's when CNT pulses are also present
                              ;   Bit    7: Select Time of Day write
                              ;               0=writing to TOD registers sets alarm 
                              ;               1=writing to TOD registers sets clock
; ------------------------------------------------------------------------------------------------------------- ;
; $DC10-$DCFF   ; CIA #1 Register Images - Mirror of $DC00-$DC0F
; ------------------------------------------------------------------------------------------------------------- ;
; CIAPRA  = $DCF0 ; Data Port Register A
; CIAPRB  = $DCF1 ; Data Port Register B
; CIDDRA  = $DCF2 ; Data Direction Register A
; CIDDRB  = $DCF3 ; Data Direction Register B
; TIMALO  = $DCF4 ; Timer A (low byte)  : TIME = LATCH VALUE / CLOCK SPEED
; TIMAHI  = $DCF5 ; Timer A (high byte) : TIME = LATCH VALUE / CLOCK SPEED
; TIMBLO  = $DCF6 ; Timer B (low byte)  : TIME = LATCH VALUE / CLOCK SPEED
; TIMBHI  = $DCF7 ; Timer B (high byte) : TIME = LATCH VALUE / CLOCK SPEED
; TODTEN  = $DCF8 ; Time of Day Clock Tenths of Seconds
; TODSEC  = $DCF9 ; Time of Day Clock Seconds
; TODMIN  = $DCFA ; Time of Day Clock Minutes
; TODHRS  = $DCFB ; Time of Day Clock Hours
; CIASDR  = $DCFC ; Serial Data Port
; CIAICR  = $DCFD ; Interrupt Control Register
; CIACRA  = $DCFE ; Control Register A
; CIACRB  = $DCFF ; Control Register B
; ------------------------------------------------------------------------------------------------------------- ;
