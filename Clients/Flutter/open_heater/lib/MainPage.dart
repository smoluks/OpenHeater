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

    //---trying to connect to last device---
    final value = prefs.getInt("last_conn_type") ?? null;
    if (value == null) {
      setState(() {
        _loading = false;
      });

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
          final address = prefs.getString("last_conn_ip_addr") ?? null;
          //if (address != null) await useTCPDevice(address);
          break;
      }

      setState(() {
        _loading = false;
      });
    } on RangeError {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> useBTDevice(String address) async {
    var state = await FlutterBluetoothSerial.instance.state;

    if (!state.isEnabled) {
      //
      await FlutterBluetoothSerial.instance.requestEnable();
      //
      FlutterBluetoothSerial.instance
          .onStateChanged()
          .listen((BluetoothState state) {
        if (state.isEnabled) {
          useBTDeviceInternal(address);
        }
      });

      return;
    }

    useBTDeviceInternal(address);
  }

  Future<void> useBTDeviceInternal(String address) async {
    if (address == null) {
      address = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) {
        return DiscoveryPage();
      }));
    }

    if (address == null) return;

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("last_conn_type", ConnectionType.bt.index);
    prefs.setString("last_conn_bt_addr", address);

    int state =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ControlPage(btAddress: address);
    }));

    if (state == -1) {
      prefs.setInt("last_conn_type", -1);
    }
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

  Widget _getMainWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenHeater client'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaisedButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.blue)),
              color: Colors.blue,
              textColor: Colors.white,
              padding: EdgeInsets.all(8.0),
              onPressed: () {
                useBTDevice(null);
              },
              child: Text(
                "Connect over BT".toUpperCase(),
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
            SizedBox(height: 10),
            RaisedButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.blue)),
              color: Colors.blue,
              textColor: Colors.white,
              padding: EdgeInsets.all(8.0),
              onPressed: () {},
              child: Text(
                "Connect over TCP".toUpperCase(),
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
}
