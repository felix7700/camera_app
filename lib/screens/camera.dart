import 'package:camera/camera.dart';
import 'package:camera_app/db_manager.dart';
import 'package:camera_app/main.dart';
import 'package:camera_app/screens/captured_picture.dart';
import 'package:camera_app/widgets/save_image_button.dart';
import 'package:camera_app/widgets/show_gallery_button.dart';
import 'package:camera_app/widgets/switch_camera_button.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'gallery.dart';

const cameraResolutionPreset = ResolutionPreset.high;

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
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
      const SnackBar(
        content: Text('Bild wurde hinzugefügt'),
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
                      SwitchCameraButton(onPressed: _switchCamera),
                      SaveImageButton(saveImageFunction: _saveImage),
                      ShowGalleryButton(
                          galleryScreenWidget: const GalleryPage()),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
