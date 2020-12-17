import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_marie/widgets/reutilisable_widgets/delete_button.dart';
import 'package:todo_marie/widgets/overview_screen/search_word_widget.dart';
import 'package:todo_marie/widgets/overview_screen/select_mode_widget.dart';

import '../providers/todo_list.dart';
import '../providers/notification_provider.dart';
import '../widgets/todo_item_elements/todo_item_widget.dart';
import '../widgets/overview_screen/sort_widget.dart';

import '../helpers/painters.dart';

import '../screens/todo_item_detail_screen.dart';

class TodoListScreen extends StatefulWidget {
  TodoListScreen({
    Key key,
  }) : super(key: key);

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  bool _isInSelectMode = false;
  List<String> _listOfSelectedId = [];

  void _toSelectMode() {
    setState(() {
      _isInSelectMode = true;
    });
  }

  void _quitSelectMode() {
    setState(() {
      _listOfSelectedId = [];
      _isInSelectMode = false;
    });
  }

  void _addIdToSelectedList(String id) {
    setState(() {
      _listOfSelectedId.add(id);
    });
  }

  void _removeIdInSelectedList(String id) {
    _listOfSelectedId.removeWhere((item) => item == id);
    if (_listOfSelectedId.length == 0) _quitSelectMode();
    setState(() {});
  }

  void _updateListOfSelectedId() {
    var _tmp1 = Provider.of<TodoList>(context, listen: false)
        .filteredItems
        .map((e) => e.id)
        .toList();
    var _tmp2 = Provider.of<TodoList>(context, listen: false)
        .filteredItemsWithoutDate
        .map((e) => e.id)
        .toList();

    _listOfSelectedId.removeWhere((element) {
      return (_tmp1.contains(element) == false &&
          _tmp2.contains(element) == false);
    });
    if (_listOfSelectedId.length == 0) {
      _quitSelectMode();
    }
  }

  void _selectAll() {
    var _tmp1 = Provider.of<TodoList>(context, listen: false)
        .filteredItems
        .map((e) => e.id)
        .toList();
    var _tmp2 = Provider.of<TodoList>(context, listen: false)
        .filteredItemsWithoutDate
        .map((e) => e.id)
        .toList();
    setState(() {
      _listOfSelectedId = [..._tmp1, ..._tmp2];
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateListOfSelectedId();
    int l = Provider.of<TodoList>(context).filteredItemsWithoutDate.length;
    int l2 = Provider.of<TodoList>(context).filteredItems.length;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            SearchWordWidget(
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            Expanded(
              child: SizedBox(),
            )
          ],
        ),

        //Expanded(child: SizedBox()),
        SortWidget(),

        /* Container(
          width: double.infinity,
          child: Row(
            children: <Widget>[
              SearchWordWidget(width: MediaQuery.of(context).size.width * 0.5,),
              Expanded(
                child: Container(),
              ),
              SortWidget(),
            ],
          ),
        ), */
        if (_isInSelectMode)
          SelectModeWidget(
            listOfSelectedId: _listOfSelectedId,
            quitSelectMode: _quitSelectMode,
            selectAll: _selectAll,
          ),
        if (l + l2 == 0) ...[
          SizedBox(height: 15),
          Text('Nothing to show', style: TextStyle(fontSize: 16)),
        ],
        Expanded(
          child: ListView.builder(
              itemCount: Provider.of<TodoList>(context).filteredItems.length +
                  (l == 0 ? 0 : 1) +
                  l,
              itemBuilder: (ctx, i) {
                if (i < Provider.of<TodoList>(context).filteredItems.length) {
                  return Column(
                    children: <Widget>[
                      TodoItemWidget(
                          addIdToSelectedList: _addIdToSelectedList,
                          toSelectMode: _toSelectMode,
                          isInSelectMode: _isInSelectMode,
                          removeIdInSelectedList: _removeIdInSelectedList,
                          isSelect: (_listOfSelectedId == [] ||
                                  _isInSelectMode == false)
                              ? false
                              : _listOfSelectedId.contains(
                                  Provider.of<TodoList>(context)
                                      .filteredItems[i]
                                      .id,
                                ),
                          item:
                              Provider.of<TodoList>(context).filteredItems[i]),
                      if (i ==
                              Provider.of<TodoList>(context)
                                      .filteredItems
                                      .length -
                                  1 &&
                          l == 0)
                        SizedBox(height: 80),
                    ],
                  );
                }
                if (i == Provider.of<TodoList>(context).filteredItems.length &&
                    l > 0) {
                  return Provider.of<TodoList>(context).withDateFilter == false
                      ? SizedBox()
                      : Column(children: [
                          SizedBox(height: 15),
                          CustomPaint(
                            painter: TitleCardPainter(
                              primaryColor: Theme.of(context).primaryColorLight,
                              secondaryColor: Theme.of(context).primaryColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 25.0),
                              child: Text(
                                'No deadline',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ),
                          SizedBox(height: 15)
                        ]);
                } else {
                  return Column(
                    children: <Widget>[
                      TodoItemWidget(
                          addIdToSelectedList: _addIdToSelectedList,
                          toSelectMode: _toSelectMode,
                          isInSelectMode: _isInSelectMode,
                          removeIdInSelectedList: _removeIdInSelectedList,
                          isSelect: (_listOfSelectedId == [] ||
                                  _isInSelectMode == false)
                              ? false
                              : _listOfSelectedId.contains(
                                  Provider.of<TodoList>(context)
                                      .filteredItemsWithoutDate[i -
                                          1 -
                                          Provider.of<TodoList>(context)
                                              .filteredItems
                                              .length]
                                      .id,
                                ),
                          item: Provider.of<TodoList>(context)
                                  .filteredItemsWithoutDate[
                              i -
                                  1 -
                                  Provider.of<TodoList>(context)
                                      .filteredItems
                                      .length]),
                      if (i ==
                          Provider.of<TodoList>(context).filteredItems.length +
                              l)
                        SizedBox(height: 80),
                    ],
                  );
                }
              }),
        ),
      ],
    );
  }
}
