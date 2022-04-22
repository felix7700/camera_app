import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras![0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: CameraPreview(controller)),
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
                  onPressed: () {},
                  child: const Icon(Icons.camera_alt),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.grey,
                  onPressed: () {},
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
    debugPrint('TakePictureScreenState initState()');
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
          Expanded(child: CameraPreview(_controller)),
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
                      imagePath: image.path,
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

class GalleryPage extends StatefulWidget {
  GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final List<Map> myProducts =
      List.generate(100000, (index) => {"id": index, "name": "Product $index"})
          .toList();

  Future<List<String>> _getImagesPaths() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    Directory _dir = Directory(tempPath);

    final List<FileSystemEntity> entities = await _dir.list().toList();
    // for (var entity in entities) {
    //   debugPrint('entity.toString(): ' + entity.toString());
    // }
    final Iterable<File> files = entities.whereType<File>();
    final List<String> _imagesPathList = [];
    for (var file in files) {
      // debugPrint('file.toString(): ' + file.toString());
      // var _fileName = (file.toString().split('/').last);
      // debugPrint('fileName: ' + _fileName);
      // _imagesPathList.add(file.toString());
      _imagesPathList.add(file.path);
    }
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
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20),
              itemCount: _imagesPathList.length,
              itemBuilder: (BuildContext ctx, index) {
                return Container(
                  alignment: Alignment.center,
                  // child: Text(_imagesPathList[index]),
                  child: Image.file(File(_imagesPathList[index])),

                  decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(15)),
                );
              },
            ),
          );
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
    );
  }
}
