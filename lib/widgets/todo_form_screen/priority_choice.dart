import 'package:flutter/material.dart';

class PriorityChoice extends StatefulWidget {
  final int initSelectedPriority;
  final Function selectPriority;
  const PriorityChoice(this.initSelectedPriority, this.selectPriority, {Key key})
      : super(key: key);

  @override
  _PriorityChoiceState createState() => _PriorityChoiceState();
}

class _PriorityChoiceState extends State<PriorityChoice> {
  int _selectedPriority;

  @override
  void initState() {
    _selectedPriority = widget.initSelectedPriority;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
            child: const Text(
              'Priority',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Text(_selectedPriority.toString()),
              DropdownButton<int>(
                underline: Container(),
                items: <int>[0, 1, 2, 3, 4, 5].map((int value) {
                  return DropdownMenuItem<int>(
                      value: value, child: Text(value.toString()));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    widget.selectPriority(value);
                    _selectedPriority = value;
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}