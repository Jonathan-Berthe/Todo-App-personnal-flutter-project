import 'package:flutter/material.dart';

class TimeChoice extends StatefulWidget {
  final TimeOfDay initSelectedTime;
  final Function selectTime;

  TimeChoice(this.initSelectedTime, this.selectTime);

  @override
  _TimeChoiceState createState() => _TimeChoiceState();
}

class _TimeChoiceState extends State<TimeChoice> {
  TimeOfDay _selectedTime;

  @override
  void initState() {
    _selectedTime = widget.initSelectedTime;
    super.initState();
  }

  void _presentTimePicker() {
    // https://flutterigniter.com/dismiss-keyboard-form-lose-focus/
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    ).then((pickedTime) {
      if (pickedTime == null) return;
      setState(() {
        widget.selectTime(pickedTime);
        _selectedTime = pickedTime;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: <Widget>[
          if (_selectedTime != null)
            InkWell(
                child: Icon(Icons.settings_backup_restore),
                onTap: () {
                  setState(() {
                    _selectedTime = null;
                    widget.selectTime(_selectedTime);
                  }); // reset le filtre
                }),
          if (_selectedTime != null) SizedBox(width: 10),
          Text(
            _selectedTime == null
                ? "No time Chosen"
                : "${_selectedTime.toString().substring(10, 15)}",
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
              "Choose time",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: _presentTimePicker,
          ),
        ],
      ),
    );
  }
}
