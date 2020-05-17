;Dynamic indication
TIM2_OVF:
push r16
push r17
in r16, SREG
push r16
;
lds r16, SEGNUMBER
inc r16
andi r16, 0b00000011
sts SEGNUMBER, r16
;
cpi r16, 1
breq to1
cpi r16, 2
breq to2
cpi r16, 3
breq to3
;----------SEG1----------
 cbi portc, 7
 ;
 lds r16, SEG1
 andi r16, 0b00001111
 lsl r16
 lsl r16
 out portc, r16 
 ;
 lds r16, SEG1
 andi r16, 0b11110000
 out portd, r16
 ;
 sbi portd, 3
 ;
 pop r16
 out SREG, r16
 pop r17
 pop r16
 reti
 ;----------SEG2----------
 to1:
 cbi portd, 3
 ;
 lds r16, SEG2
 andi r16, 0b00001111
 lsl r16
 lsl r16
 out portc, r16 
 ;
 lds r16, SEG2
 andi r16, 0b11110000
 out portd, r16
 ;
 sbi portd, 2
;
 pop r16
 out SREG, r16
 pop r17
 pop r16
 reti
 ;----------SEG3----------
 to2:
 cbi portd, 2
 ;
 lds r16, SEG3
 andi r16, 0b00001111
 lsl r16
 lsl r16
 out portc, r16 
 ;
 lds r16, SEG3
 andi r16, 0b11110000
 out portd, r16
 ;
 sbi portc, 6
;
 pop r16
 out SREG, r16
 pop r17
 pop r16
 reti
 ;----------SEG4----------
 to3:
 cbi portc, 6
 ;
 lds r16, SEG4
 andi r16, 0b00001111
 lsl r16
 lsl r16
 out portc, r16 
 ;
 lds r16, SEG4
 andi r16, 0b11110000
 out portd, r16
 ;
 sbi portc, 7
 ;
 pop r16
 out SREG, r16
 pop r17
 pop r16
 reti

TIM2_COMP:
out portc, CONST_0
out portd, CONST_0
reti