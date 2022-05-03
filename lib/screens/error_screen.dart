import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  ErrorScreen({Key? key, this.error}) : super(key: key);
  var error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Error in fetching the cameras: $error',
        ),
      ),
    );
  }
}
