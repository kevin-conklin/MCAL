;*********************************************************************************************************************************
;*   Name: 
;*   Date: 
;*   Lab#: 
;*   Grade:  B
;*   Lab Description: This lab required students to write a program that utilizes the XIRQ interrupt 
;                   to select one pattern with POT1, referred to as Pattern 1, and another 
;                   pattern with POT2, referred to as Pattern 2, and oscillate between the two patterns
;                   at a given speed by using the real time interrupt. Pattern 1 is seen in the top 4 bits of PORTA and
;                   Pattern 2 is seen in the bottom 4 bits of PORTA.
;                      
;
;*   Hardware Description: The primary hardware utilized in this lab includes the LED strip (PORTA, DDRA), 
;                      POT1, POT2, and the button routed to the XIRQ interrupt on the HCS12 development board used in the lab.
;                                                 
;
;*   Personal Notes: I wrote this program to be easily interpreted by anyone that has basic knowledge of how microcontrollers work.
;                  Hopefully this makes this program easy to understand and follow. After writing this program I understand how to
;                  use interrupts in practice. Additionally I know what that weird box at the end of the code is (the interrupt vector table).  
;
;
;********************************************************************************************************************************* 

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
TopStore    DS.W 1            ;Storage space for Pattern 1

BotStore    DS.W 1            ;Storage space for Pattern 2

            
            
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
 
 endif

           
           
           
;CODE STARTS HERE           
           
            JSR   INIT_WARE          ;This subroutine initializes the hardware used in this program
            
MAIN_LOOP   JSR   BODY               ;This subroutine is the functional part of this program
            
            BRA   MAIN_LOOP          ;Infinitely repeats the body of the program 
            
            
            
            
            
           
INIT_WARE   

            CLI                      ;enable interrupts
            
            BSET  DDRA, $FF          ;Sets DDRA as output pins to initialize the LEDs
            
            ANDCC #%10111111         ;Unmasks the X bit to allow the interrupts used in this program to work
            
            JSR   ADCINIT            ;Initializes the potentiometers 
            
            BSET  CRGINT, #%10000000 ;Sets the highest value bit of CRGINT in order to enable the real time interrupt
            
            MOVB  #$7F, RTICTL       ;Moves a value into the RTICTL space in memory
                                     ;  This instruction allows the programmer to control the time interval in which the real time 
                                     ;  interrupt is triggered, based on the clock speed.

            RTS                      ;Returns from this initialization subroutine and continues to the main function of the program
            
 
 
BODY        
            MOVB  TopStore, PORTA    ;Moves Pattern 1 into the PORTA 
 
            RTS                      ;Return from BODY and repeat BODY again
                                     ;Repeats until RTI or XIRG is triggered
 
 
RTI_INT       

            MOVB  BotStore, PORTA    ;When the RTI is triggered, Pattern 2 is moved to PORTA
                                     ;This makes the LEDs toggle between Pattern 1 and Pattern 2 at the time set by the programmer in RTICTL
            
            BSET  CRGFLG, #%10000000 ;This bit must be set within the body of the RTI in order for the RTI to work

            RTI                      ;Returns from interrupt 
 
 
;This section of code filters 5 different positions of POT1 and POT2 which allows 5 different patterns 
;  for Pattern1 and Pattern2 to be selected and stored in memory as TopStore and BotStore   

XIRQ_INT    LDAA $131                ;Loads A with value in POT1 to prepare to compare instruction 
                                     
            LDAB #204                ;Loads B with 204 to prepare for compare instruction
            
            CBA                      ;Compares values in A and B
                                     ;If value in POT1 is greater than 204 then the first of five patterns will be selected for Pattern 1
            
            BHI  TOPHAT1             ;Branches to TOPHAT1 which stores the first of five patterns that can be used as Pattern 1 in TopStore
                          ;**The next 4 blocks of code repeat the same process as this block but branch for 4 other positions of POT1** 
           
            LDAA $131
            LDAB #153
            CBA
            BHI  TOPHAT2
            
           
            LDAA $131           
            LDAB #102            
            CBA            
            BHI  TOPHAT3
                    
           
            LDAA $131            
            LDAB #51            
            CBA            
            BHI  TOPHAT4
            
            
            LDAA $131            
            CLRB            
            CBA            
            BHI  TOPHAT5
            
            
            
BOTHLF      
            LDAA  $133               ;Loads A with value in POT2 to prepare to compare instruction
            
            LDAB  #204               ;Loads B with 204 to prepare for compare instruction
            
            CBA                      ;Compares values in A and B
                                     ;If value in POT2 is greater than 204 then the first of five patterns will be selected for Pattern 2
            
            BHI   BOTPAT1            ;Branches to BOTPAT1 which stores the first of five patterns that can be used as Pattern 2 in BotStore
                           ;**The next 4 blocks of code repeat the same process as this block but branch for 4 other positions of POT1** 
   
            LDAA  $133
            LDAB  #153            
            CBA            
            BHI   BOTPAT2
            
            LDAA  $133            
            LDAB  #102            
            CBA            
            BHI   BOTPAT3
                    
            LDAA  $133            
            LDAB  #51            
            CBA            
            JMP   BOTPAT4
            
            LDAA  $133            
            CLRB            
            CBA            
            JMP   BOTPAT5

            
            
FIN         BCLR TopStore, #$0F      ;Clears highest 4 bits of TopStore to initialize TopStore to be used as Pattern 1

            BCLR BotStore, #$F0      ;Clears lowest 4 bits of BotStore to initialize BotStore to be used as Pattern 2
            
            RTI                      ;Return from XIRQ interrupt
             
            ;///|||\\\ 
             
TOPHAT1     BSET  PORTA, #$F0        ;Sets the highest 4 bits of PORTA to be used as the first option for Pattern 1
            
            BCLR  PORTA, #$00        ;Clears the necessary bits of PORTA to prevent the BSET instruction
                                     ;  from ruining the pattern selection process
            
            MOVB  PORTA, TopStore    ;Stores the first option for Pattern 1 in TopStore
                                     ;Allows Pattern 1 and Pattern 2 to be toggled when RTI is called
                                                 
            BRA   BOTHLF             ;Branches to the selection process for Pattern 2 (BOTHLF)
                  ;**The next 4 blocks of code repeat the same process as this block but set Pattern 1 for the 4 other options of Pattern 1**
                       
TOPHAT2     BSET  PORTA, #$E0
            BCLR  PORTA, #$10
            MOVB  PORTA, TopStore                                                                  
            BRA   BOTHLF            
            
TOPHAT3     BSET  PORTA, #$D0            
            BCLR  PORTA, #$20            
            MOVB  PORTA, TopStore                        
            BRA   BOTHLF            
            
TOPHAT4     BSET  PORTA, #$C0            
            BCLR  PORTA, #$30            
            MOVB  PORTA, TopStore           
            BRA   BOTHLF
                        
TOPHAT5     BSET  PORTA, #$B0
            BCLR  PORTA, #$40            
            MOVB  PORTA, TopStore            
            BRA   BOTHLF
            
            ;///|||\\\
            
BOTPAT1     BSET  PORTA, #$0F        ;Sets the lowest 4 bits of PORTA to be used as the first option for Pattern 2

            BCLR  PORTA, #$00        ;Clears the necessary bits of PORTA to prevent the BSET instruction 
                                     ;  from ruining the pattern selection process
           
            MOVB  PORTA, BotStore    ;Stores the first option for Pattern 2 in BotStore
                                     ;Allows Pattern 1 and Pattern 2 to be toggled when RTI is called
            
            BRA   FIN                ;Branches to the final part of the XIRQ interrupt
                  ;**The next 4 blocks of code repeat the same process as this block but set Pattern 2 for the 4 other options of Pattern 2**
            
BOTPAT2     BSET  PORTA, #$0E
            BCLR  PORTA, #$01
            MOVB  PORTA, BotStore
            BRA   FIN
            
BOTPAT3     BSET  PORTA, #$0D
            BCLR  PORTA, #$02
            MOVB  PORTA, BotStore
            BRA   FIN            
            
BOTPAT4     BSET  PORTA, #$0C       
            BCLR  PORTA, #$03
            MOVB  PORTA, BotStore
            JMP   FIN            
            
BOTPAT5     BSET  PORTA, #$0B
            BCLR  PORTA, #$04
            MOVB  PORTA, BotStore
            JMP   FIN
            
            
     
                    
          
             
ADCINIT     DC.B $18, $0b, $80, $01, $22   ;Initializes POT1 and POT2
            DC.B $18, $0b, $10, $01, $23           
            DC.B $18, $0B, $80, $01, $24
            DC.B $18, $0B, $F0, $01, $25
            DC.B $18, $0B, $FC, $01, $2D
            DC.B $3D 
            RTS
            
            

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
           
            ORG   $FFF0           ;Vector table setup for real time interrupt
            DC.W  RTI_INT
           
            ORG   $FFF4           ;Vector table setup for XIRQ interrupt
            DC.W  XIRQ_INT
           
            ORG   $FFFE           ;Vector table setup for reset interrupt
            DC.W  Entry         
