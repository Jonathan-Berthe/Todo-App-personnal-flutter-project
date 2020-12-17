// TODO: changer nom du fichier

import 'package:flutter/material.dart';

class SettingsCat extends StatefulWidget {
  final bool colorPropagation;
  final bool emojiPropagation;
  final Function settings;
  const SettingsCat(
      {this.settings, this.emojiPropagation, this.colorPropagation, key})
      : super(key: key);

  @override
  _SettingsCatState createState() => _SettingsCatState();
}

class _SettingsCatState extends State<SettingsCat> {
  bool _colorPropagation;
  bool _emojiPropagation;

  @override
  void initState() {
    _colorPropagation = widget.colorPropagation;
    _emojiPropagation = widget.emojiPropagation;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('Color propagation'),
                ),
                Switch(
                  value: _colorPropagation,
                  onChanged: (val) {
                    setState(() {
                      _colorPropagation = val;
                    });
                    widget.settings(colorPropagation: val);
                  },
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('Emoji propagation'),
                ),
                Switch(
                  value: _emojiPropagation,
                  onChanged: (val) {
                    setState(() {
                      _emojiPropagation = val;
                    });
                    widget.settings(emojiPropagation: val);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
