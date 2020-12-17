import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/todo_list.dart';

class Done extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _isDoneFilter = Provider.of<TodoList>(context).isDoneFilter;
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('Only done item'),
            Checkbox(
              value: _isDoneFilter == null ? false : _isDoneFilter,
              onChanged: (val) {
                if (val == false) {
                  Provider.of<TodoList>(context, listen: false)
                      .setIsDoneFilter(null);
                  return;
                }
                Provider.of<TodoList>(context, listen: false)
                    .setIsDoneFilter(true);
              },
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text('Only no done item'),
            Checkbox(
              value: _isDoneFilter == null ? false : !_isDoneFilter,
              onChanged: (val) {
                if (val == false) {
                  Provider.of<TodoList>(context, listen: false)
                      .setIsDoneFilter(null);
                  return;
                }
                Provider.of<TodoList>(context, listen: false)
                    .setIsDoneFilter(false);
              },
            ),
          ],
        )
      ],
    );
  }
}
