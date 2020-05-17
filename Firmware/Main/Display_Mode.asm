;-----------mode-----------
handler_mode:
;buttons
lds r16, BUTTONS_PRESSED
;--- +/- ---
sbrc r16, BUTTON_MINUS_FLAG
rjmp pdm3
sbrc r16, BUTTON_MINUS_HOLD_FLAG
rjmp pdm3
sbrc r16, BUTTON_PLUS_FLAG
rjmp pdm3
sbrs r16, BUTTON_PLUS_HOLD_FLAG
rjmp pdm4
pdm3:
 ldi DISPLAY_MODE_REG, DISPLAY_MODE_SETTEMP
pdm4:
;--- Mode ---
sbrs r16, BUTTON_MODE_FLAG
rjmp pdm5
 inc MODE_REG
 cpi MODE_REG, MODE_COUNT
 brlo pdm5
  clr MODE_REG
pdm5:
;--- Menu ---
sbrs r16, BUTTON_MENU_FLAG
rjmp pdm6
 ldi DISPLAY_MODE_REG, DISPLAY_MODE_DEFAULT
pdm6:
;
sts BUTTONS_PRESSED, CONST_0
;display
cpi MODE_REG, MODE_OFF
brne ccm1
 ;--MODE_OFF--
 sts SEG1, CONST_0
 ldi r16, 0b01111011
 sts SEG2, r16
 ldi r16, 0b00110101
 sts SEG3, r16
 ldi r16, 0b00110101
 sts SEG4, r16
 ret 
ccm1:
cpi MODE_REG, MODE_1
brne ccm2
 ;--1--
 sts SEG1, CONST_0
 sts SEG2, CONST_0
 sts SEG3, CONST_0
 ldi r16, 0b01001000
 sts SEG4, r16
 ret 
ccm2:
cpi MODE_REG, MODE_2
brne ccm3
 ;--2--
 sts SEG1, CONST_0
 sts SEG2, CONST_0
 sts SEG3, CONST_0
 ldi r16, 0b01110110
 sts SEG4, r16
 ret 
ccm3:
cpi MODE_REG, MODE_3
brne ccm4
 ;--3--
 sts SEG1, CONST_0
 sts SEG2, CONST_0
 sts SEG3, CONST_0
 ldi r16, 0b01111010
 sts SEG4, r16
 ret 
ccm4:
cpi MODE_REG, MODE_FAN
brne ccm5
 ;--FAN--
 sts SEG1, CONST_0
 ldi r16, 0b11100010
 sts SEG2, r16
 ldi r16, 0b01111101
 sts SEG3, r16
 ldi r16, 0b01101101
 sts SEG4, r16
 ret 
ccm5:
sbr ERRORL_REG, 1 << ERRORL_SOFTWARE 
ret