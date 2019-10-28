logic:
;
tst ERROR_REG
brne lo0
;
cpi MODE_REG, MODE_OFF
brne lo1
 ;off
 lo0:
 cbi portc, 0
 cbi portc, 2
 cbi portd, 2
 ret 
lo1:
clt
cp TLow_REG, TTARGETLow_REG ; Compare low byte
cpc THigh_REG, TTARGETHigh_REG ; Compare high byte
brlo lo2
 ;same or high
 set
lo2:

ret