import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './DiscoveryPage.dart';
import 'ControlPage.dart';

enum ConnectionType { bt, tcp }

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  String _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    loadLastDevice();
  }

  Future<void> loadLastDevice() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getInt("last_conn_type") ?? null;
    if (value == null) {
      _loading = false;
      return;
    }

    try {
      var connType = ConnectionType.values[value];
      switch (connType) {
        case ConnectionType.bt:
          final address = prefs.getString("last_conn_bt_addr") ?? null;
          if (address != null) await useBTDevice(address);
          break;
        case ConnectionType.tcp:
          break;
      }
    } on RangeError {
      _loading = false;
    }
  }

  Future<void> useBTDevice(String address) async {
    var state = await FlutterBluetoothSerial.instance.state;

    if (!state.isEnabled) {
      await FlutterBluetoothSerial.instance.requestEnable();

      FlutterBluetoothSerial.instance
          .onStateChanged()
          .listen((BluetoothState state) {
        if (state.isEnabled)
          
      });
    }

    BluetoothDevice selectedDevice;

    if (true) {
      selectedDevice = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) {
        return DiscoveryPage();
      }));
    }

    await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ControlPage(selectedDevice: selectedDevice);
    }));
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _getErrorWidget(context);
    if (_loading) return _getLoadingWidget(context);

    return _getMainWidget(context);
  }

  Widget _getLoadingWidget(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('OpenHeater client')),
        body: Center(child: Text('Loading')));
  }

  Widget _getErrorWidget(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('OpenHeater client')),
        body: Center(child: Text(_error)));
  }

  Widget _getMainWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenHeater client'),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[],
        ),
      ),
    );
  }
}
