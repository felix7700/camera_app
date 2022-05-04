import 'package:camera/camera.dart';
import 'package:camera_app/screens/camera.dart';
import 'package:camera_app/screens/error_screen.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras = [];
List<String> imagesPaths = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Widget app = const CameraScreen();
  try {
    cameras = await availableCameras();
  } on CameraException catch (error) {
    app = ErrorScreen(error: error);
  }
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: app,
    ),
  );
}
