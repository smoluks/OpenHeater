#define CONST_LONG_PRESS 30
#define BUTTON_IDLE 100

process_buttons:
;
lds r16, BUTTONS_ADC
cpi r16, 223
brlo adc0
 ;buttons released
 lds r17, BUTTONS_IDLETIMEOUT
 cpi r17, 1
 brlo prb1
 brne prb2
  ;idle handlers
  ldi DISPLAY_MODE_REG, DISPLAY_MODE_DEFAULT
 prb2:
 dec r17
 sts BUTTONS_IDLETIMEOUT, CONST_BUTTON_IDLE  
 prb1:
 sts PREVBUTTONS, CONST_0
 sts BUTTON_PLUS_PRESS_COUNT, CONST_0
 sts BUTTON_MINUS_PRESS_COUNT, CONST_0
 sts BUTTON_MODE_PRESS_COUNT, CONST_0
 sts BUTTON_MENU_PRESS_COUNT, CONST_0
 ret
;
adc0:
sts BUTTONS_IDLETIMEOUT, CONST_BUTTON_IDLE
cpi r16, 159
brsh menu_btn
cpi r16, 95
brsh mode_btn
cpi r16, 31
brsh minus_btn
rjmp plus_btn

;---------- Menu ----------
menu_btn:
lds r16, PREVBUTTONS
sbrc r16, BUTTON_MENU_FLAG
rjmp adc11
  ;first press
  sbr r16, 1 << BUTTON_MENU_FLAG
  sts PREVBUTTONS, r16
  sbr BUTTONS_REG, 1 << BUTTON_MENU_FLAG
  ret
adc11:
  ;long press detect
  lds r16, BUTTON_MENU_PRESS_COUNT
  cpi r16, CONST_LONG_PRESS
  brsh adc12
   inc r16
   sts BUTTON_MENU_PRESS_COUNT, r16
   ret
  adc12: 
   sbr BUTTONS_REG, 1 << BUTTON_MENU_HOLD_FLAG
   ret

 ;---------- Mode ----------
 mode_btn:
 lds r16, PREVBUTTONS
 sbrc r16, BUTTON_MODE_FLAG
 rjmp adc21
  ;first press
  sbr r16, 1 << BUTTON_MODE_FLAG
  sts PREVBUTTONS, r16
  sbr BUTTONS_REG, 1 << BUTTON_MODE_FLAG
  ret
 adc21:
  ;long press detect
  lds r16, BUTTON_MODE_PRESS_COUNT
  cpi r16, CONST_LONG_PRESS
  brsh adc22
   inc r16
   sts BUTTON_MODE_PRESS_COUNT, r16
   ret
  adc22: 
   sbr BUTTONS_REG, 1 << BUTTON_MODE_HOLD_FLAG
   ret

;---------- + ----------
plus_btn: 
lds r16, PREVBUTTONS
sbrc r16, BUTTON_PLUS_FLAG
rjmp adc31
 ;first press
 sbr r16, 1 << BUTTON_PLUS_FLAG
 sts PREVBUTTONS, r16
 sbr BUTTONS_REG, 1 << BUTTON_PLUS_FLAG
 ret
adc31:
 ;long press detect
 lds r16, BUTTON_PLUS_PRESS_COUNT
 cpi r16, CONST_LONG_PRESS
 brsh adc32
   inc r16
   sts BUTTON_PLUS_PRESS_COUNT, r16
   ret
  adc32: 
   sbr BUTTONS_REG, 1 << BUTTON_PLUS_HOLD_FLAG
   ret

;---------- - ----------
minus_btn:
lds r16, PREVBUTTONS
sbrc r16, BUTTON_MINUS_FLAG
rjmp adc41
 ;first press
 sbr r16, 1 << BUTTON_MINUS_FLAG
 sts PREVBUTTONS, r16
 sbr BUTTONS_REG, 1 << BUTTON_MINUS_FLAG
 ret
adc41:
 ;long press detect
 lds r16, BUTTON_MINUS_PRESS_COUNT
 cpi r16, CONST_LONG_PRESS
 brsh adc42
  inc r16
  sts BUTTON_MINUS_PRESS_COUNT, r16
  ret
 adc42: 
  sbr BUTTONS_REG, 1 << BUTTON_MINUS_HOLD_FLAG
  ret
