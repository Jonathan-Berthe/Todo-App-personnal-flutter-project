
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_marie/widgets/filters/done.dart';
import 'package:todo_marie/widgets/filters/range_date_choice.dart';
import 'package:todo_marie/widgets/filters/slider_widget.dart';
import 'package:todo_marie/widgets/filters/with_cat.dart';
import 'package:todo_marie/widgets/filters/with_date.dart';
import '../../providers/todo_list.dart';
import '../../models/category.dart';

import '../todo_form_screen/category_choice.dart';

class FilterDialog extends StatelessWidget {
  final bool calendarView;
  FilterDialog(this.calendarView, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Row(
        children: <Widget>[
          InkWell(
            child: Icon(Icons.arrow_back),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(
            width: 15,
          ),
          const Text('Parameters'),
        ],
      ),
      children: <Widget>[
        /* SimpleDialogOption(
          child: SortWidget(),
        ), */
        SimpleDialogOption(
          child: Done(),
        ),
        SimpleDialogOption(
          child: Column(
            children: <Widget>[
              Text(
                'Set a category filter:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              CategoryChoice(
                  Provider.of<TodoList>(context, listen: false).catFilter,
                  (Category cat) {
                // Delayed: permet d'éviter une erreur ou le setState du widget CategoryChoice est appelé en meme temps que le build du notifyListener
                Future.delayed(Duration.zero, () async {
                  Provider.of<TodoList>(context, listen: false)
                      .filterByCategory(newCat: cat);
                });
                return;
              }),
              WithCat(),
            ],
          ),
        ),
        SimpleDialogOption(
          child: Column(
            children: <Widget>[
              Text(
                'Set a range priority filter:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SliderWidget(),
            ],
          ),
        ),
        if (!calendarView) ...[
          SimpleDialogOption(
            child: Column(
              children: <Widget>[
                Text(
                  'Set a date filter:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                RangeDateChoice(),
                WithDate(),
              ],
            ),
          ),
        ]
      ],
    );
  }
}
