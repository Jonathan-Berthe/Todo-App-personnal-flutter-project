import 'package:flutter/material.dart';

import 'package:provider/provider.dart';


import 'package:todo_marie/widgets/todo_item_elements/leading_widget.dart';
import 'package:todo_marie/widgets/todo_item_elements/subtile_widget.dart';

import '../../providers/todo_list.dart';
import '../../providers/category_list.dart';
import '../../providers/notification_provider.dart';
import '../../models/todo_item.dart';

class HeadSection extends StatefulWidget {
  final TodoItem item;
  final Function drawSubText;
  final bool initIsDone;

  HeadSection({
    Key key,
    this.item,
    this.drawSubText,
    this.initIsDone,
  }) : super(key: key);

  @override
  _HeadSectionState createState() => _HeadSectionState();
}

class _HeadSectionState extends State<HeadSection> {
  bool _isDone;

  @override
  void initState() {
    _isDone = widget.initIsDone;
    super.initState();
  }

  void _setDoneItem({String id, bool value, BuildContext ctx}) {
    Provider.of<TodoList>(ctx, listen: false)
        .setDoneItem(widget.item.id, value);

    // Si c'est done, on reset l'éventuelle alarme
    if (value &&
        Provider.of<TodoList>(ctx, listen: false).findById(id).withAlarm) {
      Function turnOffNotificationById =
          Provider.of<NotificationProvider>(ctx, listen: false)
              .turnOffNotificationById;
      Provider.of<TodoList>(ctx, listen: false)
          .resetAlarm(id, turnOffNotificationById);
    }
    if (value != _isDone)
      setState(() {
        _isDone = value;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(
        children: <Widget>[
          Checkbox(
            activeColor: Colors.green,
            value: _isDone,
            onChanged: (bool value) {
              _setDoneItem(ctx: context, value: value, id: widget.item.id);
            },
          ),
          Text('Checked !',
              style: TextStyle(
                color: _isDone ? Colors.green : Colors.grey,
                fontWeight: _isDone ? FontWeight.bold : FontWeight.normal,
              )),
          Expanded(
            child: Container(),
          ),
          Row(
            children: <Widget>[
              if (widget.item.isInFuture && !_isDone) ...[
                widget.item.withAlarm
                    ? InkWell(
                        onTap: () {
                          Function turnOffNotificationById =
                              Provider.of<NotificationProvider>(context,
                                      listen: false)
                                  .turnOffNotificationById;
                          Provider.of<TodoList>(context, listen: false)
                              .resetAlarm(
                                  widget.item.id, turnOffNotificationById);
                          final snackBar = SnackBar(
                            content: Text('Alarm off'),
                            duration: Duration(seconds: 2),
                          );
                          Scaffold.of(context).showSnackBar(snackBar);
                        },
                        child: Icon(
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
                              .setAlarm(widget.item.id, scheduleNotification);
                          final snackBar = SnackBar(
                              content: Text('Alarm on'),
                              duration: Duration(seconds: 2));
                          Scaffold.of(context).showSnackBar(snackBar);
                        },
                        child: Icon(Icons.alarm_add),
                      ),
                SizedBox(width: 15),
              ],
            ],
          ),
          SizedBox(width: 10),
        ],
      ),
      ListTile(
        leading: LeadingWidget(
          cat: Provider.of<CategoryList>(context, listen: false)
              .findByIdKey(widget.item.idCategory),
          prior: widget.item.priority.toString(),
          numberOfImages: (widget.item.imagesPath != null &&
                  widget.item.imagesPath.length > 0)
              ? widget.item.imagesPath.length
              : 0,
          numberOfRecord:
              (widget.item.records != null && widget.item.records.length > 0)
                  ? widget.item.records.length
                  : 0,
        ),
        title: widget.drawSubText(
            text: '${widget.item.title}',
            subText: '',
            isTitle: true,
            context: context),
        subtitle: (widget.item.deadline == null)
            ? null
            : SubtileWidget(
                withDateMode: true,
                deadline: widget.item.deadline,
              ),
      ),
    ]);
  }
}
