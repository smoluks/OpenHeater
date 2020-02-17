;--------------------------------------------------
i2c_send_start:
push r16
;set start bit
ldi r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
out TWCR, r16
;wait
i1:
in r16,TWCR
sbrs r16,TWINT
rjmp i1
;process result
clt
in r16,TWSR
andi r16, 0xF8
cpi r16, START
breq i2
set
i2:
;
pop r16
ret

i2c_send_repeat_start:
push r16
;set start bit
ldi r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
out TWCR, r16
;wait
i9:
in r16,TWCR
sbrs r16,TWINT
rjmp i9
;process result
clt
in r16,TWSR
andi r16, 0xF8
cpi r16, RESTART
breq i14
set
i14:
;
pop r16
ret

i2c_send_address_w:
push r16
;
ldi r16, ADDRESS_WRITE
out TWDR, r16
ldi r16, (1<<TWINT) | (1<<TWEN)
out TWCR, r16
;
i5:
in r16,TWCR
sbrs r16,TWINT
rjmp i5
;
clt
in r16,TWSR
andi r16, 0xF8
cpi r16, SLA_W_ACK
breq i13
set
i13:
;
pop r16
ret

i2c_send_address_r:
push r16
;
ldi r16, ADDRESS_READ
out TWDR, r16
ldi r16, (1<<TWINT) | (1<<TWEN)
out TWCR, r16
;
i3:
in r16,TWCR
sbrs r16,TWINT
rjmp i3
;
clt
in r16,TWSR
andi r16, 0xF8
cpi r16, SLA_R_ACK
breq i18
set
i18:
;
pop r16
ret

;in: data - r17
i2c_send_byte:
push r16
;
out TWDR, r17
ldi r16, (1<<TWINT) | (1<<TWEN)
out TWCR, r16
;
i6:
in r16,TWCR
sbrs r16,TWINT
rjmp i6
;
clt
in r16,TWSR
andi r16, 0xF8
cpi r16, BYTE_ACK
breq i15
set
i15:
;
pop r16
ret

;out: r16
i2c_receive_byte_ack:
push r17
;
ldi r17, (1<<TWEA) | (1<<TWINT) | (1<<TWEN)
out TWCR, r17
;
i7:
in r17,TWCR
sbrs r17,TWINT
rjmp i7
;
clt
in r17,TWSR
andi r17, 0xF8
cpi r17, RECEIVE_BYTE
breq i16
 set
i16:
;
in r16, TWDR
;
pop r17
ret

;out: r16
i2c_receive_byte_nack:
push r17
;
ldi r17, (1<<TWINT) | (1<<TWEN)
out TWCR, r17
;
i8:
in r17,TWCR
sbrs r17,TWINT
rjmp i8
;
clt
in r17,TWSR
andi r17, 0xF8
cpi r17, RECEIVE_BYTE_NACK
breq i17
 set
i17:
;
in r16, TWDR
;
pop r17
ret

i2c_send_stop:
push r16
;
ldi r16, (1<<TWINT)|(1<<TWEN)|(1<<TWSTO)
out TWCR, r16
;
i12:
in r16, TWCR
sbrc r16,TWSTO
rjmp i12
;
pop r16
ret