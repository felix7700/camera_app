import 'dart:io';

import 'package:camera_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CapturedPictureScreen extends StatelessWidget {
  final String imagePath;

  const CapturedPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        elevation: 0,
        foregroundColor: AppColors.appBarFgColor,
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Image.file(
            File(imagePath),
          ),
        ),
      ),
    );
  }
}
