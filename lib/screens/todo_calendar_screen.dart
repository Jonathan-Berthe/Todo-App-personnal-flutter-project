import 'package:intl/intl.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_marie/widgets/overview_screen/search_word_widget.dart';
import 'package:todo_marie/widgets/overview_screen/select_mode_widget.dart';

import '../widgets/calendar/calendar.dart';
import '../widgets/calendar/todo_day_list.dart';

import '../widgets/todo_item_elements/todo_item_widget.dart';
import '../providers/todo_list.dart';

import '../helpers/painters.dart';
import '../models/todo_item.dart';
import 'todo_form_screen.dart';

class TodoCalendarScreen extends StatefulWidget {
  final String notificationId;
  const TodoCalendarScreen({this.notificationId});
  @override
  _TodoCalendarScreenState createState() => _TodoCalendarScreenState();
}

class _TodoCalendarScreenState extends State<TodoCalendarScreen> {
  DateTime _selectDay;
  var _formatter = DateFormat.yMMMMd('en_US');
  DateTime _today = DateTime.now();
  String _numberOfDays = '7';

  bool _isInSelectMode = false;
  List<String> _listOfSelectedId = [];

  double _paddingCal = 15;

  void _selectAll() {
    var _tmp1 = Provider.of<TodoList>(context, listen: false)
        .filteredItems
        .map((e) => e.id)
        .toList();
    var _tmp2 = Provider.of<TodoList>(context, listen: false)
        .filteredItemsWithoutDate
        .map((e) => e.id)
        .toList();
    setState(() {
      _listOfSelectedId = [..._tmp1, ..._tmp2];
    });
  }

  void _toSelectMode() {
    setState(() {
      _isInSelectMode = true;
    });
  }

  void _quitSelectMode() {
    setState(() {
      _listOfSelectedId = [];
      _isInSelectMode = false;
    });
  }

  void _addIdToSelectedList(String id) {
    setState(() {
      _listOfSelectedId.add(id);
    });
  }

  void _removeIdInSelectedList(String id) {
    _listOfSelectedId.removeWhere((item) => item == id);
    if (_listOfSelectedId.length == 0) _quitSelectMode();
    setState(() {});
  }

  void _updateListOfSelectedId() {
    var _tmp1 = _selectDay == null
        ? []
        : Provider.of<TodoList>(context)
            .todosOfADate(_selectDay)
            .map((e) => e.id)
            .toList();
    var _tmp2 = Provider.of<TodoList>(context)
        .filteredItemsWithoutDate
        .map((e) => e.id)
        .toList();
    int x = _numberOfDays == '0' ? 0 : int.parse(_numberOfDays);
    Map<int, List<TodoItem>> _tmp3 =
        Provider.of<TodoList>(context).todosFromADate(x, DateTime.now());

    _listOfSelectedId.removeWhere((element) {
      bool c = true;
      _tmp3.forEach((key, value) {
        c = c && value.map((e) => e.id).toList().contains(element) == false;
      });

      if (c == false) return false;

      return (_tmp1.contains(element) == false &&
          _tmp2.contains(element) == false);
    });
  }

  void _setSelectDay(DateTime newDate) {
    setState(() {
      _selectDay = newDate;
    });
  }

  List<Widget> _nextXDaysBuilder({int x}) {
    Map<int, List<TodoItem>> todosData =
        Provider.of<TodoList>(context).todosFromADate(x, DateTime.now());

    if (todosData == null) return [Text('Nothing to show')];
    List<Widget> out = [];
    bool nothingToShow = true;
    todosData.forEach((key, value) {
      if (value.length == 0) {
        return;
      }
      nothingToShow = false;
      out.add(Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
            child: (key == 0)
                ? Text(
                    'Today ( ${_formatter.format(_today)} )',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  )
                : (key > 1)
                    ? Text(
                        'In $key days ( ${_formatter.format(_today.add(Duration(days: key)))} ) ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      )
                    : Text(
                        'Tommorow ( ${_formatter.format(_today.add(Duration(days: 1)))} )',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
          ),
          const SizedBox(height: 15),
          RaisedButton.icon(
            label: const Text("Add todo"),
            icon: const Icon(Icons.add),
            color: Theme.of(context).accentColor,
            onPressed: () {
              DateTime initDay = _today.add(Duration(days: key));
              Navigator.of(context).pushNamed(
                TodoFormScreen.routeNamed,
                arguments: {
                  'initDate': DateTime(initDay.year, initDay.month, initDay.day)
                },
              );
            },
          ),
          //SizedBox(height: 15),
        ],
      ));

      out.add(SizedBox(height: 15));
      out.add(
        (value != null && value.length > 0)
            ? TodoDayList(
                listOfTodo: value,
                addIdToSelectedList: _addIdToSelectedList,
                toSelectMode: _toSelectMode,
                isInSelectMode: _isInSelectMode,
                removeIdInSelectedList: _removeIdInSelectedList,
                listOfSelectedId: _listOfSelectedId,
              )
            : Center(
                child: Text('Nothing to  do, go take a rest ! ',
                    style: TextStyle(
                      fontSize: 16,
                    )),
              ),
      );
      out.add(SizedBox(height: 15));
    });
    if (nothingToShow) {
      out.add(Center(
        child: Text(
            'Nothing to  do the next $x day${x < 2 ? '' : 's'}, go take a rest ! ',
            style: TextStyle(
              fontSize: 16,
            )),
      ));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    _updateListOfSelectedId();

    int l = Provider.of<TodoList>(context).filteredItemsWithoutDate.length;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const SearchWordWidget(width: 300),
            const Expanded(child: const SizedBox()),
          ],
        ),
        if (_isInSelectMode)
          SelectModeWidget(
            listOfSelectedId: _listOfSelectedId,
            quitSelectMode: _quitSelectMode,
            selectAll: _selectAll,
          ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: _paddingCal, vertical: 10),
                  child: Calendar(
                    setSelectDay: _setSelectDay,
                    horizontalSize:
                        MediaQuery.of(context).size.width - 2 * _paddingCal,
                  ),
                ),
                const SizedBox(height: 15),
                if (_selectDay != null) ...[
                  Row(
                    children: <Widget>[
                      const Expanded(child: const SizedBox()),
                      CustomPaint(
                        painter: TitleCardPainter(
                          primaryColor: Theme.of(context).primaryColorLight,
                          secondaryColor: Theme.of(context).primaryColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 25.0),
                          child: Text(
                            _formatter.format(_selectDay),
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const Expanded(child: const SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 15),
                  RaisedButton.icon(
                    label: const Text("Add todo"),
                    icon: const Icon(Icons.add),
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        TodoFormScreen.routeNamed,
                        arguments: {'initDate': _selectDay},
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  (Provider.of<TodoList>(context)
                              .todosOfADate(_selectDay)
                              .length >
                          0)
                      ? TodoDayList(
                          listOfTodo: Provider.of<TodoList>(context)
                              .todosOfADate(_selectDay),
                          addIdToSelectedList: _addIdToSelectedList,
                          toSelectMode: _toSelectMode,
                          isInSelectMode: _isInSelectMode,
                          removeIdInSelectedList: _removeIdInSelectedList,
                          listOfSelectedId: _listOfSelectedId,
                        )
                      : const Center(
                          child: const Text('Nothing to  do, go take a rest ! ',
                              style: const TextStyle(
                                fontSize: 16,
                              )),
                        ),
                  const SizedBox(height: 15),
                ],
                Row(
                  children: <Widget>[
                    const Expanded(child: const SizedBox()),
                    Container(
                      child: CustomPaint(
                        painter: TitleCardPainter(
                          primaryColor: Theme.of(context).primaryColorLight,
                          secondaryColor: Theme.of(context).primaryColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                'Next',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              DropdownButton<String>(
                                  iconEnabledColor: Colors.white,
                                  dropdownColor:
                                      Theme.of(context).primaryColorLight,
                                  value: _numberOfDays,
                                  items: List<String>.generate(
                                          30, (i) => (i).toString())
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value.toString(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white)),
                                    );
                                  }).toList(),
                                  onChanged: (String newValue) {
                                    if (newValue == _numberOfDays) return;
                                    setState(() {
                                      _numberOfDays = newValue;
                                    });
                                  }),
                              const SizedBox(width: 10),
                              Text(
                                'day${int.parse(_numberOfDays) > 1 ? 's' : ''} ${_numberOfDays == '0' ? '(Today)' : ''}',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: const SizedBox()),
                  ],
                ),
                SizedBox(height: 15),
                ..._nextXDaysBuilder(
                    x: _numberOfDays == '0' ? 0 : int.parse(_numberOfDays)),
                if (l > 0) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Divider(
                      color: Theme.of(context).accentColor,
                      thickness: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomPaint(
                    painter: TitleCardPainter(
                      primaryColor: Theme.of(context).primaryColorLight,
                      secondaryColor: Theme.of(context).primaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 25.0),
                      child: Text(
                        'No deadline',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Column(
                    children: Provider.of<TodoList>(context)
                        .filteredItemsWithoutDate
                        .map((e) => TodoItemWidget(
                            addIdToSelectedList: _addIdToSelectedList,
                            toSelectMode: _toSelectMode,
                            isInSelectMode: _isInSelectMode,
                            removeIdInSelectedList: _removeIdInSelectedList,
                            isSelect: (_listOfSelectedId == [] ||
                                    _isInSelectMode == false)
                                ? false
                                : _listOfSelectedId.contains(
                                    e.id,
                                  ),
                            item: e))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 80)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
