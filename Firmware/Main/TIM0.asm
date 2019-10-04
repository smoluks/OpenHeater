;Dynamic indication
TIM0_OVF:
push r16
push r17
in r16, SREG
push r16
;
lds r16, SEGNUMBER
inc r16
cpi r16, 4
brlo to0
 clr r16
to0:
sts SEGNUMBER, r16
;
cpi r16, 0
brne to1
 ;SEG1
 cbi portb, 5
 ;
 lds r16, SEG1
 andi r16, 0b10001111
 out portb, r16
 ;
 lds r16, SEG1
 lsl r16
 andi r16, 0b11100000
 in r17, portd
 andi r17, 0b00001111
 or r16, r17
 out portd, r16
 ;
 sbi portb, 6
 rjmp coexit
to1:
cpi r16, 1
brne to2
 ;SEG2
 cbi portb, 6
 ;
 lds r16, SEG2
 andi r16, 0b10001111
 out portb, r16
 ;
 lds r16, SEG2
 lsl r16
 andi r16, 0b11100000
 in r17, portd
 andi r17, 0b00001111
 or r16, r17
 out portd, r16
 ;
 sbi portd, 4
 rjmp coexit
to2:
cpi r16, 2
brne to3
 ;SEG3
 cbi portd, 4
 ;
 lds r16, SEG3
 andi r16, 0b10001111
 out portb, r16
 ;
 lds r16, SEG3
 lsl r16
 andi r16, 0b11100000
 in r17, portd
 andi r17, 0b00001111
 or r16, r17
 out portd, r16
 ;
 sbi portb, 4 
 rjmp coexit
to3:
 ;SEG4 
 cbi portb, 4
 ;
 lds r16, SEG4
 andi r16, 0b10001111
 out portb, r16
 ;
 lds r16, SEG4
 lsl r16
 andi r16, 0b11100000
 in r17, portd
 andi r17, 0b00001111
 or r16, r17
 out portd, r16
 ;
 sbi portb, 5
 rjmp coexit
; 
coexit:
pop r16
out SREG, r16
pop r17
pop r16
reti