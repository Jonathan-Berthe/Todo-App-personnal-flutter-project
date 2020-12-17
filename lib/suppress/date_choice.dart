// Transformer en stateless ?

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateChoice extends StatefulWidget {
  final DateTime selectedDate;
  final Function selectDate;

  DateChoice(this.selectedDate, this.selectDate);

  @override
  _DateChoiceState createState() => _DateChoiceState();
}

class _DateChoiceState extends State<DateChoice> {

  DateTime _selectedDate;

  @override
  void initState() {
    print('there');
    _selectedDate = widget.selectedDate;
    super.initState();
  }

  void _presentDatePicker(BuildContext context) {
    // https://flutterigniter.com/dismiss-keyboard-form-lose-focus/
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    ).then((pickedDate) {
      if (pickedDate == null) return;

      setState(() {
        widget.selectDate(pickedDate);
        _selectedDate = pickedDate;
      });

      
    });
  }

  @override
  Widget build(BuildContext context) {
   // final DateTime _selectedDate = widget.selectedDate;
    return Container(
      height: 50,
      child: Row(
        children: <Widget>[
          if (_selectedDate != null)
            InkWell(
                child: Icon(Icons.settings_backup_restore),
                onTap: () {
                  setState(() {
                    _selectedDate = null;
                    widget.selectDate(null);
                  });
                }),
          if (_selectedDate != null) SizedBox(width: 10),
          Text(
            _selectedDate == null
                ? "No date Chosen"
                : "${DateFormat.yMd().format(_selectedDate)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: SizedBox(),
          ),
          FlatButton(
            textColor: Theme.of(context).primaryColor,
            child: Text(
              "Choose date",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => _presentDatePicker(context),
          ),
        ],
      ),
    );
  }
}
