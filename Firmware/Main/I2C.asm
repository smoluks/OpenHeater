#define BUS_FAIL 0x00
#define START 0x08
#define RESTART 0x10
#define SLA_W_ACK 0x18
#define SLA_W_NACK 0x20
#define BYTE_ACK 0x28
#define BYTE_NACK 0x30
#define COLLISION 0x38
#define SLA_R_ACK 0x40
#define SLA_R_NACK 0x48
#define RECEIVE_BYTE 0x50
#define RECEIVE_BYTE_NACK 0x58

#define ADDRESS_READ 0xD1
#define ADDRESS_WRITE 0xD0

;in: r17 - addr
;out: r17 - data
i2c_read:
;
rcall i2c_send_start
brts i2c_read_exit
;
rcall i2c_send_address_w
brts i2c_read_exit
;
rcall i2c_send_byte
brts i2c_read_exit
;
rcall i2c_send_repeat_start
brts i2c_read_exit

rcall i2c_send_address_r
brts i2c_read_exit

rcall i2c_receive_byte_nack
brts i2c_read_exit
;
rcall i2c_send_stop
;
i2c_read_exit:
ret

;in: r16 - data, r17 - addr
i2c_write:
sts TEMP1, r16
;
rcall i2c_send_start
brts i2c_write_exit
;
rcall i2c_send_address_w
brts i2c_write_exit
;
rcall i2c_send_byte
brts i2c_write_exit
;
lds r17, TEMP1
rcall i2c_send_byte
brts i2c_write_exit
;
rcall i2c_send_stop
;
i2c_write_exit:
ret

i2c_send_start:
clt
;set start bit
ldi r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
out TWCR, r16
;wait
i1:
in r16,TWCR
sbrs r16,TWINT
rjmp i1
;process result
in r16,TWSR
andi r16, 0xF8
cpi r16, START
brne i2
ret
i2:
set
ret

i2c_send_repeat_start:
clt
;set start bit
ldi r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
out TWCR, r16
;wait
i9:
in r16,TWCR
sbrs r16,TWINT
rjmp i9
;process result
in r16,TWSR
andi r16, 0xF8
cpi r16, RESTART
brne i2
ret

i2c_send_address_w:
clt
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
in r16,TWSR
andi r16, 0xF8
cpi r16, SLA_W_ACK
brne i2
ret

i2c_send_address_r:
clt
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
in r16,TWSR
andi r16, 0xF8
cpi r16, SLA_R_ACK
brne i2
ret

;data - r17
i2c_send_byte:
clt
out TWDR, r17
ldi r16, (1<<TWINT) | (1<<TWEN)
out TWCR, r16
;
i6:
in r16,TWCR
sbrs r16,TWINT
rjmp i6
;
in r16,TWSR
andi r16, 0xF8
cpi r16, BYTE_ACK
brne i2
ret

i2c_receive_byte_ack:
clt
ldi r16, (1<<TWEA) | (1<<TWINT) | (1<<TWEN)
out TWCR, r16
;
i7:
in r16,TWCR
sbrs r16,TWINT
rjmp i7
;
in r16,TWSR
andi r16, 0xF8
cpi r16, RECEIVE_BYTE
brne i2
;
in r17, TWDR
ret

i2c_receive_byte_nack:
clt
ldi r16, (1<<TWINT) | (1<<TWEN)
out TWCR, r16
;
i8:
in r16,TWCR
sbrs r16,TWINT
rjmp i8
;
in r16,TWSR
andi r16, 0xF8
cpi r16, RECEIVE_BYTE
brne i10
;
in r17, TWDR
ret
i10:
set
ret

i2c_send_stop:
ldi r16, (1<<TWINT)|(1<<TWEN)|(1<<TWSTO)
out TWCR, r16
ret