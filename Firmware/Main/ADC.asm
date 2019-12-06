#define ADMUX_BUTTONS 0b01100110
#define ADMUX_FEEDBACK1 0b01100111
#define ADMUX_FEEDBACK2 0b01100001
#define ADMUX_FEEDBACK3 0b01100011

#define FEEDBACK_LEVEL 0x80

ADCi:
push r16
in r16, SREG
push r16
;
in r16, ADMUX
cpi r16, ADMUX_BUTTONS
breq adc_buttons
cpi r16, ADMUX_FEEDBACK1
breq adc_feedback1
cpi r16, ADMUX_FEEDBACK2
breq adc_feedback2
cpi r16, ADMUX_FEEDBACK3
breq adc_feedback3
;
out ADMUX, CONST_ADMUX_BUTTONS
sbi ADCSRA, ADSC
pop r16
out SREG, r16
pop r16
reti

;buttons
adc_buttons: 
in r16, ADCH
sts BUTTONS_ADC, r16
out ADMUX, CONST_ADMUX_FEEDBACK1
sbi ADCSRA, ADSC
;
pop r16
out SREG, r16
pop r16
reti

adc_feedback1:
cbr FEEDBACK_REG, 1 << FEEDBACK1
in r16, ADCH
cpi r16, FEEDBACK_LEVEL
brlo adc1
 sbr FEEDBACK_REG, 1 << FEEDBACK1
adc1: 
out ADMUX, CONST_ADMUX_FEEDBACK2
sbi ADCSRA, ADSC
; 
pop r16
out SREG, r16
pop r16
reti

adc_feedback2:
cbr FEEDBACK_REG, 1 << FEEDBACK2
in r16, ADCH
cpi r16, FEEDBACK_LEVEL
brlo adc2
 sbr FEEDBACK_REG, 1 << FEEDBACK2
adc2: 
out ADMUX, CONST_ADMUX_FEEDBACK3
sbi ADCSRA, ADSC
; 
pop r16
out SREG, r16
pop r16
reti

adc_feedback3:
cbr FEEDBACK_REG, 1 << FEEDBACK3
in r16, ADCH
cpi r16, FEEDBACK_LEVEL
brlo adc3
 sbr FEEDBACK_REG, 1 << FEEDBACK3
adc3: 
out ADMUX, CONST_ADMUX_BUTTONS
sbi ADCSRA, ADSC
; 
pop r16
out SREG, r16
pop r16
reti