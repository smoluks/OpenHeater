#define SKIP_ROM 0xCC

#define CONVERT_TEMPERATURE 0x44
#define COPY_SCRATCHPAD 0x48
#define READ_POWER_SUPPLY 0xB4
#define RECALL_E2 0xB8
#define READ_SCRATCHPAD 0xBE
#define WRITE_SCRATCHPAD 0x4E

#define STATE18B20_WAIT_MEASURING 0x00
#define STATE18B20_WAIT_TIMEOUT 0x01

#define MEAS_TIME 0

init_18b20:
sts state18b20, r2

;set resolution
rcall ow_reset
brts init_18b20_exit
ldi r16, SKIP_ROM
rcall ow_write_byte
ldi r16, WRITE_SCRATCHPAD
rcall ow_write_byte
clr r16
rcall ow_write_byte
clr r16
rcall ow_write_byte
ldi r16, 0b00011111
rcall ow_write_byte

;read scrathpad

;start conversion
rcall ow_reset
brts init_18b20_exit
ldi r16, SKIP_ROM
rcall ow_write_byte
ldi r16, CONVERT_TEMPERATURE
rcall ow_write_byte
;
init_18b20_exit:
ret

read_18b20:
lds r16, state18b20
cpi r16, STATE18B20_WAIT_MEASURING
breq process_18b20_readtemp
cpi r16, STATE18B20_WAIT_TIMEOUT
breq process_18b20_checktimeout
sts state18b20, r2
ret

process_18b20_checktimeout:
lds r16, Systick
lds r17, pt18b20
sub r17, r16
sbrs r17, 7
 ret
;start conversion
rcall ow_reset
brts process_18b20_exit
ldi r16, SKIP_ROM
rcall ow_write_byte
ldi r16, CONVERT_TEMPERATURE
rcall ow_write_byte
;set state
ldi r16, STATE18B20_WAIT_MEASURING
sts state18b20, r16
;
process_18b20_exit:
ret

process_18b20_readtemp:
rcall ow_read_bit
brts p1
 ret
; 
;read temperature
p1:
rcall ow_reset
brts init_18b20_exit
ldi r16, SKIP_ROM
rcall ow_write_byte
ldi r16, READ_SCRATCHPAD
rcall ow_write_byte
rcall ow_read_byte
mov TLow_REG, r16
rcall ow_read_byte
mov THigh_REG, r16
;
lds r16, Systick
ldi r17, MEAS_TIME
add r16, r17
sts pt18b20, r16
;
ldi r16, STATE18B20_WAIT_TIMEOUT
sts state18b20, r16
ret