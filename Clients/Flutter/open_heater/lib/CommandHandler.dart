import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:open_heater/Modbus/modbus.dart';

class CommandHandler {
  ModbusClient client;

  CommandHandler(BluetoothDevice selectedDevice) {
    this.client = createBluetoothClient(selectedDevice);
  }

  Future<void> connect() async {
    await this.client.connect();
  }

  void dispose() {
    client.close();
  }

  Future<List<double>> GetTemperatures() async {
    var regs = await client.readInputRegisters(0, 11);
    var count = regs[0];

    return regs
        .skip(1)
        .take(count)
        .map((f) => Convert18b20Temperature(f))
        .toList();
  }

  double Convert18b20Temperature(int f) {
    if (f >= 0x8000) {
      //minus
      return (0x10000 - f) / 16;
    }

    return f / 16;
  }
}
