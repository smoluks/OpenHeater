#define CONTROL_REG 0x07

ds1307_init:
;
ldi r16, 0b00010000
ldi r17, CONTROL_REG
rcall i2c_write
brts ds1307_init_err
;
ldi r17, 0x08
rcall i2c_read
tst r17
breq ds1307_init_exit
mov TTARGET_REG, r17
;
ds1307_init_err:
sbr ERROR_REG, 1 << ERROR_I2C
ds1307_init_exit:
ret