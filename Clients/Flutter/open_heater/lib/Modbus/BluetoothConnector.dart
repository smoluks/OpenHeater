import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'modbus.dart';

class BluetoothConnector extends ModbusConnector {
  BluetoothConnection _connection;
  String _btAddress;
  int _modbusAddress;
  List<int> _cache = [];
  Timer _timer;

  BluetoothConnector(this._btAddress, this._modbusAddress);

  @override
  Future<void> connect() async {
    await BluetoothConnection.toAddress(_btAddress).then((connection) {
      print('Connected to the device');
      _connection = connection;

      _connection.input.listen(_onData).onDone(() {
        onClose();
      });
    });
  }

  @override
  Future<void> close() async {
    _connection.dispose();
  }

  void _onData(Uint8List tcpData) {
    //
    //log.finest('RECV: ' + dumpHexToString(tcpData));

    _cache += tcpData;

    if (_timer != null) _timer.cancel();
    _timer = new Timer(Duration(milliseconds: 300), handleTimeout);
  }

  void handleTimeout() {
    var list = Uint8List.fromList(_cache);
    var view = ByteData.view(list.buffer);

    int address = view.getUint8(0);
    if (_modbusAddress != 0 && _modbusAddress != address) {
      _cache.clear();
      return;
    }

    int function = view.getUint8(1);

    //TODO: check crc
    int crc = view.getUint16(_cache.length - 2);

    onResponse(function, list.sublist(2, list.length - 2));
    _cache.clear();
  }

  @override
  void write(int function, Uint8List data) {
    Uint8List modbusHeader = Uint8List(2);
    ByteData.view(modbusHeader.buffer)
      ..setUint8(0, _modbusAddress)
      ..setUint8(1, function);

    Uint8List data2 = Uint8List.fromList(modbusHeader + data);
    Uint8List crc = _crc(data2);

    //log.finest('SEND: ' + dumpHexToString(tcpData));
    Uint8List packet = Uint8List.fromList(data2 + crc);
    try {
      _connection.output.add(packet);
    } catch (ex) {
      onError(ex, null);
    }
  }

  Uint8List _crc(Uint8List bytes) {
    var crc = 0xffff;
    var poly = 0xa001;

    for (var byte in bytes) {
      crc = crc ^ byte;
      for (int n = 0; n <= 7; n++) {
        if (crc & 0x0001 != 0) {
          crc = crc >> 1;
          crc = crc ^ poly;
        } else
          crc = crc >> 1;
      }
    }

    //return crc.toUnsigned(16).toInt();
    var ret = Uint8List(2);
    ByteData.view(ret.buffer)..setUint8(0, crc & 0x00FF)..setUint8(1, crc >> 8);
    return ret;
  }
}
