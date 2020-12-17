import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:todo_marie/widgets/category_screen/color_button.dart';

import '../../providers/category_list.dart';
import '../../models/category.dart';
import './emoji_picker.dart';
import './color_picker_content.dart';

class CatElement extends StatefulWidget {
  final Category item;
  final Function toggleExpanded;
  final String isEditingId;
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
  String _emoji;

  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.item.name;

    KeyboardVisibility.onChange.listen((bool visible) {
      if (!visible) {
        Future.delayed(Duration(), () {
          if (context == null || !_isEditing) return;
          _submit(_controller.text);
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Fin snippet

  List<Widget> _builtButtons() {
    return [
      FlatButton.icon(
        onPressed: _smileyCat,
        icon: Icon(
          Icons.insert_emoticon,
          color: Colors.grey,
        ),
        label: Text('Set smiley'),
      ),
      ColorButton(
        id: widget.item.idKey,
        initColor: widget.item.color,
      ),
      FlatButton.icon(
        onPressed: _editCat,
        icon: Icon(
          Icons.edit,
          color: Colors.grey,
        ),
        label: Text('Edit name'),
      ),
      FlatButton.icon(
        onPressed: _addCat,
        icon: Icon(
          Icons.add,
          color: Colors.grey,
        ),
        label: Text('Add'),
      ),
      FlatButton.icon(
        onPressed: _deleteCat,
        icon: Icon(
          Icons.delete,
          color: Colors.grey,
        ),
        label: Text('Delete'),
      ),
    ];
  }

  void _smileyCat() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return EmojiPicker(
          emoji: _emoji,
          setEmoji: _setEmoji,
        );
      },
    );
  }

  void _editCat() {
    Navigator.pop(context);
    if (_isEditing) return;
    if (widget.isEditingId.length > 0) {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    } // On est en train d'éditer un autre
    widget.setIsEditingId(widget.item.idKey);
  }

  void _addCat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('You want to add a Category?'),
        content: Text('Do you want to add after, or as a sub-category ?'),
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
      if (res == null) return;
      Navigator.pop(context);
      if (res) {
        String newIdKey = Provider.of<CategoryList>(context, listen: false)
            .addAfter(widget.item.idKey);

        widget.setIsEditingId(newIdKey);
      } else {
        String newIdKey = Provider.of<CategoryList>(context, listen: false)
            .addAsChild2(widget.item.idKey);

        widget.setIsEditingId(newIdKey);
      }
    });
  }

  void _deleteCat() {
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
        Navigator.pop(context);
        Provider.of<CategoryList>(context, listen: false)
            .delete(widget.item.idKey);
        return;
      } else {
        return;
      }
    });
  }

  void _setEmoji(String emoji) {
    _emoji = emoji;
    Provider.of<CategoryList>(context, listen: false).updateEmoji(
      widget.item.idKey,
      _emoji,
    );
  }

  void _submit(value) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    widget.setIsEditingId('');

    if ((widget.item.name == null || widget.item.name == '') && value == '') {
      final snackBar = SnackBar(
        content: Text('You have to provide a name'),
        duration: Duration(seconds: 2),
      );
      Scaffold.of(context).showSnackBar(snackBar);
      Provider.of<CategoryList>(context, listen: false)
          .delete(widget.item.idKey);
      return;
    }
    if (value == '') {
      final snackBar = SnackBar(
        content: Text('You have to provide a name'),
        duration: Duration(seconds: 2),
      );
      Scaffold.of(context).showSnackBar(snackBar);
      return;
    }

    _name = value;

    Provider.of<CategoryList>(context, listen: false)
        .updateName(widget.item.idKey, value);
  }

  @override
  Widget build(BuildContext context) {
    _name = widget.item.name;
    _color = widget.item.color;
    _emoji = widget.item.emoji;
    _isEditing = (widget.item.idKey == widget.isEditingId);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      height: 45,
      padding:
          EdgeInsets.only(left: (widget.item.tree.length - 1).toDouble() * 13),
      child: Row(
        children: <Widget>[
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
                  width: 15,
                ),
          if (_color != null && _color != Colors.white) ...[
            Icon(
              Icons.bookmark,
              color: _color,
              size: 18,
            ),
            SizedBox(
              width: 5,
            ),
          ],
          Expanded(
            child: (_isEditing)
                ? Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                          ],
                          controller: _controller,
                          autofocus: true,
                          style: TextStyle(
                            fontWeight: (widget.item.children == null)
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                          onFieldSubmitted: _submit,
                        ),
                      ),
                      if (_emoji != '') Text(_emoji),
                    ],
                  )
                : Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "$_name $_emoji",
                          maxLines: 2,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: (widget.item.children == null)
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          PopupMenuButton<int>(
            itemBuilder: (_) {
              return _builtButtons().asMap().entries.map((e) {
                // e.key => index, e.value => value (IconButton)
                return PopupMenuItem(
                  value: e.key,
                  child: e.value,
                );
              }).toList();
            },
          ),
        ],
      ),
    );
  }
}
