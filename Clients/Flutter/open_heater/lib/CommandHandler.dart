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
}

class Settings {
  int targetTemp;
  Mode mode;
  int brightness;

  Settings(this.targetTemp, this.mode, this.brightness);
}

enum Mode { None, First, Second, Both, Fan }
