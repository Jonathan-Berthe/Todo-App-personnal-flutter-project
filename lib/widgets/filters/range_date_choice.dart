import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

import 'package:intl/intl.dart';
import '../../providers/todo_list.dart';

class RangeDateChoice extends StatefulWidget {
  RangeDateChoice();

  @override
  _RangeDateChoiceState createState() => _RangeDateChoiceState();
}

class _RangeDateChoiceState extends State<RangeDateChoice> {
  List<DateTime> _selectedDateRange;
  bool _inFuture;

  @override
  void initState() {
    super.initState();
    _selectedDateRange =
        Provider.of<TodoList>(context, listen: false).dateRangeFilter;
  }

  Future<void> _presentDatePicker() async {
    // https://flutterigniter.com/dismiss-keyboard-form-lose-focus/
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    final List<DateTime> picked = await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: new DateTime.now(),
      initialLastDate: (new DateTime.now()).add(new Duration(days: 7)),
      firstDate: new DateTime(2015),
      lastDate: new DateTime(2050),
    );
    if (picked == null) {
      setState(() {
        _selectedDateRange = null;
        _inFuture = null;
      });
    }
    setState(() {
      _selectedDateRange =
          (picked == null || picked.length == 1) ? null : [...picked];
    });
    Provider.of<TodoList>(context, listen: false).filterByDate(
        start: (picked == null || picked.length == 1) ? null : picked[0],
        end: (picked == null || picked.length == 1) ? null : picked[1]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: (_selectedDateRange != null)
                    ? FittedBox(
                        child: Row(
                          children: <Widget>[
                            Text(
                              "${DateFormat.yMd().format(_selectedDateRange[0])} - ${DateFormat.yMd().format(_selectedDateRange[1])}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            InkWell(
                                child: Icon(Icons.settings_backup_restore),
                                onTap: () {
                                  setState(() {
                                    _selectedDateRange = null;
                                    _inFuture = null;
                                  });
                                  Provider.of<TodoList>(context, listen: false)
                                      .filterByDate(); // reset le filtre
                                })
                          ],
                        ),
                      )
                    : Text(
                        "No date range Chosen",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text(
                  "Choose date",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _presentDatePicker,
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('future todo'),
                Checkbox(
                  value: _inFuture == null ? false : _inFuture,
                  onChanged: (val) {
                    if (val == false) {
                      setState(() {
                        _selectedDateRange = null;
                        _inFuture = null;
                      });
                      Provider.of<TodoList>(context, listen: false)
                          .filterByDate();
                      return;
                    }
                    setState(() {
                      _inFuture = true;
                      _selectedDateRange = [DateTime.now(),DateTime.now().add(Duration(days: 100))];
                      Provider.of<TodoList>(context, listen: false)
                          .filterByDate(
                              start: _selectedDateRange[0],
                              end: _selectedDateRange[1]);
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: SizedBox(),
            ),
            Row(
              children: <Widget>[
                Text('past todo'),
                Checkbox(
                  value: _inFuture == null ? false : !_inFuture,
                  onChanged: (val) {
                    if (val == false) {
                      setState(() {
                        _selectedDateRange = null;
                        _inFuture = null;
                      });
                      Provider.of<TodoList>(context, listen: false)
                          .filterByDate();
                      return;
                    }
                    setState(() {
                      _inFuture = false;
                      _selectedDateRange = [DateTime.now().subtract(Duration(days: 100)), DateTime.now()];
                      Provider.of<TodoList>(context, listen: false)
                          .filterByDate(
                              start: _selectedDateRange[0],
                              end: _selectedDateRange[1]);
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}
