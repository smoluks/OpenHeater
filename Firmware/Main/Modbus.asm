#define DEV_ADDR 01
#define MODBUS_INPUT_REGS_COUNT 1

#define READ_COILS 0x01
#define READ_DISCRETE_INPUTS 0x02
#define READ_HOLDING_REGISTERS 0x03
#define READ_INPUT_REGISTERS 0x04
#define WRITE_SINGLE_COIL 0x05
#define WRITE_SINGLE_REGISTER 0x06

#define ERROR_ILLEGAL_FUNCTION 0x01
#define ERROR_ILLEGAL_DATA_ADDRESS 0x02
#define ERROR_ILLEGAL_DATA_VALUE 0x03
#define ERROR_SLAVE_DEVICE_FAILURE 0x04
#define ERROR_ACKNOWLEDGE 0x05
#define ERROR_SLAVE_DEVICE_BUSY 0x06
#define ERROR_MEMORY_PARITY ERROR 0x08
#define ERROR_GATEWAY_PATH_UNAVAILABLE 0x0A
#define ERROR_GATEWAY_TARGET_DEVICE_FAILED_TO_RESPOND 0x0B

TIM2_COMP:
push r16
push r17
in r16, SREG
push r16
;stop t2
out tccr2, CONST_0
;check crc
lds r16, CRCHI
tst r16
brne t2exit
lds r16, CRCLO
tst r16
brne t2exit
;check addr
lds r16, UART_BUFFER + 0
cpi r16, DEV_ADDR
brne t2exit
;------select command------
lds r16, UART_BUFFER + 1
cpi r16, READ_INPUT_REGISTERS
brne t2c1
 ;---Read analog input---
 rcall readAnalogInput
 rjmp t2end
;
t2c1:
ldi r17, ERROR_ILLEGAL_FUNCTION ;not supported error
rcall makeerr
;set answer handle
t2end:
ldi r16, low(UART_BUFFER)
sts TRANS_HANDLE_L, r16
ldi r16, high(UART_BUFFER)
sts TRANS_HANDLE_H, r16
;start transmit
rcall USART_TXC
;recover receive buffer handle
t2exit:
sts CRCLO, r3
sts CRCHI, r3
ldi r16, low(UART_BUFFER)
sts RECV_HANDLE_L, r16
ldi r16, high(UART_BUFFER)
sts RECV_HANDLE_H, r16
;
pop r16
out SREG, r16
pop r17
pop r16
reti

readAnalogInput:
push r18
push r28
push r29
push r30
push r31
;check address
lds r16, UART_BUFFER + 2 ;RegAddrHi
tst r16
brne rai1
lds r16, UART_BUFFER + 3 ;RegAddrLo
cpi r16, MODBUS_INPUT_REGS_COUNT+1
brsh rai1
;check count
lds r17, UART_BUFFER + 4 ;CountHi
tst r17
brne rai1
lds r17, UART_BUFFER + 5 ;CountLo
cpi r17, MODBUS_INPUT_REGS_COUNT+1
brsh rai1
;check all
mov r18, r16
add r18, r17
cpi r18, MODBUS_INPUT_REGS_COUNT+1
brlo rai2
 rai1:	
 ldi r17, ERROR_ILLEGAL_DATA_ADDRESS
 rcall makeerr
 rjmp rai_exit
;
rai2:
;---rcall readtemp---
;---build packet---
;clean CRC
sts CRCLO, r3
sts CRCHI, r3
;address
ldi r16, DEV_ADDR
rcall acrc
;command
lds r16, UART_BUFFER+1
rcall acrc
;size
ldi r16, 2
sts UART_BUFFER+2, r16
rcall acrc
;data
mov r16, THigh_REG
sts UART_BUFFER+3, r16
rcall acrc
;
ldi r16, TLow_REG
sts UART_BUFFER+4, r16
rcall acrc
;crc
lds r16, CRCHI
sts UART_BUFFER+5, r16
lds r16, CRCLO
sts UART_BUFFER+6, r16
;
ldi r16, 7
sts TRANS_COUNT, r4
rai_exit:
pop r31
pop r30
pop r29
pop r28
pop r18
ret

;in: error - r17
makeerr:
;clear crc
sts CRCLO, r3
sts CRCHI, r3
;
ldi r16, DEV_ADDR
rcall acrc
;
lds r16, UART_BUFFER+1
sbr r16, 0b10000000
sts UART_BUFFER+1, r16
rcall acrc
;������
sts UART_BUFFER+2, r17
mov r16, r17
rcall acrc
;crc
lds r16, CRCHI
sts UART_BUFFER+3, r16
lds r16, CRCLO
sts UART_BUFFER+4, r16
;���������� ���� � ������
sts TRANS_COUNT, r4
;
ret

