import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_marie/providers/todo_list.dart';
import 'package:todo_marie/widgets/todo_detail_screen/todo_item_detail_screen_content.dart';

import 'todo_form_screen.dart';

import '../widgets/reutilisable_widgets/delete_button.dart';
import '../providers/notification_provider.dart';

class TodoItemDetailScreen extends StatelessWidget {
  static const routeNamed = '/todo_item_detail';

  @override
  Widget build(BuildContext context) {
    String itemId = ModalRoute.of(context).settings.arguments as String;
    var todoListProv = Provider.of<TodoList>(context);
    return Scaffold(
      appBar: AppBar(
        title: todoListProv.findById(itemId) == null
            ? Text(' ')
            : Text(todoListProv.findById(itemId).title),
        actions: <Widget>[
          DeleteButton(
            ifDelete: () {
              Provider.of<TodoList>(context, listen: false)
                  .deleteItem(itemId, turnOffNotificationById: Provider.of<NotificationProvider>(context,
                                listen: false)
                            .turnOffNotificationById);
            },
            recursivePop: true,
            objectToDelete: 'Todo item',
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(
                TodoFormScreen.routeNamed,
                arguments: {'id' : itemId},
              );
            },
          )
        ],
      ),
      body: TodoItemScreenContent(
        item: todoListProv.findById(itemId),
      ),
    );
  }
}
