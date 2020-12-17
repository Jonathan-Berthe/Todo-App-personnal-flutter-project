import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reorderables/reorderables.dart';

import '../../providers/category_list.dart';
import '../../models/category.dart';

import './cat_element.dart';

class CategoryListWidget extends StatefulWidget {
  //final List<int> isEditingId;
  final String isEditingId;
  final Function setIsEditingId;
  final CategoryList provider;

  const CategoryListWidget(
    this.isEditingId,
    this.setIsEditingId,
    this.provider,
  );

  @override
  _CategoryListWidgetState createState() => _CategoryListWidgetState();
}

class _CategoryListWidgetState extends State<CategoryListWidget> {
  List<Category> _items;
  String _itemDragId;

  @override // On ovveride deactivate à la place place de dispose car a ce stade le Provider est encore accessible.
  void deactivate() {
    Provider.of<CategoryList>(context, listen: false)
        .setExpandedToFalse(_items);
    super.deactivate();
  }

  Map<String, dynamic> builderCat(Category item) {
    List<Widget> a = [];
    double tmp = 0; // TODO mettre tmp responsive
    bool _isInDrag = (item.idKey == _itemDragId);

    if (item.expanded && item.children != null) {
      item.children.forEach((element) {
        a = [...a, ...(builderCat(element)['widget'] as List<Widget>)];
        tmp += builderCat(element)['l'];
      });
      List<Widget> tmpWidget = _isInDrag
          ? <Widget>[
              Container(
                key: ValueKey(item.idKey + 'Container'),
                height: tmp + 51,
                child: CustomScrollView(
                    controller: ScrollController(),
                    physics: const NeverScrollableScrollPhysics(),
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate([
                          CatElement(
                            item,
                            toggleExpanded,
                            widget.isEditingId,
                            widget.setIsEditingId,
                            key: ValueKey(item.idKey),
                          ),
                          ...a
                        ]),
                      ),
                    ]),
              ),
            ]
          : <Widget>[
              GestureDetector(
                key: ValueKey(item.idKey),
                onTapDown: (_) {
                  setState(() {
                    _itemDragId = item.idKey;
                  });
                },
                child: CatElement(
                  item,
                  toggleExpanded,
                  widget.isEditingId,
                  widget.setIsEditingId,
                  //key: ValueKey(item.idKey),
                ),
              ),
              ...a
            ];

      return {'widget': tmpWidget, 'l': tmp + 51};
    } else {
      return {
        'widget': <Widget>[
          GestureDetector(
            key: ValueKey(item.idKey),
            onTapDown: (_) {
              setState(() {
                _itemDragId = item.idKey;
              });
            },
            child: CatElement(
              item,
              toggleExpanded,
              widget.isEditingId,
              widget.setIsEditingId,
              //key: ValueKey(item.idKey),
            ),
          ),
        ],
        'l': 51
      };
    }
  }

  void toggleExpanded(Category item) {
    setState(() {
      item.expanded = !item.expanded;
      _itemDragId = '';
      Provider.of<CategoryList>(context, listen: false)
          .setExpandedToFalse(item.children);
    });
  }

  void _onReorder(int oldIndex, int newIndex, List<Widget> itemsList) async {
    if (_itemDragId == null) {
      return;
    }
    Category movingItem = widget.provider.findByIdKey(_itemDragId);

    int indexBeforeItem = (newIndex > oldIndex) ? newIndex : newIndex - 1;

    Category newBeforeItem = (newIndex == 0)
        ? null
        : (itemsList[indexBeforeItem] is GestureDetector)
            ? ((itemsList[indexBeforeItem] as GestureDetector).child
                    as CatElement)
                .item
            : (itemsList[indexBeforeItem] as CatElement).item;
    bool addAsChild = false;
    if (newBeforeItem != null &&
        newBeforeItem.children != null &&
        newBeforeItem.expanded) {
      addAsChild = true;
    }

    widget.provider.movePosition(
      isAddingAsChild: addAsChild,
      beforeItemIdKey: newBeforeItem == null ? '' : newBeforeItem.idKey,
      movingItemIdKey: movingItem.idKey,
    );

    setState(() {
      _itemDragId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    _items = widget.provider.items;
    List<Widget> _itemsList = [];

    _items.forEach((element) {
      _itemsList = [
        ..._itemsList,
        ...(builderCat(element)['widget'] as List<Widget>)
      ];
    });

    double screenHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight -
        MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: screenHeight,
      child: Column(
        children: <Widget>[
          Container(
            height: screenHeight * 0.1,
            child: Row(
              children: <Widget>[
                if (_items == null || _items.length == 0) ...[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'No category',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(),
                  )
                ],
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  child: Text(
                    "Add category",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    String newIdKey =
                        Provider.of<CategoryList>(context, listen: false)
                            .addAfter('');
                    widget.setIsEditingId(newIdKey);
                  },
                ),
                if (_items != null && _items.length > 0)
                  Expanded(child: SizedBox()),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              controller: ScrollController(),
              slivers: <Widget>[
                ReorderableSliverList(
                  onReorder: (oldIndex, newIndex) =>
                      _onReorder(oldIndex, newIndex, _itemsList),
                  onNoReorder: (index) {
                    setState(() {
                      _itemDragId = null;
                    });
                  },
                  delegate: ReorderableSliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return _itemsList[index];
                      // first and last attributes affect border drawn during dragging
                    },
                    childCount: _itemsList.length,
                  ),
                ),
              ],
            ),

            //),
          ),
        ],
      ),
    );
  }
}
