#define MODBUSADDR_TKREG 0x00
#define BRIGHTNESS_TKREG 0x01
#define TTARGET_TKREG 0x02

eeprom_readall:
;modbus address
ldi r17, MODBUSADDR_TKREG
rcall EEPROM_read
cpi r16, 0xFF
brne era1
 sts MODBUS_ADDRESS, r16
era1:
;target temperatute
ldi r17, TTARGET_TKREG
rcall EEPROM_read
cpi r16, MAX_TARGET_TEMP
brge era2
cpi r16, MIN_TARGET_TEMP
brlt era2
 mov TTARGET_REG, r16
era2:
;brightness
ldi r17, BRIGHTNESS_TKREG
rcall EEPROM_read
out OCR2, r16
ret

;in r16 - address
save_modbus_address:
push r17
;
ldi r17, MODBUSADDR_TKREG
rcall EEPROM_write
;
pop r17
ret

;in - r16
save_target_temp:
push r17
;
ldi r17, TTARGET_TKREG
rcall EEPROM_write
;
pop r17
ret

;in: r16
save_brightness:
push r17
;
ldi r17, BRIGHTNESS_TKREG
rcall EEPROM_write
;
pop r17
ret

;in r16 - data, r17 - address
EEPROM_write:
; Wait for completion of previous write
sbic EECR,EEWE
rjmp EEPROM_write
; Set up address (r18:r17) in address register
out EEARH, CONST_0
out EEARL, r17
; Write data (r16) to data register
out EEDR,r16
; Write logical one to EEMWE
sbi EECR,EEMWE
; Start eeprom write by setting EEWE
sbi EECR,EEWE
ret

;in r17 - addr
;out r16 - data
EEPROM_read:
; Wait for completion of previous write
sbic EECR,EEWE
rjmp EEPROM_read
; Set up address (r18:r17) in address register
out EEARH, CONST_0
out EEARL, r17
; Start eeprom read by writing EERE
sbi EECR,EERE
; Read data from data register
in r16,EEDR
ret