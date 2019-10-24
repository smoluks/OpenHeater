#define CONST_0 r2
#define CONST_10 r3

#define ERROR_REG r24

#define BUTTONS_REG r25
#define BUTTON_PLUS_FLAG 0
#define BUTTON_MINUS_FLAG 1
#define BUTTON_MODE_FLAG 2
#define BUTTON_MENU_FLAG 3
#define BUTTON_PLUS_HOLD_FLAG 4
#define BUTTON_MINUS_HOLD_FLAG 5
#define BUTTON_MODE_HOLD_FLAG 6
#define BUTTON_MENU_HOLD_FLAG 7

#define DISPLAY_MODE_REG r26

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
;Temperature
#define TLow 0x6A
#define THigh 0x6D
;systick
#define Systick 0x6C
;18b20
#define state18b20 0x6D
#define pt18b20 0x6E
