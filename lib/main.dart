import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  _initCameras() async {
    debugPrint('_initCameras()');

// Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;
    debugPrint('firstCamera: $firstCamera');
    return firstCamera;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
          future: _initCameras(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            Widget _widget;
            if (snapshot.hasData) {
              CameraDescription _cameraDescription = snapshot.data;
              _widget = TakePictureScreen(camera: _cameraDescription);
            } else if (snapshot.hasError) {
              _widget = Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    )
                  ],
                ),
              );
            } else {
              _widget = Center(
                child: Column(
                  children: const [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Awaiting result...'),
                    )
                  ],
                ),
              );
            }
            return _widget;
          },
        ),
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final _imageIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    debugPrint('\ndispose()');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () async {
              try {
                await _initializeControllerFuture;

                final XFile image = await _controller.takePicture();

                Directory tempDir = await getTemporaryDirectory();
                String tempPath = tempDir.path;

                Directory appDocDir = await getApplicationDocumentsDirectory();
                String appDocPath = appDocDir.path;

                debugPrint('image.path: ' + image.path);

                debugPrint('tempPath: ' + tempPath);
                debugPrint('appDocPath: ' + appDocPath);

                var completePath = image.path;
                var fileName = (completePath.split('/').last);
                var filePath = completePath.replaceAll("/$fileName", '');
                debugPrint('fileName: ' + fileName);
                debugPrint('filePath: ' + filePath);

                Directory _dir = Directory(tempPath);
                final List<FileSystemEntity> entities =
                    await _dir.list().toList();
                // for (var entity in entities) {
                //   debugPrint('entity.toString(): ' + entity.toString());
                // }
                final Iterable<File> files = entities.whereType<File>();
                List<String> _imagesPathList = [];
                for (var file in files) {
                  // debugPrint('file.toString(): ' + file.toString());
                  // var _fileName = (file.toString().split('/').last);
                  // debugPrint('fileName: ' + _fileName);
                  // _imagesPathList.add(file.toString());
                  _imagesPathList.add(file.path);
                }

                debugPrint(_imagesPathList.toString());

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                      imagePath: _imagesPathList[0],
                      // imagePath: image.path,
                    ),
                  ),
                );
              } catch (e) {
                print(e);
              }
            },
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(
            height: 48,
          ),
          FloatingActionButton(
            child: const Icon(Icons.image),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GalleryPage(),
                ),
              );
            },
          )
        ],
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
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}

class GalleryPage extends StatelessWidget {
  GalleryPage({Key? key}) : super(key: key);

  final List<Map> myProducts =
      List.generate(100000, (index) => {"id": index, "name": "Product $index"})
          .toList();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20),
      itemCount: myProducts.length,
      itemBuilder: (BuildContext ctx, index) {
        return Container(
          alignment: Alignment.center,
          child: Text(myProducts[index]["name"]),
          decoration: BoxDecoration(
              color: Colors.amber, borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }
}
