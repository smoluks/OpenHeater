#define SKIP_ROM 0xCC

#define CONVERT_TEMPERATURE 0x44
#define COPY_SCRATCHPAD 0x48
#define READ_POWER_SUPPLY 0xB4
#define RECALL_E2 0xB8
#define READ_SCRATCHPAD 0xBE
#define WRITE_SCRATCHPAD 0x4E

#define MEAS_TIME 70

init_18b20:
;set resolution
rcall ow_reset
brtc i180
 ret
i180:
ldi r16, SKIP_ROM
rcall ow_write_byte
ldi r16, WRITE_SCRATCHPAD
rcall ow_write_byte
clr r16
rcall ow_write_byte
clr r16
rcall ow_write_byte
ldi r16, 0b01111111
rcall ow_write_byte
;read scrathpad
.IFDEF CHECK_18B20_GENUINE
rcall ow_reset
brtc i181
 ret
i181:
ldi r16, SKIP_ROM
rcall ow_write_byte
ldi r16, READ_SCRATCHPAD
rcall ow_write_byte
rcall ow_read_byte
cpi r16, 0x50
breq i20
 ;sbr ERROR_REG, 1 << FAKE_18B20
i20:
rcall ow_read_byte
cpi r16, 0x05
breq i21
 ;sbr ERROR_REG, 1 << FAKE_18B20
i21:
.ENDIF
;start conversion
rcall ow_reset
brtc i182
 ret
i182:
ldi r16, SKIP_ROM
rcall ow_write_byte
ldi r16, CONVERT_TEMPERATURE
rcall ow_write_byte
;
ret

read_18b20:
lds r16, D18B20_STATE
tst r16
brne r18b20_timeout
 ;read temperature
 rcall ow_read_bit
 brts r181
  ;conversation in progress
  ret
 r181:
 rcall ow_reset
 brtc r182
  ret
 r182:
 ldi r16, SKIP_ROM
 rcall ow_write_byte
 ldi r16, READ_SCRATCHPAD
 rcall ow_write_byte
 rcall ow_read_byte
 mov TLow_REG, r16
 rcall ow_read_byte
 mov THigh_REG, r16
 ;
 lds r16, SYSTICK
 ldi r17, MEAS_TIME
 add r16, r17
 sts D18B20_TIMESTAMP, r16
 ;
 sts D18B20_STATE, CONST_10
 ret
r18b20_timeout:
 lds r16, SYSTICK
 lds r17, D18B20_TIMESTAMP
 sub r17, r16
 sbrs r17, 7
 ret
 ;start conversion
 rcall ow_reset
 brtc r183
  ret
 r183:
 ldi r16, SKIP_ROM
 rcall ow_write_byte
 ldi r16, CONVERT_TEMPERATURE
 rcall ow_write_byte
 ;set state
 sts D18B20_STATE, CONST_0
 ;
 ret
