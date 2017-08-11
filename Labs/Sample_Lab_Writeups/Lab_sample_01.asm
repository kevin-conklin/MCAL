;*****************************************************************
;* Name:
;* Date:
;* Lab #: 
;* Grade:  A
;
;* Lab Description:  This project's goal was to create an infinite loop
;  in the form of an interrupt (Real-Time) and toggle between two light 
;  patterns on the LED's at PORTA on the microprocessor board.  The patterns
;  should toggle around 1000ms.  These two patterns will be known as PATTERN_A & PATTERN_B.
;  They will start at a default setting in the main code section.  The second part of this lab was to use
;  the analog POT's to program the toggling patterns.  For this we needed
;  an external interupt via an XIRQ push button on the microprocessor board.  
;  When pushing the button, each pot can display 5 patterns as they are turned
;  to allow the user to choose which patterns to use.  Pot 1 will choose the 
;  pattern for PATTERN_A and Pot 2 will choose the pattern for PATTERN_B.
;
;* Hardware Description:  The hardware used in this lab is the Freescale
;  S12 University Board.  Connecting the computer through the Debugger interface,
;  We used the PORTA, POT1 and POT2 on the board.  PORTA is used for LED patterns while
;  the POT's are used for pattern progamming control.  We also use the "XIRQ" push button.
;  This will actuate an external interrupt only while the button is pushed. 
;  One precautionary note, be sure that the slide link "jumper" at position "J12" is set
;  for using the LED strip instead of the 7 SEG LED 
; 
;* Personal Notes:  This progam will run through its cycles until the overflow bit in the
;  CCR is set in which the real time interrupt is set.  We set the "RTICTL" to prescale the
;  time the program takes to get to the overflow.  The default setting of PATTERN_A & PATTERN_B
;  will toggle (blink between the patterns on LED's) until the XIRQ button is pushed.  While
;  holding the XIRQ button you will be able to choose a pattern for A or B using POT1 and POT2
;  respectively.  Once you let go of the XIRQ button the patterns with respect to the POT settings
;  will now toggle instead of the default patterns.  We did not achieve a good way
;  to display the patterns during the XIRQ interrupt where POT1 control would be independant of
;  of POT2 pattern scrolls.  My initial approach is in this code where I wanted to toggle a 
;  value everytime the XIRQ button is pressed.  This did not work because the loop created 
;  in the XIRQ was infinite while the button was pushed and I did not account for it.  I also
;  tried to monitor if the pots were being changed then a branch could occur to allow only 
;  one pattern scroll to happen at a time on the LED's.  This didn't even come close to working
;  so I deleted it from my code, essentially giving up!  
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

 ifdef _HCS12_SERIALMON
            ORG $3FFF - (RAMEnd - RAMStart)
 else
            ORG RAMStart
 endif
 ; Insert here your data definition.


PATTERN_A   DS.B 1  ;Initializing memory locations for variables needed below 
PATTERN_B   DS.B 1
PAT1        DS.B 1
PAT2        DS.B 1
PAT3        DS.B 1
PAT4        DS.B 1
PAT5        DS.B 1                           
TOGGLE      DS.B 1
TOGGLE_PAT  DS.B 1

; code section
            ORG   ROMStart


Entry:
_Startup:
            ; remap the RAM &amp; EEPROM here. See EB386.pdf
 ifdef _HCS12_SERIALMON
            ; set registers at $0000
            CLR   $11                  ; INITRG= $0
            ; set ram to end at $3FFF
            LDAB  #$39
            STAB  $10                  ; INITRM= $39

            ; set eeprom to end at $0FFF
            LDAA  #$9
            STAA  $12                  ; INITEE= $9


            LDS   #$3FFF+1        ; See EB386.pdf, initialize the stack pointer
 else
            LDS   #RAMEnd+1       ; initialize the stack pointer
 endif
 
;***********Initialize interrupts************ 
            BSET CRGINT,#%10000000
            MOVB #$7F,RTICTL
            ANDCC #%10111111
            CLI                     ; enable interrupts
            
;*****     Initialize toggling functions            
            LDAA #0
            STAA TOGGLE
            STAA TOGGLE_PAT
            
;**********MAIN CODE************            
            JSR INIT_PINS    ;INITIALIZE PINS
            JSR ADCINIT      ;INITIALIZE ANALOG TO DIGITAL FOR POT FUNCTIONS
            JSR PATTERN_STO  ;STORE DESIRED PATTERNS INCLUDING DEFAULTS
            
SUP         BRA SUP          ;MAIN LOOP THAT CAUSES OVERFLOWS FOR INTERRUPTS 


            
INIT_PINS   LDAA  #0                ;Load the $0 hexadecimal to store in DDRB
            STAA  DDRB              ;makes DDRB all outputs
            
            LDAB  #$FF              ;Load the $FF hexadecimal to store in DDRA
            STAB  DDRA              ;stores in DDRA to make PORT A as input
            
            
            RTS                     ;Return from INIT_PINS
            
            
ADCINIT     DC.B $18,$0b,$80,$01,$22   ;POT1 and POT2 memory locations $131 and $133
            DC.B $18,$0b,$10,$01,$23
            DC.B $18,$0B,$80,$01,$24
            DC.B $18,$0B,$F0,$01,$25
            DC.B $18,$0B,$FC,$01,$2D
            DC.B $3D     
            RTS
            
PATTERN_STO MOVB #%11111111,PATTERN_A   ;DEFAULT FOR PATTERN A ON INITIAL PROGRAM RUN
            MOVB #%00000000,PATTERN_B   ;DEFAULT FOR PATTERN B ON INITIAL PROGRAM RUN
            MOVB #%11000000,PAT1        ;**PATTERN'S 1 THROUGH 5 FOR PROGRAMMING LATER
            MOVB #%00110000,PAT2        ;*
            MOVB #%00001100,PAT3        ;*
            MOVB #%00000011 ,PAT4       ;*
            MOVB #%10000000,PAT5        ;*
            RTS                         ;RETURN FROM SUBROUTINE
            

;********REAL TIME INTERRUPT*************
;          TOGGLE PATTERNS AT GIVEN TIME            
            
RTI_ISR    LDAA TOGGLE    ;GIVE A ZERO TO TOGGLE WITH $FF              ;
           EORA #$FF      ;EXCLUSIVE OR WILL REPLACE ZERO IN TOGGLE MEM LOC EVERY OTHER TIME THROUH INTERRUPT
           STAA TOGGLE    ;STORE THE TOGGLED VALUE IN ACC. A FOR NEXT TIME AROUND
           CMPA #$FF      ;COMPARE WITH A TO SET ZERO FLAG OR NOT
           BNE  PATTA     ;USE PATTERN A THIS TIME AROUND IF ACC A IS ZERO
           BEQ  PATTB     ;USE PATTERN B THIS TIME AROUND IF ACC A IS $FF

PATTA      
           LDAA PATTERN_A           ;LOAD A WITH WHATEVER IS STORED IN PATTERN A (DEFAULT OR PROGRAMMED)
           STAA PORTA               ;LIGHT UP LEDS TO REFLECT PATTERN A
           BSET CRGFLG,#%10000000   ;CLEAR RTIF FLAG IN ORDER TO RETURN FROM INTERRUPT
           RTI                      ;RETURN FROM INTERRUPT
           
PATTB                               ;
           LDAA PATTERN_B           ;LOAD A WITH WHATEVER IS STORED IN PATTERN B (DEFAULT OR PROGRAMMED)
           STAA PORTA               ;LIGHT UP LEDS TO REFLECT PATTERN B
           BSET CRGFLG,#%10000000   ;CLEAR RTIF FLAG IN ORDER TO RETURN FROM INTERRUPT
           RTI                      ;RETURN FROM INTERRUPT



;********EXTERNAL INTERRUPT
;           INITAITED BY PUSHING XIRQ BUTTON ON BOARD
XIRQ
           LDAA TOGGLE_PAT          ;GIVE A ZERO TO TOGGLE WITH $FF;
           EORA #$FF                ;EXCLUSIVE OR WILL REPLACE ZERO IN TOGGLE MEM LOC EVERY OTHER TIME THROUGH THE INTERRUPT
           STAA TOGGLE_PAT          ;STORE TOGGLED VALUE IN ACC A FOR NEXT TIME AROUND
           CMPA #$FF                ;COMPARE WITH A TO SET ZERO FLAG OR NOT
           BNE  XIRQ_B              ;BRANCH TO USE POT 2 WHEN ACC A IS $FF

      ;**POT1 CONTROL    
           LDAA $131                ;LOAD VALUE FROM POT1
           CMPA #50                 ;COMPARE IF VALUE IS IN FIRST GROUP OF VALUES (LESS THAN 50)
           BLO  PAT1_SET_A          ;IF POT IS AT FIRST GROUP OF VALUES THEN BRANCH TO SET PATTERN A WITH STORED PATTERN 1
           CMPA #100                ;COMPARE IF VALUE FROM POT1 IS BETWEEN 50 AND 100
           BLO  PAT2_SET_A          ;IF POT IS IN SECOND GROUP OF VALUES THEN BRANCH TO SET PATTERN A WITH STORED PATTERN 2
           CMPA #150                ;COMPARE IF VALUE FROM POT1 IS BETWEEN 100 AND 150
           BLO  PAT3_SET_A          ;IF POT IS IN THIRD GROUP OF VALUES THEN BRANCH TO SET PATTERN A WITH STORED PATTERN 3                                          
           CMPA #200                ;COMPARE IF VALUE FROM POT1 IS BETWEEN 150 AND 200
           BLO  PAT4_SET_A          ;IF POT IS IN FOUTH GROUP OF VALUES THEN BRANCH TO SET PATTERN A WITH STORED PATTERN 4

           LDAB PAT5                ;IF POT IS IN FIFTH GROUP OF VALUES THEN LOAD B WITH PATTERN 5
           STAB PORTA               ;SET LEDS WITH PATTERN 5 FOR DISPLAY PURPOSES
           STAB PATTERN_A           ;PROGRAM PATTERN_A FROM REAL TIME INTERRUPT WITH PATTERN 5
DONE1      
           RTI                      ;RETURN FROM INTERRUPT (LOOPS TO XIRQ UNTIL BUTTON IS RELEASED)
           
;     **POT2 CONTROL           
XIRQ_B     
           LDAA $133                ;LOAD VALUE FROM POT2
           CMPA #50                 ;COMPARE IF VALUE IS IN FIRST GROUP OF VALUES (LESS THAN 50)
           BLO  PAT1_SET_B          ;IF POT IS AT FIRST GROUP OF VALUES THEN BRANCH TO SET PATTERN B WITH STORED PATTERN 1
           CMPA #100                ;COMPARE IF VALUE FROM POT2 IS BETWEEN 50 AND 100
           BLO  PAT2_SET_B          ;IF POT IS IN SECOND GROUP OF VALUES THEN BRANCH TO SET PATTERN B WITH STORED PATTERN 2
           CMPA #150                ;COMPARE IF VALUE FROM POT2 IS BETWEEN 100 AND 150
           BLO  PAT3_SET_B          ;IF POT IS IN THIRD GROUP OF VALUES THEN BRANCH TO SET PATTERN B WITH STORED PATTERN 3
           CMPA #200                ;COMPARE IF VALUE FROM POT2 IS BETWEEN 150 AND 200
           BLO  PAT4_SET_B          ;IF POT IS IN FOUTH GROUP OF VALUES THEN BRANCH TO SET PATTERN B WITH STORED PATTERN 4

           LDAB PAT5                ;IF POT IS IN FIFTH GROUP OF VALUES THEN LOAD B WITH PATTERN 5
           STAB PORTA               ;SET LEDS WITH PATTERN 5 FOR DISPLAY PURPOSES
           STAB PATTERN_B           ;PROGRAM PATTERN_B FROM REAL TIME INTERRUPT WITH PATTERN 5
           
DONE       
          
           RTI                      ;RETURN FROM INTERRUPT(ALSO LOOPS TO XIRQ UNTIL BUTTON IS RELEASED)

      ;**PATTERN DISPLAYS AND STORING           

PAT1_SET_A LDAB PAT1                ;LOAD B WITH PATTERN 1
           STAB PORTA               ;DISPLAY PATTERN 1 ON LEDS
           STAB PATTERN_A           ;STORE PATTERN 1 AT PATTERN A FROM REAL TIME INTERRUPT
           BRA  DONE1               ;BRANCH TO POT1 CONTROL

PAT2_SET_A LDAB PAT2                ;LOAD B WITH PATTERN 2
           STAB PATTERN_A           ;DISPLAY PATTERN 2 ON LEDS
           STAB PORTA               ;STORE PATTERN 2 AT PATTERN A FROM REAL TIME INTERRUPT
           BRA  DONE1               ;BRANCH TO POT1 CONTROL

PAT3_SET_A LDAB PAT3                ;LOAD B WITH PATTERN 3
           STAB PORTA               ;DISPLAY PATTERN 3 ON LEDS
           STAB PATTERN_A           ;STORE PATTERN 3 AT PATTERN A FROM REAL TIME INTERRUPT
           BRA  DONE1               ;BRANCH TO POT1 CONTROL
           
PAT4_SET_A LDAB PAT4                ;LOAD B WITH PATTERN 4
           STAB PORTA               ;DISPLAY PATTERN 4 ON LEDS
           STAB PATTERN_A           ;STORE PATTERN 4 AT PATTERN A FROM REAL TIME INTERRUPS
           BRA  DONE1               ;BRANCH TO POT1 CONTROL
           
        

PAT1_SET_B LDAB PAT1                ;LOAD B WITH PATTERN 1
           STAB PORTA               ;DISPLAY PATTERN 1 ON LEDS
           STAB PATTERN_B           ;STORE PATTERN 1 AT PATTERN B FROM REAL TIME INTERRUPT
           BRA  DONE                ;BRANCH TO POT2 CONTROL
           
PAT2_SET_B LDAB PAT2                ;LOAD B WIH PATTERN 2
           STAB PATTERN_B           ;STORE PATTERN 2 AT PATTERN B FROM REAL TIME INTERRUPT
           STAB PORTA               ;DISPLAY PATTERN 2 ON LEDS
           BRA  DONE                ;BRANCH TO POT2 CONTROL
           
PAT3_SET_B LDAB PAT3                ;LOAD B WITH PATTERN 3
           STAB PORTA               ;DISPLAY PATTERN 3 ON LEDS
           STAB PATTERN_B           ;STORE PATTERN 3 AT PATTERN B FROM REAL TIME INTERRUPT
           BRA  DONE                ;BRANCH TO POT2 CONTROL
           
PAT4_SET_B LDAB PAT4                ;LOAD B WITH PATTERN 4
           STAB PORTA               ;DISPLAY PATTERN 4 ON LEDS
           STAB PATTERN_B           ;STORE PATTERN 4 AT PATTERN B FROM REAL TIME INTERRUPT
           BRA  DONE                ;BRANCH TO POT2 CONTROL
           
                          



;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
 ;       ****REAL TIME INTERRUPT ADDRESS
            ORG   $FFF0
            DC.W  RTI_ISR
        ;****EXTERNAL INTERRUPT FROM PUSH BUTTON    
            ORG   $FFF4
            DC.W  XIRQ
           
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
