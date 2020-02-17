#define MODBUS_INPUT_REGS_COUNT 41
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
push r16
push r17
in r16, SREG
push r16
;stop t0
out TCCR0, CONST_0
;check crc
lds r16, CRCHI
tst r16
brne t0_ovf_exit
lds r16, CRCLO
tst r16
brne t0_ovf_exit
;check addr
lds r16, UART_BUFFER + 0
tst r16
breq t0_ovf_p
lds r17, MODBUS_ADDRESS
cp r16, r17
brne t0_ovf_exit
;
t0_ovf_p:
 cbi UCSRB, RXEN
 ;set modbus process flag
 lds r16, ACTION
 sbr r16, 1 << ACTION_MODBUS
 sts ACTION, r16
t0_ovf_exit:
;repair all for new packet
sts CRCLO, CONST_FF
sts CRCHI, CONST_FF
;
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

process_modbus:
;------select command------
lds r16, UART_BUFFER + 1
cpi r16, READ_INPUT_REGISTERS
brne t2c1
 rcall readAnalogInput
 tst r17
 breq t2end
  rcall makeerr
  rjmp t2end 
t2c1:
cpi r16, READ_HOLDING_REGISTERS
brne t2c2
 rcall readHoldingRegisters
 tst r17
 breq t2end
  rcall makeerr
  rjmp t2end
t2c2:
cpi r16, WRITE_SINGLE_REGISTER
brne t2c3
 rcall writeSingleRegister
 tst r17
 breq t2end
  rcall makeerr
  rjmp t2end 
t2c3: 
ldi r17, ERROR_ILLEGAL_FUNCTION ;not supported error
rcall makeerr
t2end:
;set answer handle
ldi r16, low(UART_BUFFER)
sts TRANS_HANDLE_L, r16
ldi r16, high(UART_BUFFER)
sts TRANS_HANDLE_H, r16
;start transmit
rcall USART_TXC
;
sts CRCLO, CONST_FF
sts CRCHI, CONST_FF
ret

;IN UART_BUFFER
;OUT r17 - error
readAnalogInput:
;check address
lds r16, UART_BUFFER + 2 ;RegAddrHi
tst r16
brne rai1
lds r16, UART_BUFFER + 3 ;RegAddrLo
cpi r16, MODBUS_INPUT_REGS_COUNT
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
 ret
;
rai2:
push r18
push r19
;---build packet---
;clean CRC
ser r16
sts CRCLO, r16
sts CRCHI, r16
;address
lds r16, UART_BUFFER+0
rcall acrc
;command
lds r16, UART_BUFFER+1
rcall acrc
;size
mov r18, r17
mov r16, r17
lsl r16
sts UART_BUFFER+2, r16
rcall acrc
add r16, CONST_5
sts TRANS_COUNT, r16
;data
lds r19, UART_BUFFER + 3 ;RegAddrLo
ldi r30, low(UART_BUFFER + 3)
ldi r31, high(UART_BUFFER + 3)
rai_data_cycle:
 tst r18
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
 dec r18
 rjmp rai_data_cycle
rai_data_cycle_exit:
;crc
lds r16, CRCHI
st z+, r16
lds r16, CRCLO
st z+, r16
;
clr r17
;
pop r19
pop r18
ret

readHoldingRegisters:
;check address
lds r16, UART_BUFFER + 2 ;RegAddrHi
tst r16
brne rhr1
lds r16, UART_BUFFER + 3 ;RegAddrLo
cpi r16, MODBUS_HOLDING_REGS_COUNT
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
 ret
;
rhr2:
push r18
push r19
;---build packet---
;clean CRC
sts CRCLO, CONST_FF
sts CRCHI, CONST_FF
;address
lds r16, UART_BUFFER+0
rcall acrc
;command
lds r16, UART_BUFFER+1
rcall acrc
;size
mov r18, r17
mov r16, r17
lsl r16
sts UART_BUFFER+2, r16
rcall acrc
add r16, CONST_5
sts TRANS_COUNT, r16
;data
lds r19, UART_BUFFER + 3 ;RegAddrLo
ldi r30, low(UART_BUFFER + 3)
ldi r31, high(UART_BUFFER + 3)
rhr_data_cycle:
 tst r18
 breq rhr_data_cycle_exit
 ;
 rcall read_holding_reg
 st z+, r16
 rcall acrc
 mov r16, r17
 st z+, r16
 rcall acrc
 ;
 inc r19
 dec r18
 rjmp rhr_data_cycle
rhr_data_cycle_exit:
;crc
lds r16, CRCHI
st z+, r16
lds r16, CRCLO
st z+, r16
;
clr r17
;
pop r19
pop r18
ret

writeSingleRegister:
;check address
lds r16, UART_BUFFER + 2 ;RegAddrHi
tst r16
brne wsr1
lds r16, UART_BUFFER + 3 ;RegAddrLo
cpi r16, MODBUS_HOLDING_REGS_COUNT
brlo wsr2
wsr1:	
 ldi r17, ERROR_ILLEGAL_DATA_ADDRESS
 ret
;
wsr2:
push r18
;
ldi r16, 8
sts TRANS_COUNT, r16
;
lds r18, UART_BUFFER + 3 ;RegAddrLo
lds r17, UART_BUFFER + 4 ;Data High
lds r16, UART_BUFFER + 5 ;Data Low
rcall write_single_reg
;
pop r18
ret

;in: error - r17
makeerr:
;clear crc
ser r16
sts CRCLO, r16
sts CRCHI, r16
;address
lds r16, UART_BUFFER+0
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
;out - r17-16 data
read_input_reg:
cpi r19, 0
brne ri1
 ;--18b20 count--
 lds r17, D18B20_COUNT
 clr r16
 ret
ri1:
cpi r19, 11
brsh ri2
 ;--temperatures--
 push r19
 push r30
 push r31
 ;
 lsl r19
 ldi r30, low(D18B20_TEMPERATURES - 2)
 ldi r31, high(D18B20_TEMPERATURES - 2)
 add r30, r19
 adc r31, CONST_0
 ld r17, z+
 ld r16, z
 ;
 pop r31
 pop r30
 pop r19
 ret
ri2:
cpi r19, 41
brsh ri3
 ;--temperatures--
 push r19
 push r30
 push r31
 ;
 lsl r19
 ldi r30, low(D18B20_ADDRESSES - 22)
 ldi r31, high(D18B20_ADDRESSES - 22)
 add r30, r19
 adc r31, CONST_0
 ld r17, z+
 ld r16, z
 ;
 pop r31
 pop r30
 pop r19
 ret
ri3:
 clr r16
 clr r17 
ret

;in - r19 addr
;out - r17-16 data
read_holding_reg:
cpi r19, 0
brne h1
 ;modbus address
 lds r17, MODBUS_ADDRESS
 clr r16
 ret
h1:
cpi r19, 1
brne h2
 ;target temperature
 mov r17, TTARGET_REG
 clr r16
 ret
h2:
cpi r19, 2
brne h3
 ;mode
 mov r17, MODE_REG
 clr r16
 ret
h3: 
cpi r19, 3
brne h4
 ;brightness
 in r17, OCR2
 clr r16
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

;in r18 - addr, r17:16 - data
;out r17 - error 
write_single_reg:
clt
cpi r18, 0
brne ws1
 ;---modbus address---
 tst r17
 brne data_error
 sts MODBUS_ADDRESS, r16
 rcall save_modbus_address
 ;
 clr r17
 ret
ws1:
cpi r19, 1
brne ws2
 ;---target temperature---
 tst r17
 brne data_error
 cpi r16, MIN_TARGET_TEMP
 brlt data_error
 cpi r16, MAX_TARGET_TEMP+1
 brge data_error
 mov TTARGET_REG, r16
 ;
 clr r17
 ret
ws2:
cpi r19, 2
brne ws3
 ;---mode---
 tst r17
 brne data_error
 cpi r16, MODE_COUNT
 brsh data_error
 mov MODE_REG, r16
 ;
 clr r17
 ret
ws3: 
cpi r19, 3
brne ws4
 ;---brightness---
 tst r17
 brne data_error
 cpi r16, MODE_COUNT
 brsh data_error
 out OCR2, r16
 rcall save_brightness
 ;
 clr r17
 ret
ws4:
cpi r19, 8
brsh ws5
 ;1307 regs
 tst r17
 brne data_error
 mov r17, r18
 rcall i2c_write
 brts not_ready
 ;
 clr r17
 ret
ws5:
 ldi r17, ERROR_ILLEGAL_DATA_ADDRESS
 ret
data_error:
 ldi r17, ERROR_ILLEGAL_DATA_VALUE
 ret
not_ready:
 ldi r17, ERROR_SLAVE_DEVICE_BUSY
 ret 