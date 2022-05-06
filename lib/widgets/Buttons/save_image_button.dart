import 'package:flutter/material.dart';

class SaveImageButton extends StatelessWidget {
  const SaveImageButton({Key? key, required this.saveImageFunction})
      : super(key: key);

  final Function saveImageFunction;

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
