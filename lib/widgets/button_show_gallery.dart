import 'package:flutter/material.dart';

class ButtonShowGallery extends StatelessWidget {
  ButtonShowGallery({Key? key, required this.galleryScreenWidget})
      : super(key: key);
  Widget galleryScreenWidget;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'showGalleryPage',
      child: const Icon(Icons.image),
      backgroundColor: Colors.grey,
      onPressed: () async {
        debugPrint('show GalleryPage()');
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => galleryScreenWidget,
          ),
        );
      },
    );
  }
}
