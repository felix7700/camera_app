import 'package:camera/camera.dart';
import 'package:camera_app/db_manager.dart';
import 'package:camera_app/main.dart';
import 'package:camera_app/screens/captured_picture.dart';
import 'package:camera_app/widgets/circular_progress_indicator_custom.dart';
import 'package:camera_app/widgets/button_save_image.dart';
import 'package:camera_app/widgets/button_show_gallery.dart';
import 'package:camera_app/widgets/button_switch_camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'gallery.dart';

const cameraResolutionPreset = ResolutionPreset.high;

class ScreenCamera extends StatefulWidget {
  const ScreenCamera({Key? key}) : super(key: key);

  @override
  _ScreenCameraState createState() => _ScreenCameraState();
}

class _ScreenCameraState extends State<ScreenCamera> {
  late CameraController controller;
  final DbManager _dbManager = DbManager.instance;
  int selectedCamera = 0;
  late BuildContext _buildContext;

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      cameras[selectedCamera],
      cameraResolutionPreset,
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

  void _saveImage() async {
    final XFile _image = await controller.takePicture();
    final fileName = basename(_image.path);

    Map<String, dynamic> _newImageDataRow = {
      _dbManager.imagesColumnnameImageFileName: fileName,
      _dbManager.imagesColumnnameImageNickName: null,
      _dbManager.imagesColumnnameImageTagID: null,
    };
    int _resultImageId = await _dbManager.insertIntoTable(
        tableName: _dbManager.imagesTablename, row: _newImageDataRow);

    ScaffoldMessenger.of(_buildContext).showSnackBar(
      SnackBar(
        content: Text('Bild Nr.$_resultImageId wurde hinzugefügt'),
      ),
    );

    await Navigator.of(_buildContext).push(
      MaterialPageRoute(
        builder: (context) => CapturedPictureScreen(
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
      cameraResolutionPreset,
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
  Widget build(BuildContext context) {
    _buildContext = context;
    return Scaffold(
      backgroundColor: Colors.black,
      body: controller.value.isInitialized
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: CameraPreview(controller),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ButtonSwitchCamera(onPressed: _switchCamera),
                      ButtonSaveImage(saveImageFunction: _saveImage),
                      ButtonShowGallery(
                          galleryScreenWidget: const GalleryPage()),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicatorCustom(),
            ),
    );
  }
}
