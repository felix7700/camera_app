import 'package:camera/camera.dart';
import 'package:camera_app/screens/camera.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras = [];
List<String> imagesPaths = [];

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CameraScreen(),
      ),
    );
  } on CameraException catch (e) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text(
              'Error in fetching the cameras: $e',
            ),
          ),
        ),
      ),
    );
  }
}
