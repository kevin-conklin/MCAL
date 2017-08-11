;*****************************************************************
;* Name :                                                        *
;* Date :                                                        *
;* Grade C :                                                     *
;* Prof Comments:  Fairly Neat, working code.  Description ok 
;  but lacking hardware description and some mistakes. Has comments
; but they are "bad" comments.
;
;* Description: This program is a basic adder of two three digit *
;* numbers, since the computer does its calculations in hexadecimal*
;* this program tries to convert the number into decimal and then*
;* gives the answer. Moreover, since this micro only supports 1-bit*
;* accumulators,first we need to add the unit digits, ten digits *
;* with each other and thenthey needed to be multiplied with 1,10,100*
;* respectively and then added together.Moreover, the code also  *
;* turns any number greater than 9 into a carry in decimal number*
;* which is how the answer received is in decimal form.          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

            ORG RAMStart
 ; Insert here your data definition.
Counter     DS.W 1
FiboRes     DS.W 1


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer
           
            LDAA  NUM1            ; Loads the first digit of the first string into accumulator A 
            LDAB  #$30            ; Loads the immediate decimal value of 30 into accumulator B 
            SBA                   ; Subtracts B from A   
            STAA   HUN1           ; Stores it in a specific location in the memory
            
            LDAA   NUM1+1         ; Loads the second digit of the first string into Accumulator A    
            SBA                   ; Subtracts it from the value in B, which is 30   
            STAA   TEN1           ; Stores it in a specific location in the memory
            
            LDAA   NUM1+2         ; Loads the third digit of the first string into Accumulator A  
            SBA                   ; Subtracts it from the value in B which is 30  
            STAA   UNIT1          ; Stores it in a specific location in the memory 
            
            LDAA   NUM2           ; Loads the first digit of the second string into Accumulator A   
            SBA                   ; Subtracts it from the value in B which is 30  
            STAA   HUN2           ; Stores it in a specific location in the memory
            
            LDAA   NUM2+1         ; Loads the second digit of the second string into Accumulator A  
            SBA                   ; Subtracts it from the value in B which is 30  
            STAA   TEN2           ; Stores it in a specific location in the memory
            
            LDAA   NUM2+2         ; Loads the third digit of the second string into Accumulator A  
            SBA                   ; Subtracts it from the value in B which is 30   
            STAA   UNIT2          ; Stores it in a specific location in the memory
            
            ;*************** The above block of code converts the ASCII number values into their decimal form and saves it in memory location for later use****************************
           
           
            LDAA   UNIT1          ; Loads the Accumulator A with the value at the memory location "Unit1"
            LDAB   UNIT2          ; Loads the Accumulator B with the value at the memory location "Unit2"
            ABA                   ; Adds B into A
            STAA   SUM1           ; Stores the sum into a specific place in the memory
            
            LDAA   TEN1           ; Loads the Accumulator A with the value at memory location "Ten1"
            LDAB   TEN2           ; Loads the Accumulator B with the value at memory location "Ten2"
            ABA                   ; Adds B into A
            STAA   SUM2           ; Stores the sum into a specific place in the memory
            
            LDAA   HUN1           ; Loads the Accumulator A with the value at memory location "Hun1"
            LDAB   HUN2           ; Loads the Accumulator B with the value at memory location "Hun2"
            ABA                   ; Adds B into A
            STAA   SUM3           ; Stores the sum into a specific place in the memory
            
            ;*************** Since the micro cannot do the addition together, we split the number into three digits and add the units with units, tens with and tens and so on
            ;*************** Once we have all the sums, they are saved in the memory for later use.***************
           
           
            LDAA   SUM1           ; Loads the accumulator A with the sum of unit digits
            LDAB   #$A            ; Loads the accumulator B with the hexadecimal value of A, which is 10
            CBA                   ; Compares the value of B with A
            BLO    Loop1          ; Checks if the value of A is lower than B, if yes it branches it to second loop
            SBA                   ; If A>=B then Subtract B from A
            STAA   SUM1           ; Store the value back in its orignal location
            LDAA   SUM2           ; Loads the Sum of tens digit into Accumulator A
            INCA                  ; Increases its value by 1
            STAA   SUM2           ; Stores the value back into its original location
Loop1:
            LDAA   SUM2           ; Loads Accumulator A with the Sum of Tens digit
            LDAB   #$A            ; Loads Accumulator B with hexadecimal value of A, which is 10 in decimal
            CBA                   ; Compares B with A
            BLO    Loop2          ; If A<B, branches to "Loop2"
            SBA                   ; If A>=B, suntracts B from A
            STAA   SUM2           ; Stores the value back into its original equation
            LDAA   SUM3           ; Loads the value of sum of hundreds digit into accumulator A
            INCA                  ; Increments the value of A by 1
            STAA   SUM3           ; Stores the value of A back into the original location
            
            ;*************** This block of code compensates for carry in the units and tens place, since in decimal addition, there is no digit larger than 9 therefore
            ;*************** we must subtract A from the number. To compensate for that subtraction we just add 1 to the the next number. The same loop repeats for tens place
            ;*************** It does not do the same thing for Hundreds number because its just 3-digit addition and there is no need to elongate the code
Loop2                             
            LDAB   SUM3           ; Loads Accumulator B with the sum of the Hundreds digits
            LDY   #$100           ; Loads Y with the hexadecimal value of 100
            EMUL                  ; Multiplies B and Y, with the answer in D
            STD    MUL1           ; Stores the value of D in a memory location
                                  
            
            CLRA                  ; Clears the accumulator A
            CLRB                  ; Clears the Accumulator B
            LDAB   SUM2           ; Loads the value of sum of tens digits into Accumulator B
            LDY   #$10            ; Loads the value of hexadecimal 10 into register Y
            EMUL                  ; Multiplies Y with B and stores the value in D
            STD    MUL2           ; Stores the value of D into a memory location
            
            CLRA                  ; Clears the accumulator A
            CLRB                  ; Clears the accumulator B
            LDAB   SUM1           ; Loads Accumulator B with sum of Units digit
            LDY    #$1            ; Loads the register Y with hexadecimal value of 1
            EMUL                  ; Multiplies Y with B, with the answer in D
            STD    MUL3           ; Stores the value of D into a memory location
            
            ;***************  This block of code is converting the digits into their actual values, so a 1 in Hundred place is actually 100, therefore
            ;***************  we multiply the hundreds digit with 100, tens digit with 10 and unit digits with 1 (the units digit one is just a symbol)
            
            LDD    MUL3           ; Load the register D with the units number
            ADDD   MUL2           ; Adds the value of Tens place into register D
            ADDD   MUL1           ; Adds the value of Hundreds place into register D                                                                                           
            RTS                   ; result in D

            ;*************** In the last block we just gather all the values and add them together for the result in register D

            ;Constant Data
NUM1      DC.B   "123"    ; first ascii string
NUM2      DC.B   "037"    ; second ascii string
UNIT1     DS.B    1
TEN1      DS.B    1
HUN1      DS.B    1
UNIT2     DS.B    1
TEN2      DS.B    1
HUN2      DS.B    1
SUM1      DS.B    1
SUM2      DS.B    1
SUM3      DS.B    1
MUL1      DS.W    1
MUL2      DS.W    1
MUL3      DS.W    1
RESULT    DS.W    1
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
