ldi r30, 0x60
ldi r31, 0x00
;
check_ram_cycle:
st z, CONST_FF
ld r16, z
cpi r16, 0xFF
brne check_ram_cycle_error
st z, CONST_0
ld r16, z
cpi r16, 0x00
brne check_ram_cycle_error
;
adiw r30, 1
cpi r31, 0x04
brne check_ram_cycle
cpi r31, 0x60
brne check_ram_cycle
;
check_ram_cycle_error:
 sbr ERRORL_REG, 1 << ERRORL_BAD_RAM
check_ram_cycle_exit: