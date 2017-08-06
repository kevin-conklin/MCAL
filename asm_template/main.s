		AREA myprog, CODE, READONLY
		EXPORT __main

__main
		LDR	R0,=1		; LOAD R0 WITH 1
		LDR	R1,=2		; LOAD R1 WITH 2
		ADD R2,R0,R1	; R3 = R2 + R1
		
STOP	B STOP

		END
