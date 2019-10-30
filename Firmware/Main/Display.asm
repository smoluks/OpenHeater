#define MINUS_1SEG 0b01000000

process_display:
cpi DISPLAY_MODE_REG, DISPLAY_MODE_DEFAULT
breq display_default
cpi DISPLAY_MODE_REG, DISPLAY_MODE_SETTEMP
brne display_settemp
cpi DISPLAY_MODE_REG, DISPLAY_MODE_DEFAULT
brne display_mode
sbr ERROR_REG, 1 << ERROR_SOFTWARE 
ret

 ;-----------default-----------
 display_default:
 ;buttons
 sbrs BUTTONS_REG, BUTTON_PLUS_FLAG
 rjmp pdi3
  ldi DISPLAY_MODE_REG, DISPLAY_MODE_SETTEMP
 pdi3:
 sbrs BUTTONS_REG, BUTTON_MINUS_FLAG
 rjmp pdi4
  ldi DISPLAY_MODE_REG, DISPLAY_MODE_SETTEMP
 pdi4:
 sbrs BUTTONS_REG, BUTTON_MODE_FLAG
 rjmp pdi5
  ldi DISPLAY_MODE_REG, DISPLAY_MODE_SETMODE
 pdi5:
 clr BUTTONS_REG
 ;display
 tst ERROR_REG
 breq pdi2
  rcall showError
  ret
 pdi2:
  rcall showTemperature
  ret

 ;-----------set temp-----------
 display_settemp:
 ;buttons
 sbrs BUTTONS_REG, BUTTON_PLUS_FLAG
 rjmp pdt3
  cpi TTARGET_REG, 75
  brge pdt3
   inc TTARGET_REG
 pdt3:
 sbrs BUTTONS_REG, BUTTON_MINUS_FLAG
 rjmp pdt4
  cpi TTARGET_REG, -39
  brlt pdt4
   dec TTARGET_REG
 pdt4:
 sbrs BUTTONS_REG, BUTTON_MODE_FLAG
 rjmp pdt5
  ldi DISPLAY_MODE_REG, DISPLAY_MODE_SETMODE
 pdt5:
 clr BUTTONS_REG
 ;display
 rcall showSetTemperature
 ret

 ;-----------mode-----------
 display_mode:
 ;buttons
 sbrs BUTTONS_REG, BUTTON_MINUS_FLAG
 rjmp pdm3
  ldi DISPLAY_MODE_REG, DISPLAY_MODE_SETTEMP
 pdm3:
 sbrs BUTTONS_REG, BUTTON_MINUS_FLAG
 rjmp pdm4
  ldi DISPLAY_MODE_REG, DISPLAY_MODE_SETTEMP
 pdm4:
 sbrs BUTTONS_REG, BUTTON_MODE_FLAG
 rjmp pdm5
  inc MODE_REG
  cpi MODE_REG, MODE_COUNT
  brlo pdm5
   clr MODE_REG
 pdm5:
 clr BUTTONS_REG
 ;display
 rcall showMode
 ret

showMode:
cpi MODE_REG, MODE_OFF
brne ccm1
 ;--MODE_OFF--
 sts SEG1, CONST_0
 ldi r16, 0b10111011
 sts SEG2, r16
 ldi r16, 0b01110010
 sts SEG3, r16
 ldi r16, 0b10101010
 sts SEG4, r16
 ret 
ccm1:
cpi MODE_REG, MODE_1
brne ccm2
 ;--1--
 sts SEG1, CONST_0
 sts SEG1, CONST_0
 sts SEG1, CONST_0
 ldi r16, 0b00000101
 sts SEG4, r16
 ret 
ccm2:
cpi MODE_REG, MODE_2
brne ccm3
 ;--2--
 sts SEG1, CONST_0
 sts SEG1, CONST_0
 sts SEG1, CONST_0
 ldi r16, 0b01110110
 sts SEG4, r16
 ret 
ccm3:
cpi MODE_REG, MODE_3
brne ccm4
 ;--3--
 sts SEG1, CONST_0
 sts SEG1, CONST_0
 sts SEG1, CONST_0
 ldi r16, 0b00101111
 sts SEG4, r16
 ret 
ccm4:
cpi MODE_REG, MODE_FAN
brne ccm5
 ;--FAN--
 sts SEG1, CONST_0
 ldi r16, 0b01110010
 sts SEG2, r16
 ldi r16, 0b01011111
 sts SEG3, r16
 ldi r16, 0b00101111
 sts SEG4, r16
 ret 
ccm5:
sbr ERROR_REG, 1 << ERROR_SOFTWARE 
ret

showSetTemperature:
;-1-
sts SEG1, CONST_0
;-2-
mov r16, TTARGET_REG
sts SEG2, CONST_0
sbrs r16, 7
rjmp sst1
 ldi r17, MINUS_1SEG
 sts SEG2, r17
;-3-
sst1:
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

showTemperature:
mov r17, THigh_REG
andi r17, 0b00001111
mov r16, TLow_REG
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
 sts SEG1, r2	
wt11:
;
mov r17, r16
rcall convertnumberto7segment1
ori r17, 0b00000100 ;DP
sts SEG2, r17
;-fractional part - TLow / 16 * 10 -
mov r16, TLow_REG
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
ldi r17, MINUS_1SEG
sts SEG1, r17
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

;IN r16 - errorcode
showError:
ldi r17, 0b01110011
sts SEG1, r17
;
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
;
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
;
mov r17, r16
rcall convertnumberto7segment2
sts SEG4, r17
;
we_exit:
rjmp we_exit

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