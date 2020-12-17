import 'package:flutter/material.dart';

class AlarmChoice extends StatelessWidget {
  final DateTime date;

  final Function setAlarm;

  final bool withAlarm;

  AlarmChoice({this.date, this.setAlarm, this.withAlarm});

  @override
  Widget build(BuildContext context) {
    bool _isSwitched = withAlarm;
    return Container(
      width: double.infinity,
      child: Row(
        children: <Widget>[
          Text(
            'Set Alarm',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Switch(
            value: _isSwitched,
            onChanged: (value) {
              setAlarm(value);
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
