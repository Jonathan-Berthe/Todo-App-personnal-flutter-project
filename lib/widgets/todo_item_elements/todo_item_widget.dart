import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todo_marie/widgets/task_content.dart/tasks_view_todo_item.dart';
import 'package:todo_marie/widgets/todo_item_elements/place_section.dart';
import 'package:todo_marie/widgets/todo_item_elements/row_buttons.dart';
import 'package:todo_marie/widgets/todo_item_elements/description_section.dart';
import 'package:todo_marie/widgets/todo_item_elements/leading_widget.dart';
import 'package:todo_marie/widgets/todo_item_elements/subtile_widget.dart';

import '../../providers/todo_list.dart';
import '../../providers/category_list.dart';
import '../../providers/notification_provider.dart';

import '../../screens/todo_form_screen.dart';
import '../../screens/todo_item_detail_screen.dart';

import '../../models/todo_item.dart';



class TodoItemWidget extends StatelessWidget {
  final TodoItem item;
  final bool withDateMode;
  final bool isInSelectMode;
  final bool isSelect;
  final Function toSelectMode;
  final Function addIdToSelectedList;
  final Function removeIdInSelectedList;
  final Function changeInExpand;

  const TodoItemWidget({
    this.item,
    this.withDateMode = true,
    this.isInSelectMode = true,
    this.isSelect = false,
    this.toSelectMode,
    this.addIdToSelectedList,
    this.removeIdInSelectedList,
    this.changeInExpand,
  });

  Widget slideRightBackground(BuildContext context) {
    return Container(
      color: Theme.of(context).errorColor,
      child: Icon(
        Icons.delete,
        color: Colors.white,
        size: 40,
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
    );
  }

  Widget slideLeftBackground(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Icon(
        Icons.done,
        color: Colors.white,
        size: 40,
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 20),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
    );
  }

  Widget _drawSubText(
      {String text,
      String subText,
      bool isTitle = false,
      TextStyle style,
      BuildContext context}) {
    // TODO: réussir a surligner le mot si il est en plusieurs fois (idée: faire une récurrence sur le substring restant)
    int tmp = text.indexOf(subText);

    TextStyle tmpTitleStyle = (isTitle && item.isDone)
        ? TextStyle(decoration: TextDecoration.lineThrough)
        : null;

    if (subText == '' || tmp == -1)
      return Text(
        text,
        overflow: TextOverflow.ellipsis,
        //maxLines: 5,
        style: style == null ? tmpTitleStyle : style,
      );

    return Wrap(
      children: <Widget>[
        if (tmp > 0)
          Text(
            text.substring(0, tmp),
            overflow: TextOverflow.ellipsis,
            //maxLines: 5,
            style: style == null ? tmpTitleStyle : style,
          ),
        Container(
          color: Theme.of(context).accentColor,
          child: Text(
            subText,
            overflow: TextOverflow.ellipsis,
            //maxLines: 5,
            style: style == null ? tmpTitleStyle : style,
          ),
        ),
        if (tmp < text.length - subText.length)
          Text(
            text.substring(tmp + subText.length),
            overflow: TextOverflow.ellipsis,
            //maxLines: 5,
            style: style == null ? tmpTitleStyle : style,
          ),
      ],
    );
  }

  void _changeOccurInDoneTask({bool value, String taskId, BuildContext context}) {
    Provider.of<TodoList>(context, listen: false)
        .setTaskDone(item.id, taskId, value);
  }

  void _setDoneItem({String id, bool value, BuildContext ctx}) {
    Provider.of<TodoList>(ctx, listen: false).setDoneItem(item.id, value);

    // Si c'est done, on reset l'éventuelle alarme
    if (value &&
        Provider.of<TodoList>(ctx, listen: false).findById(id).withAlarm) {
      Function turnOffNotificationById =
          Provider.of<NotificationProvider>(ctx, listen: false)
              .turnOffNotificationById;
      Provider.of<TodoList>(ctx, listen: false)
          .resetAlarm(id, turnOffNotificationById);
    }
  }

  @override
  Widget build(BuildContext context) {
    String _searchWord = Provider.of<TodoList>(context).wordFilter;

    return InkWell(
      onDoubleTap: isInSelectMode
          ? null
          : () {
              Navigator.of(context).pushNamed(
                TodoFormScreen.routeNamed,
                arguments: {'id': item.id},
              );
            },
      onTap: isInSelectMode
          ? () {
              if (!isSelect) addIdToSelectedList(item.id);
              if (isSelect) removeIdInSelectedList(item.id);
            }
          : () {
              Navigator.of(context).pushNamed(
                TodoItemDetailScreen.routeNamed,
                arguments: item.id,
              );
            },
      onLongPress: () {
        addIdToSelectedList(item.id);
        toSelectMode();
      },
      child: Dismissible(
        key: ValueKey(item.id),
        background: slideLeftBackground(context),
        secondaryBackground: slideRightBackground(context),
        confirmDismiss: (direction) {
          if (direction == DismissDirection.endToStart) {
            return showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Are you sure ?'),
                content: Text('Do you want to delete this todo item ?'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                    child: Text('No'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Provider.of<TodoList>(context, listen: false).deleteItem(
                          item.id,
                          turnOffNotificationById:
                              Provider.of<NotificationProvider>(context,
                                      listen: false)
                                  .turnOffNotificationById);
                      Navigator.of(ctx).pop(true);
                    },
                    child: Text('Yes'),
                  )
                ],
              ),
            );
          } else {
            _setDoneItem(id: item.id, ctx: context, value: true);
          }
        },
        onDismissed: (direction) {},
        child: Card(
          color: (isSelect && isInSelectMode)
              ? Colors.grey[300]
              : (item.isDone ? Colors.lightGreen[50] : Colors.white),
          key: ValueKey(item.id),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Checkbox(
                      activeColor: Colors.green,
                      value: item.isDone,
                      onChanged: (bool value) {
                        _setDoneItem(ctx: context, value: value, id: item.id);
                      },
                    ),
                    Text('Checked !',
                        style: TextStyle(
                          color: item.isDone ? Colors.green : Colors.grey,
                          fontWeight:
                              item.isDone ? FontWeight.bold : FontWeight.normal,
                        )),
                    Expanded(
                      child: Container(),
                    ),
                    if (isInSelectMode)
                      isSelect
                          ? Icon(
                              Icons.radio_button_checked,
                              color: Colors.blue,
                              size: 30,
                            )
                          : Icon(
                              Icons.radio_button_unchecked,
                              color: Colors.grey,
                              size: 30,
                            ),
                    if (!isInSelectMode) RowButton(id: item.id),
                    SizedBox(width: 10),
                  ],
                ),
                ListTile(
                  leading: LeadingWidget(
                    cat: Provider.of<CategoryList>(context, listen: false)
                        .findByIdKey(item.idCategory),
                    prior: item.priority.toString(),
                    numberOfImages:
                        (item.imagesPath != null && item.imagesPath.length > 0)
                            ? item.imagesPath.length
                            : 0,
                    numberOfRecord:
                        (item.records != null && item.records.length > 0)
                            ? item.records.length
                            : 0,
                  ),
                  title: _drawSubText(
                      text: '${item.title}',
                      subText: _searchWord,
                      isTitle: true,
                      context: context),
                  subtitle: (item.deadline == null) ||
                          (item.deadline.hour == 0 &&
                              item.deadline.minute == 0 &&
                              !withDateMode)
                      ? null
                      : SubtileWidget(
                          withDateMode: withDateMode,
                          deadline: item.deadline,
                        ),
                ),
                if (item.description != null && item.description.length > 0)
                  DescriptionSection(
                    description: item.description,
                    drawSubText: (
                            {String text,
                            String subText,
                            bool isTitle = false,
                            TextStyle style}) =>
                        _drawSubText(
                      context: context,
                      text: text,
                      subText: subText,
                      isTitle: isTitle,
                      style: style,
                    ),
                    searchWord: _searchWord,
                  ),
                if (item.place != null)
                  PlaceSection(
                    place: item.place,
                  ),
                TasksViewTodoItem(
                  todoId: item.id,
                  drawSubText: (
                          {String text,
                          String subText,
                          bool isTitle = false,
                          TextStyle style}) =>
                      _drawSubText(
                    context: context,
                    text: text,
                    subText: subText,
                    isTitle: isTitle,
                    style: style,
                  ),
                  changeOccur: ({bool value, String taskId}) => _changeOccurInDoneTask(context: context, taskId: taskId, value: value),
                  isDone: item.isDone,
                  changeInExpand: (changeInExpand != null && !withDateMode) ? changeInExpand : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
