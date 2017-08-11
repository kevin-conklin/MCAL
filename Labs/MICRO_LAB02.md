# EEE3231 - Microcontrollers - Lab 02
  
### Lab Description
###### Goals
This is a two week lab designed to do the following:      
* practice creating a project and running code   
* familiarize you with the basics of the debugging
* familiarize you with the Integrated Development Environment (IDE)    
* give you experience solving a problem with little information    
* familiarize you with the debugger and debugging techniques    
* give you experience reading code that is unfamiliar to you    
* introduce you to some microcontroller instructions    

###### Background 
Most likely, you have not gone over assembly language in class and the code presented to you is unfamiliar. You will be working with a pre-written program, and using the debugger/simulator to understand what the program is doing.  Although difficult, working through this process is a common occurrence to individuals who work with embedded software and microprocessors. You may be given 5000 lines of assembly code and asked to figure out what it does, having never seen the code before and having no understanding of the instruction set (the commands). Your goal for this lab is document the code and understand what the program does.  You will be given very little help on the program. It is your job to figure out the instructions and what the program is doing.  

Lets take a look at some code 
```Assembly
	LDR	R1, =0x20002000
	LDR	R2, =0x20000000
	...
	ADD R0,R2,#4
	CMP R0,R1
```    

It means nothing to you, right? Now lets take a look at it with a "bad comment"

```Assembly    
	LDR	R1, =0x20002000	; Load R1 with hex value 0x20002000
	LDR	R2, =0x20000000 ; Load R2 with hex value 0x20000000
	...
	ADD R0,R2,#4		; ADD 4 to R2 and store it in R0
	CMP R0,R1		; Compare R0 to R1
```    
A bad comment is a comment that adds no additional information to a line of code.  If you new what each instruction was (you will learn throughout the semester), these comments would be redundant, thus they are considered "bad." Now take a look at the code with good comments.
```Assembly 
 	LDR	R1, =0x20002000	; Initialize pointer to end of memory
 	LDR	R2, =0x20000000 ; Initialize pointer to start of memory
	...			; (Do something with that memory)
	ADD R0,R2,#4		; Increment a pointer to the next part of memory 
	CMP R0,R1		; Check to see if code is at the end of memory
	
```

The code might not make full sense to you yet, but it is now much more clear. It makes it much easier for you, the programmer, to understand it while you are coding, and it makes it much easier for someone else to read it who has never seen the program.  This is what you will be doing for LAB02, but combining some aspects of hardware with it.  

Note:  for reminders on how to use the debugger, check the help files in Keil or view online here: [http://www.keil.com/support/man/docs/uv4/uv4_db_using.htm](http://www.keil.com/support/man/docs/uv4/uv4_db_using.htm)

### Instructions    
Make a new program and call it LAB02. If you do not know how to do so, revisit the Lab Setup instructions [here](./Lab_setup). Copy the code below EXACTLY AS SHOWN into main.s.

```Assembly    
		GET GPIO_helper.s
		
		AREA myprog, CODE, READONLY
		ENTRY
		EXPORT __main
		IMPORT SKADOOSH
		IMPORT SQUABBLE
			
			
RAM_START	EQU	0x20000000				; Starting address of RAM
		
__main

		;system control - enable peripheral
		;This block of code turns on all GPIO
		LDR		r0, =0x400FE608			; RCGCGPIO Register
		LDR		r2, =0x3F			; Turn on all GPIO
		STR		r2, [r0]			; Save to memory

		BL		GET_PF4				; Quick Hack, set PF4 as input
		
		; This sections blinks your leds on startup 
		; to make sure they are all working
		LDR r0,=5					;Set counter to 5
								;Blink LED loop
BLUNK		BL PF3_HIGH						
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
		SUBS r0,r0,#1					; Dec R0 update xPSR
		BNE	BLUNK
		
		; end of startup blink section 


		; start commenting here
		
		; Block 1
		BL PF3_HIGH				;    
CHKPIN	BL	GET_PF4					;    
		CMP		r0,#0			;	    
		BNE		CHKPIN			;    
		BL PF3_LOW				;    
		
		; Block 2
		LDR R1, =0x20000000			; 
		LDR	R2, =SKADOOSH			;
		LDR R3, =SQUABBLE			;
LOOP		LDR R4,[R2]				;
		STR R4,[R1]				;
		ADD R1,R1,#4				;
		ADD R2,R2,#4				;
		CMP R2,R3				;
		BLT LOOP				;
		
		BL DELAY				;  
		BL DELAY
		BL DELAY
		
		; Block 3
		BL PF2_HIGH				;
CHKPIN2		BL GET_PF4				;
		CMP r0,#0				;	
		BNE CHKPIN2				;
		
		
		; Block 4
		LDR R1, =0x20000000			;
		ADD R3, R1,#340				;
		
LOOP2		LDRB R2, [R1]  				;
		BIC R2, #0x20 				; 
		STRB R2,[R1]				;
		ADD R1,R1,#1				;
		CMP R1,R3				;
		BLT LOOP2				;
		NOP
		NOP
		BL PF2_LOW				;
		
		; Block 5
ENDLOOP		BL PF1_HIGH				;
		BL DELAY
		BL PF1_LOW				;
		BL DELAY
		B  ENDLOOP
		
STOP	B STOP
										
			
		END

```
Copy this into your data.s file    

```Assembly    
		AREA thisdata,DATA,READONLY
		EXPORT SKADOOSH
		EXPORT SQUABBLE			
		ALIGN		; make sure the data is aligned

SKADOOSH    DCB   "An amoeba, named Max, and his brother "        ;?
            DCB   "Were sharing a drink with each other "
            DCB   "In the midst of their quaffing, "
            DCB   "They split themselves laughing, "
            DCB   "And each of them now is a mother. "
            DCB   "There was a young belle of old Natchez "
            DCB   "Whose garments were always in patchez. "
            DCB   "When comments arose "
            DCB   "On the state of her clothes, "
            DCB   "She replied, When Ah itchez, Ah scratchez. "
SQUABBLE    DCB    0                                             ;?

		END
```

The assignment is to document the code seen before you. To help guarentee success, follow these instructions:      
* For week one 
	* Visually step through the code one line at a time making note of how the registers change  
	* Go through the code again and make a "bad" comment on every single line of code.  A full understanding of the program is not required yet.
	* Look through the code and see how the hardware is used.  The code may require signals from the hardware in order to move forward through the entire program.  
	
* For week 2
	* Use breakpoints, run to cursor, and other debugging features to help you figure out what is happening with the hardware
	* Write a good comment for every single line of code. Every line of code should look something like this
```Assembly    
	LDR	R1, =0x20002000	; Load R1 with hex value 0x20002000
 				; Initialize pointer to end of memory
```

To turn in the assignment, type up a header in the top of the document (with both names).  Make sure you follow the code formatting poilicies as well as do a thorough writeup as shown in the lab example. Make sure to address the following topics in either the header or inline in the code

* What is block 1-5 doing in technical terms (adds two 64 bit numbers to etc etc)
* What is block 1-5 doing in non-technical terms 
* There are three delay calls in block 2.  Why are they there?  Perhaps check what happens when you remove them? (This is difficult question to figure out and requires both hardware and software debugging)
  
Upload your main.s file only by the deadline to recieve credit.  If something other than the main.s file is uploaded you will not recieve credit.    
