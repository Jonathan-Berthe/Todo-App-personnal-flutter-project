import 'package:flutter/material.dart';

import 'dart:async';

import 'alarm_choice.dart';
import 'date_choice.dart';
import 'time_choice.dart';


class DateSection extends StatefulWidget {
  final Function selectTime;
  final Function selectDate;
  final Function setAlarm;
  final DateTime initDate;
  final TimeOfDay initTime;
  final bool initAlarm;
  DateSection({this.selectDate, this.selectTime, this.setAlarm, this.initDate, this.initTime, this.initAlarm, Key key})
      : super(key: key);

  @override
  _DateSectionState createState() => _DateSectionState();
}

class _DateSectionState extends State<DateSection> {

  DateTime _selectedDate;
  TimeOfDay _selectedTime;
  bool _withAlarm = false;
  bool _isInFuture;

  Timer _timer;

  @override
  void initState() { 
    super.initState();
    _selectedDate = widget.initDate;
    _selectedTime = widget.initTime;
    
    _resetTimer(init: true);
    _withAlarm = widget.initAlarm;
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectTime(TimeOfDay value) {
    if (_timer != null) _timer.cancel();
    setState(() {
      _selectedTime = value;
      widget.selectTime(value);
      _resetTimer();
      if (value == null) {
        _withAlarm = false;
        widget.setAlarm(false);
      }
    });
  }

  void _selectDate(DateTime value) {
    if (_timer != null) _timer.cancel();
    setState(() {
      _selectedDate = value;
      widget.selectDate(value);
      _resetTimer();
      if (value == null) {
        _withAlarm = false;
        widget.setAlarm(false);
      }
    });
  }

  void _resetTimer({bool init: false}) {
    // On reset le timer pour activer un changement quand on passe la date
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    if (_selectedTime != null && _selectedDate != null) {
      
      DateTime date = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
      DateTime now = DateTime.now();
      bool tmp = _isInFuture;
      _isInFuture = (date.isAfter(now));
      if (_isInFuture != null && tmp != null && _isInFuture && !tmp) {
        _withAlarm = false;
        if(!init) widget.setAlarm(false);
      }
      if (_isInFuture) {
        Duration diff = date.difference(now);
        _timer = Timer(diff, () {
          if (mounted) {
            setState(() {
              _isInFuture = false;
              _withAlarm = false;
              widget.setAlarm(false);
            });
          }
        });
      }
    } else {
      _isInFuture = null;
    }
  }

  void _setAlarm(bool val) {
    setState(() {
      _withAlarm = val;
      widget.setAlarm(val);
    });
  }

  @override
  Widget build(BuildContext context) {
     print(_withAlarm);
    return Column(
      children: <Widget>[
        DateChoice(_selectedDate, _selectDate),
        TimeChoice(_selectedTime, _selectTime),
        if (_isInFuture != null && _isInFuture )
          AlarmChoice(
            date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute),
            setAlarm: _setAlarm,
            withAlarm: _withAlarm,
          ),
        if (_isInFuture != null && !_isInFuture)
          Text(
            'Be careful, you select a past date',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }
}
