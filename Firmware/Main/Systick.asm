TIM1_COMPA:
push r16
push r17
in r16, SREG
push r16
;
;
lds r16, SYSTICK
inc r16
sts SYSTICK, r16
;
rcall process_buttons
;
rcall logic
;
pop r16
out SREG, r16
pop r17
pop r16
reti