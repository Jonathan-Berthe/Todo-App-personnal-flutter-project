/// TODO: Snippet code

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class TitleAudioPlayerWidget extends StatefulWidget {
  final String initName;
  final Function setName;

  TitleAudioPlayerWidget({
    this.setName,
    this.initName,
    Key key,
  }) : super(key: key);

  @override
  _TitleAudioPlayerWidgetState createState() => _TitleAudioPlayerWidgetState();
}

class _TitleAudioPlayerWidgetState extends State<TitleAudioPlayerWidget> {
  bool _isEditing = false;
  String _name;

  final TextStyle _nameStyle =
      TextStyle(fontWeight: FontWeight.normal, fontSize: 18);

  TextEditingController _controller = TextEditingController();

  @override
  initState() {
    _name = widget.initName;

    KeyboardVisibility.onChange.listen((bool visible) {
      if (!visible) {
        Future.delayed(Duration(), () {
          if (context == null || !_isEditing) return;
          _submit(_controller.text);
        });
      }
    });

    _controller.text = _name;

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    widget.setName(value);
    setState(() {
      _isEditing = false;
      _name = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          child: _isEditing
              ? Expanded(
                  child: TextFormField(
                    autofocus: true,
                    style: _nameStyle,
                    controller: _controller,
                    onFieldSubmitted: _submit,
                  ),
                )
              : Text(
                  _name,
                  style: _nameStyle,
                ),
        ),
        IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            }),
      ],
    );
  }
}
