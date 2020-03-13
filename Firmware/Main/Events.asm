events:
push r20
push r21
push r22
push r23
;
ldi r17, SECONDS_TKREG
rcall i2c_read
mov r20, r16
andi r20, 0x7F
;
ldi r17, MINUTES_TKREG
rcall i2c_read
mov r21, r16
andi r21, 0x7F
;
ldi r17, HOURS_TKREG
rcall i2c_read
mov r22, r16
andi r22, 0x3F
;
ldi r17, DAY_TKREG
rcall i2c_read
ldi r23, 0x01
days_cmp0:
tst r16
breq cycle
 lsl r23
 dec r16
 rjmp days_cmp0
;
cycle:
ldi r17, 8
events_cycle:
rcall i2c_read
;check enable
sbrs r16, 0
rjmp e_next_skip7
;check timestamp
rcall check_time
brts e_next_skip7
;is once?
sbrc r16, 1
cbr r16, 0b00000001
rcall i2c_write
;mode
ldi r16, 5
add r17, r16
rcall i2c_read
cpi r16, 0xFF
breq e_temp
cpi r16, MODE_COUNT
brsh e_temp
mov MODE_REG, r16
;temperature
e_temp:
inc r17
rcall i2c_read
cpi r16, 0xFF
breq e_next_1
cpi r16, MIN_TARGET_TEMP
brlt e_next_1
cpi r16, MAX_TARGET_TEMP+1
brge e_next_1
mov TTARGET_REG, r16
e_next_1:
inc r17
rjmp e_next
e_next_skip7:
ldi r16, 7
add r17, r16
e_next:
cpi r17, 64
brlo events_cycle
;
pop r23
pop r22
pop r21
pop r20
ret

check_time:
push r16
push r17
;seconds
inc r17
rcall i2c_read
cpi r16, 0xFF
breq chk_minutes
cp r16, r20
brne check_time_bad
;minutes
chk_minutes:
inc r17
rcall i2c_read
cpi r16, 0xFF
breq chk_hours
cp r16, r21
brne check_time_bad
;hours
chk_hours:
inc r17
rcall i2c_read
cpi r16, 0xFF
breq chk_days
cp r16, r22
brne check_time_bad
;days
chk_days:
inc r17
rcall i2c_read
cpi r16, 0xFF
breq chk_good
and r16, r23
breq check_time_bad
;
chk_good:
pop r17
pop r16
clt
ret
check_time_bad:
pop r17
pop r16
set
ret 