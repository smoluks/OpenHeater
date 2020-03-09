ldi r30, 0x60
ldi r31, 0x00
;
check_ram_cycle:
;
clr r16
;
check_ram_cycle_1:
st z, r16
ld r17, z
cp r16, r17
brne check_ram_cycle_error
;
dec r16
brne check_ram_cycle_1
;
adiw r30, 1
cpi r31, 0x04
brne check_ram_cycle
cpi r30, 0x60
brne check_ram_cycle
;
rjmp check_ram_cycle_exit
;
check_ram_cycle_error:
 sbr ERRORL_REG, 1 << ERRORL_BAD_RAM
check_ram_cycle_exit: