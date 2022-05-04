import 'package:flutter/material.dart';

class DropDownButtonMenuItemChild extends StatelessWidget {
  const DropDownButtonMenuItemChild({Key? key, required this.text})
      : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 16.0,
          width: 128.0,
          child: Text(
            text,
          ),
        ),
      ),
    );
  }
}
