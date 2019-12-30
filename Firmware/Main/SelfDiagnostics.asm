check_ram:
in r16, MCUCSR
sbrs r16, WDRF
rjmp init0
 sbr ERRORH_REG, 1 << ERRORH_WATCHDOG
init0:
;
ldi r30, 0x60
clr r31
cr1:
st z, CONST_FF
ld r16, z
cpi r16, 0xFF
brne check_ram_error
st z, CONST_0
ld r16, z
cpi r16, 0x00
brne check_ram_error
adiw r30, 1
;
cpi r31, 0x04
brne cr1
cpi r30, 0x5E
brne cr1
;
ret
check_ram_error:
 sbr ERRORH_REG, 1 << ERRORH_RAM
ret

check_heaters:
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
cpi FEEDBACK_REG, 0b00000111
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
cpi FEEDBACK_REG, 0b00000000
brne s2
;-----check triaks off-----
cbi portc, 0
cbi portc, 2
cbi portd, 2
lds r16, SYSTICK
inc r16
inc r16
inc r16
inc r16
inc r16
s3:
lds r17, SYSTICK
cp r17, r16
breq s1_timeout
;
cpi FEEDBACK_REG, 0b00000111
brne s3
ret

s1_timeout:
;1
sbrs FEEDBACK_REG, 1
 sbr ERRORH_REG, 1 << ERRORH_CHANNEL1_BREAK
;2
sbrs FEEDBACK_REG, 2
 sbr ERRORH_REG, 1 << ERRORH_CHANNEL2_BREAK
;3
sbrs FEEDBACK_REG, 3
 sbr ERRORH_REG, 1 << ERRORH_CHANNEL3_BREAK
ret

s2_timeout:
;1
sbrc FEEDBACK_REG, 1
 sbr ERRORH_REG, 1 << ERRORH_CHANNEL1_ENABLEFAIL
;2
sbrc FEEDBACK_REG, 2
 sbr ERRORH_REG, 1 << ERRORH_CHANNEL2_ENABLEFAIL
;3
sbrc FEEDBACK_REG, 3
 sbr ERRORH_REG, 1 << ERRORH_CHANNEL3_ENABLEFAIL
;
cbi portc, 0
cbi portc, 2
cbi portd, 2
ret