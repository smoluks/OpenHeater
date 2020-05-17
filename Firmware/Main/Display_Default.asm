handler_default:
;---buttons---
lds r16, BUTTONS_PRESSED
;+ -
sbrc r16, BUTTON_PLUS_FLAG
rjmp pdi3
sbrs r16, BUTTON_MINUS_FLAG
rjmp pdi4
pdi3:
 ldi DISPLAY_MODE_REG, DISPLAY_MODE_SETTEMP
pdi4:
;mode
sbrs r16, BUTTON_MODE_FLAG
rjmp pdi5
 ldi DISPLAY_MODE_REG, DISPLAY_MODE_SETMODE
pdi5:
;menu
sbrs r16, BUTTON_MENU_FLAG
rjmp pdi6
 ldi DISPLAY_MODE_REG, DISPLAY_MODE_MENU
pdi6:
;
sts BUTTONS_PRESSED, CONST_0
;---display---
tst ERRORL_REG
brne pdi2
tst ERRORH_REG 
brne pdi2
rjmp showTemperature
pdi2:
 rjmp showError