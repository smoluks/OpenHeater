#include "RamMapping.asm"

.ORG 0x00 rjmp RESET ; Reset Handler
;.ORG 0x01 rjmp EXT_INT0 ; IRQ0 Handler
;.ORG 0x02 rjmp EXT_INT1 ; IRQ1 Handler
.ORG 0x03 rjmp TIM2_COMP ; Timer2 Compare Handler
.ORG 0x04 rjmp TIM2_OVF ; Timer2 Overflow Handler
;.ORG 0x05 rjmp TIM1_CAPT ; Timer1 Capture Handler
.ORG 0x06 rjmp TIM1_COMPA ; Timer1 CompareA Handler
;.ORG 0x07 rjmp TIM1_COMPB ; Timer1 CompareB Handler
;.ORG 0x08 rjmp TIM1_OVF ; Timer1 Overflow Handler
.ORG 0x09 rjmp TIM0_OVF ; Timer0 Overflow Handler
;.ORG 0x0a rjmp SPI_STC ; SPI Transfer Complete Handler
.ORG 0x0b rjmp USART_RXC ; USART RX Complete Handler
;.ORG 0x0c rjmp USART_UDRE ; UDR Empty Handler
.ORG 0x0d rjmp USART_TXC ; USART TX Complete Handler
.ORG 0x0e rjmp ADCi ; ADC Conversion Complete Handler
;.ORG 0x0f rjmp EE_RDY ; EEPROM Ready Handler
;.ORG 0x10 rjmp ANA_COMP ; Analog Comparator Handler
;.ORG 0x11 rjmp TWSI ; Two-wire Serial Interface Handler
;.ORG 0x12 rjmp SPM_RDY ; Store Program Memory Ready Handler

#include "Indication.asm"
#include "ADC.asm"
#include "Systick.asm"
#include "Display.asm"
#include "Buttons.asm"

RESET:
;----init----
clr ERRORL_REG
clr ERRORH_REG
;stack
ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16
;const
clr r16
ldi r17, 10
movw r2, r16
ldi r16, TCNT0_START
ldi r17, TCCR0_START
movw r4, r16
ldi r16, ADMUX_BUTTONS
ldi r17, ADMUX_FEEDBACK1
movw r6, r16
ldi r16, ADMUX_FEEDBACK2
ldi r17, ADMUX_FEEDBACK3
movw r8, r16
ldi r16, MINUS_1SEG
ldi r17, BUTTON_IDLE
movw r10, r16
ldi r16, 5
movw r12, r16
;gpio
ldi r16, 0b11111111
out PORTB, r16
ldi r16, 0b11111111
out DDRB, r16
ldi r16, 0b00110000
out PORTC, r16
ldi r16, 0b00000101
out DDRC, r16
ldi r16, 0b11111011
out PORTD, r16
ldi r16, 0b11110110
out DDRD, r16
;regs
ldi TTARGET_REG, 28
ldi BUTTONS_REG, 0
ldi MODE_REG, MODE_OFF
ldi DISPLAY_MODE_REG, 0
ldi DISPLAY_MENU_REG, 0
;----ram----
ser r16
sts SEG1, r16
sts SEG2, r16
sts SEG3, r16
sts SEG4, r16
sts BUTTONS_IDLETIMEOUT, CONST_0
sts SEGNUMBER, CONST_0
sts PREVBUTTONS, CONST_0
sts BUTTON_PLUS_PRESS_COUNT, CONST_0
sts BUTTON_MINUS_PRESS_COUNT, CONST_0
sts BUTTON_MODE_PRESS_COUNT, CONST_0
sts BUTTON_MENU_PRESS_COUNT, CONST_0
sts D18B20_STATE, CONST_0
sts D18B20_COUNT, CONST_0
ldi r16, low(UART_BUFFER)
sts RECV_HANDLE_L, r16
ldi r16, high(UART_BUFFER)
sts RECV_HANDLE_H, r16
ldi r16, 1
sts MODBUS_ADDRESS, r16
;T0 - modbus timeout 4ms
;T1 - button read  + systick 100 ms
out TCCR1A, r2
ldi r16, 0b00001011
out TCCR1B, r16
ldi r16, 0x30
out OCR1AH, r16
ldi r16, 0xD4
out OCR1AL, r16
;T2 - indication
out TCNT2, r2
ldi r16, 128 ;Brightness
out OCR2, r16
ldi r16, 0b00000100 ;F/64
out TCCR2, r16
;
ldi r16, 0b11010001
out TIMSK, r16
;I2C
ldi r16, 32
out TWBR, r16
out TWSR, CONST_0
ldi r16, 0b10000100
out TWCR, r16
;UART 9600 ODD
out UCSRA, CONST_0
ldi r16, 0b11011000
out UCSRB, r16
ldi r16, 0b10000110
out UCSRC, r16
out UBRRH, CONST_0
ldi r16, 51
out UBRRL, r16
;ADC
ldi r16, ADMUX_BUTTONS
out ADMUX, r16
ldi r16, 0b11011111
out ADCSRA, r16
;
rcall init_18b20
;
rcall ds1307_init
;
sei
;
rcall selfdignostics
;----------main-cycle----------
main_cycle:
wdr
;--18b20--
sbrs ERRORL_REG, ERRORL_NO18B20
rjmp l1
 ;18b20 not found
 rcall init_18b20
 rjmp l2
l1:
 ;read 18b20
 rcall read_18b20
l2:
;--logic--
rcall logic
;--display--
rcall process_display
;--modbus--
lds r16, ACTION
sbrs r16, ACTION_MODBUS
 rjmp main_cycle
cbr r16, 1 << ACTION_MODBUS
sts ACTION, r16 
rcall process_modbus
sbi UCSRB, RXEN
rjmp main_cycle


#include "SelfDiagnostics.asm"
#include "Uart.asm"
#include "Modbus.asm"
#include "ModbusCrc.asm"
#include "1Wire.asm"
#include "18b20.asm"
#include "Logic.asm"
#include "I2C.asm"
#include "DS1307.asm"
#include "EEPROM.asm"
