import 'package:flutter/material.dart';

import './day_widget.dart';

class Calendar extends StatefulWidget {
  final Function setSelectDay;
  final double horizontalSize;
  Calendar({this.setSelectDay, this.horizontalSize, key}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _selectDay;
  DateTime _referenceDay;
  DateTime _firstDayOfMonth;
  DateTime _lastDayOfMonth;
  int _numberOfDayInMonth;
  String _month;
  int _monthNum;
  int _year;

  double _tileSize;

  @override
  void initState() {
    _referenceDay = DateTime.now();
    _tileSize = widget.horizontalSize / 7;
    super.initState();
  }

  Widget _dayTileBuilder(String day) {
    return Expanded(
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            color: Colors.white, //Colors.black54,
            //fontWeight: FontWeight.bold,
          ),
        ),
      ),
      //width: 50,
    );
  }

  List<Widget> _daysBuilder() {
    int nRow =
        ((_firstDayOfMonth.weekday + _numberOfDayInMonth - 1) / 7).ceil();

    List<Widget> out = [];
    List<Widget> eRow1 = [];

    for (int i = 1; i < _firstDayOfMonth.weekday; i++) {
      eRow1.add(Expanded(
        child: SizedBox(
          height: _tileSize,
        ),
      ));
    }
    int currentBuildDay = 0;
    for (int i = _firstDayOfMonth.weekday; i < 8; i++) {
      currentBuildDay++;
      DateTime tmp = DateTime(_year, _monthNum, currentBuildDay);
      eRow1.add(
        Expanded(
          child: InkWell(
            child: DayWidget(
              day: tmp,
              tileSize: _tileSize,
              isSelect: (_selectDay != null &&
                  _selectDay.year == tmp.year &&
                  _selectDay.month == tmp.month &&
                  _selectDay.day == tmp.day),
            ),
            onTap: () {
              setState(() {
                if (_selectDay != null &&
                    _selectDay.year == tmp.year &&
                    _selectDay.month == tmp.month &&
                    _selectDay.day == tmp.day) {
                  _selectDay = null;
                  widget.setSelectDay(null);
                  return;
                }
                _selectDay = tmp;
                widget.setSelectDay(tmp);
              });
            },
          ),
        ),
      );
    }

    out.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: eRow1,
    ));

    for (int i = 2; i <= nRow; i++) {
      List<Widget> eRow = [];
      for (int j = 1; j <= 7; j++) {
        currentBuildDay++;
        DateTime tmp = DateTime(_year, _monthNum, currentBuildDay);
        eRow.add(
          (currentBuildDay > _numberOfDayInMonth)
              ? Expanded(
                  child: SizedBox(
                    height: _tileSize,
                  ),
                )
              : Expanded(
                  child: InkWell(
                    child: DayWidget(
                      day: tmp,
                      tileSize: _tileSize,
                      isSelect: (_selectDay != null &&
                          _selectDay.year == tmp.year &&
                          _selectDay.month == tmp.month &&
                          _selectDay.day == tmp.day),
                    ),
                    onTap: () {
                      setState(() {
                        if (_selectDay != null &&
                            _selectDay.year == tmp.year &&
                            _selectDay.month == tmp.month &&
                            _selectDay.day == tmp.day) {
                          _selectDay = null;
                          widget.setSelectDay(null);
                          return;
                        }
                        _selectDay = tmp;
                        widget.setSelectDay(tmp);
                      });
                    },
                  ),
                ),
        );
      }
      out.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: eRow,
      ));
    }

    return out;
  }

  int _monthToInt(String name) {
    int out = -1;
    switch (name) {
      case 'January':
        out = 1;
        break;
      case 'February':
        out = 2;
        break;
      case 'March':
        out = 3;
        break;
      case 'April':
        out = 4;
        break;
      case 'May':
        out = 5;
        break;
      case 'June':
        out = 6;
        break;
      case 'July':
        out = 7;
        break;
      case 'August':
        out = 8;
        break;
      case 'September':
        out = 9;
        break;
      case 'October':
        out = 10;
        break;
      case 'November':
        out = 11;
        break;
      case 'December':
        out = 12;
        break;
      default:
        print('invalid month');
        break;
    }
    return out;
  }

  String _monthToString(int month) {
    String out = '';
    switch (month) {
      case 1:
        out = 'January';
        break;
      case 2:
        out = 'February';
        break;
      case 3:
        out = 'March';
        break;
      case 4:
        out = 'April';
        break;
      case 5:
        out = 'May';
        break;
      case 6:
        out = 'June';
        break;
      case 7:
        out = 'July';
        break;
      case 8:
        out = 'August';
        break;
      case 9:
        out = 'September';
        break;
      case 10:
        out = 'October';
        break;
      case 11:
        out = 'November';
        break;
      case 12:
        out = 'December';
        break;
      default:
        print('invalid month');
        break;
    }
    return out;
  }

  void _nextMonth() {
    setState(() {
      _referenceDay = DateTime(_referenceDay.year, _referenceDay.month + 1, 1);
      _selectDay = null;
      widget.setSelectDay(null);
    });
  }

  void _previewMonth() {
    setState(() {
      _referenceDay = DateTime(_referenceDay.year, _referenceDay.month - 1, 1);
      _selectDay = null;
      widget.setSelectDay(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    _year = _referenceDay.year;
    _monthNum = _referenceDay.month;
    _month = _monthToString(_monthNum);
    _firstDayOfMonth = DateTime(_referenceDay.year, _referenceDay.month, 1);
    _lastDayOfMonth = DateTime(_referenceDay.year, _referenceDay.month + 1, 0);
    _numberOfDayInMonth = _lastDayOfMonth.day;

    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      elevation: 2,
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
            child: Column(
              children: <Widget>[
                SizedBox(height: 15),
                Row(
                  children: <Widget>[
                    InkWell(
                      child: Icon(
                        Icons.arrow_left,
                        size: 30,
                        color: Colors.white,
                      ),
                      onTap: _previewMonth,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DropdownButton<String>(
                              iconEnabledColor: Colors.white,
                              dropdownColor:
                                  Theme.of(context).primaryColorLight,
                              value: _month,
                              items: <String>[
                                'January',
                                'February',
                                'March',
                                'April',
                                'May',
                                'June',
                                'July',
                                'August',
                                'September',
                                'October',
                                'November',
                                'December'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style: TextStyle(
                                        //fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 22,
                                      )),
                                );
                              }).toList(),
                              onChanged: (String newValue) {
                                setState(() {
                                  if (_monthToInt(newValue) ==
                                      _referenceDay.month) return;
                                  _referenceDay = DateTime(_referenceDay.year,
                                      _monthToInt(newValue), 1);
                                  _selectDay = null;
                                  widget.setSelectDay(null);
                                });
                              }),
                          SizedBox(width: 10),
                          DropdownButton<int>(
                              iconEnabledColor: Colors.white,
                              dropdownColor:
                                  Theme.of(context).primaryColorLight,
                              value: _year,
                              items: List<int>.generate(100, (i) => i + 2000)
                                  .map<DropdownMenuItem<int>>((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 18,
                                      )),
                                );
                              }).toList(),
                              onChanged: (int newValue) {
                                if (newValue == _referenceDay.year) return;
                                setState(() {
                                  _referenceDay = DateTime(
                                      newValue, _referenceDay.month, 1);
                                  _selectDay = null;
                                  widget.setSelectDay(null);
                                });
                              }),
                        ],
                      ),
                    ),
                    InkWell(
                      child: Icon(
                        Icons.arrow_right,
                        size: 30,
                        color: Colors.white,
                      ),
                      onTap: _nextMonth,
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ...['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                        .map((e) => _dayTileBuilder(e))
                        .toList(),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                const Divider(
                  height: 0,
                  color: Colors.grey,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                ),
              ],
            ),
          ),

          // TODO: Swipe a droite ou a gauche
          GestureDetector(
            onHorizontalDragEnd: (DragEndDetails details) {
              if (details.primaryVelocity > 0) {
                // User swiped Left
                _previewMonth();
              } else if (details.primaryVelocity < 0) {
                // User swiped Right
                _nextMonth();
              }
            },
            child: Column(
              children: <Widget>[
                ..._daysBuilder(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
