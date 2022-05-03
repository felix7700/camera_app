import 'dart:ffi';
import 'dart:io';

import 'package:camera_app/constants.dart';
import 'package:camera_app/widgets/add_new_tag_card.dart';
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
      _result.add([imageData, _imagePath]);
    }

    return _result;
  }

  Future<void> _showTagFilterDialog() async {
    List<DropdownMenuItem<dynamic>> tagsListAsDropdownMenuItems = [
      const DropdownMenuItem(
        child: Text('Auto'),
        value: 1,
      ),
      const DropdownMenuItem(
        child: Text('Haus'),
        value: 2,
      ),
    ];
    var tagsData = await _dbManager.queryAllRowsFromAtable(
        tableName: _dbManager.tagsTablename);
    debugPrint('tagsData: ' + tagsData.toString());
    return showDialog<void>(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nach Tag filtern'),
          content: SingleChildScrollView(
            child: DropdownButton<dynamic>(
              value: 2,
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

  Future<void> showAddNewTagCard({required BuildContext buildContext}) async {
    await Navigator.of(buildContext).push(
      MaterialPageRoute(
        builder: (buildContext) =>
            AddNewTagCard(addNewTagFunction: insertAnewTagIntoTagtable),
      ),
    );
  }

  insertAnewTagIntoTagtable({required Map<String, dynamic> newTagRow}) async {
    debugPrint('insertAnewTagIntoTagtable()');
    debugPrint('newCategoryRow: ' + newTagRow.toString());
    var _result = await _dbManager.insertIntoTable(
        tableName: _dbManager.tagsTablename, row: newTagRow);
    debugPrint('_result: ' + _result.toString());
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
                IconButton(
                  onPressed: () {
                    showAddNewTagCard(buildContext: context);
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 24,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                IconButton(
                  onPressed: () {
                    debugPrint('show filter');
                    _showTagFilterDialog();
                  },
                  icon: const Icon(
                    Icons.label_outline_rounded,
                    size: 24,
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
                    reloadImagesFunction: () {
                      setState(() {
                        getAllRelatedImagesData();
                      });
                    },
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
