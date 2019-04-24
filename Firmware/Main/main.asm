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
;.ORG 0x0e rjmp ADC ; ADC Conversion Complete Handler
;.ORG 0x0f rjmp EE_RDY ; EEPROM Ready Handler
;.ORG 0x10 rjmp ANA_COMP ; Analog Comparator Handler
;.ORG 0x11 rjmp TWSI ; Two-wire Serial Interface Handler
;.ORG 0x12 rjmp SPM_RDY ; Store Program Memory Ready Handler

#include "TIM0.asm"
#include "TIM1.asm"

RESET:
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
;ram
ser r16
sts SEG1, r16
sts SEG2, r16
sts SEG3, r16
sts SEG4, r16
sts SEGNUMBER, r2
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
;
rcall init_18b20
brtc l0
 ldi r16, 1
 rjmp writeError
l0:
sei
l_cycle:
;
rcall process_18b20
brtc l2
 ldi r16, 1
 rjmp writeError
l2:
;
rcall process_display
brtc l_cycle
 ldi r16, 2
 rjmp writeError

#include "1Wire.asm"
#include "18b20.asm"
#include "Display.asm"
