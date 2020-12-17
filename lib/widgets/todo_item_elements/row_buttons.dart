import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/todo_list.dart';
import '../../providers/notification_provider.dart';
import '../../models/todo_item.dart';

import '../../screens/todo_form_screen.dart';

class RowButton extends StatelessWidget {
  final String id;
  const RowButton({Key key, @required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TodoItem item = Provider.of<TodoList>(context, listen: false).findById(id);
    return Row(
      children: <Widget>[
        // No null seconds => code to see that there is no time selected
        if (item.isInFuture && item.isDone == false && item.deadline.second == 0 ) ...[
          item.withAlarm
              ? InkWell(
                  onTap: () {
                    Function turnOffNotificationById =
                        Provider.of<NotificationProvider>(context,
                                listen: false)
                            .turnOffNotificationById;
                    Provider.of<TodoList>(context, listen: false)
                        .resetAlarm(id, turnOffNotificationById);
                    final snackBar = SnackBar(
                      content: Text('Alarm off'),
                      duration: Duration(seconds: 2),
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                  },
                  child: const Icon(
                    Icons.alarm_on,
                    color: Colors.green,
                    size: 28,
                  ))
              : InkWell(
                  onTap: () {
                    Function scheduleNotification =
                        Provider.of<NotificationProvider>(context,
                                listen: false)
                            .scheduleNotification;
                    Provider.of<TodoList>(context, listen: false)
                        .setAlarm(id, scheduleNotification);
                    final snackBar = SnackBar(
                        content: Text('Alarm on'),
                        duration: Duration(seconds: 2));
                    Scaffold.of(context).showSnackBar(snackBar);
                  },
                  child: const Icon(Icons.alarm_add),
                ),
          const SizedBox(width: 15),
        ],
        InkWell(
          child: Icon(Icons.edit),
          onTap: () {
            Navigator.of(context).pushNamed(
              TodoFormScreen.routeNamed,
              arguments: {'id': id},
            );
          },
        ),
        SizedBox(width: 15),
        InkWell(
          child: Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Are you sure ?'),
                content: const Text('Do you want to remove this Todo item ?'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('No'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Provider.of<TodoList>(context, listen: false).deleteItem(
                          id,
                          turnOffNotificationById:
                              Provider.of<NotificationProvider>(context,
                                      listen: false)
                                  .turnOffNotificationById);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Yes'),
                  )
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
