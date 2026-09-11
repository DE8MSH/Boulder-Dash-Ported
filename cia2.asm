; ------------------------------------------------------------------------------------------------------------- ;
; Complex Interface Adapter (CIA) #2 Registers - $DD00-$DD0F
; ------------------------------------------------------------------------------------------------------------- ;
CIA2              = $DD00     ; Base address
; ------------------------------------------------------------------------------------------------------------- ;
CI2PRA            = $DD00     ; Data Port Register A
                              ;   Bits 0-1: Select the 16K VIC-II chip memory bank
                              ;     03 = $0000-$3fff - bank 0
                              ;     02 = $4000-$7fff - bank 1
                              ;     01 = $8000-$bfff - bank 2
                              ;     00 = $c000-$ffff - bank 3
; ------------------------------------------------------------------------------------------------------------- ;
VIC_MemBankClr    = $fc       ; ######..
                              ; 
VIC_MemBank_0     = %00000011 ; $03 = $0000-$3fff
VIC_MemBase_0       = $0000   ; 
VIC_MemBank_1     = %00000010 ; $02 = $4000-$7fff
VIC_MemBase_1       = $4000   ; 
VIC_MemBank_2     = %00000001 ; $01 = $8000-$bfff
VIC_MemBase_2       = $8000   ; 
VIC_MemBank_3     = %00000000 ; $00 = $c000-$ffff
VIC_MemBase_3       = $c000   ; 
; ------------------------------------------------------------------------------------------------------------- ;
                              ;   Bit 2   : RS-232 data output (Sout)/Pin M of User Port
                              ;   Bit 3   : Serial bus ATN signal output
                              ;   Bit 4   : Serial bus clock pulse output
                              ;   Bit 5   : Serial bus data output
                              ;   Bit 6   : Serial bus clock pulse input
                              ;   Bit 7   : Serial bus data input
; ------------------------------------------------------------------------------------------------------------- ;
CI2PRB            = $DD01     ; Data Port B
                              ;   Bit 0: RS-232 data input (SIN)/ Pin C of User Port
                              ;   Bit 1: RS-232 request to send (RTS)/ Pin D of User Port
                              ;   Bit 2: RS-232 data terminal ready (DTR)/ Pin E of User Port
                              ;   Bit 3: RS-232 ring indicator (RI)/ Pin F of User Port
                              ;   Bit 4: RS-232 carrier detect (DCD)/ Pin H of User Port
                              ;   Bit 5: Pin J of User Port
                              ;   Bit 6: RS-232 clear to send (CTS)/ Pin K of User Port
                              ;          Toggle or pulse data output for Timer A
                              ;   Bit 7: RS-232 data set ready (DSR)/ Pin L of User Port
                              ;          Toggle or pulse data output for Timer B
; ------------------------------------------------------------------------------------------------------------- ;
C2DDRA            = $DD02     ; Data Direction Register A
                              ;   Bit 0: Select Bit 0 of data Port A for input or output (0=input, 1=output)
                              ;   Bit 1: Select Bit 1 of data Port A for input or output (0=input, 1=output)
                              ;   Bit 2: Select Bit 2 of data Port A for input or output (0=input, 1=output)
                              ;   Bit 3: Select Bit 3 of data Port A for input or output (0=input, 1=output)
                              ;   Bit 4: Select Bit 4 of data Port A for input or output (0=input, 1=output)
                              ;   Bit 5: Select Bit 5 of data Port A for input or output (0=input, 1=output)
                              ;   Bit 6: Select Bit 6 of data Port A for input or output (0=input, 1=output)
                              ;   Bit 7: Select Bit 7 of data Port A for input or output (0=input, 1=output)
; ------------------------------------------------------------------------------------------------------------- ;
C2DDRB            = $DD03     ; Data Direction Register B
                              ;   Bit 0: Select Bit 0 of data Port B for input or output (0=input, 1=output)
                              ;   Bit 1: Select Bit 1 of data Port B for input or output (0=input, 1=output)
                              ;   Bit 2: Select Bit 2 of data Port B for input or output (0=input, 1=output)
                              ;   Bit 3: Select Bit 3 of data Port B for input or output (0=input, 1=output)
                              ;   Bit 4: Select Bit 4 of data Port B for input or output (0=input, 1=output)
                              ;   Bit 5: Select Bit 5 of data Port B for input or output (0=input, 1=output)
                              ;   Bit 6: Select Bit 6 of data Port B for input or output (0=input, 1=output)
                              ;   Bit 7: Select Bit 7 of data Port B for input or output (0=input, 1=output)
; ------------------------------------------------------------------------------------------------------------- ;
TI2ALO            = $DD04     ; Timer A (low byte)
; ------------------------------------------------------------------------------------------------------------- ;
TI2AHI            = $DD05     ; Timer A (high byte)
; ------------------------------------------------------------------------------------------------------------- ;
TI2BLO            = $DD06     ; Timer B (low byte)
; ------------------------------------------------------------------------------------------------------------- ;
TI2BHI            = $DD07     ; Timer B (high byte)
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
TO2TEN            = $DD08     ; Time of Day Clock Tenths of Seconds
                              ;   Bits 0-3: Time of Day tenths of second digit (BCD)
                              ;   Bits 4-7: Unused
; ------------------------------------------------------------------------------------------------------------- ;
TO2SEC            = $DD09     ; Time of Day Clock Seconds
                              ;   Bits 0-3: Second digit of Time of Day seconds (BCD)
                              ;   Bits 4-6: First digit of Time of Day seconds (BCD)
                              ;   Bit    7: Unused
; ------------------------------------------------------------------------------------------------------------- ;
TO2MIN            = $DD0A     ; Time of Day Clock Minutes
                              ;   Bits 0-3: Second digit of Time of Day minutes (BCD)
                              ;   Bits 4-6: First digit of Time of Day minutes (BCD)
                              ;   Bit    7: Unused
; ------------------------------------------------------------------------------------------------------------- ;
TO2HRS            = $DD0B     ; Time of Day Clock Hours
                              ;   Bits 0-3: Second digit of Time of Day hours (BCD)
                              ;   Bit    4: First digit of Time of Day hours (BCD)
                              ;   Bits 5-6: Unused
                              ;   Bit    7: AM/PM flag (1=PM, 0=AM)
; ------------------------------------------------------------------------------------------------------------- ;
CI2SDR            = $DD0C     ; Serial Data Port
; ------------------------------------------------------------------------------------------------------------- ;
CI2ICR            = $DD0D     ; Interrupt Control Register
                              ;   Bit 0:  Read / did Timer A count down to 0?  (1=yes)
                              ;           Write/ enable or disable Timer A interrupt (1=enable, 0=disable)
                              ;   Bit 1:  Read / did Timer B count down to 0?  (1=yes)
                              ;           Write/ enable or disable Timer B interrupt (1=enable, 0=disable)
                              ;   Bit 2:  Read / did Time of Day Clock reach the alarm time? (1=yes)
                              ;           Write/ enable or disable TOD clock alarm interrupt (1=enable, 0=disable)
                              ;   Bit 3:  Read / did the serial shift register finish a byte?  (1=yes)
                              ;           Write/ enable or disable serial shift register interrupt (1=enable, 0=disable)
                              ;   Bit 4:  Read / was a signal sent on the FLAG line?  (1=yes)
                              ;           Write/ enable or disable FLAG line interrupt (1=enable, 0=disable)
                              ;   Bit 5:  Not used
                              ;   Bit 6:  Not used
                              ;   Bit 7:  Read / did any CIA #2 source cause an interrupt?  (1=yes)
                              ;           Write/ set or clear bits of this register
                              ;             (1=bits written with 1 will be set, 0=bits written with 1 will be cleared)
; ------------------------------------------------------------------------------------------------------------- ;
CI2CRA            = $DD0E     ; Control Register A
                              ;   Bit 0:  Start Timer A (1=start, 0=stop)
                              ;   Bit 1:  Select Timer A output on Port B (1=Timer A output appears on Bit 6 of Port B)
                              ;   Bit 2:  Port B output mode  (1=toggle Bit 6, 0=pulse Bit 6 for one cycle)
                              ;   Bit 3:  Timer A run mode    (1=one-shot, 0=continuous)
                              ;   Bit 4:  Force latched value to be loaded to Timer A counter (1=force load strobe)
                              ;   Bit 5:  Timer A input mode
                              ;             (1=count microprocessor cycles, 0=count signals on CNT line at pin 4 of User Port)
                              ;   Bit 6:  Serial Port (56588, $DD0C) mode (1=output, 0=input)
                              ;   Bit 7:  Time of Day Clock frequency (1=50 Hz required on TOD pin, 0=60 Hz)
; ------------------------------------------------------------------------------------------------------------- ;
CI2CRB            = $DD0F     ; Control Register B
                              ;   Bit    0: Start Timer B (1=start, 0=stop)
                              ;   Bit    1: Select Timer B output on Port B (1=Timer B output appears on Bit 7 of Port B)
                              ;   Bit    2: Port B output mode (1=toggle Bit 7, 0=pulse Bit 7 for one cycle)
                              ;   Bit    3: Timer B run mode (1=one shot, 0=continuous)
                              ;   Bit    4: Force latched value to be loaded to Timer B counter (1=force load strobe)
                              ;   Bits 5-6: Timer B input mode
                              ;               00 = Timer B counts microprocessor cycles
                              ;               01 = Count signals on CNT line at pin 4 of User Port
                              ;               10 = Count each time that Timer A counts down to 0
                              ;               11 = Count Timer A 0's when CNT pulses are also present
                              ;   Bit    7: Select Time of Day write
                              ;               0=writing to TOD registers sets alarm
                              ;               1=writing to ROD registers sets clock
; ------------------------------------------------------------------------------------------------------------- ;
; $DD10-$DDFF   ; CIA #2 Register Images - Mirror of $DD00-$DD0F
; ------------------------------------------------------------------------------------------------------------- ;
; CI2PRA  = $DD10 ; Data Port Register A
; CI2PRB  = $DD11 ; Data Port B
; C2DDRA  = $DD12 ; Data Direction Register A
; C2DDRB  = $DD13 ; Data Direction Register B
; TI2ALO  = $DD14 ; Timer A (low byte)
; TI2AHI  = $DD15 ; Timer A (high byte)
; TI2BLO  = $DD16 ; Timer B (low byte)
; TI2BHI  = $DD17 ; Timer B (high byte)
; TO2TEN  = $DD18 ; Time of Day Clock Tenths of Seconds
; TO2SEC  = $DD19 ; Time of Day Clock Seconds
; TO2MIN  = $DD1A ; Time of Day Clock Minutes
; TO2HRS  = $DD1B ; Time of Day Clock Hours
; CI2SDR  = $DD1C ; Serial Data Port
; CI2ICR  = $DD1D ; Interrupt Control Register
; CI2CRA  = $DD1E ; Control Register A
; CI2CRB  = $DD1F ; Control Register B
; ------------------------------------------------------------------------------------------------------------- ;
