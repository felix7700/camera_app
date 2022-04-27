import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../db_manager.dart';

const Color galleryBackgroundColor = Colors.white;
const Color galleryForeroundColor = Colors.black;
const double galleryGridAxisSpacing = 1.0;

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final DbManager _dbManager = DbManager.instance;

  Future<List<String>> _getAllImagesPaths() async {
    List<Map<String, dynamic>> _imagesTableData = await _dbManager
        .queryAllRowsFromAtable(tableName: _dbManager.imagesTablename);

    final appDir = await getApplicationDocumentsDirectory();
    List<String> _imagesPathList = [];

    for (var imageData in _imagesTableData) {
      String _imageFileName =
          imageData[_dbManager.imagesColumnnameImageFileName];
      String _imagePath = '';
      if (Platform.isAndroid) {
        _imagePath = ('${appDir.path}/../cache/$_imageFileName');
      } else if (Platform.isIOS) {
        _imagePath = ('${appDir.path}/camera/pictures/$_imageFileName');
      }
      _imagesPathList.add(_imagePath);
    }
    return _imagesPathList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getAllImagesPaths(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        Widget _widget;
        if (snapshot.hasData) {
          final List<String> _imagesPathList = snapshot.data;
          _widget = Scaffold(
            appBar: AppBar(
              title: const Text('Bilder Gallerie'),
              backgroundColor: galleryBackgroundColor,
              foregroundColor: galleryForeroundColor,
              actions: [
                SizedBox(
                  height: 32,
                  width: 32,
                  child: FloatingActionButton(
                    heroTag: 'showFilter',
                    backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                    elevation: 0,
                    foregroundColor: galleryForeroundColor,
                    child: const Icon(
                      Icons.filter,
                    ),
                    onPressed: () {
                      debugPrint('show filter');
                    },
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100,
                  childAspectRatio: 1 / 1,
                  crossAxisSpacing: galleryGridAxisSpacing,
                  mainAxisSpacing: galleryGridAxisSpacing,
                ),
                itemCount: _imagesPathList.length,
                itemBuilder: (BuildContext ctx, index) {
                  return FittedBox(
                    fit: BoxFit.fill,
                    alignment: Alignment.center,
                    child: Image.file(
                      File(_imagesPathList[index]),
                    ),
                  );
                },
              ),
            ),
          );
        } else if (snapshot.hasError) {
          _widget = Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${snapshot.error}'),
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
