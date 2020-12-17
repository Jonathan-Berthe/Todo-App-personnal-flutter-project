import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todo_marie/models/task.dart';
import 'package:todo_marie/widgets/task_content.dart/scroll_tasks.dart';
import 'package:todo_marie/widgets/task_content.dart/task_widget.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../providers/todo_list.dart';

class TasksViewForm extends StatefulWidget {
  final List<Task> listOfTask;
  final Function addATask;
  final Function deletingTask;
  final String todoId;
  final bool isInFormMode;
  final Function changeOccur;
  final Function drawSubText;
  final Function onReorder;
  final bool isDone;

  const TasksViewForm({
    Key key,
    @required this.listOfTask,
    @required this.addATask,
    @required this.todoId,
    @required this.deletingTask,
    @required this.isInFormMode,
    this.changeOccur,
    this.drawSubText,
    this.onReorder,
    this.isDone = false,
  }) : super(key: key);

  @override
  _TasksViewFormState createState() => _TasksViewFormState();
}

class _TasksViewFormState extends State<TasksViewForm> {
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
      _listOfTasks = [...widget.listOfTask]; 
      
      _scrollSize =
          widget.listOfTask == null ? 0 : 70.0 * widget.listOfTask.length;

      if (!widget.isInFormMode) {
        _isExpand = Provider.of<TodoList>(context, listen: false)
            .findById(widget.todoId)
            .areTasksExpand;
      }

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
    setState(() {
      final Task item = _listOfTasks.removeAt(oldIndex);
      _listOfTasks.insert(newIndex, item);
     
    });

    if (!widget.isInFormMode) {
      // On modifie directement aussi dans le provider ==> A faire après directement dans le parent !!

      Provider.of<TodoList>(context, listen: false)
          .moveATask(widget.todoId, oldIndex, newIndex);
    } else {
      widget.onReorder(oldIndex, newIndex);
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

  void _deletingTask({String id, bool isEmpty = false}) {
    setState(() {
      _listOfTasks.removeWhere((element) => element.id == id);
      widget.deletingTask(id: id, isEmpty: isEmpty);
     
    });
  }

  Future<void> _addATask() async {
    if (!widget.isInFormMode && _isExpand == false) {
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
  
    widget.addATask(item);

    bool test = await Future.delayed(Duration(milliseconds: 500), () {
      bool out = true;
      print(_listOfTasks);
      if (_listOfTasks.length > 0 && _listOfTasks.last.content == '') {
     
        _deletingTask(id: _listOfTasks.last.id, isEmpty: true);
        out = false;
      }

      setState(() {
        _listOfTasks.add(item);
        _isAddingTask = false;
       
      });

      
      return out;
    });

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
          _listOfTasks == null ? 0 : 70.0 * _listOfTasks.length;
    }
    setState(() {
      _isExpand = !_isExpand;

    });
    Provider.of<TodoList>(context, listen: false)
        .toggleTasksExpand(widget.todoId);
  }

  @override
  Widget build(BuildContext context) {
    List<TaskWidget> _listOfTaskWidg = _listOfTasks.map((e) {
      return TaskWidget(
        item: e,
        deletingTask: _deletingTask,
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
                const Expanded(
                  child: const Text(
                    'List of tasks',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  child: const Text(
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
              const Expanded(child: const SizedBox()),
            ],
          ),
        if (!widget.isInFormMode && _listOfTaskWidg.length > 0)
          Row(
            children: <Widget>[
              Text(
                '${_listOfTasks.length} tasks in this todo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 5,
              ),
              GestureDetector(
                child: !_isExpand
                    ? const Icon(Icons.expand_more)
                    : const Icon(Icons.expand_less),
                onTap: _toggleExpand,
              ),
            ],
          ),
        if (_listOfTasks != null &&
            _listOfTasks.length > 0 &&
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
                  const SizedBox(
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
                        icon:const Icon(Icons.add_circle),
                        onPressed: _addATask,
                      ),
                      const Expanded(child: const SizedBox()),
                    ],
                  ),
                  const Expanded(child: const SizedBox()),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
