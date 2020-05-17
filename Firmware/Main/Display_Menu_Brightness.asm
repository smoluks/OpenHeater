handler_brightness:
lds r17, BUTTONS_PRESSED
in r16, OCR2
;buttons
sbrc r17, BUTTON_PLUS_FLAG
rjmp pdb1
sbrs r17, BUTTON_PLUS_HOLD_FLAG
rjmp pdb3
 pdb1: 
 cpi r16, 255
 breq pdb3
  inc r16
  out OCR2, r16
  call save_brightness
pdb3:
sbrc r17, BUTTON_MINUS_FLAG
rjmp pdb2
sbrs r17, BUTTON_MINUS_HOLD_FLAG
rjmp pdb4
 pdb2:
 dec r16
 out OCR2, r16
 call save_brightness
pdb4:
sbrs r17, BUTTON_MODE_FLAG
rjmp pdb5
 ldi DISPLAY_MODE_REG, DISPLAY_MODE_MENU
pdb5:
sbrs r17, BUTTON_MENU_FLAG
rjmp pdb6
 ldi DISPLAY_MODE_REG, DISPLAY_MODE_DEFAULT
pdb6:
sts BUTTONS_PRESSED, CONST_0
;display
rjmp showNumber
