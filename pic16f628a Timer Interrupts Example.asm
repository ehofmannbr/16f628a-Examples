
;**********************************************************************
; Filename: F628a_BCD.asm
; Date:  OCT. 8, 2016 
; Author: Lewis Loflin lewis@bvu.net
; http://www.bristolwatch.com/PIC16F628A/index.htm
; Compiled on MPLAB 8.88
; Demonstrates how to use interrupts with TMR0	                                                     
; Counts 0-99 in BCD on 8 LEDs B.0 - B.7
; PIC16F628A use internal 4 mHz clock                                                     
;**********************************************************************

	list      p=16f628A           ; list directive to define processor
	#include <p16F628A.inc>       ; processor specific variable definitions
	errorlevel  -302              ; suppress message 302 from list file

__CONFIG   _CP_OFF & _LVP_OFF & _BOREN_OFF & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _INTOSC_OSC_NOCLKOUT 

; for 16F628A only	
; Use  _INTOSC_OSC_NOCLKOUT  for 
; internal 4 mHz osc and no ext reset, use pin RA5 as an input
; Use _HS_OSC for a 16 mHz ext crystal. 
; Use _XT_OSC for 4 mHz ext crystal. Page 95 in spec sheet. 

	cblock 0x20	; Begin General Purpose-Register
	COUNT1
	COUNT2
	COUNT3
	CNT
	TEMP
	endc


	ORG     0x000   ; processor reset vector
	goto    setup   ; go to beginning of program

setup ; init PIC16F628A

	movlw	0x07  ; Turn comparators off
	movwf	CMCON
	banksel TRISA    ; BSF	STATUS,RP0 Jump to bank 1 use BANKSEL instead
	clrf    TRISA
	clrf    TRISB
	banksel INTCON ; back to bank 0
	clrf	PORTA
	clrf	PORTB

	; setp TMR0 interrupts
	banksel OPTION_REG 
	movlw b'10000111' 
	; internal clock, pos edge, prescale 256
	movwf OPTION_REG
	banksel INTCON ; bank 0
	clrf	CNT

goto main


main
	; count 0-99 in BCD displayed on 8 LEDS PORTB
	MOVFW CNT
	ANDLW 0x0F ; mask out 4 upper bits
	SUBLW 0x0A ; test lower nibble
	BTFSS STATUS, Z ; test for dec 10
	GOTO LOC1 
	MOVFW CNT
	ADDLW 0x06
	MOVWF CNT
	; test upper nibble
	MOVWF TEMP
	SWAPF TEMP ; swap nibbles
	MOVFW TEMP
	ANDLW 0x0F  ; mask off upper 4 bits
	SUBLW 0x0A ; test for 0x0A
	BTFSS STATUS, Z ; test for dec 10
	GOTO LOC1
	MOVFW CNT ; upper nibble = 0xA0 add 0x60
	ADDLW 0x60
	MOVWF CNT
LOC1
 	MOVFW  CNT  ; display result
	MOVWF  PORTB
	CALL TMR0_DEL ; any delay routine
	INCF CNT ; CNT = CNT + 1	

	goto main 

; Timer0 delay routine
TMR0_DEL 
	MOVLW D'5' ; value X 0.05 sec. 20 is 1 sec. at 4mHz
	MOVWF COUNT1
	MOVLW D'59' ; 196 cycles before overflow
	MOVWF TMR0
	BCF INTCON, T0IF ; clear over flow flag bit 2
	BTFSS INTCON, T0IF ; wait for flag set
	GOTO $-1
	DECFSZ COUNT1
	GOTO $-6
	RETLW 0


END  ; directive 'end of program'
