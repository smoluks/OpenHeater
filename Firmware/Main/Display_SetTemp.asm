handler_settemp:
;buttons
lds r17, BUTTONS_PRESSED
;---+---
sbrc r17, BUTTON_PLUS_FLAG
rjmp pdt1
sbrs r17, BUTTON_PLUS_HOLD_FLAG
rjmp pdt3
 pdt1:
 cpi TTARGET_REG, MAX_TARGET_TEMP
 brge pdt3
  inc TTARGET_REG
  mov r16, TTARGET_REG
  call save_target_temp
pdt3:
sbrc r17, BUTTON_MINUS_FLAG
rjmp pdt2
sbrs r17, BUTTON_MINUS_HOLD_FLAG
rjmp pdt4
 pdt2:
 cpi TTARGET_REG, MIN_TARGET_TEMP
 brlt pdt4
  dec TTARGET_REG
  mov r16, TTARGET_REG
  call save_target_temp
pdt4:
sbrs r17, BUTTON_MODE_FLAG
rjmp pdt5
 ldi DISPLAY_MODE_REG, DISPLAY_MODE_SETMODE
pdt5:
sbrs r17, BUTTON_MENU_FLAG
rjmp pdt6
 ldi DISPLAY_MODE_REG, DISPLAY_MODE_DEFAULT
pdt6:
sts BUTTONS_PRESSED, CONST_0
;-----display-----
;-1-
sts SEG1, CONST_0
;-2-
sbrs TTARGET_REG, 7
rjmp sst1
 ;<0
 sts SEG2, CONST_MINUS_1SEG
 clr r16
 sub r16, TTARGET_REG 
 rjmp sst0
sst1:
 ;>=0
 sts SEG2, CONST_0
 mov r16, TTARGET_REG
sst0:
;-3-
clr r17
sst2:
cpi r16, 10
brlo sst3
 inc r17
 subi r16, 10
 rjmp sst2
sst3:
rcall convertnumberto7segment2
sts SEG3, r17
;-4-
mov r17, r16
rcall convertnumberto7segment2
sts SEG4, r17
ret
