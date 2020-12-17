import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/todo_list.dart';
import '../../providers/category_list.dart';

import '../../models/todo_item.dart';

class DayWidget extends StatelessWidget {
  final DateTime day;
  final bool isSelect;
  final double tileSize;

  DayWidget({@required this.day, this.isSelect = false, this.tileSize, key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime _today = DateTime.now();
    List<TodoItem> _todoItemsOfTheDay =
        Provider.of<TodoList>(context).todosOfADate(day);

    Map<Color, int> _todoItemsSortByCategory = Map();

    _todoItemsOfTheDay.forEach((element) {
      String idCat = element.idCategory;
      if (idCat == '' || idCat == null) {
        idCat = 'NoCat';
      }
      Color colorKey = (idCat == 'NoCat')
          ? Colors.white
          : Provider.of<CategoryList>(context, listen: false)
              .findByIdKey(idCat)
              .color;
      if (_todoItemsSortByCategory.containsKey(colorKey)) {
        _todoItemsSortByCategory[colorKey]++;
      } else {
        _todoItemsSortByCategory[colorKey] = 1;
      }
    });

    List<Widget> _tmp = [];

    _todoItemsSortByCategory.forEach((key, value) {
      if (_tmp.length > 5) return;
      if (_tmp.length == 5) {
        _tmp.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          child: Text(
            '...',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ));
        return;
      }
      _tmp.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        child: Text(
          value.toString(),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        //margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(width: 1),
          color: key,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ));
    });

    BoxDecoration _deco;
    if (_today.year == day.year &&
        _today.month == day.month &&
        day.day == _today.day) {
      if (isSelect) {
        _deco = BoxDecoration(
            color: Color.alphaBlend(
                Theme.of(context).accentColor.withOpacity(0.7),
                Theme.of(context)
                    .primaryColor), //alphaBlend() Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.all(Radius.circular(10)));
      } else {
        _deco = BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.all(Radius.circular(10)));
      }
    } else if (isSelect) {
      _deco = BoxDecoration(
          color: Theme.of(context).accentColor.withOpacity(0.7),
          borderRadius: BorderRadius.all(Radius.circular(10)));
    }

    return Container(
      decoration: _deco,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            day.day.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_tmp.length > 0)
            Wrap(
              children: _tmp,
            )
        ],
      ),
      height: tileSize,
    );
  }
}
