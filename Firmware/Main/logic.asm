#define CH1_ON sbi porta, 4
#define CH1_OFF cbi porta, 4
#define CH2_ON sbi porta, 2
#define CH2_OFF cbi porta, 2
#define CHFAN_ON sbi porta, 0
#define CHFAN_OFF cbi porta, 0

#define LED_ON sbi portb, 3
#define LED_OFF cbi portb, 3

logic:
LED_OFF
;--checks--
tst ERRORL_REG
brne logic_off
tst ERRORH_REG
brne logic_off
cpi MODE_REG, MODE_OFF
breq logic_off
;
LED_ON
;temperature high
movw r16, THighL_REG
andi r16, 0b11110000
andi r17, 0b00001111
or r16, r17
swap r16
cpi r16, 60
brge logic_off
;temperature low
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
 CH1_ON
 CH2_OFF
 CHFAN_OFF
 ret
lo1: 
cpi MODE_REG, MODE_2
brne lo2
 ;2
 CH1_OFF
 CH2_ON
 CHFAN_OFF
 ret
lo2:
cpi MODE_REG, MODE_3
brne lo3
 ;3
 CH1_ON
 CH2_ON
 CHFAN_OFF
 ret
lo3:
cpi MODE_REG, MODE_FAN
brne lo4
 ;FAN
 CH1_OFF
 CH2_OFF
 CHFAN_ON
 ret
lo4: 
sbr ERRORL_REG, 1 << ERRORL_SOFTWARE
logic_off:
 CH1_OFF
 CH2_OFF
 CHFAN_OFF
ret
