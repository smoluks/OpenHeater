#define DISPLAY_MODE_COUNT 5

#define DISPLAY_MODE_DEFAULT 0
#define DISPLAY_MODE_SETTEMP 1
#define DISPLAY_MODE_SETMODE 2
#define DISPLAY_MODE_BRIGHTNESS 3
#define DISPLAY_MODE_MENU 4

#define DISPLAY_MENU_COUNT 2

#define DISPLAY_MENU_BRIGHTNESS 0
#define DISPLAY_MENU_EXIT 1

Display_handlers: 
.DW display_default
.DW display_settemp
.DW display_mode
.DW display_brightness
.DW display_menu
 
process_display:
cpi DISPLAY_MODE_REG, DISPLAY_MODE_COUNT
brsh label_error
;
ldi r30, low(Display_handlers * 2)
ldi r31, high(Display_handlers * 2)
mov r16, DISPLAY_MODE_REG
lsl r16
add r30, r16
adc r31, CONST_0
lpm r16, z+
lpm r17, z+
movw r30, r16
ijmp
;
label_error:
sbr ERRORL_REG, 1 << ERRORL_SOFTWARE 
ret

;-----------default-----------
display_default:
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

;-----------menu---------------
display_menu:
;---buttons---
lds r16, BUTTONS_PRESSED
;+
sbrc r16, BUTTON_PLUS_FLAG
rjmp dm_plus
sbrs r16, BUTTON_PLUS_HOLD_FLAG
rjmp dm1
 dm_plus:
 inc DISPLAY_MENU_REG
 cpi DISPLAY_MENU_REG, DISPLAY_MENU_COUNT
 brlo dm1
  clr DISPLAY_MENU_REG
dm1:
;-
sbrc r16, BUTTON_MINUS_FLAG
rjmp dm_minus
sbrs r16, BUTTON_MINUS_HOLD_FLAG
rjmp dm2
 dm_minus:
 dec DISPLAY_MENU_REG
 cpi DISPLAY_MENU_REG, -1
 brne dm2
  ldi DISPLAY_MENU_REG, DISPLAY_MENU_COUNT-1
dm2:
;mode
sbrs r16, BUTTON_MODE_FLAG
rjmp dm3
 cpi DISPLAY_MENU_REG, DISPLAY_MENU_BRIGHTNESS
 brne dm2_1
  ;go to brightness
  ldi DISPLAY_MODE_REG, DISPLAY_MODE_BRIGHTNESS
  rjmp dm3
 dm2_1:
  ldi DISPLAY_MODE_REG, DISPLAY_MODE_DEFAULT
  ;rjmp dm3
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
 ldi r16, 0b01101011
 sts SEG1, r16
 ldi r16, 0b01000010
 sts SEG2, r16
 ldi r16, 0b00000100
 sts SEG3, r16
 ldi r16, 0b00000000
 sts SEG4, r16
 ret
dm5:
 ;exit
 ldi r16, 0b01110011
 sts SEG1, r16
 ldi r16, 0b01110010
 sts SEG2, r16
 ldi r16, 0b00000100
 sts SEG3, r16
 ldi r16, 0b10000111
 sts SEG4, r16
ret  

;-----------set brightness-----------
display_brightness:
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
  rcall save_brightness
pdb3:
sbrc r17, BUTTON_MINUS_FLAG
rjmp pdb2
sbrs r17, BUTTON_MINUS_HOLD_FLAG
rjmp pdb4
 pdb2:
 dec r16
 out OCR2, r16
 rcall save_brightness
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

;-----------set temp-----------
display_settemp:
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
  rcall save_target_temp
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
  rcall save_target_temp
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
;display
rjmp showSetTemperature

;-----------mode-----------
display_mode:
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
;----- display -----
showMode:
cpi MODE_REG, MODE_OFF
brne ccm1
 ;--MODE_OFF--
 sts SEG1, CONST_0
 ldi r16, 0b10111011
 sts SEG2, r16
 ldi r16, 0b10010101
 sts SEG3, r16
 ldi r16, 0b10010101
 sts SEG4, r16
 ret 
ccm1:
cpi MODE_REG, MODE_1
brne ccm2
 ;--1--
 sts SEG1, CONST_0
 sts SEG2, CONST_0
 sts SEG3, CONST_0
 ldi r16, 0b00101000
 sts SEG4, r16
 ret 
ccm2:
cpi MODE_REG, MODE_2
brne ccm3
 ;--2--
 sts SEG1, CONST_0
 sts SEG2, CONST_0
 sts SEG3, CONST_0
 ldi r16, 0b10110110
 sts SEG4, r16
 ret 
ccm3:
cpi MODE_REG, MODE_3
brne ccm4
 ;--3--
 sts SEG1, CONST_0
 sts SEG2, CONST_0
 sts SEG3, CONST_0
 ldi r16, 0b10111010
 sts SEG4, r16
 ret 
ccm4:
cpi MODE_REG, MODE_FAN
brne ccm5
 ;--FAN--
 sts SEG1, CONST_0
 ldi r16, 0b01110010
 sts SEG2, r16
 ldi r16, 0b10111101
 sts SEG3, r16
 ldi r16, 0b00111101
 sts SEG4, r16
 ret 
ccm5:
sbr ERRORL_REG, 1 << ERRORL_SOFTWARE 
ret

showSetTemperature:
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

;in - r16
showNumber:
;-1-
sts SEG1, CONST_0
;-2-
clr r17
ssn0:
cpi r16, 100
brlo ssn1
 inc r17
 subi r16, 100
 rjmp ssn0
ssn1:
tst r17
breq ssn1p
 set
 rcall convertnumberto7segment1
 sts SEG2, r17
 rjmp ssn1n
ssn1p:
 clt
 sts SEG2, CONST_0
ssn1n:
;-3-
clr r17
ssn2:
cpi r16, 10
brlo ssn3
 inc r17
 subi r16, 10
 rjmp ssn2
ssn3:
brts ssn3t
tst r17
breq ssn3p
ssn3t:
 rcall convertnumberto7segment2
 sts SEG3, r17
 rjmp ssn3n
ssn3p: 
 sts SEG3, CONST_0
ssn3n:
;-4-
mov r17, r16
rcall convertnumberto7segment2
sts SEG4, r17
ret

showTemperature:
movw r16, TLowL_REG
andi r17, 0b00001111
andi r16, 0b11110000
or r16, r17
swap r16
;
sbrc r16, 7
rjmp wt_minus
;+
cpi r16, 100
brsh wt_over100
;-----normal-----
clr r17
wt2:
cpi r16, 10
brlo wt3
 inc r17
 subi r16, 10
 rjmp wt2
wt3:
tst r17
breq wt10
 rcall convertnumberto7segment1
 sts SEG1, r17
 rjmp wt11
wt10:
 sts SEG1, CONST_0	
wt11:
;
mov r17, r16
rcall convertnumberto7segment1
ori r17, 0b00000100 ;DP
sts SEG2, r17
;-fractional part - TLow / 16 * 10 -
mov r16, TLowL_REG
andi r16, 0b00001111
;*10
mul r16, CONST_10
mov r17, r0
;/16
swap r17
andi r17, 0b00001111
;
rcall convertnumberto7segment2
sts SEG3, r17
rjmp wt_exit
;----->100-----
wt_over100:
clr r17
wt4:
cpi r16, 100
brlo wt5
 inc r17
 subi r16, 100
 rjmp wt4
wt5:
rcall convertnumberto7segment1
sts SEG1, r17
;
clr r17
wt6:
cpi r16, 10
brlo wt7
 inc r17
 subi r16, 10
 rjmp wt6
wt7:
rcall convertnumberto7segment1
sts SEG2, r17
;
mov r17, r16
rcall convertnumberto7segment2
sts SEG3, r17
rjmp wt_exit
;-----<0-----
wt_minus:
;1
sts SEG1, CONST_MINUS_1SEG
;2
clr r17
sub r17, r16
mov r16, r17
;
clr r17
wt8:
cpi r16, 10
brlo wt9
 inc r17
 subi r16, 10
 rjmp wt8
wt9:
rcall convertnumberto7segment1
sts SEG2, r17
;
mov r17, r16
rcall convertnumberto7segment2
sts SEG3, r17
;
wt_exit:
ldi r17, 0b10110001
sts SEG4, r17
ret

showError:
;1
ldi r16, 0b01110011
sts SEG1, r16
;
clr r16
mov r17, ERRORL_REG
we5:
sbrc r17, 0
rjmp we4
 inc r16
 lsr r17
 cpi r16, 8
 brne we5
mov r17, ERRORH_REG
we6:
sbrc r17, 0
rjmp we4
 inc r16
 lsr r17
 cpi r16, 16
 brne we6
clr r16
;2
we4:
clr r17
we0:
cpi r16, 100
brlo we1
 inc r17
 subi r16, 100
 rjmp we0
we1:
rcall convertnumberto7segment1
sts SEG2, r17
;3
clr r17
we2:
cpi r16, 10
brlo we3
 inc r17
 subi r16, 10
 rjmp we2
we3:
rcall convertnumberto7segment2
sts SEG3, r17
;4
mov r17, r16
rcall convertnumberto7segment2
sts SEG4, r17
;
ret

convertnumberto7segment1:
cpi r17, 0
brne c1
 ldi r17, 0b10111011
 ret
c1:
cpi r17, 1
brne c2
 ldi r17, 0b10001000
 ret
c2:
cpi r17, 2
brne c3
 ldi r17, 0b11010011
 ret
c3:
cpi r17, 3
brne c4
 ldi r17, 0b11011001
 ret
c4:
cpi r17, 4
brne c5
 ldi r17, 0b11101000
 ret
c5:
cpi r17, 5
brne c6
 ldi r17, 0b01111001
 ret
c6:
cpi r17, 6
brne c7
 ldi r17, 0b01111011
 ret
c7:
cpi r17, 7
brne c8
 ldi r17, 0b10011000
 ret
c8:
cpi r17, 8
brne c9
 ldi r17, 0b11111011
 ret
c9:
cpi r17, 9
brne c10
 ldi r17, 0b11111001
 ret
c10:
ret

convertnumberto7segment2:
cpi r17, 0
brne cc1
 ldi r17, 0b00111111
 ret
cc1:
cpi r17, 1
brne cc2
 ldi r17, 0b00101000
 ret
cc2:
cpi r17, 2
brne cc3
 ldi r17, 0b10110110
 ret
cc3:
cpi r17, 3
brne cc4
 ldi r17, 0b10111010
 ret
cc4:
cpi r17, 4
brne cc5
 ldi r17, 0b10101001
 ret
cc5:
cpi r17, 5
brne cc6
 ldi r17, 0b10011011
 ret
cc6:
cpi r17, 6
brne cc7
 ldi r17, 0b10011111
 ret
cc7:
cpi r17, 7
brne cc8
 ldi r17, 0b00111000
 ret
cc8:
cpi r17, 8
brne cc9
 ldi r17, 0b10111111
 ret
cc9:
cpi r17, 9
brne cc10
 ldi r17, 0b10111011
 ret
cc10:
ret