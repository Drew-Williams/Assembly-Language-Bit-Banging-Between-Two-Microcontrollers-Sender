; uncomment following two lines if using 16f627 or 16f628. config uses internal oscillator
	LIST	p=16F628	; tell assembler what chip we are using
	include "p16f628.inc"	; include the defaults for the chip
	__config 0x3D18		; sets the configuration settings (oscillator type etc.)

	org 0x0000
	cblock 	0x20 		; start of general purpose registers
		Delay_Count	; delay loop counter
	endc
	
; un-comment the following two lines if using 16f627 or 16f628
	movlw	0x07
	movwf	CMCON		; turn comparators off (make it like a 16F84)
	
; set b port for output, a port for input
	bsf	STATUS,RP0	; select bank 1
	movlw	b'00000000'	
	movwf	TRISB	
	movlw	b'11000011'	; set RA1,0,7,6 as input
	movwf	TRISA
	bcf	STATUS,RP0	; return to bank 0

	bsf	PORTA, 2	; turn A2 line high
	
poll	    btfss   PORTA, 6	; poll RA6 untill high
	    goto    poll
	    
	    bcf	    PORTA, 2	; toggle is high, set RA2 low
	    call    Bit_Delay	; wait 100us
	    
	    btfsc   PORTA, 1	; if RA1 is high, set RA2 high
	    bsf	    PORTA, 2	; MSB
	    call    Bit_Delay
	    bcf	    PORTA, 2	; reset RA2
	    
	    btfsc   PORTA, 0
	    bsf	    PORTA, 2
	    call    Bit_Delay
	    bcf	    PORTA, 2	; reset RA2
	    
	    btfsc   PORTA, 7
	    bsf	    PORTA, 2	; LSB
	    call    Bit_Delay
	    
	    bsf	    PORTA, 2	; reset RA2 to high
	    
reset_loop  btfsc   PORTA, 6
	    goto    reset_loop	; loop until RA6 is low
	    
	    goto    poll
	
; 100us delay
Bit_Delay   MOVLW   d'24'	    ;1us
            MOVWF   Delay_Count	    ;1us
	    NOP			    ;1us
Bit_Wait    NOP			    ;1us x 24
            DECFSZ  Delay_Count , f ;1us x 23, 2us
            GOTO    Bit_Wait	    ;2us x 23
            RETURN		    ;2us
	
	end
