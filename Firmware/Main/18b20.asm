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
#define CONFIG_BYTE 0b01111111

init_18b20:
;search all 18b20
rcall search_18b20
brts init_18b20_error
;check count
lds r17, D18B20_COUNT
tst r17
breq init_18b20_error
;configure all 18b20
rcall set_resolution
brts init_18b20_error
ret
init_18b20_error:
sbr ERRORL_REG, 1 << ERRORL_NO18B20
ret

read_18b20:
lds r16, D18B20_STATE
tst r16
breq r18b20_read
 ;check delay
 lds r16, SYSTICK
 lds r17, D18B20_TIMESTAMP
 sub r17, r16
 sbrs r17, 7
 ret
 ;start conversion (all)
 rcall ow_reset
 brtc r183
  sbr ERRORL_REG, 1 << ERRORL_NO18B20
  ret
 r183:
 ldi r16, SKIP_ROM
 rcall ow_write_byte
 ldi r16, CONVERT_TEMPERATURE
 rcall ow_write_byte
 ;set state
 sts D18B20_STATE, CONST_0
 ret
; 
r18b20_read:
rcall ow_read_bit
brts r181
 ;conversation in progress
 ret
r181:
push r22
push r28
push r29
push r30
push r31
;clear current min, max temperature
ldi TLowH_REG, 0x7F
ldi TLowL_REG, 0xFF
ldi THighH_REG, 0x80
ldi THighL_REG, 0x00
;
lds r22, D18B20_COUNT
ldi r28, low(D18B20_TEMPERATURES)
ldi r29, high(D18B20_TEMPERATURES)
ldi r30, low(D18B20_ADDRESSES)
ldi r31, high(D18B20_ADDRESSES)
;
read_18b20_cycle:
rcall read_single_18b20
brts read_18b20_fail
;store
st y+, r17
st y+, r16
;check min
cp r17, TLowL_REG
cpc r16, TLowH_REG
brge read_18b20_low
 mov TLowL_REG, r17
 mov TLowH_REG, r16
;check max
read_18b20_low:
cp r17, THighL_REG
cpc r16, THighH_REG
brlt read_18b20_high
 mov THighL_REG, r17
 mov THighH_REG, r16 
;
read_18b20_high:
dec r22
brne read_18b20_cycle
;make new timestamp
read_18b20_exit:
lds r16, SYSTICK
ldi r17, MEAS_TIME
add r16, r17
sts D18B20_TIMESTAMP, r16
;set status
sts D18B20_STATE, CONST_10
;
pop r31
pop r30
pop r29
pop r28
pop r22
ret
read_18b20_fail:
sbr ERRORL_REG, 1 << ERRORL_NO18B20
pop r31
pop r30
pop r29
pop r28
pop r22
ret

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
ldi r30, low(D18B20_ADDRESSES)
ldi r31, high(D18B20_ADDRESSES)
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
  brtc search00
   rjmp search_exit
  search00:
  ;
  ldi r16, SEARCH_ROM
  rcall ow_write_byte
  ;
  ldi r16, 0x28
  rcall ow_write_byte_with_check
  brtc search0
   rjmp search_exit
  search0: 
  ;-----bit cycle------
  search_bit_cycle:
    clr r17
    ;old value bit
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
  brtc search2
    rcall ow_read_bit
    brtc search3
    ;none present
     rjmp search_exit
    search3:
     ;one present
     sec
     rjmp search_savebit 
  search2:
    rcall ow_read_bit
    brtc search4
    ;zero present
     clc
     rjmp search_savebit
    search4:
     ;both present
     cp r18, r19
     breq search_curr
     brsh search_out
      ;it's branch inside current - use default
      mov r20, r18
      clc ;go to one
      rjmp search_savebit
     search_out:
     ;it's brach outside current - use stored
     sec
     sbrc r17, 0
     rjmp search_savebit
      mov r20, r18
      clc
      rjmp search_savebit
     search_curr:
      ;-current bit - branch-
      sec
      ;rjmp search_savebit
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
;-----save-----
clr r17
ldi r16, 0x28
rcall calculate_dallas_crc
mov r16, r24
rcall calculate_dallas_crc
mov r16, r25
rcall calculate_dallas_crc
mov r16, r26
rcall calculate_dallas_crc
mov r16, r27
rcall calculate_dallas_crc
mov r16, r28
rcall calculate_dallas_crc
mov r16, r29
rcall calculate_dallas_crc
;check crc
mov r16, r17
rcall ow_write_byte_with_check
brts search_exit
;-----save-----
;device id
ldi r16, 0x28
st z+, r16
;addr
st z+, r24
st z+, r25
st z+, r26
st z+, r27
st z+, r28
st z+, r29
;crc
st z+, r17
;
clt
;
lds r16, D18B20_COUNT
inc r16
sts D18B20_COUNT, r16
cpi r16, D18B20_MAX_COUNT
breq search_exit
;---
mov r19, r20
tst r20
breq search_exit;no more branch
rjmp search_cycle
;save
search_exit:
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

set_resolution:
;---set config byte---
rcall ow_reset
brts set_resolution_exit
ldi r16, SKIP_ROM
rcall ow_write_byte
ldi r16, WRITE_SCRATCHPAD
rcall ow_write_byte
clr r16
rcall ow_write_byte
clr r16
rcall ow_write_byte
ldi r16, CONFIG_BYTE
rcall ow_write_byte
;---read scrathpad---
.IFNDEF DEBUG
rcall ow_reset
brts set_resolution_exit
ldi r16, SKIP_ROM
rcall ow_write_byte
ldi r16, READ_SCRATCHPAD
rcall ow_write_byte
rcall ow_read_byte
cpi r16, 0x50
breq i20
 sbr ERRORL_REG, 1 << ERRORL_FAKE_18B20
i20:
rcall ow_read_byte
cpi r16, 0x05
breq i21
 sbr ERRORL_REG, 1 << ERRORL_FAKE_18B20
i21:
.ENDIF
;start conversion
rcall ow_reset
brts set_resolution_exit
ldi r16, SKIP_ROM
rcall ow_write_byte
ldi r16, CONVERT_TEMPERATURE
rcall ow_write_byte
;
clt
set_resolution_exit:
ret

;in Z - addr
;out r17:16 - temp, T - error
read_single_18b20:
rcall ow_reset
brts ow_reset_exit
ld r16, z+
rcall ow_write_byte
ld r16, z+
rcall ow_write_byte
ld r16, z+
rcall ow_write_byte
ld r16, z+
rcall ow_write_byte
ld r16, z+
rcall ow_write_byte
ld r16, z+
rcall ow_write_byte
ld r16, z+
rcall ow_write_byte
ld r16, z+
rcall ow_write_byte
ld r16, z+
rcall ow_write_byte
;
ldi r16, READ_SCRATCHPAD
rcall ow_write_byte
;
rcall ow_read_byte
mov r17, r16
;
rcall ow_read_byte
;
clt
ow_reset_exit:
ret

#include "dallasCrc.asm"
