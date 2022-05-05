import 'dart:io';

import 'package:camera_app/screens/captured_picture.dart';
import 'package:camera_app/widgets/DropDownButtons/drop_down_button_custom_style.dart';
import 'package:flutter/material.dart';

import '../../db_manager.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({
    Key? key,
    required this.imageData,
    required this.imagePath,
    required this.reloadImagesFunction,
  }) : super(key: key);

  final Map<String, dynamic> imageData;
  final String imagePath;
  final Function reloadImagesFunction;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  final DbManager _dbManager = DbManager.instance;
  Widget? imageFileWidget;
  int? _tagId;

  @override
  void initState() {
    super.initState();
    _tagId = widget.imageData[_dbManager.tagsColumnnameTagID];
  }

  void _setNewTagId(int newTagIdValue) {
    _tagId = newTagIdValue;
  }

  void _setNewTagIdToImageDataTagId() async {
    if (_tagId != null) {
      int _error = await _dbManager.updateAValueInARow(
          tableName: _dbManager.imagesTablename,
          whereColumnName: _dbManager.imagesColumnnameImageID,
          whereColumnValue:
              widget.imageData[_dbManager.imagesColumnnameImageID],
          updateValueColumnName: _dbManager.imagesColumnnameImageTagID,
          updateValue: _tagId);
      if (_error == 1) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showMyDialog() async {
    List<Map<String, dynamic>> tagsData = await _dbManager
        .queryAllRowsFromAtable(tableName: _dbManager.tagsTablename);

    return showDialog<void>(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'Tag ändern / Bild löschen',
              style: TextStyle(fontSize: 16),
            ),
          ),
          content: SingleChildScrollView(
            child: Row(
              children: [
                const Text('Tag:'),
                DropDownButtonCustomStyle(
                  columnNameIdValue: _dbManager.tagsColumnnameTagID,
                  columnNameTextValue: _dbManager.tagsColumnnameTagName,
                  selectedValue: _tagId,
                  tableRows: tagsData,
                  onValueSelectedFunction: _setNewTagId,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    _setNewTagIdToImageDataTagId();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Tag speichern'),
                      SizedBox(width: 10),
                      Icon(Icons.save),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () async {
                    debugPrint('delete image');
                    var error = await _deleteImage();
                    debugPrint('Delete Image Result: ' + error.toString());
                    widget.reloadImagesFunction();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Bild löschen'),
                      SizedBox(width: 10),
                      Icon(Icons.delete),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> _deleteImage() async {
    try {
      await File(widget.imagePath).delete(recursive: true);
    } catch (e) {
      return 'error delete file: ' + e.toString();
    }
    try {
      await _dbManager.deleteRow(
        tableName: _dbManager.imagesTablename,
        idColumnname: _dbManager.imagesColumnnameImageID,
        id: widget.imageData[_dbManager.imagesColumnnameImageID],
      );
    } catch (e) {
      return 'error deleteRow: ' + e.toString();
    }
    Navigator.of(context).pop();

    return 'no Error';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: (() {
        debugPrint(
            'image was longPressed imageData: ' + widget.imageData.toString());
        _showMyDialog();
      }),
      onTap: (() async {
        debugPrint(
            'image was clicked imageData: ' + widget.imageData.toString());
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                CapturedPictureScreen(imagePath: widget.imagePath),
          ),
        );
      }),
      child: Image.file(
        File(widget.imagePath),
        width: 200,
        fit: BoxFit.cover,
      ),
    );
  }
}
