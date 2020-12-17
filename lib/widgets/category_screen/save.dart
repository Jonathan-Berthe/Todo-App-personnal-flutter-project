/* //{"0":"2","1":"1","2":"3","3":"1"}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../providers/category_list.dart';
import '../../models/category.dart';

class CategoryListWidget extends StatefulWidget {
  final List<int> isEditingId;
  final Function setIsEditingId;
  final CategoryList provider;

  CategoryListWidget(this.isEditingId, this.setIsEditingId, this.provider);

  @override
  _CategoryListWidgetState createState() => _CategoryListWidgetState();
}

class _CategoryListWidgetState extends State<CategoryListWidget> {
  List<Category> _items;

  @override // On ovveride deactivate à la place place de dispose car a ce stade le Provider est encore accessible.
  void deactivate() {
    Provider.of<CategoryList>(context, listen: false)
        .setExpandedToFalse(_items);
    super.deactivate();
  }

  List<Widget> builderCat(Category item) {
    List<Widget> a = [];
    if (item.expanded) {
      if (item.children != null)
        item.children.forEach((element) {
          a = [...a, ...builderCat(element)];
        });
    }
    return [
      CatElement(
          item, toggleExpanded, widget.isEditingId, widget.setIsEditingId,
          key: ValueKey(
              item.idKey)), // Key obligatoire pour éviter bug (voir chap 6)
      Divider(
        thickness: 1.0,
      ),
      ...a
    ];
  }

  void toggleExpanded(Category item) {
    setState(() {
      item.expanded = !item.expanded;
      Provider.of<CategoryList>(context, listen: false)
          .setExpandedToFalse(item.children);
    });
  }

  @override
  Widget build(BuildContext context) {
    _items = widget.provider.items;
    List<Widget> itemsList = [];
    _items.forEach((element) {
      itemsList = [...itemsList, ...builderCat(element)];
    });
    return Container(
      height: MediaQuery.of(context).size.height,
      //margin: const EdgeInsets.all(5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...itemsList,
          ],
        ),
      ),
    );
  }
}

class CatElement extends StatefulWidget {
  final Category item;
  final Function toggleExpanded;
  final List<int> isEditingId;
  final Function setIsEditingId;

  CatElement(
      this.item, this.toggleExpanded, this.isEditingId, this.setIsEditingId,
      {Key key})
      : super(key: key);

  @override
  _CatElementState createState() => _CatElementState();
}

class _CatElementState extends State<CatElement> {
  bool _isEditing;
  String _name;
  Color _color;

  @override
  Widget build(BuildContext context) {
    _name = widget.item.name;
    _color = widget.item.color;
    _isEditing = ListEquality().equals(widget.item.id, widget.isEditingId);
    return Container(
      height: 45,
      child: ListTile(
        contentPadding:
            EdgeInsets.only(left: (widget.item.id.length - 1).toDouble() * 10),
        title: Row(children: <Widget>[
          widget.item.children != null
              ? IconButton(
                  icon: widget.item.expanded
                      ? Icon(Icons.expand_less)
                      : Icon(Icons.expand_more),
                  onPressed: () {
                    widget.toggleExpanded(widget.item);
                  },
                )
              : SizedBox(
                  width: 24,
                ),
          Expanded(
            child: (_isEditing)
                ? TextFormField(
                    autofocus: true,
                    initialValue: widget.item.name,
                    style: TextStyle(
                      fontWeight: (widget.item.children == null)
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                    onFieldSubmitted: (value) {
                      _name = value;
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      widget.setIsEditingId(List<int>());
                      Provider.of<CategoryList>(context, listen: false)
                          .updateName(widget.item.idKey, value);
                    },
                  )
                : Text(
                    _name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: (widget.item.children == null)
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
          ),
        ]),
        trailing: Wrap(
          spacing: -20,
          children: <Widget>[
            IconButton(
                icon: (_color == Colors.white)
                    ? Icon(
                        Icons.bookmark_border,
                      )
                    : Icon(
                        Icons.bookmark,
                        color: _color,
                      ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Select a color'),
                        content: ColorPickerContent(
                          color: _color,
                          onColorChanged: (color) {
                            setState(() {
                              _color = color;
                              //widget.item.expanded = false;
                            });
                            Provider.of<CategoryList>(context, listen: false)
                                .updateColor(widget.item.idKey, _color,
                                    recursiveMod: false);
                            /* setState(() {
                              widget.item.expanded = true;
                            }); */
                          },
                        ),
                      );
                    },
                  );
                }),
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  if (_isEditing) return;
                  if (widget.isEditingId.length > 0) {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  } // On est en train d'éditer un autre

                  widget.setIsEditingId(widget.item.id);
                }),
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('You want to add a Category?'),
                      content: Text(
                          'Do you want to add after, or as a sub-category ?'),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(true);
                          },
                          child: Text('After'),
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(false);
                          },
                          child: Text('Sub-category'),
                        )
                      ],
                    ),
                  ).then((res) {
                    if (res) {
                      List<int> newId =
                          Provider.of<CategoryList>(context, listen: false)
                              .addAfter(widget.item.id);
                      widget.setIsEditingId(newId);
                    } else {
                      List<int> newId =
                          Provider.of<CategoryList>(context, listen: false)
                              .addAsChild(widget.item.id);
                      widget.setIsEditingId(newId);
                    }
                  });
                }),
            IconButton(icon: Icon(Icons.drag_handle), onPressed: null),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Do you want to delete this Category?'),
                      content: Text(
                          "It's irreversible ! All the existant todo items with this ctegory will attribute the parent category."),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(true);
                          },
                          child: Text('Yes'),
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(false);
                          },
                          child: Text('No'),
                        )
                      ],
                    ),
                  ).then((res) {
                    if (res == true) {
                      Provider.of<CategoryList>(context, listen: false)
                          .delete(widget.item.id);
                      return; //widget.setIsEditingId(newId);
                    } else {
                      return;
                    }
                  });
                }),
          ],
        ),
      ),
    );
  }
}

class ColorPickerContent extends StatefulWidget {
  final Color color;
  final Function onColorChanged;

  ColorPickerContent({this.color, this.onColorChanged, key}) : super(key: key);

  @override
  _ColorPickerContentState createState() => _ColorPickerContentState();
}

class _ColorPickerContentState extends State<ColorPickerContent> {
  bool _isSwitched = true;
  Color _color;

  @override
  void initState() {
    _color = widget.color;
    if (_color == Colors.white) {
      _isSwitched = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          if (_isSwitched)
            BlockPicker(
              pickerColor: _color,
              onColorChanged: (Color color) {
                setState(() => _color = color);
                widget.onColorChanged(_color);
              },
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Set a color for this category'),
              Switch(
                value: _isSwitched,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (val) {
                  setState(() {
                    _isSwitched = val;
                    if (!val) {
                      _color = Colors.white;
                    }
                  });
                  widget.onColorChanged(_color);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
 */