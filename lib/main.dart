import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_app/screens/camera_screen.dart';
import 'package:flutter/material.dart';

import 'db_manager.dart';

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

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final DbManager _dbManager = DbManager.instance;

  Future<List<String>> _getImagesPaths() async {
    List<Map<String, dynamic>> _imagesTableData =
        await _dbManager.queryAllRows(tableName: _dbManager.imagesTablename);
    debugPrint(
      '_imagesTableData: ' + _imagesTableData.toString(),
    );
    final List<String> _imagesPathList = [];
    for (var imageData in _imagesTableData) {
      _imagesPathList.add(imageData[_dbManager.imagesColumnnameImagePath]);
    }
    debugPrint(
      '_imagesPathList: ' + _imagesPathList.toString(),
    );
    return _imagesPathList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getImagesPaths(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        Widget _widget;
        if (snapshot.hasData) {
          final List<String> _imagesPathList = snapshot.data;
          _widget = Scaffold(
            appBar: AppBar(
              title: const Text('Bilder Gallerie'),
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 100,
                    childAspectRatio: 1 / 1,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2),
                itemCount: _imagesPathList.length,
                itemBuilder: (BuildContext ctx, index) {
                  return Expanded(
                    child: FittedBox(
                      fit: BoxFit.fill,
                      alignment: Alignment.center,
                      child: Image.file(
                        File(_imagesPathList[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else if (snapshot.hasError) {
          _widget = MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          _widget = const Scaffold(
            body: Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return _widget;
      },
    );
  }
}
