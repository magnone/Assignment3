	   title    "Dice program"
	   list     p=16f84
	   include  "p16f84.inc"
;	   __FUSES  _CP_OFF&_XT_OSC&_WDT_OFF

;*******************************************************************
;                           dice.ASM
;                    Implement a simple electronic dice
;
; Description
;    Program for a PIC 16c84 unit to produce a seven segment dice 
;    display.  A 1->6 binary code is output on RB[0..3] and fed
;    to a BCD display.  A push switch is connected to RB1 and used
;    as a request for a new number.
;
; Method
;    The main program does a very fast 1->6 rotation count.  During
;    each increment the input switch is tested; while it is pressed
;    the display will be updated with a new value and the count disabled.
;
; Design notes
;    The design has been done using the pseudo-code method.
;       a. The logic of the application is described by a 'C'-like language.
;       b. The pseudo-code has then be converted to PIC assembly language.
;       c. The pseudo-code has been included as comments.
;
;    The debounce code includes a 40 millisecond delay.
;
; Version
;    J Herd    V1.0   March 1997
;*******************************************************************   
;
; I/O pin definitions
;
RA0        equ     d'0'      ; Port A line 0 pin
RB4		equ		d'4'
;
;*******************************************************************   
;
; Variable declarations.
;
count        equ   h'0C'        ; dice count
presses      equ   h'0D'        ; used for switch debounce
delcnt       equ   h'0E'        ; parameter register for del1mS routine
temp         equ   h'0F'        ; temporary register
;
;
;*******************************************************************
;
; Initial system vectors.
;   
	org     h'00'           ; initialise system restart vector
	goto    start           ; 
;
;******************************************************************* 
;
; System subroutines.
;  
	org     h'05'           ; start of program space
;
;* init : initialise I/O ports and variables
;  ====
;
init    
    bsf     STATUS, RP0        ; enable page 1 register set
	movlw   b'11111'
	movwf   TRISA              ; RA0   input
	movlw   b'11100000'                 
	movwf   TRISB              ; RB0-RB7 output
	bcf     STATUS, RP0        ; back to page 0 register set
;
; clear display
;
    movlw   h'0F'              ; h'0F' to this BCD display will clear
    movwf   PORTB
;
; Set dice counter to ZERO
;
	clrf    count              ; set dice count to ZERO
    return
;
;******************************************************************* 
;
;* del1ms : Provide a 1 millisecond delay.
;  ======
;
; Memory used
;    delcnt
; Calls
;    none.
;                        ; call = 2uS    (   2)
del1ms  
	movlw   d'199'       ;      + 1      (   3)
	movwf   delcnt       ;      + 1      (   4)
del1    
	nop                  ;      + 199    ( 203)
	nop                  ;      + 199    ( 402)
	decfsz  delcnt,f     ;      + 200    ( 602)
	goto    del1         ;      + 396    ( 998)
	return               ;      + 2      (1000)
;
;******************************************************************* 
;
; MAIN program
; ============
;
start   call    init
;
;   for(;;) {
;       presses = 0;
;
gameloop
	clrf      presses
;
;     presses = read(RA0);             /* read switch               */
;     delay(40);                       /* delay 40mS                */
;     presses = presses + read(RA0);   /* read switch a second time */
;
    btfsc     PORTA,RA0
    incf      presses,F
;
    movlw     d'40'
	movwf     temp
loop1   
    call      del1ms 
    decfsz    temp,F
    goto      loop1 
;
    btfsc     PORTA,RA0 	; read switch a second time for debounce.
    incf      presses,F
;
;     if (presses == 0)          /* if 'presses==0' then no bounce detected */
;         display(count);
;
    movf      presses,F       ; test for zero
    btfss     STATUS, Z
    goto      else1
    movf      count,W
   ; movwf     PORTB, RB4
    goto      exit1
;
;     else
;         count = count + 1;
;         if (count == 7)
;             count = 1;
;
else1   
    incf      count,F
    movf      count,W
; display f
;	movwf 	PORT
    sublw     d'07'
    btfss     STATUS,Z		;	test 0
    goto      exit2
;
    movlw     d'01'
    movwf     count
exit2
exit1
;
    goto      gameloop
;
    end
        


