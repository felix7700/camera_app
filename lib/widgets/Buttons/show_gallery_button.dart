import 'package:flutter/material.dart';

class ShowGalleryButton extends StatelessWidget {
  const ShowGalleryButton({Key? key, required this.galleryScreenWidget})
      : super(key: key);
  final Widget galleryScreenWidget;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'showGalleryPage',
      child: const Icon(Icons.image),
      backgroundColor: Colors.grey,
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => galleryScreenWidget,
          ),
        );
      },
    );
  }
}
