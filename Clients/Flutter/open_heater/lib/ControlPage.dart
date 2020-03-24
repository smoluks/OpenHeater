import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import 'CommandHandler.dart';

class ControlPage extends StatefulWidget {
  final String btAddress;

  const ControlPage({this.btAddress});

  @override
  _ControlPage createState() => new _ControlPage();
}

class _ControlPage extends State<ControlPage> {
  CommandHandler _commandHandler;
  NumberPicker _targetNumberPicker;
  Timer timer;

  bool _firstLoading = true;
  bool _loading = true;

  double temperature;
  int targetTemperatue;
  Mode mode;
  int brightness;

  @override
  void initState() {
    super.initState();

    _commandHandler = new CommandHandler(widget.btAddress);
    _commandHandler.connect().then((_) {
      updateState();

      timer = new Timer.periodic(
          Duration(seconds: 10), (_) async => await updateState());
    }, onError: (_) {
      timer.cancel();
      Navigator.of(context).pop(-1);
    });
  }

  Future<void> updateState() async {
    setState(() {
      _loading = true;
    });

    try {
      var temperatures = await _commandHandler.getTemperatures();
      var settings = await _commandHandler.getSettings();

      setState(() {
        temperature = temperatures.reduce(min);
        targetTemperatue = settings.targetTemp;
        mode = settings.mode;
        brightness = settings.brightness;
        _loading = false;
        _firstLoading = false;
      });
    } catch (ex) {
      timer.cancel();
      print('updateState failed: $ex');
      Navigator.of(context).pop(-1);
    }
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    timer.cancel();
    _commandHandler.dispose();

    super.dispose();
  }

  Future<void> setMode(Mode newValue) async {
    try {
      await _commandHandler.setMode(newValue.index);
    } catch (ex) {
      print('setMode failed: $ex');
    }

    updateState();
  }

  Future<void> setTargetTemperature(num newValue) async {
    try {
      await _commandHandler.setTargetTemperature(newValue as int);
    } catch (ex) {
      print('setMode failed: $ex');
    }

    //updateState();
  }

  String getName() {
    return "OpenHeater";
  }

  String getCurrentTemperature() {
    return temperature == null ? "-" : temperature.toString() + " ºC";
  }

  String getTargetTemperature() {
    return targetTemperatue == null ? "-" : targetTemperatue.toString() + " ºC";
  }

  String getModeText(Mode mode) {
    if (mode == null) return "-";

    switch (mode) {
      case Mode.None:
        return "Off";
      case Mode.First:
        return "1";
      case Mode.Second:
        return "2";
      case Mode.Both:
        return "1+2";
      case Mode.Fan:
        return "Fan";
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getName()),
        actions: <Widget>[
          _loading
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
              title: Text(
                getCurrentTemperature(),
                style: TextStyle(fontSize: 50),
              ),
              subtitle: const Text("Current temperature"),
            ),
            ListTile(
              title: getTargetNumberPicker(),
              subtitle: const Text("Target temperature"),
            ),
            ListTile(
                title: DropdownButton<Mode>(
                  itemHeight: 60,
                  value: mode,
                  //icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(fontSize: 50, color: Colors.black),
                  underline: Container(
                    height: 2,
                    color: Color(0),
                  ),
                  onChanged: (Mode newValue) {
                    setMode(newValue);
                  },
                  items: <Mode>[
                    Mode.None,
                    Mode.First,
                    Mode.Second,
                    Mode.Both,
                    Mode.Fan,
                  ].map<DropdownMenuItem<Mode>>((Mode value) {
                    return DropdownMenuItem<Mode>(
                      value: value,
                      child: Text(getModeText(value)),
                    );
                  }).toList(),
                ),
                subtitle: const Text("Mode"))
          ],
        ),
      ),
    );
  }

  Widget getTargetNumberPicker() {
    if (_firstLoading) return Text("");

    if (_targetNumberPicker != null) return _targetNumberPicker;

    _targetNumberPicker = new NumberPicker.integer(
        scrollDirection: Axis.horizontal,
        infiniteLoop: false,
        initialValue: targetTemperatue,
        minValue: -39,
        maxValue: 75,
        onChanged: (newValue) {
          if (newValue != targetTemperatue) setTargetTemperature(newValue);
        });

    return _targetNumberPicker;
  }
}
