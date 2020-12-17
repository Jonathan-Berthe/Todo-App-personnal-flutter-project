import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../reutilisable_widgets/delete_button.dart';
import '../../providers/todo_list.dart';
import '../../providers/notification_provider.dart';

class SelectModeWidget extends StatelessWidget {
  final Function quitSelectMode;
  final Function selectAll;
  final List<String> listOfSelectedId;
  const SelectModeWidget(
      {this.listOfSelectedId, this.quitSelectMode, this.selectAll, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            Text('Quit select mode'),
            SizedBox(
              width: 3,
            ),
            IconButton(icon: Icon(Icons.clear), onPressed: quitSelectMode),
            Expanded(child: Container()),
            if (listOfSelectedId != null && listOfSelectedId.length > 0) ...[
              Text(
                '(${listOfSelectedId.length})',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 3),
              DeleteButton(
                ifDelete: () {
                  listOfSelectedId.forEach((id) {
                    Provider.of<TodoList>(context, listen: false).deleteItem(id,
                        turnOffNotificationById:
                            Provider.of<NotificationProvider>(context,
                                    listen: false)
                                .turnOffNotificationById);
                    quitSelectMode();
                  });
                },
                color: Colors.red,
              ),
              SizedBox(width: 3),
              IconButton(
                icon: Icon(Icons.done_all),
                onPressed: () {
                  listOfSelectedId.forEach((id) {
                    Provider.of<TodoList>(context, listen: false)
                        .setDoneItem(id, true);
                  });
                },
                color: Colors.green,
              ),
              SizedBox(width: 3),
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  listOfSelectedId.forEach((id) {
                    Provider.of<TodoList>(context, listen: false)
                        .setDoneItem(id, false);
                  });
                },
                color: Colors.red,
              ),
              Expanded(child: Container()),
            ],
          ],
        ),
        Row(
          children: <Widget>[
            FlatButton(
              textColor: Theme.of(context).primaryColor,
              onPressed: selectAll,
              child: Text(
                'Select all',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
