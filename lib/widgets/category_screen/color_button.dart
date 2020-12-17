import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './color_picker_content.dart';
import '../../providers/category_list.dart';

class ColorButton extends StatefulWidget {
  final Color initColor;
  final String id;

  ColorButton({this.id, this.initColor, Key key}) : super(key: key);

  @override
  _ColorButtonState createState() => _ColorButtonState();
}

class _ColorButtonState extends State<ColorButton> {
  Color _color;

  @override
  void initState() {
    _color = widget.initColor;
    super.initState();
  }

  void _setColor(Color color) {
    Provider.of<CategoryList>(context, listen: false)
        .updateColor(widget.id, color);

    setState(() {
      _color = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Select a color'),
                content: ColorPickerContent(
                  color: _color,
                  onColorChanged: _setColor,
                ),
              );
            },
          );
        },
        icon: (_color == Colors.white)
            ? Icon(
                Icons.bookmark_border,
                color: Colors.grey,
              )
            : Icon(
                Icons.bookmark,
                color: _color,
              ),
        label: Text('Set color'));
  }
}
