// TODO améliorer le plugin sur github (rappel: vérifier mounted avant setState)

import 'package:flutter/material.dart';

import 'package:emoji_picker/emoji_picker.dart' as emoji;

class EmojiPicker extends StatefulWidget {
  final String emoji;
  final Function setEmoji;

  EmojiPicker({this.setEmoji, this.emoji, key}) : super(key: key);

  @override
  _EmojiPickerState createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  String _emoji;
  Widget _emojiPicker;

  @override
  void initState() {
    _emoji = widget.emoji;
    super.initState();
  }

 /*  @override
  void dispose() {
    dispose();
    super.dispose();
  } */

  @override
  Widget build(BuildContext context) {
    _emojiPicker = emoji.EmojiPicker(
      rows: 3,
      columns: 7,
      //recommendKeywords: ["racing", "horse"],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        if (this.mounted) setState(() {
          _emoji = emoji.emoji;
        });
        widget.setEmoji(emoji.emoji);
      },
    );
    return Container(
      //height: 350,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _emojiPicker,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Text(
                        _emoji == '' ? 'No choice' : 'Your choice: $_emoji',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (_emoji != '')
                    RaisedButton(
                      onPressed: () {
                        if (this.mounted) setState(() {
                          _emoji = '';
                        });
                        widget.setEmoji('');
                      },
                      child: Text('Reset'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
