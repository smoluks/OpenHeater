import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDeviceListEntry {
  BluetoothDevice device;
  int rssi;

  BluetoothDeviceListEntry({@required this.device, this.rssi
      // GestureTapCallback onTap,
      // GestureLongPressCallback onLongPress,
      // bool enabled = true,
      });
}
