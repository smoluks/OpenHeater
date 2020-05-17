.EQU DEBUG=1
#include "RamMapping.asm"

.ORG 0x00 jmp RESET ; Reset Handler
;.ORG 0x02 jmp EXT_INT0 ; IRQ0 Handler
;.ORG 0x04 jmp EXT_INT1 ; IRQ1 Handler
.ORG 0x06 jmp TIM2_COMP ; Timer2 Compare Handler
.ORG 0x08 jmp TIM2_OVF ; Timer2 Overflow Handler
;.ORG 0x0A jmp TIM1_CAPT ; Timer1 Capture Handler
.ORG 0x0C jmp TIM1_COMPA ; Timer1 CompareA Handler
;.ORG 0x0E jmp TIM1_COMPB ; Timer1 CompareB Handler
;.ORG 0x10 jmp TIM1_OVF ; Timer1 Overflow Handler
.ORG 0x12 jmp TIM0_OVF ; Timer0 Overflow Handler
;.ORG 0x14 jmp SPI_STC ; SPI Transfer Complete Handler
.ORG 0x16 jmp USART_RXC ; USART RX Complete Handler
;.ORG 0x18 jmp USART_UDRE ; UDR Empty Handler
.ORG 0x1A jmp USART_TXC ; USART TX Complete Handler
.ORG 0x1C jmp ADCi ; ADC Conversion Complete Handler
;.ORG 0x1E jmp EE_RDY ; EEPROM Ready Handler
;.ORG 0x20 jmp ANA_COMP ; Analog Comparator Handler
;.ORG 0x22 jmp TWSI ; Two-wire Serial Interface Handler
;.ORG 0x24 jmp EXT_INT2 ; IRQ2 Handler
;.ORG 0x26 jmp TIM0_COMP ; Timer0 Compare Handler
;.ORG 0x28 jmp SPM_RDY ; Store Program Memory Ready Handler
;
;.ORG 0x2A RESET: ldi r16,high(RAMEND) ; Main program start
;.ORG 0x2B out SPH,r16 ; Set Stack Pointer to top of RAM
;.ORG 0x2C ldi r16,low(RAMEND)
;.ORG 0x2D out SPL,r16
;.ORG 0x2E sei ; Enable interrupts
;.ORG 0x2F <instr> xxx

#include "Indication.asm"
#include "ADC.asm"
#include "Systick.asm"
#include "Display.asm"
#include "Buttons.asm"

RESET:
;----------init----------
;stack
ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16
;const
clr r16
ser r17
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
ldi r17, 10
movw r12, r16
;gpio
ldi r16, 0b00000000
out PORTA, r16
ldi r16, 0b00010101
out DDRA, r16
ldi r16, 0b00011000
out PORTB, r16
ldi r16, 0b00001000
out DDRB, r16
ldi r16, 0b11111111
out PORTC, r16
ldi r16, 0b11111100
out DDRC, r16
ldi r16, 0b11111101
out PORTD, r16
ldi r16, 0b11111101
out DDRD, r16
;----regs----
clr ERRORL_REG
clr ERRORH_REG
ldi TTARGET_REG, 22
ldi MODE_REG, MODE_OFF
ldi DISPLAY_MODE_REG, 0
ldi DISPLAY_MENU_REG, 0
;----ram----
#include "CheckRam.asm"
ser r16
sts SEG1, r16
sts SEG2, r16
sts SEG3, r16
sts SEG4, r16
ldi r16, low(UART_BUFFER)
sts RECV_HANDLE_L, r16
ldi r16, high(UART_BUFFER)
sts RECV_HANDLE_H, r16
ldi r16, 1
sts MODBUS_ADDRESS, r16
;T0 - modbus timeout 4ms
;T1 - button read  + systick 100 ms
out TCCR1A, CONST_0
ldi r16, 0b00001011
out TCCR1B, r16
ldi r16, 0x30
out OCR1AH, r16
ldi r16, 0xD4
out OCR1AL, r16
;T2 - indication
out TCNT2, CONST_0
ldi r16, 128 ;Brightness
out OCR2, r16
ldi r16, 0b00000101 ;F/128
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
ldi r16, 0b10110110
out UCSRC, r16;
out UBRRH, CONST_0
ldi r16, 95
out UBRRL, r16
;ldi r16, 0xAA
;out UDR, r16
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
rcall eeprom_readall
;
sei
;
;.IFNDEF DEBUG
;rcall check_heaters
;.ENDIF
;
ldi r16, 0b00001011
out WDTCR, r16
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
;--events--
rcall events
;--modbus--
lds r16, ACTION
sbrs r16, ACTION_MODBUS
rjmp main_cycle
 cbr r16, 1 << ACTION_MODBUS
 sts ACTION, r16 
 ;
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
#include "Events.asm"
