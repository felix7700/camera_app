import 'package:camera/camera.dart';
import 'package:camera_app/db_manager.dart';
import 'package:camera_app/main.dart';
import 'package:flutter/material.dart';

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
                    imagesPaths.add(_image.path);
                    Map<String, dynamic> _newImageDataRow = {
                      _dbManager.imagesColumnnameImagePath: _image.path,
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
