

eeprom_readall:
;modbus address
;target temperatute
ldi r17, TTARGET_TKREG
rcall i2c_read
brts ds1307_err
tst r16
breq readBg
mov TTARGET_REG, r16
;brightness
readBg:
ldi r17, BRIGHTNESS_TKREG
rcall i2c_read
brts ds1307_err
cpi r16, MIN_BRIGHTNESS
brlo ds1307_init_exit
out OCR2, r16

save_modbus_address:
ret

;in - TTARGET_REG
ds1307_savetargettemp:
mov r16, TTARGET_REG
ldi r17, TTARGET_TKREG
rcall i2c_write
brts ds1307_err
ret

;in: r17
ds1307_savebrightness:
ldi r17, BRIGHTNESS_TKREG
rcall i2c_write
brts ds1307_err
ret

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