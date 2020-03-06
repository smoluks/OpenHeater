events:
ldi r30, low(EVENTS_CACHE)
ldi r31, high(EVENTS_CACHE)
ldi r19, 8
events_cycle:
ld r16, z+
sbrc r16, 0
rcall check_time
;
adiw r30, 6
;
dec r19
brne events_cycle
ret

check_time:
ld r18, z+
cpi r18, 0xFF
breq chk_minutes
;
ldi r17, SECONDS_TKREG
rcall i2c_read
andi r16, 0x7F
chk_minutes: