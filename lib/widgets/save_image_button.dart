import 'package:flutter/material.dart';

class SaveImageButton extends StatelessWidget {
  SaveImageButton({Key? key, required this.saveImageFunction})
      : super(key: key);

  Function saveImageFunction;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'saveImage',
      child: const Icon(Icons.camera_alt),
      backgroundColor: Colors.grey,
      onPressed: () => saveImageFunction(),
    );
  }
}
