import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import './BluetoothDeviceListEntry.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage();

  @override
  _DiscoveryPage createState() => new _DiscoveryPage();
}

class _DiscoveryPage extends State<DiscoveryPage> {
  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  List<BluetoothDeviceListEntry> results = List<BluetoothDeviceListEntry>();
  bool _isDiscovering = false;

  _DiscoveryPage();

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      bondedDevices.forEach((device) => _addDevice(device, 0));
    });

    _startDiscovery();
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription?.cancel();

    super.dispose();
  }

  void _startDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      _addDevice(result.device, result.rssi);
    });

    _streamSubscription.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  void _addDevice(BluetoothDevice device, int rssi) {
    print("Found device: " +
        (device.name ?? "null") +
        "/" +
        (device.address ?? "null") +
        ", RSSI: " +
        (rssi?.toString() ?? "null") +
        ", " +
        (device.bondState?.toString() ?? "null"));

    setState(() {
      Iterator i = results.iterator;
      while (i.moveNext()) {
        var _deviceListEntry = i.current;

        if (_deviceListEntry.device == device) {
          _deviceListEntry.rssi = rssi;
          return;
        }
      }

      results.add(new BluetoothDeviceListEntry(device: device, rssi: rssi));

      //Navigator.of(context).pop(_device.device);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select device'),
        // actions: <Widget>[
        //   _isDiscovering
        //       ? FittedBox(
        //           child: Container(
        //             margin: new EdgeInsets.all(16.0),
        //             child: CircularProgressIndicator(
        //               valueColor: AlwaysStoppedAnimation<Color>(
        //                 Colors.white,
        //               ),
        //             ),
        //           ),
        //         )
        //       : IconButton(
        //           icon: Icon(Icons.replay),
        //           onPressed: _startDiscovery,
        //         )
        // ],
      ),
      body: ListView(children: results),
    );
  }
}
