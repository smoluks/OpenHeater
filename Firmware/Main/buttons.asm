#define CONST_LONG_PRESS 30

TIM1_COMPA:
push r16
in r16, SREG
push r16
;
lds r16, SYSTICK
inc r16
sts SYSTICK, r16
;
in r16, ADCH
cpi r16, 223
brlo adc0
 ;buttons released
 sts PREVBUTTONS, CONST_0
 sts BUTTON_PLUS_PRESS_COUNT, CONST_0
 sts BUTTON_MINUS_PRESS_COUNT, CONST_0
 sts BUTTON_MODE_PRESS_COUNT, CONST_0
 sts BUTTON_MENU_PRESS_COUNT, CONST_0
 ;
 pop r16
 out SREG, r16
 pop r16
 reti
;
adc0:
cpi r16, 159
brlo menu_btn
cpi r16, 95
brlo mode_btn
cpi r16, 31
brlo plus_btn
rjmp minus_btn

;---------- Menu ----------
menu_btn:
lds r16, PREVBUTTONS
sbrc r16, BUTTON_MENU_FLAG
breq adc11
  ;first press
  sbr r16, 1 << BUTTON_MENU_FLAG
  sts PREVBUTTONS, r16
  sbr BUTTONS_REG, 1 << BUTTON_MENU_FLAG
  rjmp adc_exit
adc11:
  ;long press detect
  lds r16, BUTTON_MENU_PRESS_COUNT
  cpi r16, CONST_LONG_PRESS
  brsh adc12
   inc r16
   sts BUTTON_MENU_PRESS_COUNT, r16
   rjmp adc_exit
  adc12: 
   sbr BUTTONS_REG, 1 << BUTTON_MENU_HOLD_FLAG
   rjmp adc_exit


 ;---------- Mode ----------
 mode_btn:
 sbrc r17, BUTTON_MODE_FLAG
 breq adc21
  ;first press
  sbr r17, 1 << BUTTON_MODE_FLAG
  sts PREVBUTTONS, r17
  sbr BUTTONS_REG, 1 << BUTTON_MODE_FLAG
  rjmp adc_exit
 adc21:
  ;long press detect
  lds r16, BUTTON_MODE_PRESS_COUNT
  cpi r16, CONST_LONG_PRESS
  brsh adc22
   inc r16
   sts BUTTON_MODE_PRESS_COUNT, r16
   rjmp adc_exit
  adc22: 
   sbr BUTTONS_REG, 1 << BUTTON_MODE_HOLD_FLAG
   rjmp adc_exit
adc2:

 ;---------- + ----------
plus_btn: 
 sbrc r17, BUTTON_PLUS_FLAG
 breq adc31
  ;first press
  sbr r17, 1 << BUTTON_PLUS_FLAG
  sts PREVBUTTONS, r17
  sbr BUTTONS_REG, 1 << BUTTON_PLUS_FLAG
  rjmp adc_exit
 adc31:
  ;long press detect
  lds r16, BUTTON_PLUS_PRESS_COUNT
  cpi r16, CONST_LONG_PRESS
  brsh adc32
   inc r16
   sts BUTTON_PLUS_PRESS_COUNT, r16
   rjmp adc_exit
  adc32: 
   sbr BUTTONS_REG, 1 << BUTTON_PLUS_HOLD_FLAG
   rjmp adc_exit
adc3:

 ;---------- - ----------
 minus_btn:
 sbrc r17, BUTTON_MINUS_FLAG
 breq adc41
  ;first press
  sbr r17, 1 << BUTTON_MINUS_FLAG
  sts PREVBUTTONS, r17
  sbr BUTTONS_REG, 1 << BUTTON_MINUS_FLAG
  rjmp adc_exit
 adc41:
  ;long press detect
  lds r16, BUTTON_MINUS_PRESS_COUNT
  cpi r16, CONST_LONG_PRESS
  brsh adc42
   inc r16
   sts BUTTON_MINUS_PRESS_COUNT, r16
   rjmp adc_exit
  adc42: 
   sbr BUTTONS_REG, 1 << BUTTON_MINUS_HOLD_FLAG
   ;rjmp adc_exit
;   

adc_exit:
pop r16
out SREG, r16
pop r16
reti