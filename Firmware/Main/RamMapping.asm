#define CONST_0 r2
#define CONST_10 r3

;Temperature
#define TLow_REG  r20
#define THigh_REG  r21
#define TTARGET_REG r22

#define ERROR_REG r24
#define ERROR_NO18B20 0
#define ERROR_SOFTWARE 1

#define BUTTONS_REG r25
#define BUTTON_PLUS_FLAG 0
#define BUTTON_MINUS_FLAG 1
#define BUTTON_MODE_FLAG 2
#define BUTTON_MENU_FLAG 3
#define BUTTON_PLUS_HOLD_FLAG 4
#define BUTTON_MINUS_HOLD_FLAG 5
#define BUTTON_MODE_HOLD_FLAG 6
#define BUTTON_MENU_HOLD_FLAG 7

#define MODE_REG r26
#define MODE_COUNT 5
#define MODE_OFF 0
#define MODE_1 1
#define MODE_2 2
#define MODE_3 3
#define MODE_FAN 4

#define DISPLAY_MODE_REG r27
#define DISPLAY_MODE_DEFAULT 0
#define DISPLAY_MODE_SETTEMP 1
#define DISPLAY_MODE_SETMODE 2

;Display
#define SEG1 0x60
#define SEG2 0x61 
#define SEG3 0x62
#define SEG4 0x63
#define SEGNUMBER 0x64
;Buttons
#define PREVBUTTONS 0x65
#define BUTTON_PLUS_PRESS_COUNT 0x66
#define BUTTON_MINUS_PRESS_COUNT 0x67
#define BUTTON_MODE_PRESS_COUNT 0x68
#define BUTTON_MENU_PRESS_COUNT 0x69
;systick
#define Systick 0x6C
;18b20
#define state18b20 0x6D
#define pt18b20 0x6E
