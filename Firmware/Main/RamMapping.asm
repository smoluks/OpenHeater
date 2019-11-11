;-----------Regs-----------
#ifdef DEBUG
#define CONST_0 r2
#define CONST_10 r3
#define CONST_MINUS_1SEG r4 
#define CONST_T2_START r5
#endif

;Temperature
#define TLow_REG  r20
#define THigh_REG  r21
#define TTARGET_REG r22
;
#define ERROR_REG r23
#define ERROR_NO18B20 0
#define ERROR_SOFTWARE 1
;
#define BUTTONS_REG r24
#define BUTTON_PLUS_FLAG 0
#define BUTTON_MINUS_FLAG 1
#define BUTTON_MODE_FLAG 2
#define BUTTON_MENU_FLAG 3
#define BUTTON_PLUS_HOLD_FLAG 4
#define BUTTON_MINUS_HOLD_FLAG 5
#define BUTTON_MODE_HOLD_FLAG 6
#define BUTTON_MENU_HOLD_FLAG 7
;
#define MODE_REG r25
#define MODE_COUNT 5
#define MODE_OFF 0
#define MODE_1 1
#define MODE_2 2
#define MODE_3 3
#define MODE_FAN 4
;
#define DISPLAY_MODE_REG r26
#define DISPLAY_MODE_DEFAULT 0
#define DISPLAY_MODE_SETTEMP 1
#define DISPLAY_MODE_SETMODE 2

;-----------RAM-----------
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
#define SYSTICK 0x6A
;18b20
#define D18B20_STATE 0x6B
#define D18B20_TIMESTAMP 0x6C
;modbus
#define RECV_HANDLE_L 0x6D
#define RECV_HANDLE_H 0x6E 
#define TRANS_HANDLE_L 0x6F
#define TRANS_HANDLE_H 0x70
#define TRANS_COUNT 0x71
#define CRCHI 0x72
#define CRCLO 0x73
;uart
#define UART_BUFFER 0x80
