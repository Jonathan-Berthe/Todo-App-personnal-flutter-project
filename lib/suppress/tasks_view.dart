/* import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:provider/provider.dart';

import 'package:todo_marie/models/task.dart';
import 'package:todo_marie/widgets/task_content.dart/scroll_tasks.dart';
import 'package:todo_marie/widgets/task_content.dart/task_widget.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../providers/todo_list.dart';

class TasksView extends StatefulWidget {
  final List<Task> listOfTask;
  final Function addATask;
  final Function deletingTask;
  final String todoId;
  final bool isInFormMode;
  final Function changeOccur;
  final Function drawSubText;
  final bool isDone;

  TasksView({
    Key key,
    @required this.listOfTask,
    @required this.addATask,
    @required this.todoId,
    @required this.deletingTask,
    @required this.isInFormMode,
    this.changeOccur,
    this.drawSubText,
    this.isDone = false,
  }) : super(key: key);

  @override
  _TasksViewState createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  double _scrollSize;
  ScrollController _scrollController = ScrollController();
  bool _isExpand = true;
  List<TaskWidget> _listOfTaskWidg;
  double _maxHeightForScroll = 350;
  bool _isInit = true;

  bool _isAddingTask = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      _scrollSize =
          widget.listOfTask == null ? 0 : 70.0 * widget.listOfTask.length;

      if (!widget.isInFormMode) {
        _isExpand = Provider.of<TodoList>(context, listen: false)
            .findById(widget.todoId)
            .areTasksExpand;
      }

    }
    _isInit = false;
  }

  void _onReorder(int oldIndex, int newIndex) {
    final Task item = widget.listOfTask.removeAt(oldIndex);
    setState(() {
      widget.listOfTask.insert(newIndex, item);
    });
    if (!widget.isInFormMode) {
      // On modifie directement aussi dans le provider

      Provider.of<TodoList>(context, listen: false)
          .moveATask(widget.todoId, oldIndex, newIndex);
    } else {
      widget.changeOccur();
    }
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


  Future<void> _addATask() async {
    if (!widget.isInFormMode && _isExpand == false) {
      Provider.of<TodoList>(context, listen: false)
          .toggleTasksExpand(widget.todoId);
      _isExpand = true;
    }

    setState(() {
      _scrollSize += 70;
    });

    bool test = await widget.addATask(Task(
      id: DateTime.now().millisecondsSinceEpoch.toString().replaceAll(' ', ''),
    ));

    if (!test)
      setState(() {
        _scrollSize -= 70;
      });

    Future.delayed(Duration(milliseconds: 300), () {
      if (_scrollController.hasClients)
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _toggleExpand() {
    if (_isExpand == false) {
      _scrollSize =
          widget.listOfTask == null ? 0 : 70.0 * widget.listOfTask.length;
    }
    setState(() {
      _isExpand = !_isExpand;
    });
    Provider.of<TodoList>(context, listen: false)
        .toggleTasksExpand(widget.todoId);
  }

  @override
  Widget build(BuildContext context) {
    _listOfTaskWidg = widget.listOfTask.map((e) {
      return TaskWidget(
        item: e,
        deletingTask: widget.deletingTask,
        key: ValueKey(e.id + widget.isInFormMode.toString()),
        changeOccur: widget.changeOccur,
        drawSubText: widget.drawSubText,
      );
    }).toList();

    return Column(
      children: <Widget>[
        if (widget.isInFormMode)
          Container(
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'List of tasks',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  child: Text(
                    "Add task",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _addATask,
                ),
              ],
            ),
          ),
        if (!widget.isInFormMode && _listOfTaskWidg.length == 0)
          Row(
            children: <Widget>[
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
              Expanded(child: SizedBox()),
            ],
          ),
        if (!widget.isInFormMode && _listOfTaskWidg.length > 0)
          Row(
            children: <Widget>[
              Text(
                '${widget.listOfTask.length} tasks in this todo',
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
          ),
        if (widget.listOfTask != null &&
            widget.listOfTask.length > 0 &&
            _isExpand)
          Container(
            height: min(_scrollSize + 80.0, _maxHeightForScroll + 80),
            child: Card(
              elevation: 5,
              color: (!widget.isInFormMode && widget.isDone)
                  ? Colors.lightGreen[50]
                  : null,
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
 */