import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import 'CommandHandler.dart';
import 'EventPage.dart';

class ControlPage extends StatefulWidget {
  final String btAddress;
  final String deviceName;

  const ControlPage({this.btAddress, this.deviceName});

  @override
  _ControlPage createState() => new _ControlPage();
}

class _ControlPage extends State<ControlPage> {
  CommandHandler _commandHandler;
  Timer _timer;

  bool _firstLoading = true;
  bool _loading = true;

  double _currentTemperature;
  int _targetTemperatue;
  Mode _currentMode;
  List<Event> _events;

  @override
  void initState() {
    super.initState();

    _commandHandler = new CommandHandler(widget.btAddress);
    _commandHandler.connect().then((_) {
      updateState();

      updateEvents();

      _timer = new Timer.periodic(
          Duration(seconds: 10), (_) async => await updateState());
    }, onError: (_) {
      _timer?.cancel();
      Navigator.of(context).pop(-1);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _timer?.cancel();
    _commandHandler.dispose();

    super.dispose();
  }

  Future<void> updateState() async {
    setState(() {
      _loading = true;
    });

    try {
      var temperatures = await _commandHandler.getTemperatures();
      var settings = await _commandHandler.getSettings();

      setState(() {
        _currentTemperature = temperatures.reduce(min);
        _targetTemperatue = settings.targetTemp;
        _currentMode = settings.mode;

        _loading = false;
        _firstLoading = false;
      });
    } catch (ex) {
      _timer?.cancel();
      print('updateState failed: $ex');
      Navigator.of(context).pop(-1);
    }
  }

  Future<void> updateEvents() async {
    setState(() {
      _loading = true;
    });

    var events = await _commandHandler.getEvents();

    setState(() {
      try {
        _events = events;
        _loading = false;
      } catch (ex) {
        _timer?.cancel();
        print('updateState failed: $ex');
        Navigator.of(context).pop(-1);
      }
    });
  }

  Future<void> setMode(Mode newValue) async {
    try {
      await _commandHandler.setMode(newValue.index);
    } catch (ex) {
      print('setMode failed: $ex');
      return;
    }

    updateState();
  }

  Future<void> setTargetTemperature() async {
    if (_firstLoading) return;

    var value = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
            minValue: -39,
            maxValue: 75,
            title: new Text("New target temperature"),
            initialIntegerValue: _targetTemperatue,
          );
        });

    if (value == _targetTemperatue) return;

    try {
      await _commandHandler.setTargetTemperature(value);
    } catch (ex) {
      print('setMode failed: $ex');
      return;
    }

    updateState();
  }

  Future<void> editEvent(Event event) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return EventPage(event: event, commandHandler: _commandHandler);
    }));

    await updateEvents();
  }

  String getName() {
    return widget.deviceName ?? "OpenHeater";
  }

  String getCurrentTemperature() {
    return _currentTemperature == null
        ? "-"
        : _currentTemperature.toString() + " ºC";
  }

  String getTargetTemperature() {
    return _targetTemperatue == null
        ? "-"
        : _targetTemperatue.toString() + " ºC";
  }

  String getModeText(Mode mode) {
    if (mode == null) return "-";

    switch (mode) {
      case Mode.Off:
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
    return "-";
  }

  String getEventText(Event event) {
    String result = '';

    result += event.hours == null ? 'xx:' : '${event.hours.toString()}:';
    result += event.minutes == null ? 'xx:' : '${event.minutes.toString()}:';
    result += event.seconds == null ? 'xx' : event.seconds.toString();

    if (event.daysOfWeek != null) {
      if ((event.daysOfWeek & 0x01) == 0x01) result += ' SU';
      if ((event.daysOfWeek & 0x02) == 0x02) result += ' MO';
      if ((event.daysOfWeek & 0x04) == 0x04) result += ' TUE';
      if ((event.daysOfWeek & 0x08) == 0x08) result += ' WED';
      if ((event.daysOfWeek & 0x10) == 0x10) result += ' THU';
      if ((event.daysOfWeek & 0x20) == 0x20) result += ' FRI';
      if ((event.daysOfWeek & 0x40) == 0x40) result += ' SAT';
    }

    if (event.mode != null) result += ' Mode➞${getModeText(event.mode)}';

    if (event.temperature != null) result += ' t➞${event.temperature}º';

    if (event.once != null) result += ' once';

    return result;
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
        child: new ListView(children: [
          ListTile(
            title: Text(
              getCurrentTemperature(),
              style: TextStyle(fontSize: 50),
            ),
            subtitle: const Text("Current temperature"),
          ),
          ListTile(
            title: new GestureDetector(
              onTap: () {
                setTargetTemperature();
              },
              child: Text(
                getTargetTemperature(),
                style: TextStyle(fontSize: 50),
              ),
            ),
            subtitle: const Text("Target temperature"),
          ),
          ListTile(
              title: DropdownButton<Mode>(
                itemHeight: 60,
                value: _currentMode,
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
                  Mode.Off,
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
              subtitle: const Text("Mode")),
          new Divider(
            height: 15.0,
            color: Colors.grey,
          ),
          getEventTile(0),
          Divider(),
          getEventTile(1),
          Divider(),
          getEventTile(2),
          Divider(),
          getEventTile(3),
          Divider(),
          getEventTile(4),
          Divider(),
          getEventTile(5),
          Divider(),
          getEventTile(6),
          Divider(),
          getEventTile(7),
        ]),
      ),
    );
  }

  ListTile getEventTile(int number) {
    if (_events == null || _events[number] == null)
      return new ListTile(title: Text('$number: -'));

    return new ListTile(
        leading: _events[number].enabled
            ? new Image(
                image: AssetImage("assets/icons/timer.png"),
                width: 24,
                height: 24)
            : new Image(
                image: AssetImage("assets/icons/timer_disable.png"),
                width: 24,
                height: 24),
        title: Text(getEventText(_events[number])),
        onTap: () {
          editEvent(_events[number]);
        });
  }
}
