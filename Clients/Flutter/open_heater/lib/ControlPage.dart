import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'CommandHandler.dart';

class ControlPage extends StatefulWidget {
  final BluetoothDevice selectedDevice;

  const ControlPage({this.selectedDevice});

  @override
  _ControlPage createState() => new _ControlPage();
}

class _ControlPage extends State<ControlPage> {
  CommandHandler _commandHandler;
  double temperature;

  bool _isConnected = false;
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();

    _commandHandler = new CommandHandler(widget.selectedDevice);
    _commandHandler.connect().then((_) {
      _isConnected = true;
    });
  }

  Future<void> updateState() async {
    if (!_isConnected) return;

    var temperatures = await _commandHandler.GetTemperatures();

    setState(() {
      temperature = temperatures.reduce(min);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _commandHandler.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenHeater client'),
        actions: <Widget>[
          _isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: new EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.replay),
                  onPressed: updateState,
                )
        ],
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('Temperature'),
              subtitle: Text(temperature.toString()),
            ),

            // Divider(),
            // ListTile(
            //   title: const Text('General')
            // ),
            // SwitchListTile(
            //   title: const Text('Enable Bluetooth'),
            //   value: _bluetoothState.isEnabled,
            //   onChanged: (bool value) {
            //     // Do the request and update with the true value then
            //     future() async { // async lambda seems to not working
            //       if (value)
            //         await FlutterBluetoothSerial.instance.requestEnable();
            //       else
            //         await FlutterBluetoothSerial.instance.requestDisable();
            //     }
            //     future().then((_) {
            //       setState(() {});
            //     });
            //   },
            // ),
            // ListTile(
            //   title: const Text('Bluetooth status'),
            //   subtitle: Text(_bluetoothState.toString()),
            //   trailing: RaisedButton(
            //     child: const Text('Settings'),
            //     onPressed: () {
            //       FlutterBluetoothSerial.instance.openSettings();
            //     },
            //   ),
            // ),
            // ListTile(
            //   title: const Text('Local adapter address'),
            //   subtitle: Text(_address),
            // ),
            // ListTile(
            //   title: const Text('Local adapter name'),
            //   subtitle: Text(_name),
            //   onLongPress: null,
            // ),
            // ListTile(
            //   title: _discoverableTimeoutSecondsLeft == 0 ? const Text("Discoverable") : Text("Discoverable for ${_discoverableTimeoutSecondsLeft}s"),
            //   subtitle: const Text("PsychoX-Luna"),
            //   trailing: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Checkbox(
            //         value: _discoverableTimeoutSecondsLeft != 0,
            //         onChanged: null,
            //       ),
            //       IconButton(
            //         icon: const Icon(Icons.edit),
            //         onPressed: null,
            //       ),
            //       IconButton(
            //         icon: const Icon(Icons.refresh),
            //         onPressed: () async {
            //           print('Discoverable requested');
            //           final int timeout = await FlutterBluetoothSerial.instance.requestDiscoverable(60);
            //           if (timeout < 0) {
            //             print('Discoverable mode denied');
            //           }
            //           else {
            //             print('Discoverable mode acquired for $timeout seconds');
            //           }
            //           setState(() {
            //             _discoverableTimeoutTimer?.cancel();
            //             _discoverableTimeoutSecondsLeft = timeout;
            //             _discoverableTimeoutTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
            //               setState(() {
            //                 if (_discoverableTimeoutSecondsLeft < 0) {
            //                   FlutterBluetoothSerial.instance.isDiscoverable.then((isDiscoverable) {
            //                     if (isDiscoverable) {
            //                       print("Discoverable after timeout... might be infinity timeout :F");
            //                       _discoverableTimeoutSecondsLeft += 1;
            //                     }
            //                   });
            //                   timer.cancel();
            //                   _discoverableTimeoutSecondsLeft = 0;
            //                 }
            //                 else {
            //                   _discoverableTimeoutSecondsLeft -= 1;
            //                 }
            //               });
            //             });
            //           });
            //         },
            //       )
            //     ]
            //   )
            // ),

            // Divider(),
            // ListTile(
            //   title: const Text('Devices discovery and connection')
            // ),
            // SwitchListTile(
            //   title: const Text('Auto-try specific pin when pairing'),
            //   subtitle: const Text('Pin 1234'),
            //   value: _autoAcceptPairingRequests,
            //   onChanged: (bool value) {
            //     setState(() {
            //       _autoAcceptPairingRequests = value;
            //     });
            //     if (value) {
            //       FlutterBluetoothSerial.instance.setPairingRequestHandler((BluetoothPairingRequest request) {
            //         print("Trying to auto-pair with Pin 1234");
            //         if (request.pairingVariant == PairingVariant.Pin) {
            //           return Future.value("1234");
            //         }
            //         return null;
            //       });
            //     }
            //     else {
            //       FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
            //     }
            //   },
            // ),
            // ListTile(
            //   title: RaisedButton(
            //     child: const Text('Explore discovered devices'),
            //     onPressed: () async {
            //       // final BluetoothDevice selectedDevice = await Navigator.of(context).push(
            //       //   MaterialPageRoute(builder: (context) { return DiscoveryPage(); })
            //       // );

            //       // if (selectedDevice != null) {
            //       //   print('Discovery -> selected ' + selectedDevice.address);
            //       // }
            //       // else {
            //       //   print('Discovery -> no device selected');
            //       // }
            //     }
            //   ),
            // ),
            // ListTile(
            //   title: RaisedButton(
            //     child: const Text('Connect to paired device to chat'),
            //     onPressed: () async {
            //     //   final BluetoothDevice selectedDevice = await Navigator.of(context).push(
            //     //     MaterialPageRoute(builder: (context) { return SelectBondedDevicePage(checkAvailability: false); })
            //     //   );

            //     //   if (selectedDevice != null) {
            //     //     print('Connect -> selected ' + selectedDevice.address);
            //     //     _startChat(context, selectedDevice);
            //     //   }
            //     //   else {
            //     //     print('Connect -> no device selected');
            //     //   }
            //      },
            //   ),
            // ),

            // Divider(),
            // ListTile(
            //   title: const Text('Multiple connections example')
            // ),
            // ListTile(
            //   title: RaisedButton(
            //     child: (
            //       (_collectingTask != null && _collectingTask.inProgress)
            //       ? const Text('Disconnect and stop background collecting')
            //       : const Text('Connect to start background collecting')
            //     ),
            //     onPressed: () async {
            //       if (_collectingTask != null && _collectingTask.inProgress) {
            //         await _collectingTask.cancel();
            //         setState(() {/* Update for `_collectingTask.inProgress` */});
            //       }
            //       else {
            //         final BluetoothDevice selectedDevice = await Navigator.of(context).push(
            //           MaterialPageRoute(builder: (context) { return SelectBondedDevicePage(checkAvailability: false); })
            //         );

            //         if (selectedDevice != null) {
            //           await _startBackgroundTask(context, selectedDevice);
            //           setState(() {/* Update for `_collectingTask.inProgress` */});
            //         }
            //       }
            //     },
            //   ),
            // ),
            // ListTile(
            //   title: RaisedButton(
            //     child: const Text('View background collected data'),
            //     onPressed: (_collectingTask != null) ? () {
            //       Navigator.of(context).push(
            //         MaterialPageRoute(builder: (context) {
            //           return ScopedModel<BackgroundCollectingTask>(
            //             model: _collectingTask,
            //             child: BackgroundCollectedPage(),
            //           );
            //         })
            //       );
            //     } : null,
            //   )
            // ),
          ],
        ),
      ),
    );
  }
}
