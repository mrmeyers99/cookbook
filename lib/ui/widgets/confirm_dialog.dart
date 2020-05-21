import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String prompt;
  final String action;

  ConfirmDialog(this.prompt, this.action);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text("Are you sure?"),
      content: new Text(prompt),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        new FlatButton(
          child: new Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        new FlatButton(
          child: new Text(action),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
