import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_app/db_manager.dart';
import 'package:camera_app/main.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  final DbManager _dbManager = DbManager.instance;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
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
                const SizedBox(
                  width: 64,
                ),
                FloatingActionButton(
                  backgroundColor: Colors.grey,
                  onPressed: () async {
                    final XFile _image = await controller.takePicture();
                    debugPrint('_image.path: ' + _image.path);

                    final appDir = await getApplicationDocumentsDirectory();
                    debugPrint('appDir.path: ' + appDir.path);
                    final fileName = basename(_image.path);
                    debugPrint('fileName: ' + fileName);

                    String imagePath = '';
                    if (Platform.isAndroid) {
                      imagePath = ('${appDir.path}/../cache/$fileName');
                    } else if (Platform.isIOS) {
                      imagePath = ('${appDir.path}/camera/pictures/$fileName');
                    }
                    debugPrint('imagePath: ' + imagePath);

                    Map<String, dynamic> _newImageDataRow = {
                      _dbManager.imagesColumnnameImagePath: imagePath,
                      _dbManager.imagesColumnnameImageName: null,
                      _dbManager.imagesColumnnameImageTagID: null,
                    };
                    int _resultImageId = await _dbManager.insertIntoTable(
                        tableName: _dbManager.imagesTablename,
                        row: _newImageDataRow);
                    debugPrint('_resultImageId : ' + _resultImageId.toString());

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bild wurde hinzugefügt'),
                      ),
                    );

                    debugPrint(
                        'DisplayPictureScreen with path: ' + _image.path);
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DisplayPictureScreen(
                          imagePath: _image.path,
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.camera_alt),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.grey,
                  onPressed: () async {
                    debugPrint('show GalleryPage()');
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GalleryPage(),
                      ),
                    );
                  },
                  child: const Icon(Icons.image),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
