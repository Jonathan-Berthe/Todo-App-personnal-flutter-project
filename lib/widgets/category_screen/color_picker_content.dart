import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:flutter/cupertino.dart';

import '../../helpers/adaptable_text.dart';

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
    return Container(
      width: MediaQuery.of(context).size.width*0.75,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if (_isSwitched)
              BlockPicker(
                pickerColor: _color,
                onColorChanged: (Color color) {
                  setState(() => _color = color);
                  widget.onColorChanged(color);
                },
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: AdaptableText('Set a color for this category'),
                ),
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
      ),
    );
  }
}
