import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todo_marie/models/task.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../providers/todo_list.dart';

// TODO: a priori on utilise jamais le mode editing false

class TaskWidget extends StatefulWidget {
  final Task item;
  final Function deletingTask;
  final Function changeOccur;
  final bool editingMode;
  final Function drawSubText;
  final Function saveInDB;

  const TaskWidget({
    Key key,
    @required this.item,
    this.saveInDB,
    this.deletingTask,
    this.changeOccur,
    this.editingMode = true,
    this.drawSubText,
  }) : super(key: key);

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  bool _isEditing;
  bool _isDone;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.item.content ==
        ''; // vaut true à la création du task pour forcer le focus au textField, si on drag vaut d'office false
    _isDone = widget.item.isDone;
  }

  void _editing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _deleting() {
    widget.deletingTask(id: widget.item.id);
  }

  @override
  Widget build(BuildContext context) {
    _isDone = widget.item.isDone;
    TextStyle tmpTitleStyle = (_isDone)
        ? TextStyle(decoration: TextDecoration.lineThrough, fontSize: 16)
        : TextStyle(fontSize: 16);

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        color: _isDone ? Colors.lightGreen[50] : Colors.white,
        width: double.infinity,
        height: 60,
        child: Row(
          children: <Widget>[
            Icon(
              MdiIcons.dragVertical,
              size: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: (_isEditing && widget.editingMode)
                  ? Focus(
                      onFocusChange: (hasFocus) {
                        if (!mounted) return;
                        if (!hasFocus) {
                          print('on détecte un unfocus');
                          // Si un unfocus autre que par onFieldSubmitted => on setState pour plus etre en mode editing
                          if (widget.saveInDB != null) widget.saveInDB();
                      
                          setState(() {
                            _isEditing = false;
                          });
                        }
                      },
                      child: TextFormField(
                        //keyboardType: TextInputType.multiline,
                        maxLength:
                            50, // TODO: Trouver en fonction de la device a quoi correspond la maxLength pour 2 lignes
                        style: tmpTitleStyle,
                        autofocus: true,
                        initialValue: widget.item.content,
                        onChanged: (value) {
                          setState(() {
                            widget.item.content = value;
                          });
                        },
                        onFieldSubmitted: (value) {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }

                          if (value == '') {
                            widget.deletingTask(widget.item.id);
                          }

                          widget.item.content = value;

                          if (widget.saveInDB != null) widget.saveInDB();

                          setState(() {
                            _isEditing = false;
                          });
                        },
                      ),
                    )
                  : widget.drawSubText == null
                      ? Text("${widget.item.content}",
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tmpTitleStyle)
                      : Consumer<TodoList>(
                          builder: (_, todoList, child) {
                            return widget.drawSubText(
                              text: "${widget.item.content}",
                              subText: todoList.wordFilter,
                              style: tmpTitleStyle,
                            );
                          },
                        ),
            ),
            SizedBox(width: 10),
            if (widget.editingMode) ...[
              GestureDetector(
                child: Icon(Icons.edit),
                onTap: _editing,
              ),
              SizedBox(width: 5),
              GestureDetector(
                child: Icon(Icons.clear),
                onTap: _deleting,
              ),
              SizedBox(width: 10),
            ],
            Checkbox(
              activeColor: Colors.green,
              value: _isDone,
              onChanged: (bool value) {
                setState(() {
                  _isDone = value;
                });
                widget.item.isDone = value;
                if (widget.changeOccur != null)
                  widget.changeOccur(value: value, taskId: widget.item.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
