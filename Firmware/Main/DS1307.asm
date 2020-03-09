;SYS
#define SECONDS_TKREG 0x00
#define MINUTES_TKREG 0x01
#define HOURS_TKREG 0x02
#define DAY_TKREG 0x03
#define DATE_TKREG 0x04
#define MONTH_TKREG 0x05
#define YEAR_TKREG 0x06
#define CONTROL_TKREG 0x07

ds1307_init:
;stop beep 
ldi r16, 0b00000000
ldi r17, CONTROL_TKREG
rcall i2c_write
brts ds1307_err
;check oscillator
ldi r17, SECONDS_TKREG
rcall i2c_read
brts ds1307_err
sbrs r16, 7
rjmp ds1307_powerok
;---power loss present---
 ;start oscillator
 cbr r16, 0b10000000
 ldi r17, SECONDS_TKREG
 rcall i2c_write
 brts ds1307_err
 ;flush ds1307 ram
 ds1307_flush:
 ldi r18, 56
 ldi r17, 8
 rcall i2c_flush
 brts ds1307_err
;---no power loss present---
ds1307_powerok:
;check CRC
;ldi r18, 56
;ldi r17, 8
;rcall i2c_calccrc
;brts ds1307_err
;read ds1307 ram
ret
ds1307_err:
sbr ERRORL_REG, 1 << ERRORL_I2C
ret

ds1307_makebeep:
ldi r16, 0b00010001
ldi r17, CONTROL_TKREG
rcall i2c_write
brts ds1307_err
ret

ds1307_stopbeep:
ldi r16, 0b00000000
ldi r17, CONTROL_TKREG
rcall i2c_write
brts ds1307_err
ret