import 'package:flutter/material.dart';

import '../todo_item_elements/todo_item_widget.dart';
import '../../models/todo_item.dart';
import '../../providers/todo_list.dart';

class TodoDayList extends StatefulWidget {
  final List<TodoItem> listOfTodo;
  final bool isInSelectMode;
  final Function toSelectMode;
  final Function addIdToSelectedList;
  final Function removeIdInSelectedList;
  final List listOfSelectedId;
  TodoDayList({
    Key key,
    this.listOfTodo,
    this.isInSelectMode,
    this.removeIdInSelectedList,
    this.toSelectMode,
    this.addIdToSelectedList,
    this.listOfSelectedId,
  }) : super(key: key);

  @override
  _TodoDayListState createState() => _TodoDayListState();
}

class _TodoDayListState extends State<TodoDayList> {
  final GlobalKey _key = GlobalKey();
  bool _isScrollable = false;

  final ScrollController _scrollController = ScrollController();

  _checkHeight() {
    if (_key.currentContext == null) return;

    RenderBox _cardBox = _key.currentContext.findRenderObject();
    if (_cardBox.size.height == 400 && !_isScrollable) {
      setState(() {
        _isScrollable = true;
      });
    } else if (_cardBox.size.height < 400 && _isScrollable) {
      setState(() {
        _isScrollable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkHeight());

    return Column(
      children: <Widget>[
        Container(
          key: _key,
          constraints: BoxConstraints(maxHeight: 400, minHeight: 0),
          child: Scrollbar(
            controller: _scrollController,
            isAlwaysShown: _isScrollable,
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              physics: !_isScrollable
                  ? NeverScrollableScrollPhysics()
                  : AlwaysScrollableScrollPhysics(),
              itemCount: widget.listOfTodo.length,
              itemBuilder: (ctx, i) => TodoItemWidget(
                addIdToSelectedList: widget.addIdToSelectedList,
                toSelectMode: widget.toSelectMode,
                isInSelectMode: widget.isInSelectMode,
                removeIdInSelectedList: widget.removeIdInSelectedList,
                isSelect: (widget.listOfSelectedId == [] ||
                        widget.isInSelectMode == false)
                    ? false
                    : widget.listOfSelectedId.contains(
                        widget.listOfTodo[i].id,
                      ),
                item: widget.listOfTodo[i],
                withDateMode: false,
                changeInExpand: () {
                  setState(() {});
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
