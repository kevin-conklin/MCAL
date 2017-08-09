;Author: Richard Chase
;Data: 08/08/2017 
;Description
; This is a poorly written (but working) library  that will turn a GPIO 
; on or off.  Each time a ***_HIGH or ***_LOW is called, the pin is 
; configured, then it turns the pin high or low.  It will erase any
; previous pin configurations previously setup.  

;PB5 PB0 PB1 PE4 PE5 PB4 PA5 PA6 PA7 PD1 PD2 PD3 PE1 PE2 PE3 PF1  PF2 PF3
;PC4 PC5 PC6 PC7 PD6 PD7 PF4 PB2 PF0 PB7 PB6 PA4 PA3 PA2

MYDELAY	  EQU 0x00100000
	
PortABase EQU 0x40004000
PortBBase EQU 0x40005000
PortCBase EQU 0x40006000
PortDBase EQU 0x40007000
PortEBase EQU 0x40024000
PortFBase EQU 0x40025000


GPIODATA 	EQU 0x000 
GPIODIR 	EQU 0x400 
GPIOIS 		EQU 0x404 
GPIOIBE 	EQU 0x408 
GPIOIEV 	EQU 0x40C 
GPIOIM 		EQU 0x410 
GPIORIS 	EQU 0x414 
GPIOMIS 	EQU 0x418 
GPIOICR 	EQU 0x41C 
GPIOAFSEL 	EQU 0x420 
GPIODR2R 	EQU 0x500 
GPIODR4R 	EQU 0x504 
GPIODR8R 	EQU 0x508 
GPIOODR 	EQU 0x50C 
GPIOPUR 	EQU 0x510 
GPIOPDR 	EQU 0x514 
GPIOSLR 	EQU 0x518 
GPIODEN 	EQU 0x51C 
GPIOLOCK 	EQU 0x520 
GPIOCR 		EQU 0x524 
GPIOAMSEL 	EQU 0x528 
GPIOPCTL 	EQU 0x52C 
	
HIGH		EQU 1
LOW			EQU 0
	
	;enable the peripheral GPIO port F

	AREA	GPIO_FUNC, CODE, READONLY
	ALIGN
						
SET_GPIO						
	
	; 	  R0 is base register
	;     R1 is pin number 0-7
	;     R2 is on = 0xFFFFFFFF off = 0
	
	LDR R3, =1;					; 0b0000001 << 2
	LSL R3,R1 					; Shift R3 to creata a mask 0b00000100
	
	LDR R4, [R0,#GPIODIR]		; get the pin direction
	ORR	R4, R3					; make it an output
	STR R4, [R0,#GPIODIR]
	
	LDR R4, [R0,#GPIOAFSEL]		; get the alternate pin setup
	BIC	R4, R3					; no alternate
	STR R4, [R0,#GPIOAFSEL]		; save it
	
	LDR R4, [R0,#GPIOODR]		; get the open drain setup
	BIC	R4, R3					; no open drain
	STR R4, [R0,#GPIOODR]		; save it

	LDR R4, [R0,#GPIODEN]		; get the digital pin setup
	ORR	R4, R3					; digital enable
	STR R4, [R0,#GPIODEN]		; save it
	
	LDR 	R4, [R0,#GPIODATA+0x3fC]; get the current pin config
	CMP		R2, #0					; check if on or off
	ORRNE	R4, R3					; execute if val ! 0
	BICEQ   R4, R3					; execute if val == 0
	STR 	R4, [R0,#GPIODATA+0x3fC]; save it
	
	BX LR							; return back into the code

	LTORG
	
GET_GPIO						
	
	; 	  R0 is base register
	;     R1 is pin number 0-7
	
	LDR R3, =1;					; 0b0000001 << 2
	LSL R3,R1 					; Shift R3 to creata a mask 0b00000100
	
	LDR R4, [R0,#GPIODIR]		; get the pin direction
	BIC	R4, R3					; make it an input
	STR R4, [R0,#GPIODIR]
	
	LDR R4, [R0,#GPIOAFSEL]		; get the alternate pin setup
	BIC	R4, R3					; no alternate
	STR R4, [R0,#GPIOAFSEL]		; save it
	
	LDR R4, [R0,#GPIOODR]		; get the open drain setup
	BIC	R4, R3					; no open drain
	STR R4, [R0,#GPIOODR]		; save it
	
	LDR R4, [R0,#GPIOPUR]		; make it a pull up
	ORR	R4, R3					; 
	STR R4, [R0,#GPIOPUR]		; 

	LDR R4, [R0,#GPIODEN]		; get the digital pin setup
	ORR	R4, R3					; digital enable
	STR R4, [R0,#GPIODEN]		; save it
	
	LDR 	R4, [R0,R3,LSL #2]	; Load the pin info with mask
	;LDR 	R4, [R0,#GPIODATA+0x3fC]
	CLZ		R0,R3
	RSB		R0,R0,#31
	LSR		R4, R0				; shift to 0th bit
	
	BX LR							; return back into the code

	LTORG
	
PF2_HIGH
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortFBase
	LDR R1, =2;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}		
	BX LR;
	
PF2_LOW
	STMDB  SP!, {r0-r12,lr}		
	LDR R0, =PortFBase
	LDR R1, =2;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}		
	BX LR;
	
PF3_HIGH
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortFBase
	LDR R1, =3;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}		
	BX LR;
	
PF3_LOW
	STMDB  SP!, {r0-r12,lr}		
	LDR R0, =PortFBase
	LDR R1, =3;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}		
	BX LR;

	
PF1_HIGH
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortFBase
	LDR R1, =1;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}		
	BX LR;
	
PF1_LOW
	STMDB  SP!, {r0-r12,lr}		
	LDR R0, =PortFBase
	LDR R1, =1;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}		
	BX LR;

	
PF0_HIGH
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortFBase
	LDR R1, =0;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}		
	BX LR;
	
PF0_LOW
	STMDB  SP!, {r0-r12,lr}		
	LDR R0, =PortFBase
	LDR R1, =0;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}		
	BX LR;

	
PF4_HIGH
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortFBase
	LDR R1, =4;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}		
	BX LR;
	
PF4_LOW
	STMDB  SP!, {r0-r12,lr}		
	LDR R0, =PortFBase
	LDR R1, =4;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}		
	BX LR;

PB0_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortBBase
	LDR R1, =0;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
	
PB0_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortBBase
	LDR R1, =0;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;
	
PB1_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortBBase
	LDR R1, =1;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
	
PB1_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortBBase
	LDR R1, =1;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;
	
PB2_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortBBase
	LDR R1, =2;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
	
PB2_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortBBase
	LDR R1, =2;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;

PB4_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortBBase
	LDR R1, =4;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
	
PB4_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortBBase
	LDR R1, =4;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;
	

PB5_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortBBase
	LDR R1, =5;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PB5_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortBBase
	LDR R1, =5;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;
	
PB7_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortBBase
	LDR R1, =7;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PB7_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortBBase
	LDR R1, =7;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;

PA0_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortABase
	LDR R1, =0;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PA0_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortABase
	LDR R1, =0;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;


PA2_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortABase
	LDR R1, =2;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PA2_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortABase
	LDR R1, =2;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;


PA3_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortABase
	LDR R1, =3;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PA3_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortABase
	LDR R1, =3;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;


PA4_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortABase
	LDR R1, =4;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PA4_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortABase
	LDR R1, =4;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;


PA5_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortABase
	LDR R1, =5;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PA5_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortABase
	LDR R1, =5;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;


PA6_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortABase
	LDR R1, =6;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PA6_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortABase
	LDR R1, =6;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;


PA7_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortABase
	LDR R1, =7;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PA7_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortABase
	LDR R1, =7;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;

	ALIGN
	LTORG
	
PD1_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortDBase
	LDR R1, =1;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PD1_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortDBase
	LDR R1, =1;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;

PD2_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortDBase
	LDR R1, =2;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PD2_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortDBase
	LDR R1, =2;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;


PD3_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortDBase
	LDR R1, =3;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PD3_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortDBase
	LDR R1, =3;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;
	
	
PD6_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortDBase
	LDR R1, =6;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PD6_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortDBase
	LDR R1, =6;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;

PD7_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortDBase
	LDR R1, =7;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PD7_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortDBase
	LDR R1, =7;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;

PC4_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortCBase
	LDR R1, =4;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PC4_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortCBase
	LDR R1, =4;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;

PC5_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortCBase
	LDR R1, =5;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PC5_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortCBase
	LDR R1, =5;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;
	
PC6_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortCBase
	LDR R1, =6;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PC6_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortCBase
	LDR R1, =6;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;

PC7_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortCBase
	LDR R1, =7;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PC7_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortCBase
	LDR R1, =7;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;

PE1_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortEBase
	LDR R1, =1;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PE1_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortEBase
	LDR R1, =1;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;

PE2_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortEBase
	LDR R1, =2;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PE2_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortEBase
	LDR R1, =2;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;

PE3_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortEBase
	LDR R1, =3;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PE3_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortEBase
	LDR R1, =3;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;

PE4_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortEBase
	LDR R1, =4;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;

PE4_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortEBase
	LDR R1, =4;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;

PE5_HIGH
	STMDB  SP!, {r0-r12,lr}			;save vars to stack
	LDR R0, =PortEBase
	LDR R1, =5;
	LDR R2, =HIGH;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			; restore stack
	BX LR;
	
PE5_LOW
	STMDB  SP!, {r0-r12,lr}			
	LDR R0, =PortEBase
	LDR R1, =5;
	LDR R2, =LOW;
	BL SET_GPIO;
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;

GET_PF4
	STMDB  SP!, {r1-r12,lr}			
	LDR R0, =PortFBase
	LDR R1, =4;
	BL GET_GPIO		;Pin high or low is now in R4
	MOV    R0,R4	;Copy over to R4
	LDMIA  SP!, {r1-r12,lr}			
	BX LR;
	
DELAY
	STMDB  SP!, {r0-r12,lr}			
	LDR R1,=MYDELAY
LP	SUBS R1,R1,#1	
	BNE  LP
	LDMIA  SP!, {r0-r12,lr}			
	BX LR;
	
	ALIGN
	END