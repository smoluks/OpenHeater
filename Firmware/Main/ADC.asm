#define ADMUX_BUTTONS 0b01100110
#define ADMUX_FEEDBACK1 0b01100111

ADCi:
push r16
in r16, SREG
push r16
;
in r16, ADMUX
cpi r16, ADMUX_BUTTONS
brne adc1
 ;buttons
 in r16, ADCH
 sts BUTTONS_ADC, r16
 out ADMUX, CONST_ADMUX_FEEDBACK1
 sbi ADCSRA, ADSC
 rjmp adc_exit
adc1:
 in r16, ADCH
 sts FEEDBACK1_ADC, r16
 out ADMUX, CONST_ADMUX_BUTTONS
 sbi ADCSRA, ADSC
 ;rjmp adc_exit
 ; 
adc_exit:
pop r16
out SREG, r16
pop r16
reti