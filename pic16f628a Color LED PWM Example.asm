#include "p16f628a.inc"

; CONFIG
; __config 0x3F71
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF

GPR_VAR	UDATA 0x20
timer1 RES 1
timer2 RES 1 
	
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

MAIN_PROG CODE                      ; let linker place main program

START
 ; Initialize Port B RB2 RB1 RB0 as outputs
 ; 1 = input, 0 = output 
 MOVLW b'11111000'
 ; Select Bank 1
 BCF STATUS, RP1 
 BSF STATUS, RP0
 MOVWF TRISB
 ; Select Bank 0
 BCF STATUS, RP1 
 BCF STATUS, RP0
 CLRF PORTB
 LOOP
 MOVLW 0x00
 MOVWF PORTB 
 CALL ESP
 MOVLW 0x01
 MOVWF PORTB 
 CALL ESP
 MOVLW 0x02
 MOVWF PORTB 
 CALL ESP
 MOVLW 0x03
 MOVWF PORTB 
 CALL ESP
 GOTO LOOP                          ; loop forever

ESP
 MOVLW .255
 MOVWF timer1
WAITPWMSLOT1 
 DECFSZ timer1, 1
 GOTO WAITPWMSLOT1
 RETURN
 
 
 END


