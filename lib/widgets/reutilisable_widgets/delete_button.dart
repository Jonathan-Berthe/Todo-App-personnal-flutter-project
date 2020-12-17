import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final Function ifDelete;
  final String objectToDelete;
  final bool recursivePop;
  final Color color;

  DeleteButton(
      {this.ifDelete,
      this.objectToDelete,
      this.recursivePop = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete),
      color: color,
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are you sure ?'),
            content: objectToDelete == null
                ? Text('Are you sure?')
                : Text('Do you want to remove this $objectToDelete ?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (ifDelete != null) ifDelete();
                },
                child: Text('Yes'),
              )
            ],
          ),
        ).then((res) {
          print(res);
          if (res == false) return;
          if (recursivePop) {
            while (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        });
      },
    );
  }
}
