import 'package:flutter/material.dart';

class InputAlertDialog extends StatelessWidget {
  final TextEditingController _textFieldController = TextEditingController();
  final String prompt;
  final String hint;
  final TextInputType keyboardType;

  InputAlertDialog(this.prompt, this.hint, this.keyboardType);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(prompt),
      content: TextField(
        keyboardType: keyboardType,
        controller: _textFieldController,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('OK'),
          onPressed: () {
            Navigator.of(context).pop(_textFieldController.text);
          },
        ),
        new FlatButton(
          child: new Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
