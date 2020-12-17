// Transformer en stateless ?

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateChoice extends StatelessWidget {
  final DateTime selectedDate;
  final Function selectDate;

  DateChoice(this.selectedDate, this.selectDate);

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
      selectDate(pickedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final DateTime _selectedDate = widget.selectedDate;
    return Container(
      height: 50,
      child: Row(
        children: <Widget>[
          if (selectedDate != null)
            InkWell(
                child: Icon(Icons.settings_backup_restore),
                onTap: () {
                  selectDate(null);
                }),
          if (selectedDate != null) SizedBox(width: 10),
          Text(
            selectedDate == null
                ? "No date Chosen"
                : "${DateFormat.yMd().format(selectedDate)}",
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
