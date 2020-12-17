import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/todo_list.dart';

class SortWidget extends StatefulWidget {
  SortWidget({Key key}) : super(key: key);

  @override
  _SortWidgetState createState() => _SortWidgetState();
}

class _SortWidgetState extends State<SortWidget> {
  
  

  @override
  Widget build(BuildContext context) {
    bool _withDate = Provider.of<TodoList>(context).withDateFilter;
    final List<String> _textValues = _withDate != false ? ['Deadline', 'Priority', 'Adding time'] : ['Priority', 'Adding time'] ;
    int _sortMode = Provider.of<TodoList>(context).sortChoice;
    String _dropdownValue = _withDate != false ? _textValues[_sortMode] : _textValues[_sortMode == 0 ? 0 : _sortMode - 1];

    bool _ascendingOrder = Provider.of<TodoList>(context).ascendingOrder;

    return 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Container(
           // width: MediaQuery.of(context).size.width * 0.5,
            child: Row(
              children: <Widget>[
                Spacer(
                  flex: 4,
                ),
                Text(
                  'Sort by: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Spacer(
                  flex: 1,
                ),
                DropdownButton<String>(
                  value: _dropdownValue,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 15,
                  elevation: 8,
                  underline: Container(
                    height: 2,
                  ),
                  onChanged: (String newValue) {
                    if (_dropdownValue == newValue) return;
                    Provider.of<TodoList>(context, listen: false).sortTodo(
                        newVal: _withDate != false ? _textValues
                            .indexWhere((element) => element == newValue) : _textValues
                            .indexWhere((element) => element == newValue) + 1 );
                  },
                  items:
                      _textValues.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Spacer(
                  flex: 1,
                ),
                InkWell(
                  child: Card(
                    color: Theme.of(context).accentColor,
                    child: _ascendingOrder ? Icon(Icons.keyboard_arrow_down, size: 24 ,) : Icon(Icons.keyboard_arrow_up, size: 24 ) ,
                  ),
                  onTap: () {
                    Provider.of<TodoList>(context, listen: false).switchAscendingOrder();
                  },
                ),
              ],
            ),
          ),
        )/* ,
      ],
    ) */;
  }
}
