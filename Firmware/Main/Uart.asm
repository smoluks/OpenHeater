USART_RXC:
push r16
push r26
push r27
in r16, SREG
push r16
;
in r16, UDR
rcall acrc
lds r26, RECV_HANDLE_L
lds r27, RECV_HANDLE_H
st x+, r16
sts RECV_HANDLE_L, r26
sts RECV_HANDLE_H, r27
;restart T2
out tcnt2, r2
ldi r16, 0b00001101
out tccr2, r16
;
pop r16
out SREG, r16
pop r27
pop r26
pop r16
reti

USART_TXC:
push r16
push r26
push r27
in r16, SREG
push r16
;
lds r16, TRANS_COUNT
tst r16
breq utexit
;
dec r16
sts TRANS_COUNT, r16
;
lds r26, TRANS_HANDLE_L
lds r27, TRANS_HANDLE_H
ld r16, X+
sts TRANS_HANDLE_L, r26
sts TRANS_HANDLE_H, r27
out UDR, r16
;
utexit:
pop r16
out SREG, r16
pop r27
pop r26
pop r16
reti
