selfdignostics:
lds r16, SYSTICK
inc r16
inc r16
s1:
lds r17, SYSTICK
cp r17, r16
breq s1_timeout
 ;1
 lds r17, FEEDBACK1_ADC
 cpi r17, 0x80
 brlo s1
 ;2
 sbis pinc, 1
 rjmp s1
 ;3
 sbis pinc, 3
 rjmp s1
;
lds r16, SYSTICK
inc r16
inc r16
sbi portc, 0
sbi portc, 2
sbi portd, 2
s2: 
lds r17, SYSTICK
cp r17, r16
breq s2_timeout
 ;1
 lds r17, FEEDBACK1_ADC
 cpi r17, 0x80
 brsh s2
 ;2
 sbic pinc, 1
 rjmp s2
 ;3
 sbic pinc, 3
 rjmp s2
;
lds r16, SYSTICK
inc r16
inc r16
cbi portc, 0
cbi portc, 2
cbi portd, 2
s3:
lds r17, SYSTICK
cp r17, r16
breq s1_timeout
 ;1
 lds r17, FEEDBACK1_ADC
 cpi r17, 0x80
 brlo s3
 ;2
 sbis pinc, 1
 rjmp s3
 ;3
 sbis pinc, 3
 rjmp s3
ret

s1_timeout:
;1
lds r17, FEEDBACK1_ADC
cpi r17, 0x80
brsh s4
 sbr ERRORH_REG, ERRORH_CHANNEL1_BREAK
s4:
;2
sbis pinc, 1
sbr ERRORH_REG, ERRORH_CHANNEL2_BREAK
;3
sbis pinc, 3
sbr ERRORH_REG, ERRORH_CHANNEL3_BREAK
ret

s2_timeout:
;1
lds r17, FEEDBACK1_ADC
cpi r17, 0x80
brlo s5
 sbr ERRORH_REG, ERRORH_CHANNEL1_ENABLEFAIL
s5:
;2
sbic pinc, 1
sbr ERRORH_REG, ERRORH_CHANNEL2_ENABLEFAIL
;3
sbic pinc, 3
sbr ERRORH_REG, ERRORH_CHANNEL3_ENABLEFAIL
ret