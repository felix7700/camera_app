import 'dart:io';

import 'package:camera_app/screens/captured_picture.dart';
import 'package:flutter/material.dart';

import '../../db_manager.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget(
      {Key? key,
      required this.imageData,
      required this.imagePath,
      required this.reloadImagesFunction})
      : super(key: key);

  final Map<String, dynamic> imageData;
  final String imagePath;
  final Function reloadImagesFunction;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  final DbManager _dbManager = DbManager.instance;
  Widget? imageFileWidget;

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
          title: const Text(
            'Tag ändern / Bild löschen',
            style: TextStyle(fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: DropdownButton<dynamic>(
              value: 1,
              items: tagsListAsDropdownMenuItems,
              onChanged: (selectedTag) {},
            ),
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () async {
                debugPrint('delete image');
                var error = await _deleteImage();
                debugPrint('Delete Image Result: ' + error.toString());
                widget.reloadImagesFunction();
                setState(() {});
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text('Bild löschen'),
                  SizedBox(width: 10),
                  Icon(Icons.delete),
                ],
              ),
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
