#define DEV_ADDR 01

USART_RXC:
push r16
push r26
push r27
in r16, SREG
push r16
;
in r16, UDR
rcall acrc
lds r26, RECV_HANDLE_L
lds r27, RECV_HANDLE_H
st x+, r16
sts RECV_HANDLE_L, r26
sts RECV_HANDLE_H, r27
;
out tcnt2, r2
ldi r16, 0b00001101
out tccr2, r16
;
pop r16
out SREG, r16
pop r27
pop r26
pop r16
reti

USART_TXC:
push r16
push r26
push r27
in r16, SREG
push r16
;
lds r16, TRANS_COUNT
tst r16
breq utexit
;
dec r16
sts TRANS_COUNT, r16
;
lds r26, TRANS_HANDLE_L
lds r27, TRANS_HANDLE_H
ld r16, X+
sts TRANS_HANDLE_L, r26
sts TRANS_HANDLE_H, r27
out UDR, r16
;
utexit:
pop r16
out SREG, r16
pop r27
pop r26
pop r16
reti

TIM2_COMP:
push r16
push r17
in r16, SREG
push r16
;������ 2 ����
out tccr2, r2
;----------��������� ������----------
;crc
lds r16, CRCHI
tst r16
brne t2exit
lds r16, CRCLO
tst r16
brne t2exit
;�����
lds r16, uart_buffer + 0
cpi r16, DEV_ADDR
brne t2exit
;�������
lds r16, uart_buffer + 1
cpi r16, 0x04
brne t2c1
 ;---Read analog input---
 rcall readAnalogInput
 rjmp t2end
;
t2c1:
ldi r17, 1 ;������� �� ��������������
rcall makeerr
;
t2end:
;����� ������
ldi r16, low(uart_buffer)
sts TRANS_HANDLE_L, r16
ldi r16, high(uart_buffer)
sts TRANS_HANDLE_H, r16
;��������
rcall USART_TXC
;
t2exit:
sts CRCLO, r3
sts CRCHI, r3
ldi r16, low(uart_buffer)
sts RECV_HANDLE_L, r16
ldi r16, high(uart_buffer)
sts RECV_HANDLE_H, r16
;
pop r16
out SREG, r16
pop r17
pop r16
reti

readAnalogInput:
push r17
push r18
push r28
push r29
push r30
push r31
;
lds r16, uart_buffer + 2 ;RegAddrHi
tst r16
brne rai1
lds r16, uart_buffer + 3 ;RegAddrLo
cpi r16, MODBUS_INPUT_REGS_COUNT+1
brsh rai1
lds r17, uart_buffer + 4 ;CountHi
tst r17
brne rai1
lds r17, uart_buffer + 5 ;CountLo
cpi r17, MODBUS_INPUT_REGS_COUNT+1
brsh rai1
mov r18, r16
add r18, r17
cpi r18, MODBUS_INPUT_REGS_COUNT+1
brlo rai2
 rai1:	
 ldi r17, 2 ;����� �� ��������������
 rcall makeerr
 rjmp rai_exit
;
rai2:
;����������
rcall readtemp
;�����
ldi r30, low(MODBUS_INPUT_REGS)
ldi r31, high(MODBUS_INPUT_REGS)
lsl r16
add r30, r16
adc r31, r2
;
ldi r28, low(uart_buffer+2)
ldi r29, high(uart_buffer+2)
;Clean CRC
sts CRCLO, r3
sts CRCHI, r3
;�����
ldi r16, DEV_ADDR
rcall acrc
;�������
lds r16, uart_buffer+1
rcall acrc
;���������� ���� �����
lsl r17
mov r16, r17
st y+, r16
rcall acrc
add r16, r4
sts TRANS_COUNT, r16
;������
rai3:
tst r17
breq rai4
 ld r16, z+
 st y+, r16
 rcall acrc
 ;
 dec r17
 rjmp rai3
rai4:
;crc
lds r16, CRCHI
st y+, r16
lds r16, CRCLO
st y, r16
;
rai_exit:
pop r31
pop r30
pop r29
pop r28
pop r18
pop r17
ret

;in: error - r17
makeerr:
push r16
;
sts CRCLO, r3
sts CRCHI, r3
;�����
ldi r16, DEV_ADDR
rcall acrc
;�������
lds r16, uart_buffer+1
sbr r16, 0b10000000
sts uart_buffer+1, r16
rcall acrc
;������
sts uart_buffer+2, r17
mov r16, r17
rcall acrc
;crc
lds r16, CRCHI
sts uart_buffer+3, r16
lds r16, CRCLO
sts uart_buffer+4, r16
;���������� ���� � ������
sts TRANS_COUNT, r4
;
pop r16
ret

