import 'package:camera/camera.dart';
import 'package:camera_app/screens/camera.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras = [];
List<String> imagesPaths = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initAppWithCamera();
  } on CameraException catch (e) {
    initAppWithoutCamera(e);
  }
}

void initAppWithoutCamera(CameraException e) {
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

Future<void> initAppWithCamera() async {
  cameras = await availableCameras();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraScreen(),
    ),
  );
}
