import 'dart:io';

import 'package:camera_app/constants.dart';
import 'package:camera_app/widgets/image_widget.dart';
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

  Future<List<dynamic>> getAllRelatedImagesData() async {
    List<Map<String, dynamic>> _imagesTableData = await _dbManager
        .queryAllRowsFromAtable(tableName: _dbManager.imagesTablename);

    final appDir = await getApplicationDocumentsDirectory();
    List<dynamic> _result = [];

    for (var imageData in _imagesTableData) {
      String _imageFileName =
          imageData[_dbManager.imagesColumnnameImageFileName];
      String _imagePath = '';
      if (Platform.isAndroid) {
        _imagePath = ('${appDir.path}/../cache/$_imageFileName');
      } else if (Platform.isIOS) {
        _imagePath = ('${appDir.path}/camera/pictures/$_imageFileName');
      }
      int _imageId = imageData[_dbManager.imagesColumnnameImageID];
      int? _imageTagId = imageData[_dbManager.imagesColumnnameImageTagID];
      _result.add([imageData, _imagePath]);
    }

    return _result;
  }

  Future<void> _showMyDialog() async {
    List<DropdownMenuItem<dynamic>> tagsListAsDropdownMenuItems = [
      const DropdownMenuItem(
        child: Text('tag'),
        value: 1,
      ),
      const DropdownMenuItem(
        child: Text('tag'),
        value: 2,
      ),
    ];
    return showDialog<void>(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: DropdownButton<dynamic>(
              value: 1,
              items: tagsListAsDropdownMenuItems,
              onChanged: (selectedTag) {},
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                debugPrint('Tagauswahl abgebrochen');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addNewTag() async {
    debugPrint('add new tag xxx to image');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAllRelatedImagesData(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        Widget _widget;
        if (snapshot.hasData) {
          _widget = Scaffold(
            appBar: AppBar(
              title: const Text('Bilder Gallerie'),
              backgroundColor: AppColors.appBarBgColor,
              foregroundColor: AppColors.appBarFgColor,
              actions: [
                SizedBox(
                  height: 32,
                  width: 32,
                  child: FloatingActionButton(
                    heroTag: 'addNewTag',
                    backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                    elevation: 0,
                    foregroundColor: galleryForeroundColor,
                    child: const Icon(
                      Icons.add,
                    ),
                    onPressed: () {
                      addNewTag();
                    },
                  ),
                ),
                const SizedBox(
                  width: 32,
                ),
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
                      _showMyDialog();
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
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext ctx, index) {
                  return ImageWidget(
                    imageData: snapshot.data[index][0],
                    imagePath: snapshot.data[index][1],
                    reloadImagesFunction: getAllRelatedImagesData,
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
