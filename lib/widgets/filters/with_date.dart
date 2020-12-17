import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/todo_list.dart';

class WithDate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _withDate = Provider.of<TodoList>(context).withDateFilter;
    List<DateTime> _dateRange = Provider.of<TodoList>(context, listen: false).dateRangeFilter;
    return _dateRange != null ? SizedBox() : Row(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('with date'),
            Checkbox(
              value: _withDate == null ? false : _withDate,
              onChanged: (val) {
                if (val == false) {
                  Provider.of<TodoList>(context, listen: false)
                      .filterwithDate(null);
                  return;
                }
                Provider.of<TodoList>(context, listen: false)
                      .filterwithDate(true);
              },
            ),
          ],
        ),
        Expanded(child: SizedBox(),),
        Row(
          children: <Widget>[
            Text('No date'),
            Checkbox(
              value: _withDate == null ? false : !_withDate,
              onChanged: (val) {
                if (val == false) {
                  Provider.of<TodoList>(context, listen: false)
                      .filterwithDate(null);
                  return;
                }
                Provider.of<TodoList>(context, listen: false)
                      .filterwithDate(false);
              },
            ),
          ],
        )
      ],
    );
  }
}