		GET GPIO_helper.s
		GET data.s
		AREA myprog, CODE, READONLY
		ENTRY
		EXPORT __main
		
__main
		;system control - enable peripheral
		LDR		r0, =0x400FE608			; RCGCGPIO Register
		LDR		r2, =0x3F				; Turn on all GPIO
		STR		r2, [r0]				; Save to memory
		LDR		r4, beg_prog_dat

FLURBO
		;BL GET_PF4
    	BL PF3_HIGH
		BL DELAY
		BL PF3_LOW
		BL DELAY
		BL PF2_HIGH
		BL DELAY
		BL PF2_LOW
		BL DELAY
		BL PF1_HIGH
		BL DELAY
		BL PF1_LOW
		BL DELAY
		B FLURBO
		
		LDR	R0,=1		; LOAD R0 WITH 1
		LDR	R1,=2		; LOAD R1 WITH 2
		
STOP	B STOP

		END
