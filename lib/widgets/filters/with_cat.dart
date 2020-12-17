import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_marie/models/category.dart';

import '../../providers/todo_list.dart';

class WithCat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _withCat = Provider.of<TodoList>(context).withCatFilter;
    Category _cat = Provider.of<TodoList>(context, listen: false).catFilter;
    return _cat != null ? SizedBox() : Row(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('with cat.'),
            Checkbox(
              value: _withCat == null ? false : _withCat,
              onChanged: (val) {
                if (val == false) {
                  Provider.of<TodoList>(context, listen: false)
                      .filterwithCat(null);
                  return;
                }
                Provider.of<TodoList>(context, listen: false)
                      .filterwithCat(true);
              },
            ),
          ],
        ),
        Expanded(child: SizedBox(),),
        Row(
          children: <Widget>[
            Text('without cat.'),
            Checkbox(
              value: _withCat == null ? false : !_withCat,
              onChanged: (val) {
                if (val == false) {
                  Provider.of<TodoList>(context, listen: false)
                      .filterwithCat(null);
                  return;
                }
                Provider.of<TodoList>(context, listen: false)
                      .filterwithCat(false);
              },
            ),
          ],
        )
      ],
    );
  }
}