;----------------------1Wire----------------------
ow_reset:
;---init---
push r16
push r17
;Tx
sbi ddrd, 3
cbi portd, 3
ldi r16, 0xDF
ldi r17, 0x01
rcall ipause
cbi ddrd, 3
sbi portd, 3
;Rx
ldi r16, 59
clr r17
rcall ipause
set
sbic pind, 3
 rjmp ow_resetexit
clt
ldi r16, 0xA3
ldi r17, 0x01
rcall ipause
ow_reset1:
sbis pind, 3
rjmp ow_reset1;
;
ow_resetexit:
pop r17
pop r16
ret

ow_read_bit:
push r16
push r17
;
cbi portd, 3
sbi ddrd, 3
rcall pause_1us
;
cbi ddrd, 3
sbi portd,3
ldi r16, 12
clr r17
rcall ipause
;
clt
sbic pind, 3
set
;
ldi r16, 38
clr r17
rcall ipause
;
ow_read_bit_wait:
sbis pind, 3
rjmp ow_read_bit_wait
;
pop r17
pop r16
ret

ow_write_bit:
push r16 
push r17
;
cbi portd, 3
sbi ddrd, 3
rcall pause_1us
;
brtc w1
 cbi ddrd, 3
 sbi portd, 3 
w1:
clr r17
ldi r16, 54
rcall ipause
;
cbi ddrd, 3
sbi portd, 3
;
pop r17
pop r16
ret

ow_read_byte:
push r17
;
ldi r17, 8
rr1:
rcall ow_read_bit;
ror r16
bld r16, 7
dec r17
brne rr1;
;
pop r17
ret

ow_write_byte:
push r17
;
ldi r17, 8
rw1:
bst r16, 0
ror r16
rcall ow_write_bit;
dec r17
brne rw1;
;
ldi r16, 5
clr r17
rcall ipause
pop r17
ret

ow_write_byte_with_check:
push r17
;
ldi r17, 8
rw1c:
rcall ow_read_bit
rcall ow_read_bit
bst r16, 0
ror r16
rcall ow_write_bit;
dec r17
brne rw1c;
;
ldi r16, 5
clr r17
rcall ipause
pop r17
ret

ipause:
nop
nop
nop
nop
subi r16, 1
sbc r17, r2
brcc ipause;
ret

pause_1us:
nop
ret