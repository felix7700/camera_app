import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_app/db_manager.dart';
import 'package:camera_app/main.dart';
import 'package:camera_app/screens/captured_picture.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'gallery.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  final DbManager _dbManager = DbManager.instance;
  int selectedCamera = 0;

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      cameras[selectedCamera],
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    controller.initialize().then(
      (_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _saveImage(BuildContext buildcontext) async {
    final XFile _image = await controller.takePicture();
    debugPrint('_image.path: ' + _image.path);

    final fileName = basename(_image.path);
    debugPrint('fileName: ' + fileName);

    Map<String, dynamic> _newImageDataRow = {
      _dbManager.imagesColumnnameImageFileName: fileName,
      _dbManager.imagesColumnnameImageNickName: null,
      _dbManager.imagesColumnnameImageTagID: null,
    };
    int _resultImageId = await _dbManager.insertIntoTable(
        tableName: _dbManager.imagesTablename, row: _newImageDataRow);
    debugPrint('_resultImageId : ' + _resultImageId.toString());

    ScaffoldMessenger.of(buildcontext).showSnackBar(
      const SnackBar(
        content: Text('Bild wurde hinzugefügt'),
      ),
    );

    debugPrint('DisplayPictureScreen with path: ' + _image.path);
    await Navigator.of(buildcontext).push(
      MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(
          imagePath: _image.path,
        ),
      ),
    );
  }

  Future<void> _switchCamera() async {
    if (selectedCamera == 0) {
      selectedCamera = 1;
    } else {
      selectedCamera = 0;
    }
    controller = CameraController(
      cameras[selectedCamera],
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    debugPrint('selectedCamera = ' + selectedCamera.toString());
    controller.initialize().then(
      (_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: Text('!controller.value.isInitialized'),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: CameraPreview(controller),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  heroTag: 'switchCamera',
                  child: const Icon(
                    Icons.flip_camera_ios,
                  ),
                  backgroundColor: Colors.grey,
                  onPressed: () {
                    _switchCamera();
                  },
                ),
                FloatingActionButton(
                  heroTag: 'saveImage',
                  child: const Icon(Icons.camera_alt),
                  backgroundColor: Colors.grey,
                  onPressed: () async {
                    _saveImage(context);
                  },
                ),
                FloatingActionButton(
                  heroTag: 'showGalleryPage',
                  child: const Icon(Icons.image),
                  backgroundColor: Colors.grey,
                  onPressed: () async {
                    debugPrint('show GalleryPage()');
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GalleryPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
