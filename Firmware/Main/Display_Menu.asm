handler_menu:
;---buttons---
lds r16, BUTTONS_PRESSED
;--- +/- ---
sbrc r16, BUTTON_MINUS_FLAG
rjmp dm1
sbrc r16, BUTTON_MINUS_HOLD_FLAG
rjmp dm1
sbrc r16, BUTTON_PLUS_FLAG
rjmp dm1
sbrs r16, BUTTON_PLUS_HOLD_FLAG
rjmp dm2
dm1:
 ;ldi DISPLAY_MODE_REG, DISPLAY_MODE_SETTEMP
dm2:
;mode
sbrs r16, BUTTON_MODE_FLAG
rjmp dm3
 ldi DISPLAY_MODE_REG, DISPLAY_MODE_BRIGHTNESS
dm3:
;menu
sbrs r16, BUTTON_MENU_FLAG
rjmp dm4
 ldi DISPLAY_MODE_REG, DISPLAY_MODE_DEFAULT
dm4:
;
sts BUTTONS_PRESSED, CONST_0
;---display---
cpi DISPLAY_MENU_REG, DISPLAY_MENU_BRIGHTNESS
brne dm5
 ;bri
 ldi r16, 0b11001011
 sts SEG1, r16
 ldi r16, 0b10000010
 sts SEG2, r16
 ldi r16, 0b00000100
 sts SEG3, r16
 ldi r16, 0b00000000
 sts SEG4, r16
 ret
dm5:
 ;exit
 ldi r16, 0b11100011
 sts SEG1, r16
 ldi r16, 0b11100010
 sts SEG2, r16
 ldi r16, 0b00000100
 sts SEG3, r16
 ldi r16, 0b00010111
 sts SEG4, r16
ret  