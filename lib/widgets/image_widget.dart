import 'dart:io';

import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  ImageWidget(
      {Key? key,
      required this.imageId,
      required this.tagId,
      required this.imagePath})
      : super(key: key);
  int imageId;
  int? tagId;
  String imagePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() {
        debugPrint('image was clicked imageId: ' +
            imageId.toString() +
            '  tagId: ' +
            tagId.toString());
      }),
      child: Image.file(
        File(imagePath),
        width: 200,
        fit: BoxFit.cover,
      ),
    );
  }
}
