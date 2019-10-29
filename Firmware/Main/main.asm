#include "RamMapping.asm"

.ORG 0x00 rjmp RESET ; Reset Handler
;.ORG 0x01 rjmp EXT_INT0 ; IRQ0 Handler
;.ORG 0x02 rjmp EXT_INT1 ; IRQ1 Handler
;.ORG 0x03 rjmp TIM2_COMP ; Timer2 Compare Handler
;.ORG 0x04 rjmp TIM2_OVF ; Timer2 Overflow Handler
;.ORG 0x05 rjmp TIM1_CAPT ; Timer1 Capture Handler
.ORG 0x06 rjmp TIM1_COMPA ; Timer1 CompareA Handler
;.ORG 0x07 rjmp TIM1_COMPB ; Timer1 CompareB Handler
;.ORG 0x08 rjmp TIM1_OVF ; Timer1 Overflow Handler
.ORG 0x09 rjmp TIM0_OVF ; Timer0 Overflow Handler
;.ORG 0x0a rjmp SPI_STC ; SPI Transfer Complete Handler
;.ORG 0x0b rjmp USART_RXC ; USART RX Complete Handler
;.ORG 0x0c rjmp USART_UDRE ; UDR Empty Handler
;.ORG 0x0d rjmp USART_TXC ; USART TX Complete Handler
.ORG 0x0e rjmp ADCi ; ADC Conversion Complete Handler
;.ORG 0x0f rjmp EE_RDY ; EEPROM Ready Handler
;.ORG 0x10 rjmp ANA_COMP ; Analog Comparator Handler
;.ORG 0x11 rjmp TWSI ; Two-wire Serial Interface Handler
;.ORG 0x12 rjmp SPM_RDY ; Store Program Memory Ready Handler

#include "TIM0.asm"
#include "TIM1.asm"

RESET:
;----init----
;stack
ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16
;const
clr r16
ldi r17, 10
movw r2, r16
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
clr ERROR_REG
;ram
ldi TTARGET_REG, 28
ldi ERROR_REG, 0
ldi BUTTONS_REG, 0
ldi MODE_REG, MODE_OFF
ldi DISPLAY_MODE_REG, 0
ser r16
sts SEG1, r16
sts SEG2, r16
sts SEG3, r16
sts SEG4, r16
sts SEGNUMBER, CONST_0
sts PREVBUTTONS, CONST_0
sts BUTTON_PLUS_PRESS_COUNT, CONST_0
sts BUTTON_MINUS_PRESS_COUNT, CONST_0
sts BUTTON_MODE_PRESS_COUNT, CONST_0
sts BUTTON_MENU_PRESS_COUNT, CONST_0
;T0 - indication
ldi r16, 0b00000011
out TCCR0, r16
;T1 - systick
out TCCR1A, r2
ldi r16, 0b00001100
out TCCR1B, r16
ldi r16, 0x7A
out OCR1AH, r16
ldi r16, 0x12
out OCR1AL, r16
ldi r16, 0b00010001
out TIMSK, r16
;ADC
ldi r16, 0b01100110
out ADMUX, r16
ldi r16, 0b11101111
out ADCSRA, r16
;
rcall init_18b20
brtc l0
 sbr ERROR_REG, 1 << ERROR_NO18B20
l0:
sei
;----------main-cycle----------
main_cycle:
;18b20
sbrs ERROR_REG, ERROR_NO18B20
rjmp l1
 ;18b20 not found
 rcall init_18b20
 brts l2
  cbr ERROR_REG, 1 << ERROR_NO18B20
l1:
 ;read 18b20
 rcall read_18b20
 brtc l2
  sbr ERROR_REG, 1 << ERROR_NO18B20
l2:
;logic
rcall logic
;display
rcall process_display
;
rjmp main_cycle

#include "1Wire.asm"
#include "18b20.asm"
#include "display.asm"
#include "buttons.asm"
#include "logic.asm"
