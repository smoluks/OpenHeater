import 'package:open_heater/Modbus/modbus.dart';

class CommandHandler {
  ModbusClient client;

  CommandHandler(String address) {
    this.client = createBluetoothClient(address);
  }

  Future<void> connect() async {
    await this.client.connect();
  }

  void dispose() {
    client.close();
  }

  Future<List<double>> getTemperatures() async {
    var regs = await client.readInputRegisters(0, 11);
    var count = regs[0];

    return regs
        .skip(1)
        .take(count)
        .map((f) => _convert18b20Temperature(f))
        .toList();
  }

  Future<Settings> getSettings() async {
    var regs = await client.readHoldingRegisters(1, 3);

    return new Settings(regs[0], Mode.values[regs[1]], regs[2]);
  }

  Future<List<Event>> getEvents() async {
    var regs = await client.readHoldingRegisters(8, 56);
    var result = new List<Event>();

    for (var i = 0; i < 56; i += 7) {
      var event = _parceEvent(regs.getRange(i, i + 7).toList());
      event.number = i ~/ 7;
      result.add(event);
    }

    return result;
  }

  Future<void> setMode(int value) async {
    await client.writeSingleRegister(2, value);
  }

  Future<void> setTargetTemperature(int value) async {
    await client.writeSingleRegister(1, value);
  }

  Future<void> UpdateEvent(Event event) {}

  double _convert18b20Temperature(int f) {
    if (f >= 0x8000) {
      //minus
      return (0x10000 - f) / 16;
    }

    return f / 16;
  }

  Event _parceEvent(List<int> range) {
    var event = new Event();

    event.enabled = (range[0] & 0x01) == 0x01;
    event.once = (range[0] & 0x02) == 0x02;

    event.seconds = range[1] == 255 ? null : _convertBCDToInt(range[1]);
    event.minutes = range[2] == 255 ? null : _convertBCDToInt(range[2]);
    event.hours = range[3] == 255 ? null : _convertBCDToInt(range[3]);
    event.daysOfWeek = range[4] == 255 ? null : range[4];
    event.mode = range[5] == 255 ? null : Mode.values[range[5]];
    event.temperature = range[6] == 255 ? null : range[6];

    return event;
  }

  int _convertBCDToInt(int value) {
    return (value ~/ 16) * 10 + (value % 16);
  }
}

class Event {
  int number;
  bool enabled;
  bool once;
  int seconds;
  int minutes;
  int hours;
  int daysOfWeek;
  Mode mode;
  int temperature;
}

class Settings {
  int targetTemp;
  Mode mode;
  int brightness;

  Settings(this.targetTemp, this.mode, this.brightness);
}

enum Mode { Off, First, Second, Both, Fan }

enum DayOfWeeks {
  Sunday,
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Saturday,
}
