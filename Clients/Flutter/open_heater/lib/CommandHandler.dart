import 'package:mutex/mutex.dart';
import 'package:open_heater/Modbus/modbus.dart';

class CommandHandler {
  ModbusClient client;

  Mutex _m;

  CommandHandler(String address) {
    this.client = createBluetoothClient(address);
    _m = Mutex();
  }

  Future<void> connect() async {
    await this.client.connect();
  }

  void dispose() {
    client.close();
  }

  Future<List<double>> getTemperatures() async {
    await _m.acquire();
    try {
      var regs = await client.readInputRegisters(0, 11);
      var count = regs[0];

      return regs
          .skip(1)
          .take(count)
          .map((f) => _convert18b20Temperature(f))
          .toList();
    } finally {
      _m.release();
    }
  }

  Future<Settings> getSettings() async {
    await _m.acquire();
    try {
      var regs = await client.readHoldingRegisters(1, 3);

      return new Settings(regs[0], Mode.values[regs[1]], regs[2]);
    } finally {
      _m.release();
    }
  }

  Future<List<Event>> getEvents() async {
    await _m.acquire();
    try {
      var regs = await client.readHoldingRegisters(8, 56);
      var result = new List<Event>();

      for (var i = 0; i < 56; i += 7) {
        result.add(_parceEvent(regs.getRange(i, i + 7).toList()));
      }

      return result;
    } finally {
      _m.release();
    }
  }

  Future<void> setMode(int value) async {
    await _m.acquire();
    try {
      await client.writeSingleRegister(2, value);
    } finally {
      _m.release();
    }
  }

  Future<void> setTargetTemperature(int value) async {
    await _m.acquire();
    try {
      await client.writeSingleRegister(1, value);
    } finally {
      _m.release();
    }
  }

  double _convert18b20Temperature(int f) {
    if (f >= 0x8000) {
      //minus
      return (0x10000 - f) / 16;
    }

    return f / 16;
  }

  Event _parceEvent(List<int> range) {
    var event = new Event();

    event.enable = (range[0] & 0x01) == 0x01;
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
  bool enable;
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

enum Mode { None, First, Second, Both, Fan }
