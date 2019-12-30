selfdignostics:
;-----check heaters-----
lds r16, SYSTICK
inc r16
inc r16
inc r16
s1:
;timeout
lds r17, SYSTICK
cp r17, r16
breq s1_timeout
;
lds r17, FEEDBACKS
cpi r17, 0b00000111
brne s1
;-----check triaks-----
sbi portc, 0
sbi portc, 2
sbi portd, 2
lds r16, SYSTICK
inc r16
inc r16
inc r16
s2: 
lds r17, SYSTICK
cp r17, r16
breq s2_timeout
;
lds r17, FEEDBACKS
cpi r17, 0b00000000
brne s2
;-----check triaks off-----
cbi portc, 0
cbi portc, 2
cbi portd, 2
lds r16, SYSTICK
inc r16
inc r16
inc r16
s3:
lds r17, SYSTICK
cp r17, r16
breq s1_timeout
;
lds r17, FEEDBACKS
cpi r17, 0b00000111
brne s3
ret

s1_timeout:
lds r17, FEEDBACKS
;1
sbrs r17, 1
 sbr ERRORH_REG, 1 << ERRORH_CHANNEL1_BREAK
;2
sbrs r17, 2
 sbr ERRORH_REG, 1 << ERRORH_CHANNEL2_BREAK
;3
sbrs r17, 3
 sbr ERRORH_REG, 1 << ERRORH_CHANNEL3_BREAK
ret

s2_timeout:
lds r17, FEEDBACKS
;1
sbrc r17, 1
 sbr ERRORH_REG, 1 << ERRORH_CHANNEL1_ENABLEFAIL
;2
sbrc r17, 2
 sbr ERRORH_REG, 1 << ERRORH_CHANNEL2_ENABLEFAIL
;3
sbrc r17, 3
 sbr ERRORH_REG, 1 << ERRORH_CHANNEL3_ENABLEFAIL
;
cbi portc, 0
cbi portc, 2
cbi portd, 2
ret