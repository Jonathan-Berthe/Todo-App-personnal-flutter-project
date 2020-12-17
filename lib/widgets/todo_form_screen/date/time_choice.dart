import 'package:flutter/material.dart';

class TimeChoice extends StatelessWidget {
  final TimeOfDay selectedTime;
  final Function selectTime;

  TimeChoice(this.selectedTime, this.selectTime);

  void _presentTimePicker(BuildContext context) {
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
      selectTime(pickedTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: <Widget>[
          if (selectedTime != null)
            InkWell(
                child: Icon(Icons.settings_backup_restore),
                onTap: () {
                 
                    selectTime(null);
                  // reset le filtre
                }),
          if (selectedTime != null) SizedBox(width: 10),
          Text(
            selectedTime == null
                ? "No time Chosen"
                : "${selectedTime.toString().substring(10, 15)}",
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
            onPressed: () => _presentTimePicker(context),
          ),
        ],
      ),
    );
  }
}
