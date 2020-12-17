import 'package:flutter/material.dart';

class TextSection extends StatefulWidget {
  final String title;
  final String description;
  final Function changeOccur;
  final Function setTitle;
  final Function setDescription;

  const TextSection(
      {this.title,
      this.description,
      this.changeOccur,
      this.setDescription,
      this.setTitle,
      Key key})
      : super(key: key);

  @override
  _TextSectionState createState() => _TextSectionState();
}

class _TextSectionState extends State<TextSection> {
  final _titleFocusNode = FocusNode();
  String _title;
  String _description;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _description = widget.description;
    if(_title == null || _title == '') Future.delayed(Duration(), () {
      FocusScope.of(context).requestFocus(
        _titleFocusNode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
            // TITLE
            initialValue: _title,
            decoration: InputDecoration(
              labelText: 'Title',
            ),

            focusNode: _titleFocusNode,

            onSaved: (value) {
              _title = value;
              widget.setTitle(_title);
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Please provide a title.';
              }
              return null;
            },
            onChanged: (_) {
              widget.changeOccur();
            }),
        LimitedBox(
          maxHeight: 200,
          child: TextFormField(
            initialValue: _description,
            decoration: InputDecoration(
              labelText: 'Description',
            ),
            minLines: 2,
            maxLines: null, // How many line that your want
            keyboardType: TextInputType
                .multiline, // need to remove "textInputAction: TextInputAction.next" to accept multiline
           // focusNode: _descriptionFocusNode,
            onSaved: (value) {
              _description = value;
              widget.setDescription(_description);
            },
            onChanged: (_) {
              widget.changeOccur();
            },
          ),
        )
      ],
    );
  }
}
