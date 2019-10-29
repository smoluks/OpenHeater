logic:
;
tst ERROR_REG
breq logic_off
cpi MODE_REG, MODE_OFF
breq logic_off
;
movw r16, TLow_REG
andi r16, 0b11110000
andi r17, 0b00001111
or r16, r17
swap r16
cp r16, TTARGET_REG
brsh logic_off
;
cpi MODE_REG, MODE_1
breq lo1
 ;1
 sbi portc, 0
 cbi portc, 2
 cbi portd, 2
 ret
lo1: 
cpi MODE_REG, MODE_2
breq lo2
 ;2
 cbi portc, 0
 sbi portc, 2
 cbi portd, 2
 ret
lo2:
cpi MODE_REG, MODE_3
breq lo3
 ;3
 sbi portc, 0
 sbi portc, 2
 cbi portd, 2
 ret
lo3:
cpi MODE_REG, MODE_FAN
breq lo4
 ;FAN
 cbi portc, 0
 cbi portc, 2
 sbi portd, 2
 ret
lo4: 
sbr ERROR_REG, 1 << ERROR_SOFTWARE
logic_off:
 cbi portc, 0
 cbi portc, 2
 cbi portd, 2
ret