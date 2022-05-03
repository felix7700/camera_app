import 'package:flutter/material.dart';

class SwitchCameraButton extends StatelessWidget {
  const SwitchCameraButton({Key? key, required this.onPressed})
      : super(key: key);
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'switchCamera',
      child: const Icon(
        Icons.flip_camera_ios,
      ),
      backgroundColor: Colors.grey,
      onPressed: () => onPressed(),
    );
  }
}
