# EEE3231 - Microcontrollers - Lab 03
  
### Lab Description
###### Goals
This lab is designed to do the following: introduce you to basic math and ASCII to decimal
conversion, enhance your skills with loading and storing values to and from memory, reinforce your
understanding of addressing modes, force you to write your own code.    

###### Background 
Some times information is passed in between microcontrollers as strings of ASCII characters, making it easy for humans to read it.  This information then needs to be converted to binary data so that it can be used in calculations on the microcontroller.  For this lab, you must create code that changes strings of ASCII characters into binary data, and then perform mathematical operations on them. 


Three strings of ASCII characters are stored in memory(human readable format) and each has a different base. Convert these strings to binary values, sum them together, and store the 32 bit result in a memory location in RAM. Then do the same but subtract them, in order your please. Adding and subtracting is easy and fun, so remember to have a super radical time while doing it! 


### Instructions    
Copy the code below EXACTLY AS SHOWN into a new main.s.

```Assembly    
		GET GPIO_helper.s
		
		AREA myprog, CODE, READONLY
		ENTRY
		EXPORT __main
		IMPORT SKADOOSH
		IMPORT SQUABBLE
			
			
RAM_START	EQU	0x20000000				; Starting address of RAM
		
__main

		
		
STOP	B STOP
										
			
		END

```
Add these lines into your data.s file  

```Assembly    
Value1      DCB   "0x2341"    
Value2      DCB   "7975"        
Value3      DCB   "0b11010011"    
```
  
Upload your main.s file only by the deadline to recieve credit.  If something other than the main.s file is uploaded you will not recieve credit.    
