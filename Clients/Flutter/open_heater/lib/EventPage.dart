import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'CommandHandler.dart';

class EventPage extends StatefulWidget {
  final Event event;
  final CommandHandler commandHandler;

  const EventPage({this.event, this.commandHandler});

  @override
  _EventPage createState() => new _EventPage();
}

class _EventPage extends State<EventPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> setEnabled(bool value) async {
    setState(() {
      widget.event.enabled = value;
    });

    await widget.commandHandler.UpdateEvent(widget.event);
  }

  Future<void> setOnce(bool value) async {
    setState(() {
      widget.event.once = value;
    });

    await widget.commandHandler.UpdateEvent(widget.event);
  }

  Future<void> setSeconds(int value) async {}

  Future<void> setMinutes(int value) async {
    setState(() {
      widget.event.seconds = value;
    });

    await widget.commandHandler.UpdateEvent(widget.event);
  }

  Future<void> setHours(int value) async {
    setState(() {
      widget.event.seconds = value;
    });

    await widget.commandHandler.UpdateEvent(widget.event);
  }

  Future<void> setMode(EventMode newValue) async {
    var mode = toMode(newValue);

    setState(() {
      widget.event.mode = mode;
    });

    await widget.commandHandler.UpdateEvent(widget.event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(getName()),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.replay),
              onPressed: () {},
            )
          ],
        ),
        body: Container(
            child: new ListView(children: [
          ListTile(
            title: Row(
              children: <Widget>[
                Switch(
                    value: widget.event.enabled,
                    onChanged: (value) {
                      setEnabled(value);
                    }),
                const Text("Enable"),
                SizedBox(width: 30),
                Switch(
                    value: widget.event.once,
                    onChanged: (value) {
                      setOnce(value);
                    }),
                const Text("Once")
              ],
            ),
          ),
          ListTile(
            title: Row(children: <Widget>[
              Switch(
                  value: widget.event.seconds != null,
                  onChanged: (value) {
                    setState(() {
                      widget.event.seconds = value ? 0 : null;
                    });
                  }),
              new GestureDetector(
                  onTap: () async {
                    var value = await pickNumber();
                    setSeconds(value);
                  },
                  child: Text(
                      widget.event.seconds == null
                          ? ''
                          : widget.event.seconds.toString(),
                      style: TextStyle(fontSize: 50)))
            ]),
            subtitle: const Text("Seconds"),
          ),
          ListTile(
            title: Row(children: <Widget>[
              Switch(
                  value: widget.event.minutes != null,
                  onChanged: (value) {
                    setState(() {
                      widget.event.minutes = value ? 0 : null;
                    });
                  }),
              new GestureDetector(
                  onTap: () async {
                    var value = await pickNumber();
                    setMinutes(value);
                  },
                  child: Text(
                      widget.event.minutes == null
                          ? ''
                          : widget.event.minutes.toString(),
                      style: TextStyle(fontSize: 50)))
            ]),
            subtitle: const Text("Minutes"),
          ),
          ListTile(
            title: Row(children: <Widget>[
              Switch(
                  value: widget.event.hours != null,
                  onChanged: (value) {
                    setState(() {
                      widget.event.hours = value ? 0 : null;
                    });
                  }),
              new GestureDetector(
                  onTap: () async {
                    var value = await pickNumber();
                    setHours(value);
                  },
                  child: Text(
                      widget.event.hours == null
                          ? ''
                          : widget.event.hours.toString(),
                      style: TextStyle(fontSize: 50)))
            ]),
            subtitle: const Text("Hours"),
          ),
          ListTile(
            title: Row(children: <Widget>[
              Column(children: <Widget>[
                Switch(
                    value: widget.event.daysOfWeek != null,
                    onChanged: (value) {
                      setState(() {
                        widget.event.daysOfWeek = value ? 0 : null;
                      });
                    })
              ]),
              Column(
                children: <Widget>[
                  getDayOfWeekCheckBox(DayOfWeeks.Sunday),
                  getDayOfWeekCheckBox(DayOfWeeks.Monday),
                  getDayOfWeekCheckBox(DayOfWeeks.Tuesday),
                  getDayOfWeekCheckBox(DayOfWeeks.Wednesday),
                  getDayOfWeekCheckBox(DayOfWeeks.Thursday),
                  getDayOfWeekCheckBox(DayOfWeeks.Friday),
                  getDayOfWeekCheckBox(DayOfWeeks.Saturday)
                ],
              )
            ]),
            subtitle: const Text("Days of week"),
          ),
          ListTile(
            title: DropdownButton<EventMode>(
              value: toEventMode(widget.event.mode),
              //icon: Icon(Icons.arrow_downward),
              //iconSize: 24,
              elevation: 16,
              style: TextStyle(fontSize: 30, color: Colors.black),
              underline: Container(
                color: Color(0),
              ),
              onChanged: (EventMode newValue) {
                setMode(newValue);
              },
              items: <EventMode>[
                EventMode.Inherit,
                EventMode.Off,
                EventMode.First,
                EventMode.Second,
                EventMode.Both,
                EventMode.Fan,
              ].map<DropdownMenuItem<EventMode>>((EventMode value) {
                return DropdownMenuItem<EventMode>(
                  value: value,
                  child: Text(getEventModeText(value)),
                );
              }).toList(),
            ),
            subtitle: const Text("Mode"),
          ),
          getTemeratureSelector(),
        ])));
  }

  Widget getTemeratureSelector() {
    if (widget.event.seconds == null)
      return ListTile(
        title: Row(children: <Widget>[
          Switch(
              value: false,
              onChanged: (value) async {
                setState(() {
                  widget.event.seconds = 0;
                });
                await widget.commandHandler.UpdateEvent(widget.event);
              }),
        ]),
        subtitle: const Text("Temperature"),
      );
    else
      return ListTile(
        title: Row(children: <Widget>[
          Switch(
              value: true,
              onChanged: (value) async {
                setState(() {
                  widget.event.seconds = null;
                });
                await widget.commandHandler.UpdateEvent(widget.event);
              }),
          new GestureDetector(
              onTap: () async {
                var value = await pickNumber();
                if (value != widget.event.seconds) {
                  setState(() {
                    widget.event.seconds = value;
                  });
                  await widget.commandHandler.UpdateEvent(widget.event);
                }
              },
              child: Text(widget.event.seconds.toString(),
                  style: TextStyle(fontSize: 50)))
        ]),
        subtitle: const Text("Temperature"),
      );
  }

  Future<int> pickNumber() async {
    return await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
            minValue: 0,
            maxValue: 59,
            initialIntegerValue: 0,
          );
        });
  }

  Widget getDayOfWeekCheckBox(DayOfWeeks dayOfWeek) {
    return Row(children: <Widget>[
      new Checkbox(
          value: widget.event.daysOfWeek == null
              ? false
              : widget.event.daysOfWeek & (1 << dayOfWeek.index) ==
                  (1 << dayOfWeek.index),
          onChanged: (bool newValue) async {
            setState(() {
              if (newValue)
                widget.event.daysOfWeek |= (1 << dayOfWeek.index);
              else
                widget.event.daysOfWeek &= ~(1 << dayOfWeek.index);
            });

            await widget.commandHandler.UpdateEvent(widget.event);
          }),
      Text(dayOfWeek.toString())
    ]);
  }

  String getName() {
    return 'Event ${widget.event.number}';
  }

  String getEventModeText(EventMode value) {
    return value.toString();
  }

  EventMode toEventMode(Mode mode) {
    if (mode == null) return EventMode.Inherit;

    return EventMode.values[mode.index];
  }

  Mode toMode(EventMode newValue) {
    if (newValue == EventMode.Inherit) return null;

    return Mode.values[newValue.index];
  }
}

enum EventMode { Off, First, Second, Both, Fan, Inherit }
