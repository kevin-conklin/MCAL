#EEE3231 - Microcontrollers - Lab 02
  
###Lab Description
This lab is designed to do the following: Give you practice creating a project, running code, familiarize you with the basics of the debugging, and familiarize you with the Integrated Development Environment (IDE) used for class which is called Keil.

A good IDE has lots of documentation accompanying it so that the user (thats you) can get quick answers to basic questions if they need it.  Luckily for you, Keil has great documentation. Documentation can be found by going to the help menu and opening books, or for the lazy you can try this link [here](https://drive.google.com/drive/folders/0B5dyCPYc4bVjbDVFS1dXS1EyU1E?usp=sharing).  

###Instructions
Make a new program and call it LAB02. If you do not know how to do so, revisit the Lab Setup instructions [here](./Lab_setup)
Copy the code below EXACTLY AS SHOWN into your new project.

```Assembly

		AREA MICROLAB01,CODE,READONLY
		EXPORT __main
		ENTRY     
	
	RAMSTART		EQU		0x20000000		; RAM

	__main    
		;tiva datasheet p656 for configuring GPIO

		;system control - enable peripheral
		LDR		r0, =0x400FE608			; RCGCGPIO
		LDR		r2, =0x20				; bit 5 for port F
		STR		r2, [r0]				; enable the peripheral GPIO port F
		
		;set pin direction
		LDR		r0, =0x40025400			; GPIODIR for port F
		LDR		r2, =0xFF				; all pins are outputs
		STR		r2, [r0]				; set pins to outputs
		
		;turn off alternate pin function
		LDR		r0, =0x40025420			; GPIOAFSEL for port F
		LDR		r2, =0x00				; all pins are GPIO
		STR		r2, [r0]				; disable alternate function pins
		
		;turn off open drain mode
		LDR		r0, =0x4002550C			; GPIOODR for port F
		LDR		r2, =0x00				; no open drain
		STR		r2, [r0]				; port F is not open drain
		
		;set pin to digital 
		LDR		r0, =0x4002551C			; GPIODEN for port F
		LDR		r2, =0xFF				; all pins are digital
		STR		r2, [r0]				; digital enable for port F
		
		;clear the outputs
		LDR		r0, =0x40025000			; Port F base
		LDR		r1,	=0x000003FC			; address lines 9:2 mask
		ADD		r0, r0, r1				; GPIODATA for Port F with address mask 9:2
		LDR		r2, =0x00				; clear the outputs
		STR		r2, [r0]				; write 0 to all pins
	loop		
		;turn on red LED
		LDR		r0, =0x40025000			; Port F base
		LDR		r1,	=0x000003FC			; address lines 9:2 mask
		ADD		r0, r0, r1				; GPIODATA for Port F with address mask 9:2
		LDR		r2, =0x02				; pin for red LED
		STR		r2, [r0]				; turn on red LED
		
		;delay
		LDR		r0, =0x007A1200			; load with 8,000,000 (for 0.5s delay)
	delay1	
		SUBS	r0, #1					; subtract 1
		BNE		delay1
		
		;turn off LED
		LDR		r0, =0x40025000			; Port F base
		LDR		r1,	=0x000003FC			; address lines 9:2 mask
		ADD		r0, r0, r1				; GPIODATA for Port F with address mask 9:2
		LDR		r2, =0x00				; turn off LED
		STR		r2, [r0]				; turn off LED
		
		;delay
		LDR		r0, =0x007A1200			; load with 8,000,000 (for 0.5s delay)
	delay2	
		SUBS	r0, #1					; subtract 1
		BNE		delay2
		
		;repeat
		B		loop
		ALIGN							; align data
		LTORG							; keep data close by for use in main program

	data 
		SPACE	1000    

	functions
		SPACE	1000
			
		END
```

* When you are done copying the code, compile it and fix all mistakes. Build errors will be shown in the build output window at the bottom of the screen. Warnings are ok to have while you are starting off, but build errors are not. If you do not know how to start the simulator, revisit revisit the Lab Setup instructions here.
* Once completed, explore the simulation window and see what it does.  
* On a sheet of paper, draw a pretty picture of the following buttons and explain what it does.

	* Build button    
	* Debug button    
	* Single Step button   
	* Run To button    
	* File extensions books and environments   
	* Load   
	* Build   
	* Rebuild   
	* breakpoint   
	* remove all breakpoints  

Figure out these next questions by yourself.  Sure, you can copy from someone, but the point of this lab is to teach you how to get the information you need, which you will be doing a lot of when you are debugging. 

* What is happening to Register R0 during the block of code 
```Assembly     
	LDR     r0, =0x007A1200         ; load with 8,000,000 (for 0.5s delay)     
	delay1  
		SUBS    r0, #1                  ; subtract 1
	BNE     delay1
```

In that block of code, what happens when R0 = 0?

What is 32 bit value is in the following memory locations    
	* 0x00000000  
	* 0x00000000  
	* 0x00000000  
	* 0x00000000      

    
What code do you need to modify to change this program to blink the green led or the blue led.  Write it out. 