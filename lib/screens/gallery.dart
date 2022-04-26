import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../db_manager.dart';

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

    final appDir = await getApplicationDocumentsDirectory();
    debugPrint('appDir.path: ' + appDir.path);
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
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100,
                  childAspectRatio: 1 / 1,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
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
