import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:todo_marie/widgets/task_content.dart/tasks_view_todo_item.dart';
import 'package:todo_marie/widgets/todo_detail_screen/category_section.dart';
import 'package:todo_marie/widgets/todo_detail_screen/head_section.dart';
import 'package:todo_marie/widgets/todo_detail_screen/map_todo.dart';
import 'package:todo_marie/widgets/todo_detail_screen/image_section.dart';
import 'package:todo_marie/widgets/todo_item_elements/place_section.dart';

import 'package:todo_marie/widgets/todo_item_elements/description_section.dart';

import 'package:todo_marie/widgets/todo_detail_screen/audio_section.dart';
import '../../providers/todo_list.dart';

import '../../models/todo_item.dart';

// TODO: faire un meilleur listTile qd la catégorie n'a ni couleur ni smiley

class TodoItemScreenContent extends StatelessWidget {
  final TodoItem item;

  TodoItemScreenContent({
    this.item,
  });

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

  void _changeOccurInDoneTask(
      {bool value, String taskId, BuildContext context}) {
    Provider.of<TodoList>(context, listen: false)
        .setTaskDone(item.id, taskId, value);
  }

  Widget _titleBuilder(String title) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 15,
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(child: SizedBox()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (item == null) return SizedBox();
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if (item.imagesPath != null && item.imagesPath.length > 0)
              ImageSection(
                todoId: item.id,
              ),
            HeadSection(
              item: item,
              drawSubText: _drawSubText,
              initIsDone: item.isDone,
            ),
            if (item.idCategory != null && item.idCategory != '')
              CategorySection(
                catId: item.idCategory,
              ),
            if (item.description != null && item.description.length > 0)
              DescriptionSection(
                description: item.description,
                maxHeight: 200,
              ),
            SizedBox(height: 10),
            if (item.place != null) ...[
              SizedBox(height: 10),
              _titleBuilder('Place'),
              PlaceSection(
                place: item.place,
              ),
              if (item.place.latitude != null && item.place.longitude != null)
                MapTodo(
                  location: LatLng(
                    item.place.latitude,
                    item.place.longitude,
                  ),
                ),
              SizedBox(height: 10),
            ],
            _titleBuilder('Tasks'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TasksViewTodoItem(
                expandMode: false,
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
                changeOccur: ({bool value, String taskId}) =>
                    _changeOccurInDoneTask(
                        context: context, taskId: taskId, value: value),
                isDone: item.isDone,
              ),
            ),
            if (item.records != null && item.records.length > 0) ...[
              SizedBox(height: 10),
              _titleBuilder('Records'),
              SizedBox(height: 15),
              AudioSection(records: item.records)
            ],
          ],
        ),
      ),
    );
  }
}
