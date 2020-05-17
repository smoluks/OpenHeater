#define DISPLAY_MODE_COUNT 5

#define DISPLAY_MODE_DEFAULT 0
#define DISPLAY_MODE_SETTEMP 1
#define DISPLAY_MODE_SETMODE 2
#define DISPLAY_MODE_BRIGHTNESS 3
#define DISPLAY_MODE_MENU 4

#define DISPLAY_MENU_COUNT 1

#define DISPLAY_MENU_BRIGHTNESS 0

Display_handlers: 
.DW handler_default
.DW handler_settemp
.DW handler_mode
.DW handler_brightness
.DW handler_menu
 
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

#include "Display_Menu_Brightness.asm"
#include "Display_Default.asm"
#include "Display_Menu.asm"
#include "Display_Mode.asm"
#include "Display_SetTemp.asm"

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
ldi r17, 0b01110001
sts SEG4, r17
ret

showError:
;1
ldi r16, 0b11100011
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
 ldi r17, 0b01111011
 ret
c1:
cpi r17, 1
brne c2
 ldi r17, 0b00011000
 ret
c2:
cpi r17, 2
brne c3
 ldi r17, 0b10110011
 ret
c3:
cpi r17, 3
brne c4
 ldi r17, 0b10111001
 ret
c4:
cpi r17, 4
brne c5
 ldi r17, 0b11011000
 ret
c5:
cpi r17, 5
brne c6
 ldi r17, 0b11101001
 ret
c6:
cpi r17, 6
brne c7
 ldi r17, 0b11101011
 ret
c7:
cpi r17, 7
brne c8
 ldi r17, 0b00111000
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
 ldi r17, 0b01101111
 ret
cc1:
cpi r17, 1
brne cc2
 ldi r17, 0b01001000
 ret
cc2:
cpi r17, 2
brne cc3
 ldi r17, 0b01110110
 ret
cc3:
cpi r17, 3
brne cc4
 ldi r17, 0b01111010
 ret
cc4:
cpi r17, 4
brne cc5
 ldi r17, 0b01011001
 ret
cc5:
cpi r17, 5
brne cc6
 ldi r17, 0b00111011
 ret
cc6:
cpi r17, 6
brne cc7
 ldi r17, 0b00111111
 ret
cc7:
cpi r17, 7
brne cc8
 ldi r17, 0b01101000
 ret
cc8:
cpi r17, 8
brne cc9
 ldi r17, 0b01111111
 ret
cc9:
cpi r17, 9
brne cc10
 ldi r17, 0b01111011
 ret
cc10:
ret