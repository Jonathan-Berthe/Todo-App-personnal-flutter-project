import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todo_marie/models/task.dart';
import 'package:todo_marie/widgets/task_content.dart/scroll_tasks.dart';
import 'package:todo_marie/widgets/task_content.dart/task_widget.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../providers/todo_list.dart';

class TasksViewTodoItem extends StatefulWidget {
  final String todoId;

  final Function changeOccur;
  final Function drawSubText;

  final bool isDone;

  final bool expandMode;

  final Function changeInExpand;

  TasksViewTodoItem({
    Key key,
    this.todoId,
    this.changeOccur,
    this.drawSubText,
    this.isDone = false,
    this.expandMode = true,
    this.changeInExpand,
  }) : super(key: key);

  @override
  _TasksViewTodoItemState createState() => _TasksViewTodoItemState();
}

class _TasksViewTodoItemState extends State<TasksViewTodoItem> {
  double _scrollSize;
  ScrollController _scrollController = ScrollController();
  bool _isExpand = true;
  List<Task> _listOfTasks;
  double _maxHeightForScroll = 350;
  bool _isInit = true;

  bool _isAddingTask = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      _scrollSize = Provider.of<TodoList>(context, listen: false)
                  .findById(widget.todoId)
                  .tasks ==
              null
          ? 0
          : 70.0 *
              Provider.of<TodoList>(context, listen: false)
                  .findById(widget.todoId)
                  .tasks
                  .length;

      _isExpand = widget.expandMode
          ? Provider.of<TodoList>(context, listen: false)
              .findById(widget.todoId)
              .areTasksExpand
          : true;

      // Subscribe
      KeyboardVisibility.onChange.listen((bool visible) {
        if (!visible && !_isAddingTask) {
          if (_listOfTasks.length > 0 && _listOfTasks.last.content == '') {
            _deletingTask(id: _listOfTasks.last.id, isEmpty: true);
          }

          _unFocus(list: true);

        }
      });
    }
    _isInit = false;
  }

  void _onReorder(int oldIndex, int newIndex) {
    Provider.of<TodoList>(context, listen: false)
        .moveATask(widget.todoId, oldIndex, newIndex);
  }

  void _setScrollSize(double size) {
    setState(() {
      _scrollSize = size;
    });
  }

  void _unFocus({bool list = false}) {
    if (context == null) return;
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void _deletingTask({String id, bool isEmpty = false}) {
    Provider.of<TodoList>(context, listen: false)
        .deleteATask(widget.todoId, id);
  }

  Future<void> _addATask() async {
    if (_isExpand == false && widget.expandMode) {
      Provider.of<TodoList>(context, listen: false)
          .toggleTasksExpand(widget.todoId);
      _isExpand = true;
    }

    setState(() {
      _scrollSize += 70;
      _isAddingTask = true;
    });

    _unFocus();

    Task item = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString().replaceAll(' ', ''),
    );

    /* Provider.of<TodoList>(context, listen: false)
        .addATask(widget.todoId, item, null); */

    bool test = await Future.delayed(Duration(milliseconds: 500), () {
      bool out = true;
      if (_listOfTasks.length > 0 && _listOfTasks.last.content == '') {
        _deletingTask(id: _listOfTasks.last.id, isEmpty: true);
        out = false;
      }

      setState(() {
        _isAddingTask = false;
      });

      return out;
    });

    if (!test)
      setState(() {
        _scrollSize -= 70;
      });

    Provider.of<TodoList>(context, listen: false)
        .addATask(widget.todoId, item, null);

    Future.delayed(Duration(milliseconds: 300), () {
      if (_scrollController.hasClients)
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _toggleExpand() {
    if (_isExpand == false) {
      _scrollSize = _listOfTasks == null ? 0 : 70.0 * _listOfTasks.length;
    }
    setState(() {
      _isExpand = !_isExpand;
    });
    Provider.of<TodoList>(context, listen: false)
        .toggleTasksExpand(widget.todoId);
    if (widget.changeInExpand != null) widget.changeInExpand();
  }

  @override
  Widget build(BuildContext context) {
    _listOfTasks = Provider.of<TodoList>(context).findById(widget.todoId).tasks;
    List<TaskWidget> _listOfTaskWidg = _listOfTasks.map((e) {
      return TaskWidget(
        item: e,
        deletingTask: _deletingTask,
        key: ValueKey(e.id + 'false'),
        changeOccur: widget.changeOccur,
        drawSubText: widget.drawSubText,
        saveInDB: () {
          Provider.of<TodoList>(context, listen: false)
              .updateInDb(widget.todoId);
        },
      );
    }).toList();

    return Column(
      children: <Widget>[
        if (_listOfTaskWidg.length == 0)
          Row(
            children: <Widget>[
              Text(
                'No task to show',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              Expanded(
                child: SizedBox(),
              ),
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text(
                  "Add a task",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _addATask,
              ),
            ],
          ),
        if (_listOfTaskWidg.length > 0)
          Row(
            children: <Widget>[
              if (widget.expandMode) ...[
                Text(
                  '${_listOfTasks.length} tasks in this todo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  child: !_isExpand
                      ? Icon(Icons.expand_more)
                      : Icon(Icons.expand_less),
                  onTap: _toggleExpand,
                ),
              ],
            ],
          ),
        if (_listOfTasks != null && _listOfTasks.length > 0 && _isExpand)
          Container(
            height: min(_scrollSize + 80.0, _maxHeightForScroll + 80),
            child: Card(
              elevation: 5,
              color: (widget.isDone) ? Colors.lightGreen[50] : null,
              margin: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  ScrollTasks(
                    listOfTaskWidg: _listOfTaskWidg,
                    onReorder: _onReorder,
                    setSize: _setScrollSize,
                    scrollController: _scrollController,
                    maxHeight: _maxHeightForScroll,
                  ),
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.add_circle),
                        onPressed: _addATask,
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
