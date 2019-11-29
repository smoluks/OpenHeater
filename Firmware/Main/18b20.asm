#define READ_ROM 0x33
#define MATCH_ROM 0x55
#define SEARCH_ROM 0xF0
#define ALARM_SEARCH 0xEC
#define SKIP_ROM 0xCC

#define CONVERT_TEMPERATURE 0x44
#define COPY_SCRATCHPAD 0x48
#define READ_POWER_SUPPLY 0xB4
#define RECALL_E2 0xB8
#define READ_SCRATCHPAD 0xBE
#define WRITE_SCRATCHPAD 0x4E

#define MEAS_TIME 70

init_18b20:
search_18b20:
push r16
push r17
push r18
push r19
push r20
push r24
push r25
push r26
push r27
push r28
push r29
push r30
push r31
;---search all 18b20---
ldi r19, 0xFF ;last cycle last zero-wented branch
;handle to store
ldi r30, low(D18B20_ADDRESSES * 2)
ldi r31, high(D18B20_ADDRESSES * 2)
;address
clr r24
clr r25
clr r26
clr r27
clr r28
clr r29
;
search_cycle:
movw r8, r24
movw r10, r26
movw r12, r28
ldi r18, 48
clr r20 ;current cycle last zero-wented branch
;
rcall ow_reset
;
ldi r16, SEARCH_ROM
rcall ow_write_byte
;
ldi r16, 0x28
rcall ow_write_byte_with_check
;-----bit cycle------
search_bit_cycle:
clr r17
clr r20
;
ror r13
ror r12
ror r11
ror r10
ror r9
ror r8
brcc search1
 sbr r17, 0b00000001
search1:
;----- read -----
rcall ow_read_bit
brts search2
 ;
 rcall ow_read_bit
 brts search3
  ;none present
  rjmp search_exit
 search3:
  ;zero present
  clc
  rjmp search_savebit 
search2:
rcall ow_read_bit
brts search4
 ;one present
 sec
 rjmp search_savebit
search4:
 ;both present
 cp r19, r18
 brne search6
  ;-current bit - branch-
  sec ;go to one
  rjmp search_savebit
 search6:
 brlo search7
  ;i's branch inside current - use default
  mov r20, r18
  clc ;go to one
  rjmp search_savebit
 search7:
  ;it's brach outside current - use stored
  sec
  sbrc r17, 0
  rjmp search8
   mov r20, r18
   clc
  search8:  
  ;rjmp search_savebit 
;save bit
search_savebit:
ror r29
ror r28
ror r27
ror r26
ror r25
ror r24
clt
sbrc r29, 7
 set
rcall ow_write_bit
;
dec r18
brne search_bit_cycle
;
tst r20
breq search_exit;no more branch
mov r19, r20
;save
search_exit:
ldi r16, 0x28
st z+, r16
st z+, r24
st z+, r25
st z+, r26
st z+, r27
st z+, r28
st z+, r29
clr r16
st x+, r16
;
pop r31
pop r30
pop r29
pop r28
pop r27
pop r26
pop r25
pop r24
pop r20
pop r19
pop r18
pop r17
pop r16
ret

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
