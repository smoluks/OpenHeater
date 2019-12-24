# OpenHeater
3-channel controller for oil-filled heater based on ATMEGA8 & 18B20
![Photo](/Docs/E.png)

#### Roadmap:
- [x] PCB
- [x] Main firmware
- [x] Monitoring and diagnostics over feedback
- [x] Additional 18b20 оn J1(on heater) or J5(external sensor)
- [x] Remote control over Modbus on J3
#### WARNING: external sensor cause electric shock in current version of power pcb with LNK306. Use alternate power source such as phone charger

#### Toolchain:
PCB - Diptrace  
Firmware - AVRASM
Heater - polaris PRE C 1129 HF

#### Building:
- Make PCB

Main:
![Main](/Docs/Schemas/Main.png)
Power:
![Power](/Docs/Schemas/Power.png)
Remote (if needed)
![Remote_WIFI](/Docs/Schemas/Remote_WIFI.png)
- Flash Atmega8 with USBASP or similarly
- Assemble the heater
![Common](/Docs/Schemas/Common.png)

