logic:
;checks
tst ERRORL_REG
brne logic_off
tst ERRORH_REG
brne logic_off
cpi MODE_REG, MODE_OFF
breq logic_off
;temperature
movw r16, TLowL_REG
andi r16, 0b11110000
andi r17, 0b00001111
or r16, r17
swap r16
cp r16, TTARGET_REG
brge logic_off
;
cpi MODE_REG, MODE_1
brne lo1
 ;1
 sbi portc, 0
 cbi portc, 2
 cbi portd, 2
 ret
lo1: 
cpi MODE_REG, MODE_2
brne lo2
 ;2
 cbi portc, 0
 sbi portc, 2
 cbi portd, 2
 ret
lo2:
cpi MODE_REG, MODE_3
brne lo3
 ;3
 sbi portc, 0
 sbi portc, 2
 cbi portd, 2
 ret
lo3:
cpi MODE_REG, MODE_FAN
brne lo4
 ;FAN
 cbi portc, 0
 cbi portc, 2
 sbi portd, 2
 ret
lo4: 
sbr ERRORL_REG, 1 << ERRORL_SOFTWARE
logic_off:
 cbi portc, 0
 cbi portc, 2
 cbi portd, 2
ret
