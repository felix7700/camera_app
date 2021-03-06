import 'dart:io';

import 'package:camera_app/constants.dart';
import 'package:camera_app/widgets/Dialogs/add_new_tag_dialog.dart';
import 'package:camera_app/widgets/ImageWidgets/image_widget.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../db_manager.dart';
import '../widgets/Dialogs/select_tag_dialog.dart';

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
  late Future<List<dynamic>> resultTableData;

  @override
  void initState() {
    super.initState();
    _loadAllImages();
  }

  void _loadAllImages() {
    resultTableData = getAllRelatedImagesData();
    setState(() {});
  }

  void _loadRelatedImagesFromSelectedTag({required int selectedTagId}) {
    resultTableData =
        getAllRelatedImagesDataWithSelectedTag(selectedTagId: selectedTagId);
    setState(() {});
  }

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

  Future<List<dynamic>> getAllRelatedImagesDataWithSelectedTag(
      {required int selectedTagId}) async {
    List<Map<String, dynamic>> _imagesTableData =
        await _dbManager.queryRelatedRowsFromAtable(
            tableName: _dbManager.imagesTablename,
            whereColumnName: _dbManager.imagesColumnnameImageTagID,
            whereColumnValue: selectedTagId);

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
    List<Map<String, dynamic>> tagsData = await _dbManager
        .queryAllRowsFromAtable(tableName: _dbManager.tagsTablename);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SelectTagDialog(
          tagsData: tagsData,
          onTagSelectedFunction: _loadRelatedImagesFromSelectedTag,
        );
      },
    );
  }

  Future<void> showAddNewTagCard({required BuildContext buildContext}) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AddNewTagDialog(
          addNewTagFunction: insertAnewTagIntoTagtable,
        );
      },
    );
  }

  insertAnewTagIntoTagtable({required Map<String, dynamic> newTagRow}) async {
    var _result = await _dbManager.insertIntoTable(
        tableName: _dbManager.tagsTablename, row: newTagRow);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: resultTableData,
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
                  Map<String, dynamic> _imageData = snapshot.data[index][0];
                  String _imagePath = snapshot.data[index][1];
                  return ImageWidget(
                    imageData: _imageData,
                    imagePath: _imagePath,
                    reloadImagesFunction: () {
                      setState(() {
                        _loadAllImages();
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
