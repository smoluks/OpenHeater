# OpenHeater
![Main](https://github.com/smoluks/OpenHeater/blob/master/Docs/Wiki/Assembled.png)

3-channel controller for replacing the mechanical thermostat of oil-filled heaterw

#### Main features:
- **Up to 10 1-wire themperature sensors (18b20 and some)** - lowest temperature for control and highest for protection
- **8 time events for selecting mode/temperature** (specific or any seconds, minutes, hours and day of week)
- **Remote control implemented by modbus over uart** (you may connect HC05 for bluetooth, or ESP8266 with serial-tcp modbus bridge firmware for WIFI, or MAX13487 (replace 5-3.3v dc-dc parts by jumper) for non-halvanic isolation RS485)
- **Mobile client** (in progress)

#### Toolchain:
Main controller - Atmega16, language AVRASM
PCB - Diptrace
Mobile client - Flutter
Heater - polaris PRE C 1129 HF

#### Building:
[See wiki](https://github.com/smoluks/OpenHeater/wiki)
