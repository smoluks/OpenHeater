# OpenHeater
3-channel controller for oil-filled heater

#### Main features:
- Up to 10 1-wire themperature sensors (18b20 and some) - lowest temperature for control and highest for protection
- 8 time events for selecting mode/temperature (specific or any seconds, minutes, hours and day of week)
- Remote control implemented by modbus over uart (you may connect HC05 for bluetooth, or ESP8266 with serial-tcp modbus bridge firmware for WIFI, or MAX13487 (do not solder 5-3.3v dc-dc parts) for non-halvanic isolation RS485)

#### Toolchain:
Main controller - Atmega16, language AVRASM
PCB - Diptrace
Heater - polaris PRE C 1129 HF

#### Building:
[See wiki](https://github.com/smoluks/OpenHeater/wiki)
