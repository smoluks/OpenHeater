# OpenHeater
2,3-channel controller for oil-filled heater based on ATMEGA8 & 18B20

#### Roadmap:
- [x] PCB
- [ ] Main firmware
- [ ] Monitoring and diagnostics over feedback
- [ ] PID regulation
- [ ] Additionals 18b20 оn J1(on heater) or J5(external sensor)
- [ ] Remote control over ESP8266 connected to J3
#### WARNING: You need galvanic-isolation version of power pcb, another external sensor will be shocked

#### Toolchain:
PCB - Diptrace  
Firmware - Proteus VSM Studio (you can compile it with AVRASM)  
Heater -

#### Building:
- Make PCB with LUT (https://cxem.net/master/45.php) or another 
- Flash Atmega8 with USBASP or similarly
- Assemble the heater


