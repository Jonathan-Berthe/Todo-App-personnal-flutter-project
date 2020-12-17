import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../../providers/todo_list.dart';

// TODO: gérer problème de focus

class SearchWordWidget extends StatefulWidget {
  final double width;
  const SearchWordWidget({Key key, this.width = 150}) : super(key: key);

  @override
  _SearchWordWidgetState createState() => _SearchWordWidgetState();
}

class _SearchWordWidgetState extends State<SearchWordWidget> {
  TextEditingController _controller;
  bool _showClearButton = false;

  

  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {
        _showClearButton = _controller.text.length > 0;
      });
    });
     KeyboardVisibility.onChange.listen((bool visible) {
      if (!visible) {
        Future.delayed(Duration(milliseconds: 300), () {
          _unFocus();
        });
      }
    });
  }

  void _unFocus() {
    if (context == null) return;
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _getClearButton() {
    if (!_showClearButton) {
      return null;
    }
    return IconButton(
      onPressed: () {
        Provider.of<TodoList>(context, listen: false).filterByWord('');
        _controller.clear();
      },
      icon: Icon(
        Icons.clear,
        size: 18,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: widget.width,
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          icon: Icon(Icons.search),
          hintText: '',
          labelText: 'Search',
          suffixIcon: _getClearButton(),
        ),
        onChanged: (String value) {
          Provider.of<TodoList>(context, listen: false).filterByWord(value);
        },
      ),
    );
    //Expanded(child: Container()),
  }
}
