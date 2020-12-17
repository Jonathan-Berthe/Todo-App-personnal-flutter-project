import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class SubtileWidget extends StatelessWidget {
  final bool withDateMode;
  final DateTime deadline;

  const SubtileWidget({
    Key key,
    this.deadline,
    this.withDateMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Row(
      children: <Widget>[
        (deadline.second != 0)
            ? Row(
                children: <Widget>[
                  Text(
                    withDateMode
                        ? DateFormat('dd/MM/yyyy').format(deadline)
                        : '',
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (deadline.add(Duration(days: 1)).isBefore(now))
                    Text(
                      ' (Past) ',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                ],
              )
            : Row(
                children: <Widget>[
                  Text(
                      withDateMode
                          ? DateFormat('dd/MM/yyyy HH:mm').format(deadline)
                          : DateFormat('HH:mm').format(deadline),
                      overflow: TextOverflow.ellipsis,
                      style: !withDateMode
                          ? TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                          : null),
                  if (deadline.isBefore(now))
                    Text(
                      ' (Past) ',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
      ],
    );
  }
}
