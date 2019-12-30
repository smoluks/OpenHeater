#define D18B20_MAX_COUNT 10
#define MIN_TARGET_TEMP -39
#define MAX_TARGET_TEMP 75

;-----------Regs-----------
#define CONST_0 r2
#define CONST_FF r3

#define TCNT0_START 131
#define CONST_TCNT0_START r4
#define TCCR0_START 0b00000100
#define CONST_TCCR0_START r5

#define CONST_ADMUX_BUTTONS r6 
#define CONST_ADMUX_FEEDBACK1 r7

#define CONST_ADMUX_FEEDBACK2 r8
#define CONST_ADMUX_FEEDBACK3 r9

#define MINUS_1SEG 0b01000000
#define CONST_MINUS_1SEG r10
#define CONST_BUTTON_IDLE r11

#define CONST_5 r12
#define CONST_10 r13

;Temperature
#define TLowL_REG  r18
#define TLowH_REG  r19
#define THighL_REG  r20
#define THighH_REG  r21
#define TTARGET_REG r22
;
#define ERRORL_REG r23
#define ERRORL_NO18B20 0
#define ERRORL_SOFTWARE 1
#define ERRORL_I2C 2
#define ERRORL_FAKE_18B20 3

#define ERRORH_REG r24
#define ERRORH_CHANNEL1_BREAK 0
#define ERRORH_CHANNEL1_ENABLEFAIL 1
#define ERRORH_CHANNEL2_BREAK 2
#define ERRORH_CHANNEL2_ENABLEFAIL 3
#define ERRORH_CHANNEL3_BREAK 4
#define ERRORH_CHANNEL3_ENABLEFAIL 5
#define ERRORH_RAM 6
#define ERRORH_WATCHDOG 7
;
#define BUTTONS_REG r25
#define BUTTON_PLUS_FLAG 0
#define BUTTON_MINUS_FLAG 1
#define BUTTON_MODE_FLAG 2
#define BUTTON_MENU_FLAG 3
#define BUTTON_PLUS_HOLD_FLAG 4
#define BUTTON_MINUS_HOLD_FLAG 5
#define BUTTON_MODE_HOLD_FLAG 6
#define BUTTON_MENU_HOLD_FLAG 7
;
#define MODE_REG r26
#define MODE_COUNT 5
#define MODE_OFF 0
#define MODE_1 1
#define MODE_2 2
#define MODE_3 3
#define MODE_FAN 4
;
#define DISPLAY_MODE_REG r27
#define DISPLAY_MENU_REG r28

#define FEEDBACK_REG r29
#define FEEDBACK1 0
#define FEEDBACK2 1
#define FEEDBACK3 2

;-----------RAM-----------
#define ACTION 0x60
#define ACTION_MODBUS 0
;Display
#define SEG1 0x61
#define SEG2 0x62 
#define SEG3 0x63
#define SEG4 0x64
#define SEGNUMBER 0x65
;Buttons
#define BUTTONS_ADC 0x66
#define PREVBUTTONS 0x67
#define BUTTON_PLUS_PRESS_COUNT 0x68
#define BUTTON_MINUS_PRESS_COUNT 0x69
#define BUTTON_MODE_PRESS_COUNT 0x6A
#define BUTTON_MENU_PRESS_COUNT 0x6B
#define BUTTONS_IDLETIMEOUT 0x6C
;systick
#define SYSTICK 0x6D
;modbus
#define MODBUS_ADDRESS 0x6E
#define RECV_HANDLE_L 0x6F
#define RECV_HANDLE_H 0x70
#define TRANS_HANDLE_L 0x71
#define TRANS_HANDLE_H 0x72
#define TRANS_COUNT 0x73
#define CRCHI 0x74
#define CRCLO 0x75
;i2c
#define TEMP1 0x76
;18b20
#define D18B20_STATE 0x77
#define D18B20_TIMESTAMP 0x78
#define D18B20_COUNT 0x79
#define D18B20_TEMPERATURES 0x7A
#define D18B20_ADDRESSES D18B20_TEMPERATURES + 20
;events
#define EVENTS_CACHE D18B20_ADDRESSES + 80
;uart
#define UART_BUFFER EVENTS_CACHE + 64

#define ram_size UART_BUFFER+100
#message "Ram used:" ram_size
