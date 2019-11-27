;SYS
#define SECONDS_TKREG 0x00
#define MINUTES_TKREG 0x01
#define HOURS_TKREG 0x02
#define DAY_TKREG 0x03
#define DATE_TKREG 0x04
#define MONTH_TKREG 0x05
#define YEAR_TKREG 0x06
#define CONTROL_TKREG 0x07
;CUSTOM
#define TTARGET_TKREG 0x08

ds1307_init:
;--start oscillator--
ldi r17, SECONDS_TKREG
rcall i2c_read
brts ds1307_err
sbrs r16, 7
rjmp d1
cbr r16, 0b10000000
ldi r17, CONTROL_TKREG
rcall i2c_write
d1:
;--test 1 HZ output--
ldi r16, 0b00010000
ldi r17, CONTROL_TKREG
rcall i2c_write
brts ds1307_err
;--read params--
ldi r17, TTARGET_TKREG
rcall i2c_read
brts ds1307_err
tst r16
breq ds1307_init_exit
mov TTARGET_REG, r16
;
ds1307_init_exit:
ret

ds1307_savetargettemp:
mov r16, TTARGET_REG
ldi r17, TTARGET_TKREG
rcall i2c_write
brts ds1307_err
ret

ds1307_err:
sbr ERRORL_REG, 1 << ERRORL_I2C
ret