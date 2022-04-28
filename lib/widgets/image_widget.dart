import 'dart:io';

import 'package:camera_app/screens/captured_picture.dart';
import 'package:flutter/material.dart';

import '../db_manager.dart';

class ImageWidget extends StatefulWidget {
  ImageWidget({Key? key, required this.imageData, required this.imagePath})
      : super(key: key);

  Map<String, dynamic> imageData;
  String imagePath;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  final DbManager _dbManager = DbManager.instance;

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
