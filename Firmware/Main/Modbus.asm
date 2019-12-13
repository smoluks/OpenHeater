#define MODBUS_INPUT_REGS_COUNT 11
#define MODBUS_HOLDING_REGS_COUNT 8

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

TIM0_OVF:
out tccr2, CONST_0
reti


process_modbus:
;check crc
lds r16, CRCHI
tst r16
brne t2exit
lds r16, CRCLO
tst r16
brne t2exit
;check addr
lds r16, UART_BUFFER + 0
lds r17, MODBUS_ADDRESS
cp r16, r17
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
cpi r16, READ_HOLDING_REGISTERS
brne t2c2
 ;---Read analog input---
 rcall readHoldingRegisters
 rjmp t2end
;
t2c2:
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
ret

readAnalogInput:
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
add r16, r17
cpi r16, MODBUS_INPUT_REGS_COUNT+1
brlo rai2
 rai1:	
 ldi r17, ERROR_ILLEGAL_DATA_ADDRESS
 rjmp makeerr 
;
rai2:
push r18
push r19
push r30
push r31
;---build packet---
;clean CRC
sts CRCLO, r3
sts CRCHI, r3
;address
lds r16, MODBUS_ADDRESS
rcall acrc
;command
lds r16, UART_BUFFER+1
rcall acrc
;size
mov r16, r17
lsl r16
mov r18, r16
sts UART_BUFFER+2, r16
rcall acrc
;data
lds r19, UART_BUFFER + 3 ;RegAddrLo
ldi r30, low(UART_BUFFER + 3)
ldi r31, high(UART_BUFFER + 3)
rai_data_cycle:
 tst r17
 breq rai_data_cycle_exit
 ;
 rcall read_input_reg
 st z+, r16
 rcall acrc
 mov r16, r17
 st z+, r16
 rcall acrc
 ;
 inc r19
 dec r17
 rjmp rai_data_cycle
rai_data_cycle_exit:
;crc
lds r16, CRCHI
st z+, r16
lds r16, CRCLO
st z+, r16
;
add r18, CONST_5
st z+, r18
;
pop r31
pop r30
pop r19
pop r18
ret

readHoldingRegisters:
;check address
lds r16, UART_BUFFER + 2 ;RegAddrHi
tst r16
brne rhr1
lds r16, UART_BUFFER + 3 ;RegAddrLo
cpi r16, MODBUS_HOLDING_REGS_COUNT+1
brsh rhr1
;check count
lds r17, UART_BUFFER + 4 ;CountHi
tst r17
brne rhr1
lds r17, UART_BUFFER + 5 ;CountLo
cpi r17, MODBUS_HOLDING_REGS_COUNT+1
brsh rhr1
;check all
add r16, r17
cpi r16, MODBUS_HOLDING_REGS_COUNT+1
brlo rhr2
 rhr1:	
 ldi r17, ERROR_ILLEGAL_DATA_ADDRESS
 rjmp makeerr 
;
rhr2:
push r18
push r30
push r31
;---build packet---
;clean CRC
sts CRCLO, r3
sts CRCHI, r3
;address
lds r16, MODBUS_ADDRESS
rcall acrc
;command
lds r16, UART_BUFFER+1
rcall acrc
;size
mov r16, r17
lsl r16
mov r18, r16
sts UART_BUFFER+2, r16
rcall acrc
;data
lds r16, UART_BUFFER + 3 ;RegAddrLo
ldi r30, low(UART_BUFFER + 3)
ldi r31, high(UART_BUFFER + 3)
rhr_data_cycle:
 tst r17
 breq rhr_data_cycle_exit
 ;
 rcall read_holding_reg
 st z+, r16
 rcall acrc
 mov r16, r17
 st z+, r16
 rcall acrc
 ;
 inc r16
 dec r17
 rjmp rhr_data_cycle
rhr_data_cycle_exit:
;crc
lds r16, CRCHI
st z+, r16
lds r16, CRCLO
st z+, r16
;
add r18, CONST_5
st z+, r18
;
pop r31
pop r30
pop r18
ret

;in: error - r17
makeerr:
;clear crc
sts CRCLO, r3
sts CRCHI, r3
;address
lds r16, MODBUS_ADDRESS
rcall acrc
;command
lds r16, UART_BUFFER+1
sbr r16, 0b10000000
sts UART_BUFFER+1, r16
rcall acrc
;error
sts UART_BUFFER+2, r17
mov r16, r17
rcall acrc
;crc
lds r16, CRCHI
sts UART_BUFFER+3, r16
lds r16, CRCLO
sts UART_BUFFER+4, r16
;start
ldi r16, 5
sts TRANS_COUNT, r16
;
ret

;in - r19 addr
;out - r16-17 data
read_input_reg:
cpi r19, 0
brne ri1
 ;18b20 count
 lds r16, D18B20_COUNT
 clr r17
 ret
ri1:
cpi r19, 12
brsh ri2
 ;temperatures
 push r19
 push r30
 push r31
 ;
 lsl r19
 ldi r30, low(D18B20_TEMPERATURES - 2)
 ldi r31, high(D18B20_TEMPERATURES - 2)
 add r30, r19
 adc r31, CONST_0
 ld r16, z+
 ld r17, z
 ;
 pop r31
 pop r30
 pop r19
 ret
ri2:
 clr r16
 clr r17 
ret

;in - r19 addr
;out - r16-17 data
read_holding_reg:
cpi r19, 0
brne h1
 ;modbus address
 lds r16, MODBUS_ADDRESS
 clr r17
 ret
h1:
cpi r19, 1
brne h2
 ;target temperature
 mov r16, TTARGET_REG
 clr r17
 ret
h2:
cpi r19, 2
brne h3
 ;mode
 mov r16, MODE_REG
 clr r17
 ret
h3: 
cpi r19, 3
brne h4
 ;brightness
 in r16, OCR2
 clr r17
 ret
h4:
cpi r19, 8
brsh h5
 ;1307 regs
 mov r17, r19
 subi r17, 4
 lsl r17
 rcall i2c_read_pair
 ret
h5:
 clr r16
 clr r17 
 ret