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
;out: r16 - data
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
clt
i2c_read_exit:
ret

;in: r17 - addr
;out: r16:17 - data
i2c_read_pair:
;
rcall i2c_send_start
brts i2c_read_pair_exit
;
rcall i2c_send_address_w
brts i2c_read_pair_exit
;
rcall i2c_send_byte
brts i2c_read_pair_exit
;
rcall i2c_send_repeat_start
brts i2c_read_pair_exit

rcall i2c_send_address_r
brts i2c_read_pair_exit

rcall i2c_receive_byte_ack
brts i2c_read_pair_exit
mov r17, r16

rcall i2c_receive_byte_nack
brts i2c_read_pair_exit
;
rcall i2c_send_stop
;
clt
i2c_read_pair_exit:
ret

;in: r17 - addr, r18 - count, Z - buffer
i2c_read_buffer:
;
rcall i2c_send_start
brts i2c_read_buffer_exit
;
rcall i2c_send_address_w
brts i2c_read_buffer_exit
;addr
rcall i2c_send_byte
brts i2c_read_buffer_exit
;
rcall i2c_send_repeat_start
brts i2c_read_buffer_exit
;
rcall i2c_send_address_r
brts i2c_read_buffer_exit
;
i2c_read_buffer_cycle:
cpi r18, 1
breq i30
 rcall i2c_receive_byte_ack
 brts i2c_read_buffer_exit
 rjmp i31
i30: 
 rcall i2c_receive_byte_nack
 brts i2c_read_buffer_exit
i31: 
st z+, r16
dec r18
brne i2c_read_buffer_cycle
;
rcall i2c_send_stop
;
clt
i2c_read_buffer_exit:
ret

;in: r16 - data, r17 - addr
i2c_write:
push r16
push r17
;
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
clt
i2c_write_exit:
pop r17
pop r16
ret

;in: r18 - count, r17 - addr
i2c_flush:
;
rcall i2c_send_start
brts i2c_flush_exit
;
rcall i2c_send_address_w
brts i2c_flush_exit
;
rcall i2c_send_byte
brts i2c_write_exit
;
ldi r17, 0x00
i2c_flush_cycle:
rcall i2c_send_byte
brts i2c_flush_exit
dec r18
brne i2c_flush_cycle
;
rcall i2c_send_stop
;
clt
i2c_flush_exit:
ret

#include "I2CRoutine.asm"
