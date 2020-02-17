;----------------------1Wire routine 8MHz----------------------
#define OW_DDR ddrd, 3
#define OW_PORT portd, 3
#define OW_PIN pind, 3

ow_reset:
push r16
push r17
;Tx
cbi OW_PORT
sbi OW_DDR
ldi r16, low(479)
ldi r17, high(479)
rcall ipause
cbi OW_DDR
sbi OW_PORT
;Rx
ldi r16, 59
clr r17
rcall ipause
set
sbic OW_PIN
 rjmp ow_resetexit
clt
;
ldi r16, low(419)
ldi r17, high(419)
rcall ipause
;
ow_reset1:
sbis OW_PIN
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
cbi OW_PORT
sbi OW_DDR
rcall pause_1us
;
cbi OW_DDR
sbi OW_PORT
ldi r16, 12
clr r17
rcall ipause
;
clt
sbic OW_PIN
set
;
;ldi r16, 38
;clr r17
;rcall ipause
;
ow_read_bit_wait:
sbis OW_PIN
rjmp ow_read_bit_wait
;
pop r17
pop r16
ret

ow_write_bit:
push r16 
push r17
;
cbi OW_PORT
sbi OW_DDR
rcall pause_1us
;
brtc w1
 cbi OW_DDR
 sbi OW_PORT 
w1:
clr r17
ldi r16, 54
rcall ipause
;
cbi OW_DDR
sbi OW_PORT
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
;ldi r16, 5
;clr r17
;rcall ipause
pop r17
ret

ow_write_byte_with_check:
push r17
;
ldi r17, 8
rw1c:
;direct
rcall ow_read_bit
sbrc r16, 0
rjmp owbwc1
 brts owbwc_error
owbwc1:
;inverted
rcall ow_read_bit
sbrs r16, 0
rjmp owbwc2
 brts owbwc_error
owbwc2:
;send bit
bst r16, 0
ror r16
rcall ow_write_bit;
;
dec r17
brne rw1c;
;
;ldi r16, 5
;clr r17
;rcall ipause
;pop r17
clt
owbwc_error:
ret

ipause:
nop
nop
nop
nop
subi r16, 1
sbc r17, CONST_0
brcc ipause;
ret

pause_1us:
nop
ret